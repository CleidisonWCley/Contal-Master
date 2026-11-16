extends Node
## V0.15 - Memoria da firma e Arquivo da Equipe (lore).
##
## O que este autoload guarda (user://contal_master_lore.json, SEPARADO dos recordes: nao mexe em saves antigos):
##   - por ESTACAO: quantas vezes foi concluida (campanha + livre), melhor/ultima proporcao, metas Bronze/Prata/Ouro;
##   - NIVEL DE CONFIANCA de cada anfitriao (0..3), derivado das metas;
##   - quais perfis e trechos de lore o jogador ja VIU;
##   - finais secretos liberados (so dados por enquanto; as cenas virao depois).
##
## Quem alimenta: GameManager chama record_stage(report) ao concluir QUALQUER estacao (campanha ou modo livre).
## Quem consome: StageDebrief (novel curta depois do minigame) e TeamArchive (tela "Arquivo da Equipe").
##
## Niveis (ContalMaster_Fase2_Design, secao 7):
##   0 Desconhecidos  -> ainda nao jogou a estacao
##   1 Apresentados   -> Bronze: concluir a estacao (em qualquer dificuldade)
##   2 De Confianca   -> Prata: bom desempenho na dificuldade Normal/Dificil OU "caminho de dedicacao" (DEDICATION_PLAYS conclusoes)
##   3 Da Casa        -> Ouro: desempenho excelente na dificuldade Normal/Dificil
## As metas ficam em GOALS (numeros a CALIBRAR com testes reais). Melhor marca vale para sempre: uma meta nunca e perdida.

signal lore_changed

const SAVE_PATH := Paths.SAVE_LORE
const SAVE_VERSION := 1

const LEVEL_NAMES: Array[String] = ["Desconhecidos", "Apresentados", "De Confiança", "Da Casa"]

## Ordem das estacoes (a mesma de GameManager.PHASES) e o anfitriao de cada uma.
const STATION_ORDER: Array[String] = [
	"show_do_bilhao", "batalha_naval", "maleta_certa", "roleta_risco",
	"perseguicao", "forca_tecnica", "stop", "desvio_logico"
]
const HOST_BY_STATION := {
	"show_do_bilhao": "priscila",
	"batalha_naval": "anderson",
	"maleta_certa": "tiago",
	"roleta_risco": "julios",
	"perseguicao": "ariel",
	"forca_tecnica": "aline",
	"stop": "cleiton",
	"desvio_logico": "natalia"
}
## Ordem de exibicao dos 9 personagens no Arquivo.
const CHARACTER_ORDER: Array[String] = [
	"jales", "priscila", "anderson", "tiago", "julios", "ariel", "aline", "cleiton", "natalia"
]
const CHARACTER_NAMES := {
	"jales": "Jales", "priscila": "Priscila", "anderson": "Anderson", "tiago": "Tiago", "julios": "Julios",
	"ariel": "Ariel", "aline": "Aline", "cleiton": "Cleiton", "natalia": "Natalia"
}

## Faixas de desempenho do feedback (proporcao de acertos 0..1). Seguem de perto os limiares do final (80/55/30).
const TIER_GREAT_MIN := 0.80
const TIER_OK_MIN := 0.50
const TIER_PERFECT_MIN := 0.999

## Caminho de dedicacao: apos N conclusoes da estacao (campanha ou livre) a Prata e concedida mesmo sem mérito.
const DEDICATION_PLAYS := 3

## METAS POR ESTACAO (a calibrar). "ratio" = report.ratio (acertos / total; na Batalha Naval, precisao = achadas / tiros).
##   silver / gold          proporcao minima em Normal ou Dificil (no Facil so o Bronze conta, exceto a dedicacao);
##   gold_hard              Ouro na dificuldade Dificil, quando for diferente (ex.: 5 de 6 em vez de 6 de 6);
##   gold_max_errors        Ouro exige no maximo N erros no total (report.extra.erros_totais), alem da proporcao;
##   kind "plays"           estacao sem acerto/erro (Roleta de Risco): Prata/Ouro por numero de conclusoes.
const GOALS := {
	"show_do_bilhao": {"kind": "ratio", "silver": 0.66, "gold": 1.0, "gold_hard": 0.83},
	"batalha_naval": {"kind": "ratio", "silver": 0.60, "gold": 0.80},
	"maleta_certa": {"kind": "ratio", "silver": 0.66, "gold": 1.0, "gold_hard": 0.83},
	"roleta_risco": {"kind": "plays", "silver": 2, "gold": 4},
	"perseguicao": {"kind": "ratio", "silver": 0.70, "gold": 0.90},
	"forca_tecnica": {"kind": "ratio", "silver": 0.70, "gold": 1.0, "gold_max_errors": 1},
	"stop": {"kind": "ratio", "silver": 0.66, "gold": 1.0},
	"desvio_logico": {"kind": "ratio", "silver": 0.70, "gold": 0.90}
}

var _data: Dictionary = {}
var _fragments: Array = []
var _profiles: Array = []
var _endings: Array = []


func _ready() -> void:
	_load_content()
	_load_save()


# ---------------------------------------------------------------- conteudo (JSON)

func _load_content() -> void:
	_fragments = _read_list(Paths.LORE_FRAGMENTS, "fragments")
	_profiles = _read_list(Paths.LORE_PROFILES, "profiles")
	_endings = _read_list(Paths.LORE_SECRET_ENDINGS, "endings")


func _read_list(path: String, key: String) -> Array:
	if not FileAccess.file_exists(path):
		push_warning("LoreManager: arquivo ausente: %s" % path)
		return []
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary and (parsed as Dictionary).get(key, null) is Array:
		return ((parsed as Dictionary).get(key, []) as Array).duplicate(true)
	push_warning("LoreManager: JSON invalido em %s" % path)
	return []


func get_fragments() -> Array:
	return _fragments


func get_profiles() -> Array:
	return _profiles


func get_fragment(fragment_id: String) -> Dictionary:
	for item in _fragments:
		if str((item as Dictionary).get("id", "")) == fragment_id:
			return item as Dictionary
	return {}


func get_profile(character_id: String) -> Dictionary:
	for item in _profiles:
		if str((item as Dictionary).get("id", "")) == character_id:
			return item as Dictionary
	return {}


# ---------------------------------------------------------------- save

static func _default_station() -> Dictionary:
	return {
		"plays": 0, "plays_campaign": 0, "plays_free": 0,
		"best_ratio": 0.0, "last_ratio": 0.0, "last_tier": "",
		"goals": {"bronze": false, "prata": false, "ouro": false},
		"events_seen": []
	}


static func _default_data() -> Dictionary:
	var stations: Dictionary = {}
	for key in STATION_ORDER:
		stations[key] = _default_station()
	return {
		"version": SAVE_VERSION,
		"global": {"first_seen": "", "last_seen": "", "campaigns_completed": 0},
		"stations": stations,
		"profiles_seen": [],
		"fragments_seen": [],
		"secret_endings": {"unlocked": [], "viewed": []},
		"line_cursor": {}
	}


func _load_save() -> void:
	_data = _default_data()
	if FileAccess.file_exists(SAVE_PATH):
		var text: String = FileAccess.get_file_as_string(SAVE_PATH)
		var parsed: Variant = JSON.parse_string(text)
		if parsed is Dictionary:
			_data = parsed as Dictionary
		elif text.strip_edges() != "":
			_backup_unreadable_save(text)
	_ensure_data_shape()
	var now: String = Time.get_datetime_string_from_system(true)
	var global: Dictionary = _data.get("global", {}) as Dictionary
	if str(global.get("first_seen", "")) == "":
		global["first_seen"] = now
	global["last_seen"] = now
	_data["global"] = global
	refresh_secret_endings(false)
	_save()


func _backup_unreadable_save(text: String) -> void:
	var backup: FileAccess = FileAccess.open(SAVE_PATH + ".corrompido.bak", FileAccess.WRITE)
	if backup != null:
		backup.store_string(text)
		backup.close()
	push_warning("LoreManager: save ilegivel; copia guardada em %s.corrompido.bak" % SAVE_PATH)


func _save() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("LoreManager: nao foi possivel salvar em %s" % SAVE_PATH)
		return
	file.store_string(JSON.stringify(_data, "\t"))
	file.close()


## Garante todas as chaves (saves de versoes futuras/antigas nunca quebram a leitura).
func _ensure_data_shape() -> void:
	var base: Dictionary = _default_data()
	if not (_data is Dictionary) or _data.is_empty():
		_data = base
		return
	for key in base.keys():
		if not _data.has(key) or typeof(_data[key]) != typeof(base[key]):
			_data[key] = base[key]
	var stations: Dictionary = _data.get("stations", {}) as Dictionary
	for key in STATION_ORDER:
		if not stations.has(key) or not (stations[key] is Dictionary):
			stations[key] = _default_station()
		var station: Dictionary = stations[key] as Dictionary
		var default_station: Dictionary = _default_station()
		for field in default_station.keys():
			if not station.has(field) or typeof(station[field]) != typeof(default_station[field]):
				station[field] = default_station[field]
		var goals: Dictionary = station.get("goals", {}) as Dictionary
		for goal_key in ["bronze", "prata", "ouro"]:
			goals[goal_key] = bool(goals.get(goal_key, false))
		station["goals"] = goals
	_data["stations"] = stations
	_data["version"] = SAVE_VERSION


## "Esquecer a equipe": apaga tudo (para um botao futuro em Configuracoes). Nao toca em recordes nem conquistas.
func reset_all() -> void:
	_data = _default_data()
	refresh_secret_endings(false)
	_save()
	lore_changed.emit()


# ---------------------------------------------------------------- niveis e metas

func get_station(phase_key: String) -> Dictionary:
	var stations: Dictionary = _data.get("stations", {}) as Dictionary
	if stations.has(phase_key) and stations[phase_key] is Dictionary:
		return stations[phase_key] as Dictionary
	return _default_station()


## Nivel de confianca (0..3) da estacao.
func get_level(phase_key: String) -> int:
	var goals: Dictionary = get_station(phase_key).get("goals", {}) as Dictionary
	if bool(goals.get("ouro", false)):
		return 3
	if bool(goals.get("prata", false)):
		return 2
	if bool(goals.get("bronze", false)):
		return 1
	return 0


func get_level_name(level: int) -> String:
	return LEVEL_NAMES[clampi(level, 0, LEVEL_NAMES.size() - 1)]


## Nivel do personagem: o da estacao dele; Jales = menor nivel entre TODAS as estacoes.
func get_character_level(character_id: String) -> int:
	if character_id == "jales":
		var lowest: int = 3
		for key in STATION_ORDER:
			lowest = mini(lowest, get_level(key))
		return lowest
	for key in STATION_ORDER:
		if str(HOST_BY_STATION.get(key, "")) == character_id:
			return get_level(key)
	return 0


func min_station_level() -> int:
	var lowest: int = 3
	for key in STATION_ORDER:
		lowest = mini(lowest, get_level(key))
	return lowest


func count_stations_at_least(level: int) -> int:
	var count: int = 0
	for key in STATION_ORDER:
		if get_level(key) >= level:
			count += 1
	return count


## Faixa do feedback a partir do relatorio. report["tier"] (ex.: Roleta: "bom"/"ruim") tem prioridade.
static func tier_for_report(report: Dictionary) -> String:
	var forced: String = str(report.get("tier", ""))
	if forced != "":
		return forced
	if int(report.get("total", 0)) <= 0:
		return "medio"
	return tier_for_ratio(float(report.get("ratio", 0.0)))


static func tier_for_ratio(ratio: float) -> String:
	if ratio >= TIER_PERFECT_MIN:
		return "perfeito"
	if ratio >= TIER_GREAT_MIN:
		return "otimo"
	if ratio >= TIER_OK_MIN:
		return "medio"
	return "fraco"


## Registra uma estacao concluida (campanha ou livre). Devolve {"tier", "level_before", "level_after", "leveled_up"}.
## Chamado por GameManager ANTES de abrir o feedback; nao altera pontos nem recordes.
func record_stage(report: Dictionary) -> Dictionary:
	var phase_key: String = str(report.get("phase_key", ""))
	var result: Dictionary = {"tier": tier_for_report(report), "level_before": 0, "level_after": 0, "leveled_up": false}
	if not STATION_ORDER.has(phase_key):
		return result
	var level_before: int = get_level(phase_key)
	var station: Dictionary = get_station(phase_key)
	var is_campaign: bool = str(report.get("mode", "")) == "campaign"
	var ratio: float = clampf(float(report.get("ratio", 0.0)), 0.0, 1.0)
	station["plays"] = int(station.get("plays", 0)) + 1
	if is_campaign:
		station["plays_campaign"] = int(station.get("plays_campaign", 0)) + 1
	else:
		station["plays_free"] = int(station.get("plays_free", 0)) + 1
	station["last_ratio"] = ratio
	station["best_ratio"] = maxf(float(station.get("best_ratio", 0.0)), ratio)
	station["last_tier"] = str(result["tier"])
	var extra: Dictionary = report.get("extra", {}) as Dictionary
	var event_name: String = str(extra.get("event_name", ""))
	if event_name != "":
		var seen: Array = station.get("events_seen", []) as Array
		if not seen.has(event_name):
			seen.append(event_name)
		station["events_seen"] = seen
	var goals: Dictionary = station.get("goals", {}) as Dictionary
	goals["bronze"] = true
	var difficulty: String = str(report.get("difficulty", "normal"))
	if _silver_reached(phase_key, station, report, difficulty):
		goals["prata"] = true
	if _gold_reached(phase_key, station, report, difficulty):
		goals["prata"] = true
		goals["ouro"] = true
	station["goals"] = goals
	(_data["stations"] as Dictionary)[phase_key] = station
	var level_after: int = get_level(phase_key)
	result["level_before"] = level_before
	result["level_after"] = level_after
	result["leveled_up"] = level_after > level_before
	_data["global"]["last_seen"] = Time.get_datetime_string_from_system(true)
	refresh_secret_endings(false)
	_save()
	lore_changed.emit()
	return result


func _silver_reached(phase_key: String, station: Dictionary, report: Dictionary, difficulty: String) -> bool:
	if int(station.get("plays", 0)) >= DEDICATION_PLAYS:
		return true
	var goal: Dictionary = GOALS.get(phase_key, {}) as Dictionary
	if str(goal.get("kind", "ratio")) == "plays":
		return int(station.get("plays", 0)) >= int(goal.get("silver", 2))
	if difficulty == "facil":
		return false
	return float(report.get("ratio", 0.0)) >= float(goal.get("silver", 0.7)) and int(report.get("total", 0)) > 0


func _gold_reached(phase_key: String, station: Dictionary, report: Dictionary, difficulty: String) -> bool:
	var goal: Dictionary = GOALS.get(phase_key, {}) as Dictionary
	if str(goal.get("kind", "ratio")) == "plays":
		return int(station.get("plays", 0)) >= int(goal.get("gold", 4))
	if difficulty == "facil" or int(report.get("total", 0)) <= 0:
		return false
	var needed: float = float(goal.get("gold", 0.9))
	if difficulty == "dificil" and goal.has("gold_hard"):
		needed = float(goal.get("gold_hard", needed))
	if float(report.get("ratio", 0.0)) < needed:
		return false
	if goal.has("gold_max_errors"):
		var extra: Dictionary = report.get("extra", {}) as Dictionary
		if int(extra.get("erros_totais", 0)) > int(goal.get("gold_max_errors", 0)):
			return false
	return true


# ---------------------------------------------------------------- perfis e trechos

func has_seen_profile(character_id: String) -> bool:
	return (_data.get("profiles_seen", []) as Array).has(character_id)


func has_seen_fragment(fragment_id: String) -> bool:
	return (_data.get("fragments_seen", []) as Array).has(fragment_id)


func mark_profile_seen(character_id: String) -> void:
	var seen: Array = _data.get("profiles_seen", []) as Array
	if seen.has(character_id):
		return
	seen.append(character_id)
	_data["profiles_seen"] = seen
	_save()
	lore_changed.emit()


func mark_fragment_seen(fragment_id: String) -> void:
	var seen: Array = _data.get("fragments_seen", []) as Array
	if seen.has(fragment_id):
		return
	seen.append(fragment_id)
	_data["fragments_seen"] = seen
	refresh_secret_endings(true)
	_save()
	lore_changed.emit()


## O perfil esta liberado (nivel 1 da estacao do personagem; Jales: 3 estacoes no nivel 1)?
func is_profile_unlocked(character_id: String) -> bool:
	var profile: Dictionary = get_profile(character_id)
	if profile.is_empty():
		return false
	var unlock: Dictionary = profile.get("unlock", {}) as Dictionary
	if unlock.has("stations_level_1"):
		return count_stations_at_least(1) >= int(unlock.get("stations_level_1", 3))
	return get_level(str(profile.get("station", ""))) >= 1


func is_fragment_unlocked(fragment: Dictionary) -> bool:
	var unlock: Dictionary = fragment.get("unlock", {}) as Dictionary
	if unlock.has("all_stations_level"):
		return min_station_level() >= int(unlock.get("all_stations_level", 2))
	return get_level(str(fragment.get("station", ""))) >= int(fragment.get("level", 1))


## O que o modo livre mostra DEPOIS de concluir `phase_key`: no maximo UM item novo.
## Prioridade: trecho liberado e ainda nao visto (do mais profundo para o mais raso) > perfil novo > nada.
## Devolve {"kind": "fragment"|"profile", "id", "owner", "title", "frames": [String]} ou {} se nao houver novidade.
func next_unseen_item(phase_key: String) -> Dictionary:
	var host: String = str(HOST_BY_STATION.get(phase_key, ""))
	# 1) perfil do anfitriao desta estacao (primeira conclusao)
	if host != "" and is_profile_unlocked(host) and not has_seen_profile(host):
		return _profile_item(host)
	# 2) trechos liberados e nao vistos: primeiro os desta estacao, depois os globais (ex.: Jales)
	var candidates: Array = []
	for item in _fragments:
		var fragment: Dictionary = item as Dictionary
		if has_seen_fragment(str(fragment.get("id", ""))) or not is_fragment_unlocked(fragment):
			continue
		candidates.append(fragment)
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_here: int = 0 if str(a.get("station", "")) == phase_key else 1
		var b_here: int = 0 if str(b.get("station", "")) == phase_key else 1
		if a_here != b_here:
			return a_here < b_here
		return int(a.get("level", 1)) < int(b.get("level", 1)))
	if not candidates.is_empty():
		var chosen: Dictionary = candidates[0] as Dictionary
		return {
			"kind": "fragment", "id": str(chosen.get("id", "")), "owner": str(chosen.get("owner", host)),
			"title": str(chosen.get("title", "")), "frames": (chosen.get("frames", []) as Array).duplicate()
		}
	# 3) perfil do Jales (quando 3 estacoes chegam ao nivel 1)
	if is_profile_unlocked("jales") and not has_seen_profile("jales"):
		return _profile_item("jales")
	return {}


func _profile_item(character_id: String) -> Dictionary:
	var profile: Dictionary = get_profile(character_id)
	return {
		"kind": "profile", "id": character_id, "owner": character_id,
		"title": "Quem é", "frames": (profile.get("frames", []) as Array).duplicate()
	}


## Quantos itens (perfis + trechos) existem e quantos ja foram liberados/vistos (para o Arquivo).
func count_items() -> Dictionary:
	var total: int = _profiles.size() + _fragments.size()
	var unlocked: int = 0
	for item in _profiles:
		if is_profile_unlocked(str((item as Dictionary).get("id", ""))):
			unlocked += 1
	for item in _fragments:
		if is_fragment_unlocked(item as Dictionary):
			unlocked += 1
	return {"total": total, "unlocked": unlocked}


# ---------------------------------------------------------------- finais secretos (so dados)

func get_secret_endings() -> Array:
	return _endings


func is_secret_ending_unlocked(ending_id: String) -> bool:
	return ((_data.get("secret_endings", {}) as Dictionary).get("unlocked", []) as Array).has(ending_id)


func get_unlocked_secret_endings() -> Array:
	var result: Array = []
	for item in _endings:
		if is_secret_ending_unlocked(str((item as Dictionary).get("id", ""))):
			result.append(item)
	return result


## Reavalia as condicoes de cada final secreto. Futuro: a cena final/Arquivo usa get_unlocked_secret_endings().
func refresh_secret_endings(notify: bool = true) -> void:
	var block: Dictionary = _data.get("secret_endings", {}) as Dictionary
	var unlocked: Array = block.get("unlocked", []) as Array
	var changed: bool = false
	for item in _endings:
		var ending: Dictionary = item as Dictionary
		var ending_id: String = str(ending.get("id", ""))
		if ending_id == "" or unlocked.has(ending_id):
			continue
		if _ending_condition_met(ending.get("requires", {}) as Dictionary):
			unlocked.append(ending_id)
			changed = true
	block["unlocked"] = unlocked
	_data["secret_endings"] = block
	if changed and notify:
		lore_changed.emit()


func _ending_condition_met(requires: Dictionary) -> bool:
	if requires.is_empty():
		return false
	if requires.has("fragments"):
		for fragment_id in requires.get("fragments", []) as Array:
			if not has_seen_fragment(str(fragment_id)):
				return false
	if requires.has("all_station_level"):
		if min_station_level() < int(requires.get("all_station_level", 3)):
			return false
	return true


# ---------------------------------------------------------------- variacao das falas

## Alterna entre as falas de uma lista (round-robin salvo): nunca a mesma duas vezes seguidas e todas aparecem.
func pick_index(cursor_key: String, count: int) -> int:
	if count <= 1:
		return 0
	var cursors: Dictionary = _data.get("line_cursor", {}) as Dictionary
	var next_index: int = (int(cursors.get(cursor_key, -1)) + 1) % count
	cursors[cursor_key] = next_index
	_data["line_cursor"] = cursors
	_save()
	return next_index
