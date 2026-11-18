extends Node

signal settings_changed(settings: Dictionary)

const SETTINGS_PATH := Paths.SAVE_SETTINGS
const DEFAULT_SETTINGS := {
	"music_volume": 0.5,
	"sfx_volume": 1.0,
	"fullscreen": false,
	"difficulty": "normal",
	"animations_enabled": true,
	"tutorials_enabled": true,
	"novel_auto": false
}

var settings: Dictionary = DEFAULT_SETTINGS.duplicate(true)

## V0.14.3: instante (ms) do ultimo pedido de tela cheia feito pelo jogador (ver sync_fullscreen_state).
var _fs_request_msec: int = -100000

## V0.15.6: gravar em disco a CADA tique do slider de volume (user:// vira IndexedDB na web) travava a pagina e, junto,
## o audio. Agora a gravacao e adiada: so acontece ~0,6 s depois da ULTIMA mudanca (ou ao sair/esconder a aba).
const SAVE_DELAY_SECONDS: float = 0.6
var _save_dirty: bool = false
var _save_timer: Timer = null

func _ready() -> void:
	load_settings()
	if OS.has_feature("web"):
		# V0.14.3 (web): o navegador so libera tela cheia em resposta a um toque/clique do jogador. Ao abrir o jogo
		# nao tentamos entrar sozinhos (falhava em silencio e a opcao ficava "LIGADA" sem estar). Comeca desligada.
		settings["fullscreen"] = false
	else:
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
	_save_dirty = false
	var file: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Não foi possível salvar settings.json.")
		return
	file.store_string(JSON.stringify(settings, "	"))

func set_setting(key: String, value: Variant) -> void:
	if key != "fullscreen" and settings.has(key) and typeof(settings[key]) == typeof(value) and settings[key] == value:
		return   # nada mudou: sem gravacao e sem sinal (evita trabalho a cada tique do slider)
	settings[key] = value
	if key == "fullscreen":
		_fs_request_msec = Time.get_ticks_msec()
		apply_window_settings()
	_schedule_save()
	settings_changed.emit(settings)


func _schedule_save() -> void:
	_save_dirty = true
	if _save_timer == null:
		_save_timer = Timer.new()
		_save_timer.one_shot = true
		_save_timer.process_mode = Node.PROCESS_MODE_ALWAYS
		_save_timer.timeout.connect(flush_pending_save)
		add_child(_save_timer)
	_save_timer.start(SAVE_DELAY_SECONDS)


## Grava agora se houver mudanca pendente (chamado ao esconder a aba, fechar o jogo ou sair).
func flush_pending_save() -> void:
	if _save_dirty:
		save_settings()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		flush_pending_save()

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

## V0.14: modo das novels (conversas com personagens). false = CLIQUE (o jogador avanca), true = AUTO (passa sozinha).
func set_novel_auto(value: bool) -> void:
	set_setting("novel_auto", value)

func novel_auto() -> bool:
	return bool(settings.get("novel_auto", DEFAULT_SETTINGS["novel_auto"]))

func toggle_novel_auto() -> void:
	set_novel_auto(not novel_auto())

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

## V0.14.3 (web): o navegador pode entrar/sair da tela cheia sem o jogo pedir (Esc, gesto do celular, F11...).
## Alinha o valor salvo com o estado REAL, sem reaplicar (nada de laco) e sem gravar em disco. Ignora avisos nos
## 1,2 s seguintes a um pedido do jogador: a tela cheia ainda esta "entrando" e o aviso traria o estado antigo.
func sync_fullscreen_state(real_fullscreen: bool) -> void:
	if is_fullscreen() == real_fullscreen:
		return
	if Time.get_ticks_msec() - _fs_request_msec < 1200:
		return
	settings["fullscreen"] = real_fullscreen
	settings_changed.emit(settings)
