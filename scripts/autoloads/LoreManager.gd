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
## V0.15.3 - CONFIANCA POR ESTRELAS (substitui as metas Bronze/Prata/Ouro como regra dos niveis):
##   0 Desconhecidos  -> ainda sem estrela
##   1 Apresentados   -> 1a estrela     2 De Confianca -> 2a estrela     3 Da Casa -> 3a estrela
## Cada estacao concluida (campanha OU modo livre) rende PONTOS DE CONFIANCA ao anfitriao (TRUST_*). Quando os pontos
## alcancam o limite da proxima estrela (STAR_THRESHOLDS) a estrela fica PENDENTE e e entregue numa conversa do MODO LIVRE
## (a StageDebrief toca a cena do personagem, "Apos uma longa conversa..." e o cartao de conquista). O Jales nao tem
## minigame: ele participa de TODAS essas conversas e ganha pontos a cada uma (JALES_THRESHOLDS).
## Saves antigos: as estrelas que o jogador ja tinha (Bronze/Prata/Ouro da v0.15) viram estrelas e pontos equivalentes.
## As metas GOALS continuam sendo gravadas (compatibilidade), mas nao decidem mais o nivel.
##
## CAPITULOS da firma: abrem quando os PONTOS DE RECORDE (soma dos recordes de campanha + modo livre, em qualquer
## dificuldade) passam do min_points do capitulo (firma.json). Dificuldade maior rende mais pontos, entao ela abre mais rapido.

signal lore_changed
## V0.15.3: uma estrela de confianca foi entregue (id do personagem, total de estrelas).
signal trust_star_granted(character_id: String, stars: int)
## V0.15.3: capitulos da firma recem-abertos (ids).
signal chapters_unlocked(chapter_ids: Array)

const SAVE_PATH := Paths.SAVE_LORE
const SAVE_VERSION := 2

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
## Nomes dos minigames (dicas de como evoluir a confianca).
const MINIGAME_NAMES := {
	"show_do_bilhao": "o Show do Bilhão", "batalha_naval": "a Batalha Naval", "maleta_certa": "a Maleta Certa",
	"roleta_risco": "a Roleta de Risco", "perseguicao": "a Perseguição", "forca_tecnica": "a Força Técnica",
	"stop": "o STOP", "desvio_logico": "o Desvio Lógico"
}
## V0.15.5 - Cor do NOME de cada personagem = cor principal do minigame dele (a mesma do acento das transicoes).
## O Jales nao tem estacao: usa o dourado da marca. O STOP usa o verde vivo (o acento claro dele quase some sobre fundo escuro).
const CHARACTER_COLORS := {
	"jales": Color(1.0, 0.84, 0.12),
	"priscila": Color(1.0, 0.82, 0.12),    # Show do Bilhao
	"anderson": Color(0.25, 0.78, 1.0),    # Batalha Naval
	"tiago": Color(1.0, 0.66, 0.20),       # Maleta Certa
	"julios": Color(1.0, 0.35, 1.0),       # Roleta de Risco
	"ariel": Color(1.0, 0.30, 0.26),       # Perseguicao
	"aline": Color(0.46, 1.0, 0.82),       # Forca Tecnica
	"cleiton": Color(0.30, 0.85, 0.36),    # STOP
	"natalia": Color(0.0, 0.88, 1.0)       # Desvio Logico
}


static func character_color(character_id: String) -> Color:
	return CHARACTER_COLORS.get(character_id, Color(1.0, 0.84, 0.12)) as Color


## Ordem de exibicao dos 9 personagens no Arquivo.
const CHARACTER_ORDER: Array[String] = [
	"jales", "priscila", "anderson", "tiago", "julios", "ariel", "aline", "cleiton", "natalia"
]
const CHARACTER_NAMES := {
	"jales": "Jales", "priscila": "Priscila", "anderson": "Anderson", "tiago": "Tiago", "julios": "Julios",
	"ariel": "Ariel", "aline": "Aline", "cleiton": "Cleiton", "natalia": "Natalia"
}

## V0.15.3 - PONTOS DE CONFIANCA (numeros a calibrar com testes reais; ficam todos aqui).
##   ganho por estacao concluida = TRUST_BASE + TRUST_FIRST_PLAY (1a vez) + bonus da faixa + bonus da dificuldade
const STAR_THRESHOLDS: Array[int] = [12, 48, 105]       # pontos para a 1a, 2a e 3a estrela de cada anfitriao
const JALES_THRESHOLDS: Array[int] = [20, 50, 90]       # Jales: 2, 5 e 9 conversas (JALES_POINTS_PER_TALK cada)
const JALES_POINTS_PER_TALK := 10
const JALES_POINTS_PER_CAMPAIGN := 15
const TRUST_BASE := 10
const TRUST_FIRST_PLAY := 5
const TRUST_TIER_BONUS := {"perfeito": 10, "otimo": 6, "bom": 6, "medio": 3, "fraco": 0, "ruim": 0}
const TRUST_DIFFICULTY_BONUS := {"facil": 0, "normal": 3, "dificil": 6}

## V0.15: abas da ficha de cada personagem (Arquivos da Equipe) e o nivel de confianca que abre cada uma.
const DOSSIER_TABS: Array[Dictionary] = [
	{"id": "perfil", "title": "Perfil", "min_level": 1},
	{"id": "gostos", "title": "Gostos e forças", "min_level": 1},
	{"id": "origem", "title": "Origem e motivação", "min_level": 2},
	{"id": "relacoes", "title": "Relações", "min_level": 2},
	{"id": "momento", "title": "Momento marcante", "min_level": 3},
	{"id": "lembrancas", "title": "Lembranças", "min_level": 0}
]

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
var _dossiers: Array = []
var _chapters: Array = []


func _ready() -> void:
	_load_content()
	_load_save()
	chapters_unlocked.connect(_on_chapters_unlocked)
	refresh_chapters(false)   # saves antigos: capitulos que ja estao dentro da meta abrem sem aviso


# ---------------------------------------------------------------- conteudo (JSON)

func _load_content() -> void:
	_fragments = _read_list(Paths.LORE_FRAGMENTS, "fragments")
	_profiles = _read_list(Paths.LORE_PROFILES, "profiles")
	_endings = _read_list(Paths.LORE_SECRET_ENDINGS, "endings")
	_dossiers = _read_list(Paths.LORE_DOSSIERS, "characters")
	_chapters = _read_list(Paths.LORE_FIRMA, "chapters")


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
		"line_cursor": {},
		"trust": {},                  # V0.15.3: {personagem: {"points": int, "stars": int}}
		"chapters_unlocked": []       # V0.15.3: capitulos da firma ja abertos (nunca fecham de novo)
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
	var needs_trust_migration: bool = int(_data.get("version", 1)) < 2 or not _data.has("trust")
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
	_ensure_trust_shape()
	if needs_trust_migration:
		_migrate_trust_from_goals()


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


func get_level_name(level: int) -> String:
	return LEVEL_NAMES[clampi(level, 0, LEVEL_NAMES.size() - 1)]


# ---------------------------------------------------------------- V0.15.3: confianca por estrelas

func _ensure_trust_shape() -> void:
	var trust: Dictionary = _data.get("trust", {}) as Dictionary
	for character_id in CHARACTER_ORDER:
		var entry: Dictionary = trust.get(character_id, {}) as Dictionary
		entry["points"] = maxi(int(entry.get("points", 0)), 0)
		entry["stars"] = clampi(int(entry.get("stars", 0)), 0, 3)
		trust[character_id] = entry
	_data["trust"] = trust
	if not (_data.get("chapters_unlocked", []) is Array):
		_data["chapters_unlocked"] = []


## Nivel que a estacao tinha na v0.15 (Bronze/Prata/Ouro). So usado para MIGRAR saves antigos.
func _legacy_level(phase_key: String) -> int:
	var goals: Dictionary = get_station(phase_key).get("goals", {}) as Dictionary
	if bool(goals.get("ouro", false)):
		return 3
	if bool(goals.get("prata", false)):
		return 2
	if bool(goals.get("bronze", false)):
		return 1
	return 0


## Save da v0.15 -> v0.15.3: quem ja tinha estrelas continua com elas (e com os pontos equivalentes). Ninguem perde nada.
func _migrate_trust_from_goals() -> void:
	var trust: Dictionary = _data.get("trust", {}) as Dictionary
	var at_least: Dictionary = {1: 0, 2: 0}
	for key in STATION_ORDER:
		var level: int = _legacy_level(str(key))
		for needed in [1, 2]:
			if level >= int(needed):
				at_least[needed] = int(at_least[needed]) + 1
		var host: String = str(HOST_BY_STATION.get(key, ""))
		if host == "":
			continue
		var entry: Dictionary = trust.get(host, {}) as Dictionary
		entry["stars"] = level
		entry["points"] = maxi(int(entry.get("points", 0)), STAR_THRESHOLDS[level - 1] if level > 0 else 0)
		trust[host] = entry
	var jales_level: int = 0
	if int(at_least[1]) >= 3:
		jales_level = 1
	if int(at_least[2]) >= 5:
		jales_level = 2
	if int(at_least[2]) >= 8:
		jales_level = 3
	var jales_entry: Dictionary = trust.get("jales", {}) as Dictionary
	jales_entry["stars"] = jales_level
	jales_entry["points"] = maxi(int(jales_entry.get("points", 0)), JALES_THRESHOLDS[jales_level - 1] if jales_level > 0 else 0)
	trust["jales"] = jales_entry
	_data["trust"] = trust
	# As cenas dos niveis que o jogador ja tem contam como lembrancas (e mantem os finais secretos coerentes).
	var seen: Array = _data.get("fragments_seen", []) as Array
	for character_id in CHARACTER_ORDER:
		for level in range(1, int((trust[character_id] as Dictionary).get("stars", 0)) + 1):
			var scene_id: String = "%s_%d" % [character_id, level]
			if not seen.has(scene_id):
				seen.append(scene_id)
	_data["fragments_seen"] = seen


func thresholds_for(character_id: String) -> Array[int]:
	return JALES_THRESHOLDS if character_id == "jales" else STAR_THRESHOLDS


func get_stars(character_id: String) -> int:
	var entry: Dictionary = (_data.get("trust", {}) as Dictionary).get(character_id, {}) as Dictionary
	return clampi(int(entry.get("stars", 0)), 0, 3)


## Nivel de confianca (0..3) do personagem = quantas estrelas ele ja entregou.
func get_character_level(character_id: String) -> int:
	return get_stars(character_id)


## Nivel de confianca (0..3) do anfitriao da estacao.
func get_level(phase_key: String) -> int:
	var host: String = str(HOST_BY_STATION.get(phase_key, ""))
	return get_stars(host) if host != "" else 0


func get_trust_points(character_id: String) -> int:
	var entry: Dictionary = (_data.get("trust", {}) as Dictionary).get(character_id, {}) as Dictionary
	return maxi(int(entry.get("points", 0)), 0)


## Pontos que faltam para a PROXIMA estrela (-1 = ja tem as 3).
func next_threshold(character_id: String) -> int:
	var stars: int = get_stars(character_id)
	if stars >= 3:
		return -1
	return thresholds_for(character_id)[stars]


## Estrela ganha, mas ainda nao entregue (a conversa acontece no Modo Livre).
func has_pending_star(character_id: String) -> bool:
	var next_value: int = next_threshold(character_id)
	return next_value >= 0 and get_trust_points(character_id) >= next_value


## {"stars", "points", "previous", "next", "remaining", "maxed", "pending"} para barras e cartoes.
func trust_progress(character_id: String) -> Dictionary:
	var stars: int = get_stars(character_id)
	var points: int = get_trust_points(character_id)
	var limits: Array[int] = thresholds_for(character_id)
	var next_value: int = next_threshold(character_id)
	var previous: int = limits[stars - 1] if stars > 0 else 0
	return {
		"stars": stars, "points": points, "previous": previous, "next": next_value,
		"remaining": maxi(next_value - points, 0) if next_value >= 0 else 0,
		"maxed": stars >= 3, "pending": has_pending_star(character_id)
	}


func add_trust_points(character_id: String, amount: int) -> void:
	if amount <= 0 or not CHARACTER_ORDER.has(character_id):
		return
	var trust: Dictionary = _data.get("trust", {}) as Dictionary
	var entry: Dictionary = trust.get(character_id, {}) as Dictionary
	entry["points"] = maxi(int(entry.get("points", 0)), 0) + amount
	trust[character_id] = entry
	_data["trust"] = trust
	_save()
	lore_changed.emit()


## Pontos que uma estacao concluida rende ao anfitriao (base + 1a vez + faixa + dificuldade).
static func trust_gain_for(tier: String, difficulty: String, first_play: bool) -> int:
	var gain: int = TRUST_BASE + int(TRUST_TIER_BONUS.get(tier, 0)) + int(TRUST_DIFFICULTY_BONUS.get(difficulty, 0))
	if first_play:
		gain += TRUST_FIRST_PLAY
	return gain


## Cena de conversa de um personagem para uma estrela (fragments.json: id "<personagem>_<nivel>").
func get_trust_scene(character_id: String, level: int) -> Dictionary:
	return get_fragment("%s_%d" % [character_id, level])


## Quais conversas (estrelas pendentes) o Modo Livre toca depois de concluir `phase_key`.
## Regra: 1) o anfitriao da estacao, se tiver estrela pendente; 2) senao o Julios, que nao tem estacao no Modo Livre
## e "passa pela sala"; 3) o JALES participa de TODAS as conversas e, se isso completar a conta dele, tem a dele em seguida.
## Devolve [{"owner", "level", "co"}] (co = quem fica em cena junto). Vazio = nenhuma conversa agora.
func plan_talks(phase_key: String) -> Array:
	var talks: Array = []
	var host: String = str(HOST_BY_STATION.get(phase_key, ""))
	var talker: String = ""
	if host != "" and host != "jales" and has_pending_star(host):
		talker = host
	elif host != "julios" and has_pending_star("julios"):
		talker = "julios"
	if talker == "" or get_trust_scene(talker, get_stars(talker) + 1).is_empty():
		return talks
	talks.append({"owner": talker, "level": get_stars(talker) + 1, "co": host if host != "" else talker})
	var jales_stars: int = get_stars("jales")
	if jales_stars < 3 and get_trust_points("jales") + JALES_POINTS_PER_TALK >= JALES_THRESHOLDS[jales_stars] \
			and not get_trust_scene("jales", jales_stars + 1).is_empty():
		talks.append({"owner": "jales", "level": jales_stars + 1, "co": talker})
	return talks


## A conversa COMECOU: entrega a estrela (quem pular a cena nao perde) e o Jales ganha pontos por participar.
## Devolve {"granted": bool, "stars", "owner", "level"}.
func begin_talk(owner: String, level: int) -> Dictionary:
	var result: Dictionary = {"granted": false, "stars": get_stars(owner), "owner": owner, "level": level}
	if get_stars(owner) != level - 1 or not has_pending_star(owner):
		return result
	var trust: Dictionary = _data.get("trust", {}) as Dictionary
	var entry: Dictionary = trust.get(owner, {}) as Dictionary
	entry["stars"] = level
	trust[owner] = entry
	_data["trust"] = trust
	var seen: Array = _data.get("fragments_seen", []) as Array
	var scene_id: String = "%s_%d" % [owner, level]
	if not seen.has(scene_id):
		seen.append(scene_id)
	_data["fragments_seen"] = seen
	if owner != "jales":
		var jales_entry: Dictionary = trust.get("jales", {}) as Dictionary
		jales_entry["points"] = maxi(int(jales_entry.get("points", 0)), 0) + JALES_POINTS_PER_TALK
		trust["jales"] = jales_entry
	refresh_secret_endings(false)
	_save()
	result["granted"] = true
	result["stars"] = level
	lore_changed.emit()
	trust_star_granted.emit(owner, level)
	return result


## Jales ganha pontos tambem ao terminar a campanha (participou da jornada inteira).
func record_campaign_completed() -> void:
	add_trust_points("jales", JALES_POINTS_PER_CAMPAIGN)


# ---------------------------------------------------------------- V0.15.3: capitulos por pontos de recorde

## Soma dos recordes: melhor campanha de cada dificuldade + melhor marca de cada minigame do Modo Livre em cada dificuldade.
## So cresce (recorde so e gravado quando e superado) e dificuldade maior rende mais pontos.
func archive_points() -> int:
	if not has_node("/root/ScoreManager"):
		return 0
	return ScoreManager.get_campaign_general_total() + ScoreManager.get_free_mode_records_total()


func chapter_target(chapter: Dictionary) -> int:
	return maxi(int(chapter.get("min_points", 0)), 0)


func is_chapter_unlocked(chapter: Dictionary) -> bool:
	if (_data.get("chapters_unlocked", []) as Array).has(str(chapter.get("id", ""))):
		return true
	return archive_points() >= chapter_target(chapter)


## {"points", "target", "unlocked"} para barras e dicas do capitulo.
func chapter_progress(chapter: Dictionary) -> Dictionary:
	var points: int = archive_points()
	return {"points": points, "target": chapter_target(chapter), "unlocked": is_chapter_unlocked(chapter)}


## Grava os capitulos que passaram da meta (nunca fecham de novo) e avisa. Devolve os ids recem-abertos.
## Chamado pelo GameManager depois de salvar os recordes de cada estacao.
func refresh_chapters(notify: bool = true) -> Array:
	var opened: Array = _data.get("chapters_unlocked", []) as Array
	var fresh: Array = []
	for item in _chapters:
		var chapter: Dictionary = item as Dictionary
		var chapter_id: String = str(chapter.get("id", ""))
		if chapter_id == "" or opened.has(chapter_id):
			continue
		if archive_points() >= chapter_target(chapter):
			opened.append(chapter_id)
			fresh.append(chapter_id)
	if fresh.is_empty():
		return fresh
	_data["chapters_unlocked"] = opened
	_save()
	lore_changed.emit()
	if notify:
		chapters_unlocked.emit(fresh)
	return fresh


func get_chapter(chapter_id: String) -> Dictionary:
	for item in _chapters:
		if str((item as Dictionary).get("id", "")) == chapter_id:
			return item as Dictionary
	return {}


## Dica de como evoluir a confianca (mostrada no cartao do personagem).
func unlock_hint_for_character(character_id: String) -> String:
	var progress: Dictionary = trust_progress(character_id)
	var name: String = str(CHARACTER_NAMES.get(character_id, character_id.capitalize()))
	var station: String = station_of_character(character_id)
	var free_station: bool = station != "" and station != "roleta_risco"
	var where: String = "Jogue %s no Modo Livre." % str(MINIGAME_NAMES.get(station, "um minigame")) if free_station else "Jogue qualquer minigame no Modo Livre."
	if bool(progress.get("maxed", false)):
		return "Confiança máxima: %s já trata você como gente da casa." % name
	if bool(progress.get("pending", false)):
		return "Conversa disponível! %s" % where
	if character_id == "jales":
		return "O Jales participa de todas as conversas do Modo Livre. Cada conversa o aproxima de você."
	return "Faltam %d pontos de confiança para a próxima estrela. Concluir estações (campanha ou Modo Livre) rende pontos: notas altas e dificuldades maiores rendem mais." % int(progress.get("remaining", 0))


## Conversas ja liberadas de um personagem (aba Lembrancas): uma por estrela que ele ja entregou.
func seen_fragments_of(character_id: String) -> Array:
	var result: Array = []
	var stars: int = get_stars(character_id)
	for item in _fragments:
		var fragment: Dictionary = item as Dictionary
		if str(fragment.get("owner", "")) == character_id and int(fragment.get("level", 1)) <= stars:
			result.append(fragment)
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("level", 1)) < int(b.get("level", 1)))
	return result


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
	var result: Dictionary = {"tier": tier_for_report(report), "level_before": 0, "level_after": 0, "leveled_up": false, "trust_gain": 0}
	if not STATION_ORDER.has(phase_key):
		return result
	var level_before: int = get_level(phase_key)
	var station: Dictionary = get_station(phase_key)
	var is_campaign: bool = str(report.get("mode", "")) == "campaign"
	var ratio: float = clampf(float(report.get("ratio", 0.0)), 0.0, 1.0)
	station["plays"] = int(station.get("plays", 0)) + 1
	var first_play: bool = int(station.get("plays", 0)) == 1
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
	# V0.15.3: pontos de confianca do anfitriao (a estrela e entregue na conversa do Modo Livre).
	var host_id: String = str(HOST_BY_STATION.get(phase_key, ""))
	var trust_gain: int = trust_gain_for(str(result["tier"]), str(report.get("difficulty", "normal")), first_play)
	if host_id != "":
		var trust: Dictionary = _data.get("trust", {}) as Dictionary
		var trust_entry: Dictionary = trust.get(host_id, {}) as Dictionary
		trust_entry["points"] = maxi(int(trust_entry.get("points", 0)), 0) + trust_gain
		trust[host_id] = trust_entry
		_data["trust"] = trust
	result["trust_gain"] = trust_gain
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


## Progresso dos Arquivos: abas de ficha abertas + capitulos da firma abertos (perfis e trechos nao entram: sao "lembrancas").
func count_items() -> Dictionary:
	var total: int = 0
	var unlocked: int = 0
	for item in _dossiers:
		var character_id: String = str((item as Dictionary).get("id", ""))
		for tab in DOSSIER_TABS:
			if str(tab.get("id", "")) == "lembrancas":
				continue
			total += 1
			if is_tab_unlocked(character_id, tab):
				unlocked += 1
	for item in _chapters:
		total += 1
		if is_chapter_unlocked(item as Dictionary):
			unlocked += 1
	return {"total": total, "unlocked": unlocked}


## V0.15.2: estacao (chave do minigame) que o personagem apresenta. Jales nao tem estacao: devolve "".
func station_of_character(character_id: String) -> String:
	for key in STATION_ORDER:
		if str(HOST_BY_STATION.get(key, "")) == character_id:
			return key
	return ""


## V0.15.2: capitulos da firma abertos / total (para o hub "Arquivos da Equipe").
func count_chapters() -> Dictionary:
	var unlocked: int = 0
	for item in _chapters:
		if is_chapter_unlocked(item as Dictionary):
			unlocked += 1
	return {"total": _chapters.size(), "unlocked": unlocked}


## V0.15.2: personagens ja conhecidos (nivel >= 1) / total (para o hub "Arquivos da Equipe").
func count_profiles() -> Dictionary:
	var met: int = 0
	for character_id in CHARACTER_ORDER:
		if get_character_level(str(character_id)) >= 1:
			met += 1
	return {"total": CHARACTER_ORDER.size(), "met": met}


func get_dossiers() -> Array:
	return _dossiers


func get_dossier(character_id: String) -> Dictionary:
	for item in _dossiers:
		if str((item as Dictionary).get("id", "")) == character_id:
			return item as Dictionary
	return {}


func get_chapters() -> Array:
	return _chapters


func is_tab_unlocked(character_id: String, tab: Dictionary) -> bool:
	return get_character_level(character_id) >= int(tab.get("min_level", 1))


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


## V0.15.3: aviso (mesmo quadro das conquistas) quando um capitulo da firma abre.
func _on_chapters_unlocked(chapter_ids: Array) -> void:
	if not has_node("/root/AchievementManager"):
		return
	for chapter_id in chapter_ids:
		var chapter: Dictionary = get_chapter(str(chapter_id))
		AchievementManager.notify_custom({
			"header": "Capítulo liberado!", "title": str(chapter.get("title", "Capítulo")),
			"description": "Arquivos da Firma: já pode ler.", "icon": "archive"
		})
