extends RefCounted
class_name DLTraffic
## Trafego de NPCs: ondas fixas por dificuldade, abertura guiada, combos, distancias seguras e spawn.

var g: DesvioLogicoGame

func _init(game: DesvioLogicoGame) -> void:
	g = game

# ---- estado ----
var next_spawn_time: float = 0.0
var last_spawn_lane: int = DLConfig.LANE_LEFT
var last_combo_lane: int = DLConfig.LANE_RIGHT
var traffic_safe_opening_done: bool = false
var traffic_opening_step: int = 0
var traffic_wave_count_bag: Array = []
var traffic_wave_lane_bags: Dictionary = {}
var traffic_combo_queue: Array = []
var last_npc_sprite_path: String = ""

func _reset_traffic_wave_distribution() -> void:
	last_spawn_lane = DLConfig.LANE_LEFT
	last_combo_lane = DLConfig.LANE_RIGHT
	traffic_safe_opening_done = false
	traffic_opening_step = 0
	traffic_wave_count_bag.clear()
	traffic_wave_lane_bags.clear()
	traffic_combo_queue.clear()

func _final_spawn_cutoff_progress() -> float:
	return float(DLConfig.NPC_FINAL_SPAWN_CUTOFF_PROGRESS.get(g.difficulty, 0.90))

func _final_spawn_cutoff_seconds() -> float:
	return float(DLConfig.NPC_FINAL_SPAWN_CUTOFF_SECONDS.get(g.difficulty, 3.5))

func _can_spawn_new_traffic() -> bool:
	if g.state != DLConfig.STATE_DRIVE:
		return false
	var progress: float = g._route_progress_ratio()
	if progress >= _final_spawn_cutoff_progress():
		return false
	var remaining: float = maxf(0.0, g._drive_duration() - g.drive_elapsed)
	if remaining <= _final_spawn_cutoff_seconds():
		return false
	return true

func _spawn_obstacle() -> bool:
	if not _can_spawn_new_traffic():
		return false
	if not traffic_combo_queue.is_empty():
		return false
	var available_slots: int = _max_active_npcs() - _active_threat_count()
	if available_slots <= 0:
		return false
	var pattern: Array = _traffic_fixed_next_wave_pattern(available_slots)
	if pattern.is_empty():
		return false
	if pattern.size() <= 1:
		return _spawn_single_obstacle(int(pattern[0]) if not pattern.is_empty() else DLConfig.LANE_CENTER)
	if _spawn_fixed_lane_wave(pattern):
		return true
	return _spawn_single_obstacle()

func _traffic_fixed_next_wave_pattern(available_slots: int) -> Array:
	# V0.13.13.2: abertura fixa e legível em todas as dificuldades.
	# Primeiro NPC na direita, segundo NPC na esquerda; só depois entram
	# as ondas balanceadas. Nada aqui reage à faixa atual do jogador.
	if not traffic_safe_opening_done:
		return [_traffic_safe_opening_lane()]
	var count: int = _traffic_fixed_next_count()
	count = mini(count, mini(available_slots, 3))
	var progress: float = g._route_progress_ratio()
	if count >= 3 and progress < _traffic_triple_min_progress():
		count = 2
	if count >= 2 and progress < _traffic_pair_min_progress():
		count = 1
	return _traffic_fixed_lane_pattern_candidates(count)[0]

func _traffic_fixed_next_count() -> int:
	if traffic_wave_count_bag.is_empty():
		traffic_wave_count_bag = _traffic_fixed_count_template()
		traffic_wave_count_bag.shuffle()
	if traffic_wave_count_bag.is_empty():
		return 1
	return int(traffic_wave_count_bag.pop_back())

func _traffic_fixed_count_template() -> Array:
	match g.difficulty:
		"facil":
			# Fácil mantém leitura alta: maioria simples, algumas duplas, sem trio.
			return [1, 1, 1, 2]
		"normal":
			# V0.13.13.4: Normal fica mais tenso com mais duplas
			# escalonadas, sem virar parede impossível.
			return [1, 1, 1, 2, 2, 2, 2, 2, 2, 3]
		"dificil":
			# V0.13.13.3: Difícil fica mais tenso por padrão fixo:
			# menos ondas simples, mais duplas e trios escalonados.
			return [1, 1, 2, 2, 2, 2, 2, 3, 3, 3]
	return [1, 1, 2]

func _traffic_fixed_lane_pattern_candidates(count: int) -> Array:
	count = clampi(count, 1, 3)
	var key: String = str(count)
	if not traffic_wave_lane_bags.has(key) or (traffic_wave_lane_bags[key] as Array).is_empty():
		var new_bag: Array = _traffic_fixed_lane_pattern_template(count)
		new_bag.shuffle()
		traffic_wave_lane_bags[key] = new_bag
	var bag: Array = traffic_wave_lane_bags[key]
	var pattern: Array = bag.pop_back()
	traffic_wave_lane_bags[key] = bag
	var first: Array = []
	for lane in pattern:
		first.append(int(lane))
	var inverted: Array = []
	for lane in first:
		inverted.append(_other_lane(int(lane)))
	return [first, inverted]

func _traffic_fixed_lane_pattern_template(count: int) -> Array:
	match count:
		1:
			return [[DLConfig.LANE_LEFT], [DLConfig.LANE_RIGHT], [DLConfig.LANE_LEFT], [DLConfig.LANE_RIGHT]]
		2:
			return [[DLConfig.LANE_LEFT, DLConfig.LANE_RIGHT], [DLConfig.LANE_RIGHT, DLConfig.LANE_LEFT], [DLConfig.LANE_LEFT, DLConfig.LANE_RIGHT], [DLConfig.LANE_RIGHT, DLConfig.LANE_LEFT]]
		3:
			return [[DLConfig.LANE_LEFT, DLConfig.LANE_RIGHT, DLConfig.LANE_LEFT], [DLConfig.LANE_RIGHT, DLConfig.LANE_LEFT, DLConfig.LANE_RIGHT]]
	return [[DLConfig.LANE_LEFT]]

func _traffic_pair_min_progress() -> float:
	match g.difficulty:
		"facil":
			return 0.24
		"normal":
			return 0.20
		"dificil":
			return 0.16
	return 0.22

func _traffic_triple_min_progress() -> float:
	match g.difficulty:
		"facil":
			return 1.0
		"normal":
			return 0.48
		"dificil":
			return 0.38
	return 0.48

func _spawn_single_obstacle(forced_lane: int = DLConfig.LANE_CENTER) -> bool:
	if not _can_spawn_new_traffic():
		return false
	if _active_threat_count() >= _max_active_npcs():
		return false
	var spawn_y: float = g._obstacle_spawn_y()
	var lanes: Array = [forced_lane] if forced_lane == DLConfig.LANE_LEFT or forced_lane == DLConfig.LANE_RIGHT else _traffic_fixed_single_lane_candidates()
	for lane in lanes:
		if _can_spawn_at_lane(int(lane), spawn_y):
			var was_safe_opening: bool = not traffic_safe_opening_done
			_register_fixed_traffic_wave([int(lane)])
			_spawn_npc_at(int(lane), spawn_y, was_safe_opening, _initial_safe_car_speed_multiplier() if was_safe_opening else 1.0)
			if was_safe_opening:
				traffic_opening_step += 1
				traffic_safe_opening_done = traffic_opening_step >= 2
			return true
	return false

func _traffic_safe_opening_lane() -> int:
	# Abertura fixa: direita primeiro, esquerda em seguida.
	return DLConfig.LANE_RIGHT if traffic_opening_step <= 0 else DLConfig.LANE_LEFT

func _traffic_fixed_single_lane_candidates() -> Array:
	var preferred_lane: int = _other_lane(last_spawn_lane)
	return [preferred_lane, _other_lane(preferred_lane)]

func _spawn_fixed_lane_wave(pattern: Array) -> bool:
	if not _can_spawn_new_traffic():
		return false
	if pattern.size() <= 1:
		return _spawn_single_obstacle()
	if _active_threat_count() >= _max_active_npcs():
		return false
	var spawn_y: float = g._obstacle_spawn_y()
	var candidates: Array = [pattern]
	var inverted: Array = []
	for lane in pattern:
		inverted.append(_other_lane(int(lane)))
	candidates.append(inverted)
	for candidate in candidates:
		var lanes: Array = []
		for lane in candidate:
			lanes.append(int(lane))
		if lanes.is_empty():
			continue
		var first_lane: int = int(lanes[0])
		if not _can_spawn_at_lane(first_lane, spawn_y):
			continue
		_spawn_npc_at(first_lane, spawn_y, false, 1.0)
		_queue_fixed_wave_tail(lanes)
		_register_fixed_traffic_wave(lanes)
		return true
	return false

func _queue_fixed_wave_tail(pattern: Array) -> void:
	traffic_combo_queue.clear()
	if pattern.size() <= 1:
		return
	var delay_step: float = _traffic_wave_combo_delay(pattern.size())
	for i in range(1, pattern.size()):
		traffic_combo_queue.append({
			"lane": int(pattern[i]),
			"spawn_at": g.drive_elapsed + delay_step * float(i),
			"speed_multiplier": 1.0 + float(i) * _combo_speed_step(pattern.size()),
			"attempts": 0,
			"count": pattern.size()
		})

func _update_pending_combo_spawns() -> void:
	if traffic_combo_queue.is_empty():
		return
	if not _can_spawn_new_traffic():
		traffic_combo_queue.clear()
		return
	while not traffic_combo_queue.is_empty():
		var pending: Dictionary = traffic_combo_queue[0]
		if g.drive_elapsed < float(pending.get("spawn_at", g.drive_elapsed)):
			return
		if _active_threat_count() >= _max_active_npcs():
			pending["spawn_at"] = g.drive_elapsed + _traffic_wave_combo_retry_delay()
			pending["attempts"] = int(pending.get("attempts", 0)) + 1
			traffic_combo_queue[0] = pending
			return
		var lane: int = int(pending.get("lane", DLConfig.LANE_RIGHT))
		var spawn_y: float = g._obstacle_spawn_y()
		if _can_spawn_at_lane(lane, spawn_y):
			_spawn_npc_at(lane, spawn_y, false, float(pending.get("speed_multiplier", 1.0)))
			traffic_combo_queue.remove_at(0)
			continue
		pending["attempts"] = int(pending.get("attempts", 0)) + 1
		if int(pending.get("attempts", 0)) >= _traffic_wave_combo_max_attempts():
			traffic_combo_queue.remove_at(0)
		else:
			pending["spawn_at"] = g.drive_elapsed + _traffic_wave_combo_retry_delay()
			traffic_combo_queue[0] = pending
		return

func _traffic_wave_combo_delay(count: int) -> float:
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

func _register_fixed_traffic_wave(pattern: Array) -> void:
	if not pattern.is_empty():
		last_spawn_lane = int(pattern[0])
		last_combo_lane = int(pattern[0]) if pattern.size() > 1 else last_combo_lane

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
	return int(g._rules().get("max_npcs", DLConfig.MAX_ACTIVE_NPCS))

func _active_threat_count() -> int:
	var count := 0
	for data in g.obstacle_data:
		if bool(data.get("preview_only", false)):
			continue
		var node: Control = data.get("node", null)
		if node != null and is_instance_valid(node):
			count += 1
	return count

func _active_obstacle_count() -> int:
	var count := 0
	for data in g.obstacle_data:
		var node: Control = data.get("node", null)
		if node != null and is_instance_valid(node):
			count += 1
	return count

func _spawn_has_player_clearance(lane: int, spawn_y: float) -> bool:
	var viewport_height: float = maxf(g.get_viewport_rect().size.y, 720.0)
	var player_center_y: float = _player_current_center_y()
	var safety_ratio: float = float(DLConfig.SPAWN_HORIZON_SAFETY_RATIO.get(g.difficulty, 0.22))
	if lane != g.current_lane:
		safety_ratio = float(DLConfig.SPAWN_HORIZON_SAFETY_OPPOSITE_RATIO.get(g.difficulty, 0.18))
	return spawn_y <= player_center_y - viewport_height * safety_ratio

func _player_current_center_y() -> float:
	if g.car_rect != null and is_instance_valid(g.car_rect):
		return g.car_rect.position.y + g.car_rect.size.y * 0.5
	var viewport_height: float = maxf(g.get_viewport_rect().size.y, 720.0)
	return viewport_height * g.car_y_ratio

func _can_spawn_at_lane(lane: int, spawn_y: float) -> bool:
	var viewport_height: float = maxf(g.get_viewport_rect().size.y, 720.0)
	var same_lane_min: float = viewport_height * _same_lane_spacing_ratio()
	var cross_lane_min: float = viewport_height * _cross_lane_spacing_ratio()
	if not _spawn_has_player_clearance(lane, spawn_y):
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

func _spawn_npc_at(lane: int, y: float, initial_traffic: bool = false, speed_multiplier: float = 1.0) -> void:
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
	var viewport_height: float = maxf(g.get_viewport_rect().size.y, 720.0)
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
	return root

func _pick_npc_sprite_path() -> String:
	var options: Array = DLConfig.NPC_SPRITES.duplicate()
	if options.size() > 1 and last_npc_sprite_path != "":
		options.erase(last_npc_sprite_path)
	var selected: String = str(options.pick_random())
	last_npc_sprite_path = selected
	return selected

func _first_spawn_delay() -> float:
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

func _minimum_spawn_interval() -> float:
	match g.difficulty:
		"facil":
			return 2.10
		"normal":
			return 1.42
		"dificil":
			return 1.05
		_:
			return 1.70

func _same_lane_spacing_ratio() -> float:
	match g.difficulty:
		"facil":
			return 0.205
		"normal":
			return 0.188
		"dificil":
			return 0.162
		_:
			return 0.185

func _cross_lane_spacing_ratio() -> float:
	match g.difficulty:
		"facil":
			return 0.245
		"normal":
			return 0.205
		"dificil":
			return 0.172
		_:
			return 0.200

func _opposite_critical_start_ratio() -> float:
	match g.difficulty:
		"facil":
			return 0.70
		"normal":
			return 0.735
		"dificil":
			return 0.765
	return 0.72

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

func _spawn_interval() -> float:
	var base: float = float(g._rules().get("spawn_base", 3.8))
	var round_reduction: float = float(g.current_round) * 0.035
	var jitter: float = randf_range(0.16, 0.48)
	if g.difficulty == "normal":
		jitter = randf_range(0.06, 0.20)
	elif g.difficulty == "dificil":
		jitter = randf_range(0.04, 0.14)
	return maxf(_minimum_spawn_interval(), base - round_reduction + jitter)
