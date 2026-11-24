extends RefCounted
## ContalMaster - Banco de perguntas (tema: Revisão Externa de Qualidade pelos Pares, NBC PA 11).
##
## Le os 4 JSONs em res://scripts/core/data/ e entrega cada item JA NO FORMATO que
##   pick_rounds(minigame, difficulty, count) -> Array[Dictionary]
##   get_bank(minigame, difficulty)           -> Array[Dictionary]
## Extras novos:
##   get_stop_terms_by_initial()  -> Dictionary  {"A": ["Amostra", ...]}
##   get_roleta_events()          -> Array[Dictionary]
##   get_load_errors()            -> Array[String]
##
## Mapa arquivo -> minigame:
##   quiz_auditoria.json -> show_do_bilhao, perseguicao
##   dilemas.json        -> desvio_logico, maleta_certa
##   dicionario.json     -> forca_tecnica, stop
##   matriz_riscos.json  -> batalha_naval, roleta_risco

const DATA_DIR := "res://scripts/core/data/"
const FILE_QUIZ := "quiz_auditoria.json"
const FILE_DILEMAS := "dilemas.json"
const FILE_DICIONARIO := "dicionario.json"
const FILE_MATRIZ := "matriz_riscos.json"

const DIFFICULTIES: Array[String] = ["facil", "normal", "dificil"]
const DEFAULT_ROUND_COUNT := 6
const STOP_OPTIONS_PER_ITEM := 6   # V0.14.4.2: o STOP mostra sempre 6 opcoes (grade 3x2)
const RECENT_MEMORY_MAX := 60
## V0.16.2: historico de itens ja vistos. Fica em user:// (vira IndexedDB na web) para as rodadas nao repetirem
## conteudo nem ao reabrir o jogo, e e COMPARTILHADO entre os minigames que leem o mesmo banco
## (Show do Bilhao + Perseguicao, Desvio Logico + Maleta Certa, Forca + STOP, Batalha Naval + Roleta).
const HISTORY_PATH := "user://contal_master_question_history.json"
const FAMILY_BY_MINIGAME := {
	"show_do_bilhao": "quiz", "perseguicao": "quiz",
	"desvio_logico": "dilemas", "maleta_certa": "dilemas",
	"forca_tecnica": "dicionario", "stop": "dicionario",
	"batalha_naval": "naval", "roleta_risco": "roleta",
}

const ACCENT_MAP := {
	"Á": "A", "À": "A", "Â": "A", "Ã": "A", "Ä": "A",
	"É": "E", "È": "E", "Ê": "E", "Ë": "E",
	"Í": "I", "Ì": "I", "Î": "I", "Ï": "I",
	"Ó": "O", "Ò": "O", "Ô": "O", "Õ": "O", "Ö": "O",
	"Ú": "U", "Ù": "U", "Û": "U", "Ü": "U",
	"Ç": "C",
}

static var _loaded: bool = false
static var _errors: Array[String] = []
static var _banks: Dictionary = {}          # minigame -> { dificuldade -> Array[Dictionary] }
static var _stop_terms: Dictionary = {}     # "A" -> Array[String]
static var _term_definitions: Dictionary = {}  # V0.16.2: "CRE" -> definicao (motivo da opcao errada no STOP)
static var _roleta_events: Array[Dictionary] = []
static var _recent_by_key: Dictionary = {}  # "familia|dificuldade" -> Array[String] (ids dos itens ja vistos)
static var _history_loaded: bool = false


# ======================================================================
# API PUBLICA
# ======================================================================

static func ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_errors.clear()
	_banks.clear()
	_stop_terms.clear()
	_term_definitions.clear()
	_roleta_events.clear()
	_build_quiz(_read_json(FILE_QUIZ))
	_build_dilemas(_read_json(FILE_DILEMAS))
	_build_dicionario(_read_json(FILE_DICIONARIO))
	_build_matriz(_read_json(FILE_MATRIZ))
	for e in _errors:
		push_warning("[QuestionBank] " + e)


static func reload() -> void:
	_loaded = false
	ensure_loaded()


static func get_load_errors() -> Array[String]:
	ensure_loaded()
	var out: Array[String] = []
	for e in _errors:
		out.append(e)
	return out


static func get_bank(minigame: String, difficulty: String) -> Array[Dictionary]:
	ensure_loaded()
	var result: Array[Dictionary] = []
	var by_diff: Dictionary = _banks.get(minigame, {})
	var items: Array = by_diff.get(_norm_difficulty(difficulty), [])
	for raw in items:
		result.append(_materialize(minigame, raw as Dictionary))
	return result


static func pick_rounds(minigame: String, difficulty: String, count: int = DEFAULT_ROUND_COUNT, record: bool = true) -> Array[Dictionary]:
	ensure_loaded()
	_load_history()
	var diff: String = _norm_difficulty(difficulty)
	var pool: Array[Dictionary] = get_bank(minigame, diff)
	if pool.size() < count:
		pool = _fill_from_other_levels(minigame, diff, pool, count)
	if pool.is_empty():
		return []

	# V0.16.2: o historico e por FAMILIA de banco (nao por minigame): se o Desvio Logico ja usou o dilema DL-003,
	# a Maleta Certa na mesma campanha prefere outro. "Visto" = id do item (estavel entre sessoes).
	var key: String = _history_key(minigame, diff)
	var recent: Array = _recent_by_key.get(key, [])
	# Guarda ate (pool - count) itens: sempre sobra material novo suficiente para a proxima rodada.
	var memory: int = maxi(0, mini(RECENT_MEMORY_MAX, pool.size() - count))

	var fresh: Array[Dictionary] = []
	var seen: Array[Dictionary] = []
	for item in pool:
		if recent.has(_item_id(item)):
			seen.append(item)
		else:
			fresh.append(item)
	fresh.shuffle()
	# Os ja vistos entram so se faltar item novo; os MAIS ANTIGOS na memoria voltam primeiro.
	seen.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return recent.find(_item_id(a)) < recent.find(_item_id(b)))
	var ordered: Array[Dictionary] = []
	for item in fresh:
		ordered.append(item)
	for item in seen:
		ordered.append(item)

	# 1a passada: um item por tema (variedade). 2a passada: completa o que faltar.
	var picked: Array[Dictionary] = []
	var used_topics: Array[String] = []
	for item in ordered:
		if picked.size() >= count:
			break
		var topic: String = _item_topic(item)
		if used_topics.has(topic):
			continue
		used_topics.append(topic)
		picked.append(item)
	if picked.size() < count:
		for item in ordered:
			if picked.size() >= count:
				break
			if not picked.has(item):
				picked.append(item)
	picked.shuffle()

	if record:
		for item in picked:
			_remember_item(key, _item_id(item), memory)
		_save_history()
	return picked


## V0.16.2: registra um item como "visto" (usado pela Roleta, que monta uma roda com 16 setores mas so o
## sorteado deve contar como conteudo ja mostrado).
static func mark_seen(minigame: String, difficulty: String, item: Dictionary) -> void:
	ensure_loaded()
	_load_history()
	var diff: String = _norm_difficulty(difficulty)
	var pool_size: int = (get_bank(minigame, diff) as Array).size()
	_remember_item(_history_key(minigame, diff), _item_id(item), maxi(0, pool_size - 1))
	_save_history()


## V0.16.2: ids ja vistos (mais antigo primeiro) para o minigame/dificuldade.
static func get_seen_ids(minigame: String, difficulty: String) -> Array:
	_load_history()
	return (_recent_by_key.get(_history_key(minigame, _norm_difficulty(difficulty)), []) as Array).duplicate()


## Zera o historico (autoteste / opcao futura de "recomecar conteudo").
static func clear_history() -> void:
	_recent_by_key.clear()
	_history_loaded = true
	_save_history()


## Termos do dicionario + distratores_stop agrupados pela inicial (opcoes erradas do STOP).
static func get_stop_terms_by_initial() -> Dictionary:
	ensure_loaded()
	return _stop_terms.duplicate(true)


## Eventos da Roleta de Risco no formato que a cena ja usa:
## { name, practice ("good"/"bad"), strength ("high"/"low"), description, learning }
static func get_roleta_events() -> Array[Dictionary]:
	ensure_loaded()
	var result: Array[Dictionary] = []
	for e in _roleta_events:
		result.append(e.duplicate(true))
	return result


## Contagem por minigame/dificuldade (usado no autoteste).
static func get_counts() -> Dictionary:
	ensure_loaded()
	var out: Dictionary = {}
	for mg in _banks.keys():
		out[mg] = {}
		for d in (_banks[mg] as Dictionary).keys():
			out[mg][d] = ((_banks[mg] as Dictionary)[d] as Array).size()
	out["roleta_eventos"] = _roleta_events.size()
	return out


# ======================================================================
# LEITURA
# ======================================================================

static func _read_json(file_name: String) -> Dictionary:
	var path: String = DATA_DIR + file_name
	if not FileAccess.file_exists(path):
		_errors.append("Arquivo ausente: " + path)
		return {}
	var text: String = FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null or not (parsed is Dictionary):
		_errors.append("JSON invalido: " + path)
		return {}
	return parsed as Dictionary


static func _push(minigame: String, difficulty: String, entry: Dictionary) -> void:
	if not _banks.has(minigame):
		_banks[minigame] = {}
	var by_diff: Dictionary = _banks[minigame]
	if not by_diff.has(difficulty):
		by_diff[difficulty] = []
	(by_diff[difficulty] as Array).append(entry)


# ======================================================================
# ADAPTADORES (JSON novo -> formato legado de cada minigame)
# ======================================================================

static func _build_quiz(data: Dictionary) -> void:
	for raw in data.get("itens", []):
		var it: Dictionary = raw
		var diff: String = _norm_difficulty(str(it.get("nivel", "normal")))
		var modos: Array = it.get("modos", ["show_do_bilhao"])
		var resp: String = str(it.get("resposta_correta", ""))
		var alts: Dictionary = it.get("alternativas", {})
		if resp == "" or not alts.has(resp):
			_errors.append("Quiz %s: resposta_correta invalida" % str(it.get("id", "?")))
			continue
		var explicacao: String = str(it.get("explicacao", ""))
		var pratica: String = str(it.get("na_pratica", ""))
		if modos.has("show_do_bilhao"):
			# V0.16.2: cada alternativa errada tem o seu motivo ("porque_erradas"); a certa leva a explicacao.
			var motivos: Dictionary = {resp: explicacao}
			var porque_erradas: Dictionary = it.get("porque_erradas", {})
			for letter in porque_erradas.keys():
				if str(letter) != resp and alts.has(str(letter)):
					motivos[str(letter)] = str(porque_erradas[letter])
			_push("show_do_bilhao", diff, {
				"id": str(it.get("id", "")),
				"topic": str(it.get("tema", "")),
				"pergunta": str(it.get("enunciado", "")),
				"opcoes": alts.duplicate(),
				"resposta": resp,
				"motivos": motivos,
				"pratica": pratica,
				"explanation": explicacao,
				"referencia": str(it.get("referencia", "")),
			})
		var rapida: Dictionary = it.get("rapida", {})
		if modos.has("perseguicao") and not rapida.is_empty():
			var certa: String = str(rapida.get("correta", ""))
			var opcoes: Array = [certa]
			var motivos_rapidos: Dictionary = {}   # V0.16.2: distrator -> motivo (quando casa com uma alternativa do quiz)
			for d in rapida.get("distratores", []):
				opcoes.append(str(d))
				var reason_match: String = _match_wrong_reason(str(d), alts, resp, it.get("porque_erradas", {}))
				if reason_match != "":
					motivos_rapidos[str(d)] = reason_match
			_push("perseguicao", diff, {
				"id": "P-" + str(it.get("id", "")),
				"topic": str(it.get("tema", "")),
				"descricao": str(rapida.get("enunciado", "")),
				"opcoes": opcoes,
				"correta": certa,
				"motivos_texto": motivos_rapidos,
				"pratica": pratica,
				"explanation": explicacao,
				"referencia": str(it.get("referencia", "")),
			})


## V0.16.2: liga um distrator da versao rapida ("CRE") a uma alternativa errada do quiz ("O CRE") para reaproveitar
## o motivo especifico. Sem correspondencia segura, devolve "" e o jogo usa a mensagem generica.
static func _match_wrong_reason(distractor: String, alternatives: Dictionary, correct_letter: String, reasons: Variant) -> String:
	if not (reasons is Dictionary):
		return ""
	var wanted: String = _plain_option(distractor)
	if wanted == "":
		return ""
	for letter in alternatives.keys():
		if str(letter) == correct_letter:
			continue
		var candidate: String = _plain_option(str(alternatives[letter]))
		# Contem-se so por PALAVRA inteira ("adequado" nao casa com "inadequado").
		var wanted_in_candidate: bool = (" " + candidate + " ").contains(" " + wanted + " ")
		var candidate_in_wanted: bool = (" " + wanted + " ").contains(" " + candidate + " ")
		if candidate == wanted or (wanted.length() >= 3 and (wanted_in_candidate or candidate_in_wanted)):
			return str((reasons as Dictionary).get(str(letter), ""))
	return ""


static func _plain_option(text: String) -> String:
	var t: String = text.strip_edges().to_lower()
	for article in ["o ", "a ", "os ", "as "]:
		if t.begins_with(article):
			t = t.substr(article.length())
			break
	return t


static func _build_dilemas(data: Dictionary) -> void:
	for raw in data.get("itens", []):
		var it: Dictionary = raw
		var diff: String = _norm_difficulty(str(it.get("nivel", "normal")))
		var modos: Array = it.get("modos", ["desvio_logico", "maleta_certa"])
		var certa: String = str(it.get("acao_correta", ""))
		var erradas: Array = it.get("acoes_incorretas", [])
		if certa == "" or erradas.is_empty():
			_errors.append("Dilema %s: acao_correta/acoes_incorretas ausentes" % str(it.get("id", "?")))
			continue
		var explicacao: String = str(it.get("explicacao", ""))
		var pratica: String = str(it.get("na_pratica", ""))
		if modos.has("maleta_certa"):
			var opcoes: Array = [certa]
			var motivos_texto: Dictionary = {}   # V0.16.2: texto da opcao errada -> por que ela nao resolve
			for e in erradas:
				var texto_errado: String = str((e as Dictionary).get("texto", ""))
				opcoes.append(texto_errado)
				motivos_texto[texto_errado] = str((e as Dictionary).get("porque", ""))
			_push("maleta_certa", diff, {
				"id": str(it.get("id", "")),
				"topic": str(it.get("tema", "")),
				"problema": str(it.get("cenario", "")),
				"opcoes": opcoes,
				"correta": certa,
				"motivos_texto": motivos_texto,
				"pratica": pratica,
				"explanation": explicacao,
				"referencia": str(it.get("referencia", "")),
			})
		if modos.has("desvio_logico"):
			# A errada exibida e sorteada em _materialize (varia a cada partida).
			_push("desvio_logico", diff, {
				"id": str(it.get("id", "")),
				"topic": str(it.get("tema", "")),
				"pergunta": str(it.get("cenario", "")),
				"_certa": certa,
				"_erradas": erradas.duplicate(true),
				"_explicacao": explicacao,
				"pratica": pratica,
				"referencia": str(it.get("referencia", "")),
			})


static func _build_dicionario(data: Dictionary) -> void:
	for raw in data.get("termos", []):
		var it: Dictionary = raw
		var diff: String = _norm_difficulty(str(it.get("nivel", "normal")))
		var termo: String = str(it.get("termo", "")).strip_edges()
		if termo == "":
			continue
		var categoria: String = str(it.get("categoria", ""))
		var definicao: String = str(it.get("definicao", ""))
		var initial: String = _initial_of(termo)
		var pratica: String = str(it.get("na_pratica", ""))
		_term_definitions[termo] = definicao
		if not _stop_terms.has(initial):
			_stop_terms[initial] = []
		(_stop_terms[initial] as Array).append(termo)
		_push("forca_tecnica", diff, {
			"id": str(it.get("id", "")),
			"topic": categoria,
			"word": termo,
			"area": categoria,
			"hint": str(it.get("dica", "")),
			"pratica": pratica,
			"pista_aline": str(it.get("pista_aline", "")),   # V0.16.15: frase de associacao da Aline (botao Pedir pista)
			"explanation": definicao,
			"referencia": str(it.get("referencia", "")),
		})
		_push("stop", diff, {
			"id": "S-" + str(it.get("id", "")),
			"topic": categoria,
			"categoria": categoria,
			"letra": initial,
			"dica": str(it.get("dica", "")),
			"correta": termo,
			"pratica": pratica,
			"explanation": definicao,
			"referencia": str(it.get("referencia", "")),
		})
	# V0.14.4.2: termos extras (so opcoes erradas do STOP), para toda inicial ter 6+ opcoes.
	var extras: Dictionary = data.get("distratores_stop", {})
	for key in extras.keys():
		var initial_key: String = str(key).to_upper()
		if not _stop_terms.has(initial_key):
			_stop_terms[initial_key] = []
		var bucket: Array = _stop_terms[initial_key]
		for extra in extras[key]:
			var extra_text: String = str(extra).strip_edges()
			if extra_text != "" and not bucket.has(extra_text):
				bucket.append(extra_text)
	for initial_key in _stop_terms.keys():
		if (_stop_terms[initial_key] as Array).size() < STOP_OPTIONS_PER_ITEM:
			_errors.append("STOP: inicial %s tem menos de %d termos" % [initial_key, STOP_OPTIONS_PER_ITEM])


static func _build_matriz(data: Dictionary) -> void:
	var naval: Dictionary = data.get("batalha_naval", {})
	for raw in naval.get("ameacas", []):
		var it: Dictionary = raw
		var diff: String = _norm_difficulty(str(it.get("nivel", "normal")))
		var explicacao: String = str(it.get("explicacao", ""))
		var consequencia: String = str(it.get("consequencia", ""))
		if consequencia != "":
			explicacao += " Consequência: " + consequencia
		_push("batalha_naval", diff, {
			"id": str(it.get("id", "")),
			"topic": str(it.get("tema", "")),
			"ameaca": str(it.get("ameaca", "")),
			"controle": str(it.get("controle", "")),
			"explanation": explicacao,
			"referencia": str(it.get("referencia", "")),
		})
	var roleta: Dictionary = data.get("roleta_risco", {})
	for raw in roleta.get("eventos", []):
		var it: Dictionary = raw
		var ev: Dictionary = {
			"id": str(it.get("id", "")),
			"name": str(it.get("nome", "")),
			"practice": str(it.get("pratica", "good")),
			"strength": str(it.get("forca", "low")),
			"description": str(it.get("descricao", "")),
			"learning": str(it.get("aprendizado", "")),
			"referencia": str(it.get("referencia", "")),
		}
		_roleta_events.append(ev)
	# get_bank("roleta_risco", ...) tambem funciona (dificuldade ignorada).
	for ev in _roleta_events:
		for d in DIFFICULTIES:
			var copy: Dictionary = ev.duplicate(true)
			copy["topic"] = ev["name"]
			_push("roleta_risco", d, copy)


# ======================================================================
# MATERIALIZACAO (itens que variam a cada sorteio)
# ======================================================================

static func _materialize(minigame: String, raw: Dictionary) -> Dictionary:
	if minigame == "desvio_logico":
		return _materialize_desvio(raw)
	if minigame == "stop":
		return _materialize_stop(raw)
	return raw.duplicate(true)


static func _materialize_desvio(raw: Dictionary) -> Dictionary:
	var certa: String = str(raw.get("_certa", ""))
	var erradas: Array = raw.get("_erradas", [])
	var errada: Dictionary = erradas[randi() % erradas.size()] as Dictionary
	var correct_on_a: bool = randi() % 2 == 0
	var key_certa: String = "A" if correct_on_a else "B"
	var key_errada: String = "B" if correct_on_a else "A"
	var explicacao: String = str(raw.get("_explicacao", ""))
	var opcoes: Dictionary = {}
	opcoes[key_certa] = certa
	opcoes[key_errada] = str(errada.get("texto", ""))
	var motivos: Dictionary = {}
	motivos[key_certa] = explicacao
	motivos[key_errada] = str(errada.get("porque", ""))
	return {
		"id": raw.get("id", ""),
		"topic": raw.get("topic", ""),
		"pergunta": raw.get("pergunta", ""),
		"opcoes": opcoes,
		"resposta": key_certa,
		"motivos": motivos,
		"pratica": raw.get("pratica", ""),
		"explanation": explicacao,
		"referencia": raw.get("referencia", ""),
	}


static func _materialize_stop(raw: Dictionary) -> Dictionary:
	var item: Dictionary = raw.duplicate(true)
	var correta: String = str(raw.get("correta", ""))
	var initial: String = str(raw.get("letra", ""))
	var others: Array = []
	for t in (_stop_terms.get(initial, []) as Array):
		if str(t) != correta:
			others.append(str(t))
	others.shuffle()
	var opcoes: Array = [correta]
	for t in others:
		if opcoes.size() >= STOP_OPTIONS_PER_ITEM:
			break
		opcoes.append(t)
	opcoes.shuffle()
	item["opcoes"] = opcoes
	# V0.16.2: se o jogador errar, mostramos o que a opcao escolhida realmente significa (didatico).
	var motivos_texto: Dictionary = {}
	for t in opcoes:
		var termo: String = str(t)
		if termo != correta and _term_definitions.has(termo):
			motivos_texto[termo] = str(_term_definitions[termo])
	item["motivos_texto"] = motivos_texto
	return item


# ======================================================================
# HISTORICO (V0.16.2)
# ======================================================================

static func _history_key(minigame: String, difficulty: String) -> String:
	return "%s|%s" % [str(FAMILY_BY_MINIGAME.get(minigame, minigame)), difficulty]


static func _remember_item(key: String, item_id: String, memory: int) -> void:
	if item_id == "":
		return
	var recent: Array = _recent_by_key.get(key, [])
	recent.erase(item_id)          # re-visto vai para o fim (o mais "recente")
	recent.append(item_id)
	while recent.size() > memory:
		recent.pop_front()
	_recent_by_key[key] = recent


static func _load_history() -> void:
	if _history_loaded:
		return
	_history_loaded = true
	if not FileAccess.file_exists(HISTORY_PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(HISTORY_PATH))
	if not (parsed is Dictionary):
		return   # arquivo corrompido: comeca do zero, sem travar o jogo
	for key in (parsed as Dictionary).keys():
		var ids: Variant = (parsed as Dictionary)[key]
		if ids is Array:
			var clean: Array = []
			for v in (ids as Array):
				clean.append(str(v))
			_recent_by_key[str(key)] = clean


static func _save_history() -> void:
	var file: FileAccess = FileAccess.open(HISTORY_PATH, FileAccess.WRITE)
	if file == null:
		return   # sem permissao de escrita (ex.: web sem IndexedDB): o historico vale so nesta sessao
	file.store_string(JSON.stringify(_recent_by_key))


# ======================================================================
# APOIO
# ======================================================================

static func _fill_from_other_levels(minigame: String, difficulty: String, pool: Array[Dictionary], count: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for it in pool:
		result.append(it)
	var ids: Array = []
	for it in result:
		ids.append(str(it.get("id", "")))
	for d in DIFFICULTIES:
		if d == difficulty:
			continue
		for it in get_bank(minigame, d):
			if result.size() >= count:
				return result
			var id_text: String = str(it.get("id", ""))
			if not ids.has(id_text):
				ids.append(id_text)
				result.append(it)
	return result


static func _norm_difficulty(value: String) -> String:
	var v: String = value.strip_edges().to_lower()
	if v == "facil" or v == "fácil" or v == "easy":
		return "facil"
	if v == "dificil" or v == "difícil" or v == "hard":
		return "dificil"
	return "normal"


static func _initial_of(text: String) -> String:
	var up: String = text.strip_edges().to_upper()
	if up == "":
		return ""
	var first: String = up.substr(0, 1)
	return str(ACCENT_MAP.get(first, first))


static func _item_topic(item: Dictionary) -> String:
	return str(item.get("topic", item.get("id", "")))


## Identificador estavel do item. Os itens do Desvio Logico/STOP variam a cada sorteio (alternativas embaralhadas),
## entao o historico usa o ID do banco (QA-001, DL-003...) e nao o texto. O prefixo "P-"/"S-" das versoes rapidas
## e removido para Show do Bilhao e Perseguicao contarem como o MESMO conteudo.
static func _item_id(item: Dictionary) -> String:
	var id_text: String = str(item.get("id", ""))
	if id_text.begins_with("P-") or id_text.begins_with("S-"):
		id_text = id_text.substr(2)
	if id_text != "":
		return id_text
	for key in ["correta", "word", "controle", "name"]:
		if item.has(key):
			return str(item[key])
	return ""
