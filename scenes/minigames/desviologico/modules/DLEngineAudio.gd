extends RefCounted
class_name DLEngineAudio
## Audio do motor do Bionix (aceleracao e loop), bus de efeitos e perfil de musica do Desvio Logico.

var g: DesvioLogicoGame

func _init(game: DesvioLogicoGame) -> void:
	g = game

# ---- estado ----
var engine_acceleration_player: AudioStreamPlayer
var engine_loop_player: AudioStreamPlayer
var engine_acceleration_active: bool = false
var engine_loop_active: bool = false
var _duck_state: bool = false
var _ensure_next_ms: int = 0
var _last_sfx_volume: float = -1.0
var _fade_tween: Tween
## V0.14.6: ponto (s) para onde o loop volta. Os arquivos novos tem uma introducao curta
## e a emenda final ja e um crossfade com este ponto (sem queda para silencio).
const ENGINE_LOOP_RESTART_S: float = 0.12
const ENGINE_FADE_S: float = 0.18

func _configure_desvio_music_audio_profile() -> void:
	if not g.has_node("/root/AudioManager"):
		return
	if AudioManager.has_method("apply_desvio_music_profile"):
		AudioManager.apply_desvio_music_profile(true)
	if AudioManager.has_method("set_music_volume_offset_db"):
		AudioManager.set_music_volume_offset_db(DLConfig.DESVIO_MUSIC_VOLUME_DB)

func _clear_desvio_music_audio_profile() -> void:
	if not g.has_node("/root/AudioManager"):
		return
	if AudioManager.has_method("apply_desvio_music_profile"):
		AudioManager.apply_desvio_music_profile(false)
	elif AudioManager.has_method("clear_music_volume_offset"):
		AudioManager.clear_music_volume_offset()

func _build_engine_audio() -> void:
	# V0.13.8.10: o áudio do Bionix volta a ser local e obrigatório no minigame.
	# A V0.13.8.9 dependia do AudioManager para tocar os loops e, em algumas builds,
	# isso deixava o motor mudo. Agora o Desvio Lógico cria players próprios no Master.
	engine_acceleration_player = AudioStreamPlayer.new()
	engine_acceleration_player.name = "VeloxAccelerationPlayer"
	engine_acceleration_player.stream = _load_audio_stream(DLConfig.ENGINE_ACCELERATION_SOUND, true)
	_force_stream_playback(engine_acceleration_player)
	engine_acceleration_player.bus = _engine_audio_bus()
	engine_acceleration_player.volume_db = _engine_volume_db(DLConfig.ENGINE_ACCELERATION_VOLUME_DB)
	engine_acceleration_player.pitch_scale = _engine_acceleration_pitch()
	g.add_child(engine_acceleration_player)

	engine_loop_player = AudioStreamPlayer.new()
	engine_loop_player.name = "VeloxEngineLoopPlayer"
	engine_loop_player.stream = _load_audio_stream(DLConfig.ENGINE_LOOP_SOUND, true)
	_force_stream_playback(engine_loop_player)
	engine_loop_player.bus = _engine_audio_bus()
	engine_loop_player.volume_db = _engine_volume_db(DLConfig.ENGINE_LOOP_VOLUME_DB)
	engine_loop_player.pitch_scale = _engine_loop_pitch()
	g.add_child(engine_loop_player)

func _force_stream_playback(player: AudioStreamPlayer) -> void:
	# V0.14.6 (causa raiz do som cortado na web): no Godot 4.5 o modo "Sample" do navegador
	# (padrao na web) emula loop pelo evento 'ended' do WebAudio e RECRIA o buffer inteiro a cada
	# volta; alem disso, qualquer stream_paused=false reinicia o som do zero e deixa um
	# AudioBufferSourceNode orfao tocando. Loops do motor ficam em modo Stream (loop nativo do
	# engine, sem JavaScript por volta). Efeitos curtos continuam em Sample.
	if player == null:
		return
	player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM

func _load_audio_stream(path: String, loop_enabled: bool) -> AudioStream:
	var resource: Resource = load(path)
	if resource == null or not resource is AudioStream:
		push_warning("Áudio do Bionix não encontrado: %s" % path)
		return null
	var stream: AudioStream = resource as AudioStream
	_set_audio_stream_loop(stream, loop_enabled)
	if loop_enabled and "loop_offset" in stream:
		stream.set("loop_offset", ENGINE_LOOP_RESTART_S)
	return stream

func _set_audio_stream_loop(stream: AudioStream, loop_enabled: bool) -> void:
	if stream == null:
		return
	for property: Dictionary in stream.get_property_list():
		var property_name: String = str(property.get("name", ""))
		if property_name == "loop":
			stream.set("loop", loop_enabled)
			return
		if property_name == "loop_mode":
			stream.set("loop_mode", 1 if loop_enabled else 0)
			return

func _engine_audio_bus() -> StringName:
	# V0.14.1 (web): sem bus criado em tempo de execucao. O motor toca direto no Master.
	return &"Master"

func _engine_volume_db(base_db: float) -> float:
	# V0.13.9.3: motor limpo e perceptível; sem filtro que abafe o loop.
	var value: float = 1.0
	if g.has_node("/root/SettingsManager"):
		value = clampf(SettingsManager.get_sfx_volume(), 0.0, 1.0)
		if value <= 0.001:
			return -80.0
	return clampf(base_db + linear_to_db(value), -80.0, 0.0)

func _engine_loop_pitch() -> float:
	# V0.13.9.3: pitch controlado para manter variação sem distorcer o motor.
	match g.difficulty:
		"facil":
			return 0.96
		"normal":
			return 1.00
		"dificil":
			return 1.05
	return 1.0

func _engine_acceleration_pitch() -> float:
	match g.difficulty:
		"facil":
			return 0.98
		"normal":
			return 1.00
		"dificil":
			return 1.02
	return 1.0

func _set_engine_music_duck(active: bool) -> void:
	# V0.14.1: sem ducking e sem trabalho repetido. So age quando o estado muda.
	if active == _duck_state:
		return
	_duck_state = active
	if not g.has_node("/root/AudioManager"):
		return
	if active:
		_configure_desvio_music_audio_profile()
	else:
		AudioManager.clear_music_duck()

func _stop_audio_manager_engine_loops() -> void:
	# Limpa loops criados pela V0.13.8.9, mas não depende mais deles para tocar o motor.
	if not g.has_node("/root/AudioManager") or not AudioManager.has_method("stop_loop_sfx"):
		return
	AudioManager.stop_loop_sfx(DLConfig.ENGINE_ACCELERATION_LOOP_ID)
	AudioManager.stop_loop_sfx(DLConfig.ENGINE_LOOP_ID)

func _kill_fade() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = null

func _start_engine_acceleration_audio() -> void:
	_stop_engine_audio()
	engine_acceleration_active = true
	engine_loop_active = false
	_stop_audio_manager_engine_loops()
	_set_engine_music_duck(true)
	if engine_acceleration_player == null or engine_acceleration_player.stream == null:
		push_warning("Som de aceleração do Bionix não foi carregado.")
		return
	_last_sfx_volume = _current_sfx_volume()
	engine_acceleration_player.bus = _engine_audio_bus()
	engine_acceleration_player.volume_db = _engine_volume_db(DLConfig.ENGINE_ACCELERATION_VOLUME_DB)
	engine_acceleration_player.pitch_scale = _engine_acceleration_pitch()
	engine_acceleration_player.play()

func _start_engine_loop_audio() -> void:
	# Passagem aceleracao -> loop com crossfade curto (antes: stop()+play() = buraco e clique).
	engine_acceleration_active = false
	engine_loop_active = true
	_stop_audio_manager_engine_loops()
	_set_engine_music_duck(true)
	if engine_loop_player == null or engine_loop_player.stream == null:
		push_warning("Som de loop do motor do Bionix não foi carregado.")
		if engine_acceleration_player != null:
			engine_acceleration_player.stop()
		return
	_kill_fade()
	_last_sfx_volume = _current_sfx_volume()
	var loop_db: float = _engine_volume_db(DLConfig.ENGINE_LOOP_VOLUME_DB)
	engine_loop_player.bus = _engine_audio_bus()
	engine_loop_player.pitch_scale = _engine_loop_pitch()
	var accel_playing: bool = engine_acceleration_player != null and engine_acceleration_player.playing
	if accel_playing and loop_db > -60.0:
		engine_loop_player.volume_db = -60.0
		engine_loop_player.play()
		var accel_player: AudioStreamPlayer = engine_acceleration_player
		_fade_tween = g.create_tween()
		_fade_tween.set_parallel(true)
		_fade_tween.tween_property(engine_loop_player, "volume_db", loop_db, ENGINE_FADE_S)
		_fade_tween.tween_property(accel_player, "volume_db", -60.0, ENGINE_FADE_S)
		_fade_tween.chain().tween_callback(accel_player.stop)
	else:
		if engine_acceleration_player != null:
			engine_acceleration_player.stop()
		engine_loop_player.volume_db = loop_db
		engine_loop_player.play()

func _stop_engine_audio() -> void:
	engine_acceleration_active = false
	engine_loop_active = false
	_stop_audio_manager_engine_loops()
	_set_engine_music_duck(false)
	_kill_fade()
	if engine_acceleration_player != null:
		engine_acceleration_player.stop()
	if engine_loop_player != null:
		engine_loop_player.stop()

func _set_engine_audio_paused(paused: bool) -> void:
	_stop_audio_manager_engine_loops()
	# So escreve stream_paused quando o valor realmente muda (ver _force_stream_playback).
	for player: AudioStreamPlayer in [engine_acceleration_player, engine_loop_player]:
		if player != null and player.playing and player.stream_paused != paused:
			player.stream_paused = paused
	if _fade_tween != null and _fade_tween.is_valid():
		if paused:
			_fade_tween.pause()
		else:
			_fade_tween.play()
	if paused:
		_set_engine_music_duck(false)
	elif engine_acceleration_active or engine_loop_active:
		_set_engine_music_duck(true)

func _current_sfx_volume() -> float:
	if g.has_node("/root/SettingsManager"):
		return clampf(SettingsManager.get_sfx_volume(), 0.0, 1.0)
	return 1.0

func _ensure_engine_audio_state() -> void:
	if g.gameplay_paused:
		return
	# 4x por segundo. V0.14.6: NAO reescreve volume/pitch/stream_paused a cada checagem.
	# Antes, stream_paused=false a cada 250 ms reiniciava o som do zero na web.
	var now_ms: int = Time.get_ticks_msec()
	if now_ms < _ensure_next_ms:
		return
	_ensure_next_ms = now_ms + 250
	if g.state == DLConfig.STATE_ACCELERATION and engine_acceleration_active:
		_set_engine_music_duck(true)
		_refresh_engine_player(engine_acceleration_player, DLConfig.ENGINE_ACCELERATION_VOLUME_DB, true)
	elif g.state == DLConfig.STATE_DRIVE and engine_loop_active:
		_set_engine_music_duck(true)
		_refresh_engine_player(engine_loop_player, DLConfig.ENGINE_LOOP_VOLUME_DB, false)
	else:
		_set_engine_music_duck(false)

func _refresh_engine_player(player: AudioStreamPlayer, base_db: float, is_accel: bool) -> void:
	if player == null or player.stream == null:
		return
	if not player.playing:
		player.volume_db = _engine_volume_db(base_db)
		player.pitch_scale = _engine_acceleration_pitch() if is_accel else _engine_loop_pitch()
		if player.stream_paused:
			player.stream_paused = false
		player.play()
		return
	# Volume so muda se o ajuste de SFX mudou (e nunca durante o crossfade).
	var sfx: float = _current_sfx_volume()
	if not is_equal_approx(sfx, _last_sfx_volume) and (_fade_tween == null or not _fade_tween.is_valid()):
		_last_sfx_volume = sfx
		player.volume_db = _engine_volume_db(base_db)
