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
	"conquista": Paths.SFX_ACHIEVEMENT,
	"porta": Paths.SFX_DOOR
}

# V0.14.1 (web): UM unico player de musica, pool fixo de efeitos (sem criar/liberar nos a cada som),
# cache de streams, NENHUMA chamada ao AudioServer em loop e nenhum bus criado em tempo de execucao.
# A musica do Desvio Logico e as dos outros jogos passam pelo mesmo caminho (Master): nao existe mais
# "perfil" que possa derrubar as demais. Um watchdog religa a musica se o navegador a interromper.
const DESVIO_MUSIC_VOLUME_OFFSET_DB := 0.0
const SFX_POOL_SIZE := 8
const WATCHDOG_INTERVAL := 0.75
const WATCHDOG_MAX_RESTARTS := 8

var music_player: AudioStreamPlayer
var current_music_key: String = ""
var music_volume_offset_db: float = 0.0
var desvio_music_profile_active: bool = false

var _wants_music: bool = false
var _suspended: bool = false
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_cache: Dictionary = {}
var _sfx_next: int = 0
var _watchdog_timer: float = 0.0
var _watchdog_restarts: int = 0
var _last_music_db: float = 999.0
var _tempo_target: float = 1.0
var _tempo_speed: float = 0.0  # variacao de pitch_scale por segundo

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	add_child(music_player)
	for i in range(SFX_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.name = "SfxPool_%d" % i
		# Cliques precisam soar tambem com o jogo pausado.
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(player)
		_sfx_pool.append(player)
	_apply_volumes()
	if has_node("/root/SettingsManager"):
		SettingsManager.settings_changed.connect(_on_settings_changed)

func _process(delta: float) -> void:
	_update_tempo(delta)
	# Watchdog: se a musica deveria estar tocando e parou (web/aba/contexto de audio), religa.
	_watchdog_timer += delta
	if _watchdog_timer < WATCHDOG_INTERVAL:
		return
	_watchdog_timer = 0.0
	if not _wants_music or _suspended or get_tree().paused or music_player.stream == null:
		return
	if music_player.playing:
		_watchdog_restarts = 0
		return
	if _watchdog_restarts >= WATCHDOG_MAX_RESTARTS:
		return
	_watchdog_restarts += 1
	music_player.stream_paused = false
	music_player.play()

func _on_settings_changed(_settings: Dictionary) -> void:
	_apply_volumes()

func _apply_volumes() -> void:
	if music_player == null:
		return
	var base_volume_db: float = 0.0
	if has_node("/root/SettingsManager"):
		base_volume_db = _volume_to_db(SettingsManager.get_music_volume())
	var target: float = clampf(base_volume_db + music_volume_offset_db, -80.0, 6.0)
	if is_equal_approx(target, _last_music_db):
		return
	_last_music_db = target
	music_player.volume_db = target

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
	_wants_music = true
	if current_music_key == key and music_player.playing and not force_restart:
		return
	var stream_resource: Resource = load(MUSIC[key])
	if stream_resource == null or not stream_resource is AudioStream:
		push_warning("Arquivo de música inválido: %s" % MUSIC[key])
		return
	var stream: AudioStream = stream_resource as AudioStream
	_enable_music_loop(stream)
	current_music_key = key
	_watchdog_restarts = 0
	music_player.stop()
	music_player.stream_paused = false
	music_player.stream = stream
	if not is_equal_approx(music_player.pitch_scale, 1.0) or not is_equal_approx(_tempo_target, 1.0):
		set_music_tempo(1.0, 0.0)
	apply_desvio_music_profile(key == "desvio_logico")
	music_player.play()

func _enable_music_loop(stream: AudioStream) -> void:
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	elif stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD

## Ritmo da musica (1.0 = normal). Troca de forma suave em glide_seconds. Em Godot o pitch_scale muda
## velocidade e tom juntos; com passos pequenos (ate ~1.12) soa como "musica mais animada".
func set_music_tempo(scale: float, glide_seconds: float = 2.0) -> void:
	_tempo_target = clampf(scale, 0.5, 1.5)
	if glide_seconds <= 0.01 or music_player == null:
		_tempo_speed = 0.0
		if music_player != null:
			music_player.pitch_scale = _tempo_target
		return
	_tempo_speed = absf(_tempo_target - music_player.pitch_scale) / glide_seconds

func _update_tempo(delta: float) -> void:
	if music_player == null or _tempo_speed <= 0.0:
		return
	music_player.pitch_scale = move_toward(music_player.pitch_scale, _tempo_target, _tempo_speed * delta)
	if is_equal_approx(music_player.pitch_scale, _tempo_target):
		music_player.pitch_scale = _tempo_target
		_tempo_speed = 0.0

func set_music_volume_offset_db(offset_db: float) -> void:
	if is_equal_approx(offset_db, music_volume_offset_db):
		return
	music_volume_offset_db = offset_db
	_apply_volumes()

func clear_music_volume_offset() -> void:
	set_music_volume_offset_db(0.0)

func clear_music_duck() -> void:
	# Compatibilidade: sem ducking. So reaplica o volume atual (barato, so age se mudou).
	_apply_volumes()

## Compatibilidade com o Desvio Logico: agora so ajusta o offset de volume (sem bus, sem AudioServer).
func apply_desvio_music_profile(active: bool) -> void:
	desvio_music_profile_active = active
	set_music_volume_offset_db(DESVIO_MUSIC_VOLUME_OFFSET_DB if active else 0.0)

## Compatibilidade (loops antigos de motor): nao ha mais loops no AudioManager.
func stop_loop_sfx(_loop_id: String) -> void:
	return

func stop_music() -> void:
	_wants_music = false
	set_music_tempo(1.0, 0.0)
	current_music_key = ""
	apply_desvio_music_profile(false)
	if music_player != null:
		music_player.stop()

func stop_all_sfx() -> void:
	for player in _sfx_pool:
		player.stop()

## Aba escondida / pagina fechando (WebBridge): pausa e retoma a musica sem perder a posicao.
func set_suspended(value: bool) -> void:
	_suspended = value
	if music_player != null:
		music_player.stream_paused = value
	if not value:
		_watchdog_timer = WATCHDOG_INTERVAL

func play_sfx(key: String) -> void:
	if _suspended:
		return
	if not SFX.has(key):
		push_warning("Efeito sonoro não mapeado: %s" % key)
		return
	var stream: AudioStream = _sfx_cache.get(key, null) as AudioStream
	if stream == null:
		stream = load(SFX[key]) as AudioStream
		if stream == null:
			push_warning("Arquivo de efeito não encontrado: %s" % SFX[key])
			return
		_sfx_cache[key] = stream
	var player: AudioStreamPlayer = _next_sfx_player()
	player.stream = stream
	if has_node("/root/SettingsManager"):
		player.volume_db = _volume_to_db(SettingsManager.get_sfx_volume())
	player.play()

func _next_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_pool:
		if not player.playing:
			return player
	var chosen: AudioStreamPlayer = _sfx_pool[_sfx_next]
	_sfx_next = (_sfx_next + 1) % _sfx_pool.size()
	return chosen

func play_click() -> void:
	play_sfx("click")
