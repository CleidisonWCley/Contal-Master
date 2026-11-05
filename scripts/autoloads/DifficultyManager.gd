extends Node

signal difficulty_changed(difficulty: String)

const DIFFICULTIES := {
	"facil": {
		"label": "Fácil",
		"perda_pontos": 25,
		"tempo_pergunta": 90.0,
		"perseguicao_tempo": 5.0,
		"naval_qtd": 14,
		"questoes_por_partida": 6,
		"pergunta_tipo": "facil",
		"bonus_acerto": 0,
		"multiplicador_final": 1.0
	},
	"normal": {
		"label": "Normal",
		"perda_pontos": 55,
		"tempo_pergunta": 75.0,
		"perseguicao_tempo": 4.0,
		"naval_qtd": 10,
		"questoes_por_partida": 6,
		"pergunta_tipo": "normal",
		"bonus_acerto": 0,
		"multiplicador_final": 1.0
	},
	"dificil": {
		"label": "Difícil",
		"perda_pontos": 90,
		"tempo_pergunta": 60.0,
		"perseguicao_tempo": 3.0,
		"naval_qtd": 6,
		"questoes_por_partida": 6,
		"pergunta_tipo": "dificil",
		"bonus_acerto": 0,
		"multiplicador_final": 1.3
	}
}

const SCORE_PROFILES := {
	"show_do_bilhao": {
		"facil": {"correct": 80, "wrong": -25},
		"normal": {"correct": 120, "wrong": -55},
		"dificil": {"correct": 170, "wrong": -90}
	},
	"maleta_certa": {
		"facil": {"correct": 90, "wrong": -25},
		"normal": {"correct": 135, "wrong": -60},
		"dificil": {"correct": 185, "wrong": -95}
	},
	"perseguicao": {
		"facil": {"correct": 70, "wrong": -20},
		"normal": {"correct": 110, "wrong": -50},
		"dificil": {"correct": 160, "wrong": -90}
	},
	"stop": {
		"facil": {"correct": 75, "wrong": -20},
		"normal": {"correct": 115, "wrong": -50},
		"dificil": {"correct": 165, "wrong": -85}
	},
	"batalha_naval": {
		"facil": {"correct": 45, "wrong": -12},
		"normal": {"correct": 75, "wrong": -30},
		"dificil": {"correct": 130, "wrong": -65}
	}
}

const TIME_FAST_LIMIT := 15.0
const TIME_MEDIUM_LIMIT := 34.0
const TIME_FAST_MULTIPLIER := 1.0
const TIME_MEDIUM_MULTIPLIER := 0.75
const TIME_SLOW_MULTIPLIER := 0.55
const CHASE_FAST_RATIO := 0.60
const CHASE_MEDIUM_RATIO := 0.25

var current_difficulty: String = "normal"

func _ready() -> void:
	if has_node("/root/SettingsManager"):
		current_difficulty = SettingsManager.get_difficulty()

func set_difficulty(value: String) -> void:
	if not DIFFICULTIES.has(value):
		value = "normal"
	current_difficulty = value
	if has_node("/root/SettingsManager"):
		SettingsManager.set_difficulty(value)
	difficulty_changed.emit(current_difficulty)

func get_difficulty() -> String:
	if has_node("/root/SettingsManager"):
		current_difficulty = SettingsManager.get_difficulty()
	return current_difficulty

func get_rules(value: String = "") -> Dictionary:
	var key := value
	if key == "":
		key = get_difficulty()
	if not DIFFICULTIES.has(key):
		key = "normal"
	return DIFFICULTIES[key].duplicate(true)

func get_label(value: String = "") -> String:
	return str(get_rules(value).get("label", "Normal"))

func get_loss_points() -> int:
	return int(get_rules().get("perda_pontos", 12))

func get_question_time() -> float:
	return float(get_rules().get("tempo_pergunta", 8.0))

func get_chase_time() -> float:
	return float(get_rules().get("perseguicao_tempo", 2.5))

func get_naval_quantity() -> int:
	return int(get_rules().get("naval_qtd", 12))

func get_correct_bonus() -> int:
	return int(get_rules().get("bonus_acerto", 0))

func get_final_multiplier() -> float:
	return float(get_rules().get("multiplicador_final", 1.0))


func apply_difficulty_chip(label: Label, value: String = "", font_size: int = -1) -> void:
	if label == null:
		return
	var key: String = value
	if key == "":
		key = get_difficulty()
	var palette: Dictionary = _difficulty_chip_palette(key)
	var fill_color: Color = palette.get("fill", Color(0.42, 0.30, 0.04, 0.96)) as Color
	var border_color: Color = palette.get("border", Color(1.0, 0.84, 0.05, 1.0)) as Color
	var text_color: Color = palette.get("text", Color(1.0, 1.0, 1.0, 1.0)) as Color
	if font_size > 0:
		label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", text_color)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.76))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.add_theme_stylebox_override("normal", _make_difficulty_chip_style(fill_color, border_color, 13, 2))

func _difficulty_chip_palette(value: String) -> Dictionary:
	match value:
		"facil":
			return {"fill": Color(0.02, 0.22, 0.40, 0.96), "border": Color(0.12, 0.90, 1.0, 1.0), "text": Color(0.90, 1.0, 1.0, 1.0)}
		"dificil":
			return {"fill": Color(0.42, 0.04, 0.07, 0.96), "border": Color(1.0, 0.20, 0.18, 1.0), "text": Color(1.0, 0.95, 0.95, 1.0)}
		_:
			return {"fill": Color(0.42, 0.30, 0.04, 0.96), "border": Color(1.0, 0.84, 0.05, 1.0), "text": Color(1.0, 0.98, 0.84, 1.0)}

func _make_difficulty_chip_style(bg_color: Color, border_color: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.set_corner_radius_all(radius)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 7
	style.content_margin_bottom = 7
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.34)
	style.shadow_size = 6
	return style

func get_score_profile(minigame_key: String, value: String = "") -> Dictionary:
	var diff_key: String = value
	if diff_key == "":
		diff_key = get_difficulty()
	if not DIFFICULTIES.has(diff_key):
		diff_key = "normal"
	var profiles_value: Variant = SCORE_PROFILES.get(minigame_key, {})
	var profiles: Dictionary = {}
	if profiles_value is Dictionary:
		profiles = profiles_value as Dictionary
	if profiles.is_empty():
		profiles = SCORE_PROFILES.get("show_do_bilhao", {}) as Dictionary
	var profile_value: Variant = profiles.get(diff_key, profiles.get("normal", {"correct": 100, "wrong": -40}))
	if profile_value is Dictionary:
		return (profile_value as Dictionary).duplicate(true)
	return {"correct": 100, "wrong": -40}

func get_correct_points(minigame_key: String, value: String = "") -> int:
	return int(get_score_profile(minigame_key, value).get("correct", 100))

func get_wrong_points(minigame_key: String, value: String = "") -> int:
	return int(get_score_profile(minigame_key, value).get("wrong", -40))

func get_time_multiplier(elapsed_seconds: float) -> float:
	if elapsed_seconds <= TIME_FAST_LIMIT:
		return TIME_FAST_MULTIPLIER
	if elapsed_seconds <= TIME_MEDIUM_LIMIT:
		return TIME_MEDIUM_MULTIPLIER
	return TIME_SLOW_MULTIPLIER

func get_time_tier_label(elapsed_seconds: float) -> String:
	if elapsed_seconds <= TIME_FAST_LIMIT:
		return "Rápido"
	if elapsed_seconds <= TIME_MEDIUM_LIMIT:
		return "Médio"
	return "Lento"

func get_time_adjusted_points(base_points: int, elapsed_seconds: float) -> int:
	return maxi(1, int(round(float(base_points) * get_time_multiplier(elapsed_seconds))))

func get_chase_time_multiplier(remaining_ratio: float) -> float:
	if remaining_ratio >= CHASE_FAST_RATIO:
		return TIME_FAST_MULTIPLIER
	if remaining_ratio >= CHASE_MEDIUM_RATIO:
		return TIME_MEDIUM_MULTIPLIER
	return TIME_SLOW_MULTIPLIER

func get_chase_time_tier_label(remaining_ratio: float) -> String:
	if remaining_ratio >= CHASE_FAST_RATIO:
		return "Rápido"
	if remaining_ratio >= CHASE_MEDIUM_RATIO:
		return "Médio"
	return "Lento"

func get_chase_time_adjusted_points(base_points: int, remaining_ratio: float) -> int:
	return maxi(1, int(round(float(base_points) * get_chase_time_multiplier(remaining_ratio))))
