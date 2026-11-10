extends Node

signal settings_changed(settings: Dictionary)

const SETTINGS_PATH := Paths.SAVE_SETTINGS
const DEFAULT_SETTINGS := {
	"music_volume": 0.5,
	"sfx_volume": 1.0,
	"fullscreen": false,
	"difficulty": "normal",
	"animations_enabled": true,
	"tutorials_enabled": true
}

var settings: Dictionary = DEFAULT_SETTINGS.duplicate(true)

func _ready() -> void:
	load_settings()
	apply_window_settings()

func load_settings() -> void:
	settings = DEFAULT_SETTINGS.duplicate(true)
	if not FileAccess.file_exists(SETTINGS_PATH):
		save_settings()
		return

	var file: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		push_warning("Não foi possível abrir settings.json para leitura.")
		return

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		for key in DEFAULT_SETTINGS.keys():
			if parsed.has(key):
				settings[key] = parsed[key]
	else:
		push_warning("settings.json inválido. As configurações padrão foram carregadas.")

func save_settings() -> void:
	var file: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Não foi possível salvar settings.json.")
		return
	file.store_string(JSON.stringify(settings, "	"))

func set_setting(key: String, value: Variant) -> void:
	settings[key] = value
	if key == "fullscreen":
		apply_window_settings()
	save_settings()
	settings_changed.emit(settings)

func get_setting(key: String, fallback: Variant = null) -> Variant:
	return settings.get(key, fallback)

func set_music_volume(value: float) -> void:
	set_setting("music_volume", clampf(value, 0.0, 1.0))

func get_music_volume() -> float:
	return float(settings.get("music_volume", DEFAULT_SETTINGS["music_volume"]))

func set_sfx_volume(value: float) -> void:
	set_setting("sfx_volume", clampf(value, 0.0, 1.0))

func get_sfx_volume() -> float:
	return float(settings.get("sfx_volume", DEFAULT_SETTINGS["sfx_volume"]))

func set_fullscreen(value: bool) -> void:
	set_setting("fullscreen", value)

func toggle_fullscreen() -> void:
	set_fullscreen(not is_fullscreen())

func is_fullscreen() -> bool:
	return bool(settings.get("fullscreen", DEFAULT_SETTINGS["fullscreen"]))

func set_animations_enabled(value: bool) -> void:
	set_setting("animations_enabled", value)

func animations_enabled() -> bool:
	return bool(settings.get("animations_enabled", DEFAULT_SETTINGS["animations_enabled"]))

func toggle_animations_enabled() -> void:
	set_animations_enabled(not animations_enabled())

func set_tutorials_enabled(value: bool) -> void:
	set_setting("tutorials_enabled", value)

func tutorials_enabled() -> bool:
	return bool(settings.get("tutorials_enabled", DEFAULT_SETTINGS["tutorials_enabled"]))

func toggle_tutorials_enabled() -> void:
	set_tutorials_enabled(not tutorials_enabled())

func set_difficulty(value: String) -> void:
	if not ["facil", "normal", "dificil"].has(value):
		value = "normal"
	set_setting("difficulty", value)

func get_difficulty() -> String:
	var value: String = str(settings.get("difficulty", DEFAULT_SETTINGS["difficulty"]))
	if not ["facil", "normal", "dificil"].has(value):
		return "normal"
	return value

func apply_window_settings() -> void:
	if is_fullscreen():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
