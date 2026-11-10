extends Node

const MUSIC := {
	"menu": Paths.MUSIC_MENU,
	"loop_start": Paths.MUSIC_LOOP_START,
	"intro_jornada": Paths.MUSIC_INTRO_JORNADA,
	"musica_show_do_bilhao": Paths.MUSIC_SHOW_DO_BILHAO,
	"musica_batalha_naval": Paths.MUSIC_BATALHA_NAVAL,
	"musica_maleta_certa": Paths.MUSIC_MALETA_CERTA,
	"musica_rodada_bonus": Paths.MUSIC_RODADA_BONUS,
	"musica_perseguicao": Paths.MUSIC_PERSEGUICAO,
	"musica_forca_tecnica": Paths.MUSIC_FORCA_TECNICA,
	"musica_stop": Paths.MUSIC_STOP,
	"desvio_logico": Paths.MUSIC_DESVIO_LOGICO,
	"musica_final": Paths.MUSIC_FINAL
}

## V0.12: musica de cada minigame da campanha (chave = key de GameManager.PHASES). A transicao toca a musica
## do PROPRIO minigame (em vez do "loop_start" generico) e ela segue sem corte quando o minigame comeca,
## porque play_music() ignora a chamada se a mesma musica ja esta tocando.
const PHASE_MUSIC := {
	"show_do_bilhao": "musica_show_do_bilhao",
	"batalha_naval": "musica_batalha_naval",
	"maleta_certa": "musica_maleta_certa",
	"roleta_risco": "musica_rodada_bonus",
	"perseguicao": "musica_perseguicao",
	"forca_tecnica": "musica_forca_tecnica",
	"stop": "musica_stop",
	"desvio_logico": "desvio_logico"
}

const SFX := {
	"click": Paths.SFX_CLICK,
	"correto": Paths.SFX_CORRECT,
	"errado": Paths.SFX_WRONG,
	"explosion": Paths.SFX_EXPLOSION,
	"roleta": Paths.SFX_ROULETTE,
	"conquista": Paths.SFX_ACHIEVEMENT
}

# V0.13.9.5: perfil limpo. A mixagem do Desvio Lógico agora usa volume puro,
# sem low-pass, reverb, stereo enhance ou filtros criados por código.
const MUSIC_BUS_MASTER := &"Master"
const DESVIO_MUSIC_BUS := &"DesvioMusic"
const DESVIO_MUSIC_VOLUME_OFFSET_DB := 0.0

var music_player: AudioStreamPlayer
var current_music_key: String = ""
var music_volume_offset_db: float = 0.0
var desvio_music_profile_active: bool = false

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	add_child(music_player)
	_apply_volumes()
	if has_node("/root/SettingsManager"):
		SettingsManager.settings_changed.connect(_on_settings_changed)

func _on_settings_changed(_settings: Dictionary) -> void:
	_apply_volumes()

func _apply_volumes() -> void:
	if music_player == null:
		return
	var base_volume_db: float = 0.0
	if has_node("/root/SettingsManager"):
		base_volume_db = _volume_to_db(SettingsManager.get_music_volume())
	music_player.volume_db = clampf(base_volume_db + music_volume_offset_db, -80.0, 6.0)

func _volume_to_db(value: float) -> float:
	value = clamp(value, 0.0, 1.0)
	if value <= 0.001:
		return -80.0
	return linear_to_db(value)

## Chave de musica (MUSIC) do minigame; "loop_start" se a fase nao tiver musica propria.
func music_key_for_phase(phase_key: String) -> String:
	return str(PHASE_MUSIC.get(phase_key, "loop_start"))


func play_music(key: String, force_restart: bool = false) -> void:
	if not MUSIC.has(key):
		push_warning("Música não mapeada: %s" % key)
		return
	if current_music_key == key and music_player.playing and not force_restart:
		return

	var stream_resource: Resource = load(MUSIC[key])
	if stream_resource == null:
		push_warning("Arquivo de música não encontrado: %s" % MUSIC[key])
		return
	if not stream_resource is AudioStream:
		push_warning("Recurso carregado não é áudio: %s" % MUSIC[key])
		return

	var stream: AudioStream = stream_resource as AudioStream
	_enable_music_loop(stream)

	current_music_key = key
	music_player.stop()
	music_player.stream = stream
	apply_desvio_music_profile(key == "desvio_logico")
	music_player.play()


func _enable_music_loop(stream: AudioStream) -> void:
	# Garante loop infinito para músicas de menu e minigames.
	# Em Godot 4, OGG/MP3 normalmente expõem a propriedade `loop`,
	# enquanto WAV usa `loop_mode`. O projeto usa OGG nas músicas, mas
	# esta função mantém compatibilidade caso algum áudio mude depois.
	if stream == null:
		return
	for property: Dictionary in stream.get_property_list():
		var property_name: String = str(property.get("name", ""))
		if property_name == "loop":
			stream.set("loop", true)
			return
		if property_name == "loop_mode":
			stream.set("loop_mode", 1)
			return

func set_music_volume_offset_db(offset_db: float) -> void:
	music_volume_offset_db = offset_db
	_apply_volumes()


func clear_music_volume_offset() -> void:
	music_volume_offset_db = 0.0
	_apply_volumes()


func clear_music_duck() -> void:
	# Compatibilidade com versões anteriores do Desvio Lógico.
	# O refinamento atual não usa ducking forte; só reaplica o volume do perfil ativo.
	_apply_volumes()


func apply_desvio_music_profile(active: bool) -> void:
	desvio_music_profile_active = active
	if music_player == null:
		return
	# V0.13.9.6: perfil totalmente limpo. A música do Desvio Lógico volta ao Master
	# e qualquer bus/effect criado por versões anteriores é apenas limpo, sem ser usado.
	music_player.bus = MUSIC_BUS_MASTER
	_cleanup_desvio_music_bus_effects()
	music_volume_offset_db = DESVIO_MUSIC_VOLUME_OFFSET_DB if active else 0.0
	_apply_volumes()


func _cleanup_desvio_music_bus_effects() -> void:
	var bus_index: int = AudioServer.get_bus_index(DESVIO_MUSIC_BUS)
	if bus_index == -1:
		return
	AudioServer.set_bus_volume_db(bus_index, 0.0)
	AudioServer.set_bus_mute(bus_index, false)
	AudioServer.set_bus_bypass_effects(bus_index, true)
	while AudioServer.get_bus_effect_count(bus_index) > 0:
		AudioServer.remove_bus_effect(bus_index, 0)


func _set_effect_property_if_present(_effect: AudioEffect, _property_name: String, _value: Variant) -> void:
	# Mantido por compatibilidade com patches antigos, sem uso no perfil limpo.
	return


func stop_music() -> void:
	current_music_key = ""
	apply_desvio_music_profile(false)
	if music_player != null:
		music_player.stop()

func play_sfx(key: String) -> void:
	if not SFX.has(key):
		push_warning("Efeito sonoro não mapeado: %s" % key)
		return

	var stream = load(SFX[key])
	if stream == null:
		push_warning("Arquivo de efeito não encontrado: %s" % SFX[key])
		return

	var player := AudioStreamPlayer.new()
	player.name = "Sfx_%s" % key
	player.stream = stream
	if has_node("/root/SettingsManager"):
		player.volume_db = _volume_to_db(SettingsManager.get_sfx_volume())
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

func play_click() -> void:
	play_sfx("click")
