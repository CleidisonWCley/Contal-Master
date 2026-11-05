extends Node

signal score_changed(new_score: int)
signal profile_changed(nickname: String)
signal records_changed()

const SAVE_PATH := Paths.SAVE_SCORES
const DEFAULT_NICKNAME := "Jogador"

const MODE_CAMPAIGN := "campaign"
const MODE_FREE := "free_mode"
const MODE_ALL := "todos"

const DIFFICULTY_ALL := "todas"
const DIFFICULTY_KEYS := ["facil", "normal", "dificil"]
const DIFFICULTY_LABELS := {
	"facil": "Fácil",
	"normal": "Normal",
	"dificil": "Difícil"
}

const MINIGAMES := {
	"show_do_bilhao": "Show do Bilhão",
	"batalha_naval": "Batalha Naval",
	"maleta_certa": "Maleta Certa",
	"roleta_risco": "Roleta de Risco",
	"perseguicao": "Perseguição",
	"forca_tecnica": "Forca Tecnica",
	"stop": "STOP",
	"desvio_logico": "Desvio Lógico"
}

const MINIGAME_ORDER := [
	"show_do_bilhao",
	"batalha_naval",
	"maleta_certa",
	"roleta_risco",
	"perseguicao",
	"forca_tecnica",
	"stop",
	"desvio_logico"
]

var _score: int = 0
var _displayed_score: float = 0.0
var _data: Dictionary = {}

var _campaign_run_active: bool = false
var _campaign_run_difficulty: String = "normal"
var _campaign_run_minigames: Dictionary = {}
var _campaign_run_total: int = 0

func _ready() -> void:
	_load_records()

func reset() -> void:
	reset_score()

func reset_score() -> void:
	_score = 0
	_displayed_score = 0.0
	score_changed.emit(_score)

func add_points(amount: int) -> void:
	set_score(_score + amount)

func subtract_points(amount: int, clamp_zero: bool = false) -> void:
	var new_value := _score - amount
	if clamp_zero:
		new_value = max(new_value, 0)
	set_score(new_value)

func set_score(value: int) -> void:
	# Mantém fidelidade com o Pygame: erros podem deixar a pontuação negativa.
	_score = value
	score_changed.emit(_score)

func get_score() -> int:
	return _score

func get_displayed_score() -> int:
	return int(_displayed_score)

func update_displayed(speed: float = 0.3) -> int:
	if abs(_displayed_score - float(_score)) < 0.5:
		_displayed_score = float(_score)
	else:
		_displayed_score = lerp(_displayed_score, float(_score), speed)
	return int(_displayed_score)

func get_player_nickname() -> String:
	_ensure_data_shape()
	var player: Dictionary = _data.get("player", {})
	return str(player.get("nickname", DEFAULT_NICKNAME))

func set_player_nickname(value: String) -> void:
	_ensure_data_shape()
	var nickname := _sanitize_nickname(value)
	var player: Dictionary = _data.get("player", {})
	player["nickname"] = nickname
	_data["player"] = player
	_save_records()
	profile_changed.emit(nickname)

func get_minigame_keys() -> Array:
	return MINIGAME_ORDER.duplicate()

func get_minigame_label(key: String) -> String:
	return str(MINIGAMES.get(key, key.capitalize()))

func get_difficulty_keys() -> Array:
	return DIFFICULTY_KEYS.duplicate()

func get_difficulty_label(key: String) -> String:
	return str(DIFFICULTY_LABELS.get(key, key.capitalize()))

func get_mode_label(key: String) -> String:
	match key:
		MODE_CAMPAIGN:
			return "Campanha"
		MODE_FREE:
			return "Modo Livre"
		_:
			return "Todos"

func begin_campaign_run(difficulty: String) -> void:
	_campaign_run_active = true
	_campaign_run_difficulty = _normalize_difficulty(difficulty)
	_campaign_run_minigames.clear()
	_campaign_run_total = 0

func save_campaign_stage_score(minigame_key: String, difficulty: String, points: int) -> void:
	var difficulty_key := _normalize_difficulty(difficulty)
	if not _campaign_run_active or _campaign_run_difficulty != difficulty_key:
		begin_campaign_run(difficulty_key)
	var safe_key := _normalize_minigame_key(minigame_key)
	_campaign_run_minigames[safe_key] = {
		"stage_score": points,
		"cumulative_score": 0
	}
	_campaign_run_total = 0
	for item_key in _campaign_run_minigames.keys():
		var item: Variant = _campaign_run_minigames[item_key]
		if item is Dictionary:
			_campaign_run_total += int((item as Dictionary).get("stage_score", 0))
		else:
			_campaign_run_total += int(item)
	var current_data: Dictionary = _campaign_run_minigames.get(safe_key, {})
	current_data["cumulative_score"] = _campaign_run_total
	_campaign_run_minigames[safe_key] = current_data

func finish_campaign_run(difficulty: String, total_score: int = 0) -> Dictionary:
	var difficulty_key := _normalize_difficulty(difficulty)
	if not _campaign_run_active or _campaign_run_difficulty != difficulty_key:
		begin_campaign_run(difficulty_key)
	if total_score != 0:
		_campaign_run_total = total_score
	var previous := get_campaign_total_score(difficulty_key)
	var is_record := _campaign_run_total > previous or not has_campaign_record(difficulty_key)
	_ensure_data_shape()
	var scores: Dictionary = _data.get("scores", {})
	var latest_campaign: Dictionary = scores.get("campaign_latest", {})
	latest_campaign[difficulty_key] = {
		"minigames": _campaign_run_minigames.duplicate(true),
		"total_score": _campaign_run_total,
		"updated_at": _timestamp()
	}
	scores["campaign_latest"] = latest_campaign
	if is_record:
		var campaign: Dictionary = scores.get(MODE_CAMPAIGN, {})
		campaign[difficulty_key] = {
			"minigames": _campaign_run_minigames.duplicate(true),
			"total_score": _campaign_run_total,
			"updated_at": _timestamp()
		}
		scores[MODE_CAMPAIGN] = campaign
	_data["scores"] = scores
	_save_records()
	records_changed.emit()
	var result := {
		"saved": is_record,
		"previous_score": previous,
		"total_score": _campaign_run_total,
		"difficulty": difficulty_key,
		"mode": MODE_CAMPAIGN
	}
	_campaign_run_active = false
	_campaign_run_minigames.clear()
	_campaign_run_total = 0
	return result

func save_free_mode_score(minigame_key: String, difficulty: String, points: int) -> Dictionary:
	_ensure_data_shape()
	var safe_key := _normalize_minigame_key(minigame_key)
	var difficulty_key := _normalize_difficulty(difficulty)
	var safe_points: int = max(points, 0)
	var previous := get_free_mode_best_score(safe_key, difficulty_key)
	var is_record := safe_points > previous or not has_free_mode_record(safe_key, difficulty_key)
	if is_record:
		var scores: Dictionary = _data.get("scores", {})
		var free_mode: Dictionary = scores.get(MODE_FREE, {})
		var minigame_data: Dictionary = free_mode.get(safe_key, {})
		minigame_data[difficulty_key] = {
			"best_score": safe_points,
			"updated_at": _timestamp()
		}
		free_mode[safe_key] = minigame_data
		scores[MODE_FREE] = free_mode
		_data["scores"] = scores
		_save_records()
		records_changed.emit()
	return {
		"saved": is_record,
		"previous_score": previous,
		"best_score": max(safe_points, previous),
		"score": safe_points,
		"minigame": safe_key,
		"difficulty": difficulty_key,
		"mode": MODE_FREE
	}

func has_campaign_record(difficulty: String) -> bool:
	_ensure_data_shape()
	var scores: Dictionary = _data.get("scores", {})
	var campaign: Dictionary = scores.get(MODE_CAMPAIGN, {})
	var difficulty_key := _normalize_difficulty(difficulty)
	return campaign.has(difficulty_key)

func get_campaign_record(difficulty: String) -> Dictionary:
	_ensure_data_shape()
	var scores: Dictionary = _data.get("scores", {})
	var campaign: Dictionary = scores.get(MODE_CAMPAIGN, {})
	var difficulty_key := _normalize_difficulty(difficulty)
	var record: Dictionary = campaign.get(difficulty_key, {})
	return record.duplicate(true)

func get_campaign_total_score(difficulty: String) -> int:
	var record := get_campaign_record(difficulty)
	return int(record.get("total_score", 0))

func get_campaign_minigame_score(minigame_key: String, difficulty: String) -> int:
	var record := get_campaign_record(difficulty)
	var minigames: Dictionary = record.get("minigames", {})
	var value: Variant = minigames.get(_normalize_minigame_key(minigame_key), 0)
	if value is Dictionary:
		return int((value as Dictionary).get("cumulative_score", (value as Dictionary).get("stage_score", 0)))
	return int(value)

func get_campaign_best_total() -> int:
	_ensure_data_shape()
	var scores: Dictionary = _data.get("scores", {})
	var campaign: Dictionary = scores.get(MODE_CAMPAIGN, {})
	var best := 0
	for difficulty_key in campaign.keys():
		var record: Dictionary = campaign.get(difficulty_key, {})
		best = max(best, int(record.get("total_score", 0)))
	return best

func get_campaign_latest_total() -> int:
	_ensure_data_shape()
	if _campaign_run_active:
		return max(_campaign_run_total, 0)
	var scores: Dictionary = _data.get("scores", {})
	var latest_campaign: Dictionary = scores.get("campaign_latest", {})
	var latest_date := ""
	var latest_score := 0
	for difficulty_key in latest_campaign.keys():
		var record: Dictionary = latest_campaign.get(difficulty_key, {})
		var updated_at := str(record.get("updated_at", ""))
		if latest_date == "" or updated_at > latest_date:
			latest_date = updated_at
			latest_score = int(record.get("total_score", 0))
	if latest_date != "":
		return max(latest_score, 0)
	return get_campaign_best_total()

func has_free_mode_record(minigame_key: String, difficulty: String) -> bool:
	_ensure_data_shape()
	var scores: Dictionary = _data.get("scores", {})
	var free_mode: Dictionary = scores.get(MODE_FREE, {})
	var safe_key := _normalize_minigame_key(minigame_key)
	var difficulty_key := _normalize_difficulty(difficulty)
	var minigame_data: Dictionary = free_mode.get(safe_key, {})
	return minigame_data.has(difficulty_key)

func get_free_mode_record(minigame_key: String, difficulty: String) -> Dictionary:
	_ensure_data_shape()
	var scores: Dictionary = _data.get("scores", {})
	var free_mode: Dictionary = scores.get(MODE_FREE, {})
	var safe_key := _normalize_minigame_key(minigame_key)
	var difficulty_key := _normalize_difficulty(difficulty)
	var minigame_data: Dictionary = free_mode.get(safe_key, {})
	var record: Dictionary = minigame_data.get(difficulty_key, {})
	return record.duplicate(true)

func get_free_mode_best_score(minigame_key: String, difficulty: String) -> int:
	var record := get_free_mode_record(minigame_key, difficulty)
	return max(int(record.get("best_score", 0)), 0)

func get_campaign_general_total() -> int:
	_ensure_data_shape()
	var scores: Dictionary = _data.get("scores", {})
	var campaign: Dictionary = scores.get(MODE_CAMPAIGN, {})
	var total := 0
	for difficulty_key in campaign.keys():
		var record: Dictionary = campaign.get(difficulty_key, {})
		total += int(record.get("total_score", 0))
	return total

func get_free_mode_records_total() -> int:
	_ensure_data_shape()
	var scores: Dictionary = _data.get("scores", {})
	var free_mode: Dictionary = scores.get(MODE_FREE, {})
	var total := 0
	for minigame_key in free_mode.keys():
		var minigame_data: Dictionary = free_mode.get(minigame_key, {})
		for difficulty_key in minigame_data.keys():
			var record: Dictionary = minigame_data.get(difficulty_key, {})
			total += max(int(record.get("best_score", 0)), 0)
	return total

func get_score_file_path() -> String:
	return SAVE_PATH

func _load_records() -> void:
	Paths.migrate_legacy_saves()
	_data = _default_data()
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file != null:
			var parsed: Variant = JSON.parse_string(file.get_as_text())
			if parsed is Dictionary:
				_data = parsed as Dictionary
	_ensure_data_shape()
	_save_records()

func _save_records() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Não foi possível salvar a pontuação local em %s" % SAVE_PATH)
		return
	file.store_string(JSON.stringify(_data, "\t"))

func _ensure_data_shape() -> void:
	if not (_data is Dictionary) or _data.is_empty():
		_data = _default_data()
	if not _data.has("player") or not (_data["player"] is Dictionary):
		_data["player"] = {"nickname": DEFAULT_NICKNAME}
	var player: Dictionary = _data.get("player", {})
	player["nickname"] = _sanitize_nickname(str(player.get("nickname", DEFAULT_NICKNAME)))
	_data["player"] = player
	if not _data.has("scores") or not (_data["scores"] is Dictionary):
		_data["scores"] = {MODE_CAMPAIGN: {}, MODE_FREE: {}}
	var scores: Dictionary = _data.get("scores", {})
	if not scores.has(MODE_CAMPAIGN) or not (scores[MODE_CAMPAIGN] is Dictionary):
		scores[MODE_CAMPAIGN] = {}
	if not scores.has(MODE_FREE) or not (scores[MODE_FREE] is Dictionary):
		scores[MODE_FREE] = {}
	if not scores.has("campaign_latest") or not (scores["campaign_latest"] is Dictionary):
		scores["campaign_latest"] = {}
	_data["scores"] = scores

func _default_data() -> Dictionary:
	return {
		"player": {
			"nickname": DEFAULT_NICKNAME
		},
		"scores": {
			MODE_CAMPAIGN: {},
			MODE_FREE: {},
			"campaign_latest": {}
		}
	}

func _sanitize_nickname(value: String) -> String:
	var nickname := value.strip_edges()
	if nickname == "":
		nickname = DEFAULT_NICKNAME
	if nickname.length() > 18:
		nickname = nickname.substr(0, 18)
	return nickname

func _normalize_difficulty(value: String) -> String:
	var key := value.to_lower().strip_edges()
	if not DIFFICULTY_KEYS.has(key):
		key = "normal"
	return key

func _normalize_minigame_key(value: String) -> String:
	var key := value.strip_edges()
	if key == "" or not MINIGAMES.has(key):
		key = "desvio_logico"
	return key

func _timestamp() -> String:
	return Time.get_datetime_string_from_system(false, true)
