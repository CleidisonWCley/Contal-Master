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
	engine_acceleration_player.bus = _engine_audio_bus()
	engine_acceleration_player.volume_db = _engine_volume_db(DLConfig.ENGINE_ACCELERATION_VOLUME_DB)
	engine_acceleration_player.pitch_scale = _engine_acceleration_pitch()
	engine_acceleration_player.finished.connect(_on_engine_acceleration_finished)
	g.add_child(engine_acceleration_player)

	engine_loop_player = AudioStreamPlayer.new()
	engine_loop_player.name = "VeloxEngineLoopPlayer"
	engine_loop_player.stream = _load_audio_stream(DLConfig.ENGINE_LOOP_SOUND, true)
	engine_loop_player.bus = _engine_audio_bus()
	engine_loop_player.volume_db = _engine_volume_db(DLConfig.ENGINE_LOOP_VOLUME_DB)
	engine_loop_player.pitch_scale = _engine_loop_pitch()
	engine_loop_player.finished.connect(_on_engine_loop_finished)
	g.add_child(engine_loop_player)

func _load_audio_stream(path: String, loop_enabled: bool) -> AudioStream:
	var resource: Resource = load(path)
	if resource == null or not resource is AudioStream:
		push_warning("Áudio do Bionix não encontrado: %s" % path)
		return null
	var stream: AudioStream = resource as AudioStream
	_set_audio_stream_loop(stream, loop_enabled)
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

func _start_engine_acceleration_audio() -> void:
	_stop_engine_audio()
	engine_acceleration_active = true
	engine_loop_active = false
	_stop_audio_manager_engine_loops()
	_set_engine_music_duck(true)
	if engine_loop_player != null:
		engine_loop_player.stop()
	if engine_acceleration_player == null or engine_acceleration_player.stream == null:
		push_warning("Som de aceleração do Bionix não foi carregado.")
		return
	engine_acceleration_player.bus = _engine_audio_bus()
	engine_acceleration_player.volume_db = _engine_volume_db(DLConfig.ENGINE_ACCELERATION_VOLUME_DB)
	engine_acceleration_player.pitch_scale = _engine_acceleration_pitch()
	engine_acceleration_player.stream_paused = false
	engine_acceleration_player.stop()
	engine_acceleration_player.play()

func _start_engine_loop_audio() -> void:
	engine_acceleration_active = false
	engine_loop_active = true
	_stop_audio_manager_engine_loops()
	_set_engine_music_duck(true)
	if engine_acceleration_player != null:
		engine_acceleration_player.stop()
	if engine_loop_player == null or engine_loop_player.stream == null:
		push_warning("Som de loop do motor do Bionix não foi carregado.")
		return
	engine_loop_player.bus = _engine_audio_bus()
	engine_loop_player.volume_db = _engine_volume_db(DLConfig.ENGINE_LOOP_VOLUME_DB)
	engine_loop_player.pitch_scale = _engine_loop_pitch()
	engine_loop_player.stream_paused = false
	engine_loop_player.stop()
	engine_loop_player.play()

func _stop_engine_audio() -> void:
	engine_acceleration_active = false
	engine_loop_active = false
	_stop_audio_manager_engine_loops()
	_set_engine_music_duck(false)
	if engine_acceleration_player != null:
		engine_acceleration_player.stop()
	if engine_loop_player != null:
		engine_loop_player.stop()

func _set_engine_audio_paused(paused: bool) -> void:
	_stop_audio_manager_engine_loops()
	if engine_acceleration_player != null and engine_acceleration_player.playing:
		engine_acceleration_player.stream_paused = paused
	if engine_loop_player != null and engine_loop_player.playing:
		engine_loop_player.stream_paused = paused
	if paused:
		_set_engine_music_duck(false)
	elif engine_acceleration_active or engine_loop_active:
		_set_engine_music_duck(true)

func _ensure_engine_audio_state() -> void:
	if g.gameplay_paused:
		return
	# V0.14.1: era chamado todo frame. Basta checar 4x por segundo (so religa player parado).
	var now_ms: int = Time.get_ticks_msec()
	if now_ms < _ensure_next_ms:
		return
	_ensure_next_ms = now_ms + 250
	if g.state == DLConfig.STATE_ACCELERATION and engine_acceleration_active:
		_set_engine_music_duck(true)
		if engine_acceleration_player != null and engine_acceleration_player.stream != null:
			engine_acceleration_player.volume_db = _engine_volume_db(DLConfig.ENGINE_ACCELERATION_VOLUME_DB)
			engine_acceleration_player.pitch_scale = _engine_acceleration_pitch()
			engine_acceleration_player.stream_paused = false
			if not engine_acceleration_player.playing:
				engine_acceleration_player.play()
	elif g.state == DLConfig.STATE_DRIVE and engine_loop_active:
		_set_engine_music_duck(true)
		if engine_loop_player != null and engine_loop_player.stream != null:
			engine_loop_player.volume_db = _engine_volume_db(DLConfig.ENGINE_LOOP_VOLUME_DB)
			engine_loop_player.pitch_scale = _engine_loop_pitch()
			engine_loop_player.stream_paused = false
			if not engine_loop_player.playing:
				engine_loop_player.play()
	else:
		_set_engine_music_duck(false)

func _on_engine_acceleration_finished() -> void:
	if engine_acceleration_active and g.state == DLConfig.STATE_ACCELERATION and not g.gameplay_paused and engine_acceleration_player != null:
		engine_acceleration_player.play()

func _on_engine_loop_finished() -> void:
	if engine_loop_active and g.state == DLConfig.STATE_DRIVE and not g.gameplay_paused and engine_loop_player != null:
		engine_loop_player.play()
