extends RefCounted
class_name DLTraffic
## Trafego de NPCs (V0.16.13): DIRETOR DINAMICO. Substitui as ondas fixas por sacolas de padroes.
## - Ondas de 1 ou 2 carros (nunca 3). Faixa escolhida por sorteio PONDERADO, sem padrao decoravel:
##   puxa para a faixa onde o jogador esta (mais ainda quanto mais tempo ele fica parado nela) e para a faixa que esta ha mais tempo sem carro.
## - Garantia: nenhuma faixa passa DIRECTOR_MAX_LANE_GAP segundos sem receber carro (o jogador sempre tem o que desviar dos dois lados).
## - Folga do jogador por TEMPO (nao por distancia): o NPC so nasce se levar >= SPAWN_MIN_REACTION_SECONDS ate o carro. Isso vale com o Bionix
##   alto na pista (antes a regra por distancia bloqueava todo spawn depois de ~38% do percurso).
## - Prazo final por simulacao: o NPC so nasce se, andando com a desaceleracao final, sair de vista antes da parada (e passar do carro antes da centralizacao).

var g: DesvioLogicoGame

func _init(game: DesvioLogicoGame) -> void:
	g = game

# ---- estado ----
var next_spawn_time: float = 0.0
var last_spawn_lane: int = DLConfig.LANE_LEFT
var traffic_safe_opening_done: bool = false
var traffic_opening_step: int = 0
var opening_first_lane: int = DLConfig.LANE_RIGHT
var traffic_combo_queue: Array = []
var last_npc_sprite_path: String = ""
var lane_last_spawn: Dictionary = {}     # faixa -> drive_elapsed do ultimo nascimento
var _tracked_lane: int = DLConfig.LANE_CENTER
var player_lane_since: float = 0.0
var pending_lane: int = -1               # faixa sorteada da onda atual: fica ate o carro nascer (senao cada nova tentativa re-sorteia e so a faixa livre vence)
var pending_forced: bool = false
var pending_since: float = 0.0
var lane_streak: int = 0                 # ondas seguidas na mesma faixa
var pick_forced: bool = false             # a ultima faixa escolhida veio da garantia anti-seca
var spawn_log: Array = []                # {t, lane, count} (so para teste/diagnostico; limitado)

func _reset_traffic_wave_distribution() -> void:
	last_spawn_lane = DLConfig.LANE_LEFT
	traffic_safe_opening_done = false
	traffic_opening_step = 0
	opening_first_lane = DLConfig.LANE_RIGHT if randf() < 0.5 else DLConfig.LANE_LEFT
	traffic_combo_queue.clear()
	lane_last_spawn = {DLConfig.LANE_LEFT: 0.0, DLConfig.LANE_RIGHT: 0.0}
	lane_streak = 0
	pending_lane = -1
	pending_forced = false
	_tracked_lane = DLConfig.LANE_CENTER
	player_lane_since = 0.0
	spawn_log.clear()

# ---- quando pode nascer ----
func _can_spawn_new_traffic() -> bool:
	if g.state != DLConfig.STATE_DRIVE:
		return false
	return g.drive_elapsed < g._drive_duration() - 1.0

## Simula o NPC andando (com a desaceleracao final) e diz se ele passa do carro e sai de vista a tempo.
func _npc_schedule_ok(spawn_y: float, speed_mult: float) -> bool:
	var duration: float = g._drive_duration()
	var viewport_height: float = maxf(g.STAGE_SIZE.y, 720.0)
	var car_pass_y: float = _player_current_center_y() + 70.0
	var center_blend_t: float = DLConfig.CAR_DECISION_CENTER_BLEND_START_BY_DIFFICULTY.get(g.difficulty, 0.90) * duration
	var speed: float = _npc_planning_speed() * speed_mult * 0.96   # 4% mais lento que o tipico: o sorteio de velocidade do NPC e -3..+4
	var y: float = spawn_y
	var t: float = g.drive_elapsed
	var passed_car: bool = false
	while t < duration + 0.5:
		var ratio: float = g._final_deceleration_ratio(clampf(t / maxf(duration, 1.0), 0.0, 1.0))
		y += speed * lerpf(0.28, 0.82, g._depth_t(y)) * ratio * 0.05
		t += 0.05
		if not passed_car and y >= car_pass_y:
			passed_car = true
			if t > center_blend_t:
				return false
		if y > viewport_height + 185.0:
			return passed_car and t <= duration - DLConfig.DIRECTOR_EXIT_MARGIN_SECONDS
	return false

## Tempo (s) que um NPC recem-nascido leva para andar `px` pixels (mundo a 100% de movimento).
func _time_to_travel(px: float) -> float:
	var speed: float = _npc_planning_speed()
	var y: float = g._obstacle_spawn_y()
	var y_end: float = y + px
	var t: float = 0.0
	while y < y_end and t < 10.0:
		y += speed * lerpf(0.28, 0.82, g._depth_t(y)) * 0.02
		t += 0.02
	return t

func _npc_planning_speed() -> float:
	# velocidade tipica do NPC (sem o sorteio de -3..+4), usada so nas previsoes
	var round_bonus: float = float(g.current_round) * (2.8 if g.difficulty == "facil" else 4.2)
	return float(g._rules().get("npc_speed", 58.0)) + round_bonus

## Tempo (s) que um NPC recem-nascido leva ate o centro do Bionix, com o mundo a 100% de movimento.
func _npc_time_to_player(spawn_y: float, speed_mult: float) -> float:
	var target_y: float = _player_current_center_y()
	var speed: float = _npc_planning_speed() * speed_mult
	var y: float = spawn_y
	var t: float = 0.0
	while y < target_y and t < 20.0:
		y += speed * lerpf(0.28, 0.82, g._depth_t(y)) * 0.02
		t += 0.02
	return t

func _spawn_has_player_clearance(lane: int, spawn_y: float, speed_mult: float = 1.0) -> bool:
	var need: float = float(DLConfig.SPAWN_MIN_REACTION_SECONDS.get(g.difficulty, 0.9))
	if lane != g.current_lane:
		need *= DLConfig.SPAWN_OTHER_LANE_REACTION_FACTOR
	return _npc_time_to_player(spawn_y, speed_mult) >= need

func _can_spawn_at_lane(lane: int, spawn_y: float, speed_mult: float = 1.0) -> bool:
	var viewport_height: float = maxf(g.STAGE_SIZE.y, 720.0)
	var same_lane_min: float = viewport_height * _same_lane_spacing_ratio()
	var cross_lane_min: float = viewport_height * _cross_lane_spacing_ratio()
	if not _spawn_has_player_clearance(lane, spawn_y, speed_mult):
		return false
	if not _npc_schedule_ok(spawn_y, speed_mult):
		return false
	for data in g.obstacle_data:
		if bool(data.get("preview_only", false)):
			continue
		var node: Control = data.get("node", null)
		if node == null or not is_instance_valid(node):
			continue
		var existing_y: float = float(data.get("y", 0.0))
		var existing_lane: int = int(data.get("lane", DLConfig.LANE_RIGHT))
		var distance_y: float = absf(existing_y - spawn_y)
		if existing_lane == lane and distance_y < same_lane_min:
			return false
		if existing_lane != lane and distance_y < cross_lane_min:
			return false
		if existing_lane != lane and existing_y >= viewport_height * _opposite_critical_start_ratio() and existing_y <= viewport_height * 0.90:
			return false
	return true

# ---- diretor: onda, faixa e intervalo ----
func _track_player_lane() -> void:
	if g.current_lane != _tracked_lane:
		_tracked_lane = g.current_lane
		player_lane_since = g.drive_elapsed

func _lane_idle_seconds(lane: int) -> float:
	return g.drive_elapsed - float(lane_last_spawn.get(lane, 0.0))

func _director_wave_size() -> int:
	if not traffic_safe_opening_done:
		return 1
	if g._route_progress_ratio() < _traffic_pair_min_progress():
		return 1
	var idx: int = DLConfig.traffic_index(g.current_round)
	var chance: float = float(DLConfig.DIRECTOR_PAIR_CHANCE_BY_ROUND[idx]) * float(DLConfig.DIRECTOR_PAIR_DIFFICULTY_MULT.get(g.difficulty, 1.0))
	return 2 if randf() < clampf(chance, 0.0, 0.85) else 1

func _director_pick_lane() -> int:
	pick_forced = false
	if not traffic_safe_opening_done:
		return opening_first_lane if traffic_opening_step <= 0 else _other_lane(opening_first_lane)
	var gap_max: float = float(DLConfig.DIRECTOR_MAX_LANE_GAP.get(g.difficulty, 3.0))
	# a garantia dispara um intervalo medio ANTES do limite, porque a proxima onda ainda leva esse tempo para sair
	var wait_estimate: float = float(DLConfig.DIRECTOR_INTERVAL.get(g.difficulty, 1.5)) * float(DLConfig.DIRECTOR_INTERVAL_ROUND_MULT[DLConfig.traffic_index(g.current_round)])
	var trigger: float = maxf(gap_max - wait_estimate, gap_max * 0.4)
	var left_idle: float = _lane_idle_seconds(DLConfig.LANE_LEFT)
	var right_idle: float = _lane_idle_seconds(DLConfig.LANE_RIGHT)
	if left_idle >= trigger or right_idle >= trigger:
		pick_forced = true
		if left_idle >= trigger and right_idle >= trigger:
			return g.current_lane if g.current_lane == DLConfig.LANE_LEFT or g.current_lane == DLConfig.LANE_RIGHT else (DLConfig.LANE_LEFT if randf() < 0.5 else DLConfig.LANE_RIGHT)
		return DLConfig.LANE_LEFT if left_idle >= trigger else DLConfig.LANE_RIGHT
	var w_left: float = 1.0 + clampf(left_idle / gap_max, 0.0, 1.5) * DLConfig.DIRECTOR_IDLE_WEIGHT
	var w_right: float = 1.0 + clampf(right_idle / gap_max, 0.0, 1.5) * DLConfig.DIRECTOR_IDLE_WEIGHT
	if g.current_lane == DLConfig.LANE_LEFT or g.current_lane == DLConfig.LANE_RIGHT:
		var dwell: float = clampf((g.drive_elapsed - player_lane_since) / DLConfig.DIRECTOR_DWELL_FULL_SECONDS, 0.0, 1.0)
		var bonus: float = DLConfig.DIRECTOR_PLAYER_LANE_BIAS + dwell * DLConfig.DIRECTOR_DWELL_BIAS
		if g.current_lane == DLConfig.LANE_LEFT:
			w_left += bonus
		else:
			w_right += bonus
	# fila longa numa faixa so: depois de N ondas seguidas na mesma faixa, a proxima vai para a outra
	if lane_streak >= DLConfig.DIRECTOR_MAX_SAME_LANE_STREAK:
		pick_forced = true
		return _other_lane(last_spawn_lane)
	return DLConfig.LANE_LEFT if randf() * (w_left + w_right) < w_left else DLConfig.LANE_RIGHT

func _spawn_obstacle() -> bool:
	if not _can_spawn_new_traffic():
		return false
	if not traffic_combo_queue.is_empty():
		return false
	var available_slots: int = _max_active_npcs() - _active_threat_count()
	if available_slots <= 0 or _visible_npc_count() >= DLConfig.DIRECTOR_MAX_VISIBLE_NPCS:
		return false
	var count: int = mini(_director_wave_size(), mini(available_slots, 2))
	if pending_lane < 0:
		pending_lane = _director_pick_lane()
		pending_forced = pick_forced
		pending_since = g.drive_elapsed
	var first_lane: int = pending_lane
	var was_opening: bool = not traffic_safe_opening_done
	var speed_mult: float = _initial_safe_car_speed_multiplier() if was_opening else 1.0
	var spawn_y: float = g._obstacle_spawn_y()
	var lane_used: int = -1
	var candidates: Array = [first_lane]
	# A faixa sorteada espera a vez (o spawn e tentado de novo a cada ~0.2 s) em vez de ceder o carro a outra faixa. Se cedesse, o espacamento
	# minimo (um carro recem-nascido ainda esta perto do ponto de spawn) fazia as faixas se alternarem sempre: L R L R... facil de decorar.
	# So depois de esperar demais (alem do limite da faixa + paciencia) o carro vai para a outra faixa.
	if g.drive_elapsed - pending_since > DLConfig.DIRECTOR_FORCED_PATIENCE_SECONDS and not was_opening:
		candidates.append(_other_lane(first_lane))
	for lane in candidates:
		if _can_spawn_at_lane(int(lane), spawn_y, speed_mult):
			lane_used = int(lane)
			break
	if lane_used < 0:
		return false
	pending_lane = -1
	_spawn_npc_at(lane_used, spawn_y, was_opening, speed_mult)
	if was_opening:
		traffic_opening_step += 1
		traffic_safe_opening_done = traffic_opening_step >= 2
	elif count >= 2:
		_queue_wave_tail(lane_used)
	_log_spawn(lane_used, count)
	return true

func _queue_wave_tail(first_lane: int) -> void:
	traffic_combo_queue.clear()
	# 2o carro: normalmente na faixa oposta (o jogador precisa trocar), as vezes na mesma (sequencia na mesma faixa)
	var second_lane: int = _other_lane(first_lane) if randf() < DLConfig.DIRECTOR_PAIR_OPPOSITE_CHANCE else first_lane
	# a dupla so e escapavel se o 2o carro nasce quando o 1o ja andou o espacamento minimo (senao o spawn e recusado e a dupla some)
	var viewport_height: float = maxf(g.STAGE_SIZE.y, 720.0)
	var spacing_px: float = viewport_height * (_same_lane_spacing_ratio() if second_lane == first_lane else _cross_lane_spacing_ratio()) + 14.0
	var delay: float = maxf(_traffic_wave_combo_delay(2) * 0.9, _time_to_travel(spacing_px)) + randf_range(0.0, 0.30)
	traffic_combo_queue.append({
		"lane": second_lane,
		"spawn_at": g.drive_elapsed + delay,
		"speed_multiplier": 1.0 + _combo_speed_step(2),
		"attempts": 0,
		"count": 2
	})

func _update_pending_combo_spawns() -> void:
	_track_player_lane()
	if traffic_combo_queue.is_empty():
		return
	if not _can_spawn_new_traffic():
		traffic_combo_queue.clear()
		return
	var pending: Dictionary = traffic_combo_queue[0]
	if g.drive_elapsed < float(pending.get("spawn_at", g.drive_elapsed)):
		return
	if _active_threat_count() >= _max_active_npcs():
		pending["spawn_at"] = g.drive_elapsed + _traffic_wave_combo_retry_delay()
		pending["attempts"] = int(pending.get("attempts", 0)) + 1
		traffic_combo_queue[0] = pending
		return
	var lane: int = int(pending.get("lane", DLConfig.LANE_RIGHT))
	var mult: float = float(pending.get("speed_multiplier", 1.0))
	var spawn_y: float = g._obstacle_spawn_y()
	if _can_spawn_at_lane(lane, spawn_y, mult):
		_spawn_npc_at(lane, spawn_y, false, mult)
		traffic_combo_queue.clear()
		# depois da dupla, respira um pouco antes da proxima onda
		next_spawn_time = maxf(next_spawn_time, g.drive_elapsed + _spawn_interval() * 0.55)
		return
	pending["attempts"] = int(pending.get("attempts", 0)) + 1
	if int(pending.get("attempts", 0)) >= _traffic_wave_combo_max_attempts():
		traffic_combo_queue.clear()
	else:
		pending["spawn_at"] = g.drive_elapsed + _traffic_wave_combo_retry_delay()
		traffic_combo_queue[0] = pending

func _log_spawn(lane: int, count: int) -> void:
	if spawn_log.size() < 200:
		spawn_log.append({"t": snappedf(g.drive_elapsed, 0.01), "lane": lane, "count": count})

## Intervalo ate a proxima onda: curto (mais carros), encolhe a cada horario e sempre sorteado (sem ritmo fixo para decorar).
func _spawn_interval() -> float:
	var idx: int = DLConfig.traffic_index(g.current_round)
	var base: float = float(DLConfig.DIRECTOR_INTERVAL.get(g.difficulty, 1.5)) * float(DLConfig.DIRECTOR_INTERVAL_ROUND_MULT[idx])
	return base * randf_range(0.78, 1.30)

func _spawn_npc_at(lane: int, y: float, initial_traffic: bool = false, speed_multiplier: float = 1.0) -> void:
	lane_last_spawn[lane] = g.drive_elapsed
	lane_streak = (lane_streak + 1) if lane == last_spawn_lane else 1
	last_spawn_lane = lane
	# V0.13.5: NPCs podem nascer em padrões de tráfego, mas sempre com brecha de escape.
	var base_size: Vector2 = Vector2(180, 130) * (1.0 + float(g.current_round) * 0.010)
	var node: Control = _make_npc_obstacle(base_size)
	var scale_factor: float = g._perspective_scale(y)
	var obstacle_size: Vector2 = base_size * scale_factor
	node.size = obstacle_size
	node.custom_minimum_size = obstacle_size
	node.position = g._obstacle_position(lane, y, obstacle_size)
	node.modulate = Color(1.0, 1.0, 1.0, 0.66 if initial_traffic else 0.50)
	g.obstacles_layer.add_child(node)
	var viewport_height: float = maxf(g.STAGE_SIZE.y, 720.0)
	g.obstacle_data.append({
		"node": node,
		"lane": lane,
		"y": y,
		"base_size": base_size,
		"speed": g._obstacle_speed() * (0.82 if initial_traffic else speed_multiplier),
		"hit": false,
		"grace": DLConfig.NPC_INITIAL_DAMAGE_GRACE_SECONDS if initial_traffic else DLConfig.TRAFFIC_WAVE_SPAWN_GRACE_SECONDS,
		"collision_y": viewport_height * 0.805,
		"preview_only": false,
		"initial_traffic": initial_traffic,
		"kind": "npc"
	})

func _final_spawn_cutoff_progress() -> float:
	return float(DLConfig.NPC_FINAL_SPAWN_CUTOFF_PROGRESS.get(g.difficulty, 0.90))

func _final_spawn_cutoff_seconds() -> float:
	return float(DLConfig.NPC_FINAL_SPAWN_CUTOFF_SECONDS.get(g.difficulty, 3.5))

func _traffic_pair_min_progress() -> float:
	match g.difficulty:
		"facil":
			return 0.24
		"normal":
			return 0.20
		"dificil":
			return 0.16
	return 0.22

func _traffic_wave_combo_delay(count: int) -> float:
	return _traffic_wave_combo_delay_base(count) * float(DLConfig.TRAFFIC_COMBO_DELAY_MULT[DLConfig.traffic_index(g.current_round)])

func _traffic_wave_combo_delay_base(count: int) -> float:
	# V0.13.13.2: espaçamento vertical maior dentro da onda.
	# A dificuldade vem da frequência e da leitura menor, não de spawn impossível.
	match g.difficulty:
		"facil":
			return 1.34 if count >= 3 else 1.42
		"normal":
			return 1.18 if count >= 3 else 1.24
		"dificil":
			return 0.96 if count >= 3 else 1.04
	return 1.24

func _traffic_wave_combo_retry_delay() -> float:
	match g.difficulty:
		"facil":
			return 0.22
		"normal":
			return 0.18
		"dificil":
			return 0.15
	return 0.18

func _traffic_wave_combo_max_attempts() -> int:
	match g.difficulty:
		"facil":
			return 9
		"normal":
			return 7
		"dificil":
			return 6
	return 7

func _combo_speed_step(count: int) -> float:
	# Mantém a leitura do combo: os carros não aceleram a ponto de fechar a curva.
	if g.difficulty == "dificil":
		return 0.018 if count >= 3 else 0.014
	if g.difficulty == "normal":
		return 0.012
	return 0.010

func _other_lane(lane: int) -> int:
	return DLConfig.LANE_RIGHT if lane == DLConfig.LANE_LEFT else DLConfig.LANE_LEFT

func _max_active_npcs() -> int:
	# V0.14.1: horarios mais tardios permitem mais carros ao mesmo tempo (com teto por dificuldade).
	var base: int = int(g._rules().get("max_npcs", DLConfig.MAX_ACTIVE_NPCS))
	var extra: int = int(DLConfig.TRAFFIC_EXTRA_NPCS[DLConfig.traffic_index(g.current_round)])
	var cap: int = int(DLConfig.TRAFFIC_MAX_NPCS_CAP.get(g.difficulty, base))
	return mini(base + extra, maxi(base, cap))

## Carros que ainda ameacam o Bionix (nao passaram dele). Quem ja passou e so esta saindo da tela nao ocupa vaga de onda.
func _active_threat_count() -> int:
	var count := 0
	var passed_y: float = _player_current_center_y() + 60.0
	for data in g.obstacle_data:
		if bool(data.get("preview_only", false)):
			continue
		var node: Control = data.get("node", null)
		if node != null and is_instance_valid(node) and float(data.get("y", 0.0)) < passed_y:
			count += 1
	return count

func _visible_npc_count() -> int:
	var count := 0
	for data in g.obstacle_data:
		if bool(data.get("preview_only", false)):
			continue
		var node: Control = data.get("node", null)
		if node != null and is_instance_valid(node):
			count += 1
	return count

func _player_current_center_y() -> float:
	if g.car_rect != null and is_instance_valid(g.car_rect):
		return g.car_rect.position.y + g.car_rect.size.y * 0.5
	var viewport_height: float = maxf(g.STAGE_SIZE.y, 720.0)
	return viewport_height * g.car_y_ratio

func _make_npc_obstacle(base_size: Vector2) -> Control:
	var root: Control = Control.new()
	root.name = "NpcTraffic"
	root.size = base_size
	root.custom_minimum_size = base_size
	var sprite: TextureRect = TextureRect.new()
	sprite.set_anchors_preset(Control.PRESET_FULL_RECT)
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.texture = g._load_texture(_pick_npc_sprite_path())
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(sprite)
	# V0.16.9.6: lanternas vermelhas a partir do Entardecer (nao cria o no nos horarios sem luz: custo zero de dia).
	if DLCarLights.round_intensity(DLCarLights.KIND_TAIL, g.current_round) > 0.01:
		var tail_lights: DLCarLights = DLCarLights.new()
		tail_lights.setup(DLCarLights.KIND_TAIL, g.current_round)
		root.add_child(tail_lights)
	return root

func _pick_npc_sprite_path() -> String:
	var options: Array = DLConfig.NPC_SPRITES.duplicate()
	if options.size() > 1 and last_npc_sprite_path != "":
		options.erase(last_npc_sprite_path)
	var selected: String = str(options.pick_random())
	last_npc_sprite_path = selected
	return selected

func _first_spawn_delay() -> float:
	return _first_spawn_delay_base() * minf(1.0, float(DLConfig.TRAFFIC_SPAWN_MULT[DLConfig.traffic_index(g.current_round)]) + 0.08)

func _first_spawn_delay_base() -> float:
	# V0.13.13.2: o primeiro NPC deve aparecer logo após a aceleração,
	# sempre na direita, para o jogador entrar no ritmo sem corredor vazio.
	match g.difficulty:
		"facil":
			return 0.82
		"normal":
			return 0.72
		"dificil":
			return 0.64
		_:
			return 0.72

func _same_lane_spacing_ratio() -> float:
	match g.difficulty:
		"facil":
			return 0.165
		"normal":
			return 0.170
		"dificil":
			return 0.150
		_:
			return 0.185

func _cross_lane_spacing_ratio() -> float:
	match g.difficulty:
		"facil":
			return 0.185
		"normal":
			return 0.182
		"dificil":
			return 0.155
		_:
			return 0.200

func _opposite_critical_start_ratio() -> float:
	match g.difficulty:
		"facil":
			return 0.80
		"normal":
			return 0.82
		"dificil":
			return 0.84
	return 0.82

func _initial_safe_car_speed_multiplier() -> float:
	match g.difficulty:
		"facil":
			return 0.76
		"normal":
			return 0.72
		"dificil":
			return 0.70
	return 0.74

func _safe_opening_followup_delay() -> float:
	# Distância segura entre o primeiro carro da direita e o segundo da esquerda.
	match g.difficulty:
		"facil":
			return 1.90
		"normal":
			return 1.68
		"dificil":
			return 1.55
	return 1.72

func _post_safe_opening_delay() -> float:
	match g.difficulty:
		"facil":
			return 2.30
		"normal":
			return 1.78
		"dificil":
			return 1.48
	return 1.92

func _traffic_spawn_retry_delay() -> float:
	match g.difficulty:
		"facil":
			return 0.30
		"normal":
			return 0.24
		"dificil":
			return 0.16
	return 0.24
