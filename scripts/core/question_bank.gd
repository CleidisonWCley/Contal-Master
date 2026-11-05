extends RefCounted
## ContaLMaster - Banco de perguntas (tema: Revisão Externa de Qualidade pelos Pares, NBC PA 11).
##
## Le os 4 JSONs em res://scripts/core/data/ e entrega cada item JA NO FORMATO que
## cada minigame atual espera (mesmos nomes de campo do antigo DynamicQuestionBank),
## entao as cenas quase nao mudam. API publica compativel:
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
const STOP_OPTIONS_PER_ITEM := 5
const RECENT_MEMORY_MAX := 60

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
static var _roleta_events: Array[Dictionary] = []
static var _recent_by_key: Dictionary = {}  # "minigame|dificuldade" -> Array[String]


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


static func pick_rounds(minigame: String, difficulty: String, count: int = DEFAULT_ROUND_COUNT) -> Array[Dictionary]:
	ensure_loaded()
	var diff: String = _norm_difficulty(difficulty)
	var pool: Array[Dictionary] = get_bank(minigame, diff)
	if pool.size() < count:
		pool = _fill_from_other_levels(minigame, diff, pool, count)
	if pool.is_empty():
		return []

	var key: String = "%s|%s" % [minigame, diff]
	var recent: Array = _recent_by_key.get(key, [])
	var memory: int = maxi(0, mini(RECENT_MEMORY_MAX, pool.size() - count))

	var fresh: Array[Dictionary] = []
	var seen: Array[Dictionary] = []
	for item in pool:
		if recent.has(_item_signature(item)):
			seen.append(item)
		else:
			fresh.append(item)
	fresh.shuffle()
	seen.shuffle()
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

	for item in picked:
		recent.append(_item_signature(item))
	while recent.size() > memory:
		recent.pop_front()
	_recent_by_key[key] = recent
	return picked


## Termos do dicionario agrupados pela inicial (usado pelo STOP para montar distratores).
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
		if modos.has("show_do_bilhao"):
			_push("show_do_bilhao", diff, {
				"id": str(it.get("id", "")),
				"topic": str(it.get("tema", "")),
				"pergunta": str(it.get("enunciado", "")),
				"opcoes": alts.duplicate(),
				"resposta": resp,
				"motivos": {resp: explicacao},
				"explanation": explicacao,
				"referencia": str(it.get("referencia", "")),
			})
		var rapida: Dictionary = it.get("rapida", {})
		if modos.has("perseguicao") and not rapida.is_empty():
			var certa: String = str(rapida.get("correta", ""))
			var opcoes: Array = [certa]
			for d in rapida.get("distratores", []):
				opcoes.append(str(d))
			_push("perseguicao", diff, {
				"id": "P-" + str(it.get("id", "")),
				"topic": str(it.get("tema", "")),
				"descricao": str(rapida.get("enunciado", "")),
				"opcoes": opcoes,
				"correta": certa,
				"explanation": explicacao,
				"referencia": str(it.get("referencia", "")),
			})


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
		if modos.has("maleta_certa"):
			var opcoes: Array = [certa]
			for e in erradas:
				opcoes.append(str((e as Dictionary).get("texto", "")))
			_push("maleta_certa", diff, {
				"id": str(it.get("id", "")),
				"topic": str(it.get("tema", "")),
				"problema": str(it.get("cenario", "")),
				"opcoes": opcoes,
				"correta": certa,
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
		if not _stop_terms.has(initial):
			_stop_terms[initial] = []
		(_stop_terms[initial] as Array).append(termo)
		_push("forca_tecnica", diff, {
			"id": str(it.get("id", "")),
			"topic": categoria,
			"word": termo,
			"area": categoria,
			"hint": str(it.get("dica", "")),
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
			"explanation": definicao,
			"referencia": str(it.get("referencia", "")),
		})


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
	return item


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


static func _item_signature(item: Dictionary) -> String:
	for key in ["correta", "word", "controle", "name"]:
		if item.has(key):
			return str(item[key])
	if item.has("resposta") and item.has("opcoes"):
		var ops: Variant = item["opcoes"]
		if ops is Dictionary:
			return str((ops as Dictionary).get(str(item["resposta"]), item.get("id", "")))
	return str(item.get("id", ""))
