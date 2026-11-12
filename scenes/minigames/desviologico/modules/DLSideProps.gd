extends RefCounted
class_name DLSideProps
## Props laterais da estrada (postes, placa de bifurcacao, ciclista): spawn, movimento em perspectiva e desenho.

var g: DesvioLogicoGame

func _init(game: DesvioLogicoGame) -> void:
	g = game

# ---- estado ----
var side_props: Array = []
var prop_textures: Dictionary = {}
var side_prop_time: float = 0.0

func _load_side_prop_textures() -> void:
	prop_textures.clear()
	for prop_type in DLConfig.PROP_SPRITES.keys():
		prop_textures[prop_type] = g._load_texture(str(DLConfig.PROP_SPRITES[prop_type]))

func _side_grass_x_at_y(side: int, y: float, viewport_size: Vector2) -> float:
	var prop_type: String = DLConfig.PROP_CYCLIST if side < 0 else DLConfig.PROP_POST
	var marker_x: float = _side_prop_path_x_at_y(prop_type, side, y)
	if marker_x >= 0.0:
		return marker_x
	var t: float = clampf((y - viewport_size.y * 0.345) / maxf(viewport_size.y * 0.64, 1.0), 0.0, 1.0)
	var top_x: float = 0.435 if side < 0 else 0.565
	var bottom_x: float = 0.075 if side < 0 else 0.925
	return viewport_size.x * lerpf(top_x, bottom_x, t)

func _side_prop_path_x_at_y(prop_type: String, side: int, y: float) -> float:
	var start_node: Node = _side_prop_marker(prop_type, side, true)
	var end_node: Node = _side_prop_marker(prop_type, side, false)
	if start_node == null or end_node == null:
		return -1.0
	var start_pos: Vector2 = g._canvas_item_global_position(start_node)
	var end_pos: Vector2 = g._canvas_item_global_position(end_node)
	if prop_type == DLConfig.PROP_POST_LEFT:
		var mid_node: Node = _side_prop_marker_named(prop_type, side, "Mid")
		if mid_node != null:
			var mid_pos: Vector2 = g._canvas_item_global_position(mid_node)
			if mid_pos.y > start_pos.y + 1.0 and end_pos.y > mid_pos.y + 1.0:
				if y <= mid_pos.y:
					var t_a: float = clampf((y - start_pos.y) / (mid_pos.y - start_pos.y), 0.0, 1.0)
					return lerpf(start_pos.x, mid_pos.x, t_a)
				var t_b: float = clampf((y - mid_pos.y) / (end_pos.y - mid_pos.y), 0.0, 1.0)
				return lerpf(mid_pos.x, end_pos.x, t_b)
	if absf(end_pos.y - start_pos.y) < 1.0:
		return -1.0
	var t: float = clampf((y - start_pos.y) / (end_pos.y - start_pos.y), 0.0, 1.0)
	return lerpf(start_pos.x, end_pos.x, t)

func _side_prop_position_at_y(prop_type: String, side: int, y: float, viewport_size: Vector2) -> Vector2:
	var x: float = _side_prop_path_x_at_y(prop_type, side, y)
	if x < 0.0:
		x = _side_grass_x_at_y(side, y, viewport_size)
	return Vector2(x, y)

func _side_prop_depth_t(prop_type: String, side: int, y: float) -> float:
	var start_node: Node = _side_prop_marker(prop_type, side, true)
	var end_node: Node = _side_prop_marker(prop_type, side, false)
	if start_node == null or end_node == null:
		return g._depth_t(y)
	var start_pos: Vector2 = g._canvas_item_global_position(start_node)
	var end_pos: Vector2 = g._canvas_item_global_position(end_node)
	if absf(end_pos.y - start_pos.y) < 1.0:
		return g._depth_t(y)
	return clampf((y - start_pos.y) / (end_pos.y - start_pos.y), 0.0, 1.0)

func _side_prop_start_y(prop_type: String, side: int, viewport_size: Vector2) -> float:
	var start_node: Node = _side_prop_marker(prop_type, side, true)
	if start_node != null:
		return g._canvas_item_global_position(start_node).y
	return viewport_size.y * 0.415

func _side_prop_end_y(prop_type: String, side: int, viewport_size: Vector2) -> float:
	var end_node: Node = _side_prop_marker(prop_type, side, false)
	if end_node != null:
		return g._canvas_item_global_position(end_node).y
	return viewport_size.y * 1.10

func _side_prop_exit_y(prop_type: String, side: int, viewport_size: Vector2) -> float:
	var end_y: float = _side_prop_end_y(prop_type, side, viewport_size)
	if prop_type == DLConfig.PROP_POST or prop_type == DLConfig.PROP_POST_LEFT:
		# V0.13.7.1: postes dos dois lados saem naturalmente antes de reciclar.
		return end_y + viewport_size.y * 0.16
	return end_y + viewport_size.y * 0.10

func _side_prop_marker(prop_type: String, side: int, is_start: bool) -> Node:
	var point_name: String = "Start" if is_start else "End"
	return _side_prop_marker_named(prop_type, side, point_name)

func _side_prop_marker_named(prop_type: String, side: int, point_name: String) -> Node:
	if prop_type == DLConfig.PROP_POST:
		return g.get_node_or_null("SidePropMarkers/PostRight%s" % point_name)
	if prop_type == DLConfig.PROP_POST_LEFT:
		var marker: Node = g.get_node_or_null("SidePropMarkers/PostLeft%s" % point_name)
		if marker != null:
			return marker
		if point_name == "Start" or point_name == "End":
			return g.get_node_or_null("SidePropMarkers/CyclistLeft%s" % point_name)
		return null
	if prop_type == DLConfig.PROP_CYCLIST:
		return g.get_node_or_null("SidePropMarkers/CyclistLeft%s" % point_name)
	if prop_type == DLConfig.PROP_SIGN:
		var side_name: String = "Left" if side < 0 else "Right"
		return g.get_node_or_null("SidePropMarkers/Sign%s%s" % [side_name, point_name])
	return null

func _reset_side_props() -> void:
	side_props.clear()
	var viewport_size: Vector2 = g.get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(1280, 720)

	# V0.13.7.2: postes deixam de ser spawns aleatórios e passam a formar profundidades fixas (V0.14.4: 2 por lado, ver DLConfig.POST_DEPTH_SLOTS).
	# Cada profundidade possui um par proporcional: poste esquerdo + poste direito.
	# Quando o poste mais próximo é ultrapassado, ele recicla para o fundo mantendo a distância visual.
	for slot_t in DLConfig.POST_DEPTH_SLOTS:
		var depth_value: float = float(slot_t)
		_add_side_prop(DLConfig.PROP_POST_LEFT, -1, _side_prop_y_at_depth(DLConfig.PROP_POST_LEFT, -1, depth_value, viewport_size), _side_prop_base_speed(DLConfig.PROP_POST_LEFT), true, true, 0.0)
		_add_side_prop(DLConfig.PROP_POST, 1, _side_prop_y_at_depth(DLConfig.PROP_POST, 1, depth_value, viewport_size), _side_prop_base_speed(DLConfig.PROP_POST), true, true, 0.0)

	# O ciclista continua existindo no lado esquerdo, mas passa na frente dos postes via ordem de desenho.
	# Ele não bloqueia mais os postes e os postes não bloqueiam o ciclista.
	_add_side_prop(DLConfig.PROP_CYCLIST, -1, _side_prop_start_y(DLConfig.PROP_CYCLIST, -1, viewport_size), _side_prop_base_speed(DLConfig.PROP_CYCLIST), false, false, 10.0)
	_add_side_prop(DLConfig.PROP_CYCLIST, -1, _side_prop_start_y(DLConfig.PROP_CYCLIST, -1, viewport_size), _side_prop_base_speed(DLConfig.PROP_CYCLIST), false, false, 27.0)

	# V0.13.4.8: a placa Y deixou de ser prop em movimento.
	# Ela agora é desenhada como elemento fixo de distância em _draw_fixed_bifurcation_sign().

func _side_prop_y_at_depth(prop_type: String, side: int, depth_value: float, viewport_size: Vector2) -> float:
	var start_y: float = _side_prop_start_y(prop_type, side, viewport_size)
	var end_y: float = _side_prop_end_y(prop_type, side, viewport_size)
	return lerpf(start_y, end_y, clampf(depth_value, 0.0, 1.0))

func _add_side_prop(prop_type: String, side: int, y: float, speed: float, active: bool, recycle: bool, spawn_at: float) -> void:
	side_props.append({
		"type": prop_type,
		"side": side,
		"y": y,
		"speed": speed,
		"phase": randf() * TAU,
		"active": active,
		"recycle": recycle,
		"spawn_at": spawn_at,
		"expired": false
	})

func _side_prop_base_speed(prop_type: String) -> float:
	var factor: float = g._difficulty_motion_factor()
	if prop_type == DLConfig.PROP_POST or prop_type == DLConfig.PROP_POST_LEFT:
		# V0.13.7.2: velocidade determinística para manter postes esquerdo/direito proporcionais.
		return 86.0 * factor
	if prop_type == DLConfig.PROP_CYCLIST:
		return randf_range(56.0, 74.0) * factor
	if prop_type == DLConfig.PROP_SIGN:
		return randf_range(50.0, 66.0) * factor
	return randf_range(62.0, 84.0) * factor

func _side_prop_recycle_delay(prop_type: String) -> float:
	if prop_type == DLConfig.PROP_POST or prop_type == DLConfig.PROP_POST_LEFT:
		return 0.0
	return randf_range(5.0, 7.0)

func _side_prop_spawn_y(prop_type: String, side: int, viewport_size: Vector2) -> float:
	var start_y: float = _side_prop_start_y(prop_type, side, viewport_size)
	var end_y: float = _side_prop_end_y(prop_type, side, viewport_size)
	if prop_type == DLConfig.PROP_POST or prop_type == DLConfig.PROP_POST_LEFT:
		return start_y
	if prop_type == DLConfig.PROP_SIGN:
		return lerpf(start_y, end_y, 0.08)
	if prop_type == DLConfig.PROP_CYCLIST:
		return start_y + randf_range(4.0, 16.0)
	return start_y

func _update_side_motion_props(delta: float) -> void:
	if side_props.is_empty():
		_reset_side_props()
	var viewport_size: Vector2 = g.get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(1280, 720)
	for i in range(side_props.size()):
		var data: Dictionary = side_props[i]
		if bool(data.get("expired", false)):
			continue
		var prop_type: String = str(data.get("type", DLConfig.PROP_POST))
		var side: int = int(data.get("side", 1))
		if not bool(data.get("active", true)):
			if g.drive_elapsed >= float(data.get("spawn_at", 0.0)):
				if _side_prop_activation_blocked(prop_type, side):
					data["spawn_at"] = g.drive_elapsed + _side_prop_retry_delay(prop_type)
					side_props[i] = data
					continue
				data["active"] = true
				data["y"] = _side_prop_spawn_y(prop_type, side, viewport_size)
				data["speed"] = _side_prop_base_speed(prop_type)
				data["phase"] = randf() * TAU
			else:
				side_props[i] = data
				continue
		var y: float = float(data.get("y", _side_prop_start_y(prop_type, side, viewport_size)))
		var t: float = _side_prop_depth_t(prop_type, side, y)
		var type_factor: float = 0.040
		if prop_type == DLConfig.PROP_CYCLIST:
			type_factor = 0.030
		elif prop_type == DLConfig.PROP_SIGN:
			type_factor = 0.014
		var speed: float = float(data.get("speed", 74.0)) + float(g.current_round) * 1.4 + g._world_speed() * type_factor
		y += speed * lerpf(0.18, 0.74, t) * delta
		var end_y: float = _side_prop_exit_y(prop_type, side, viewport_size)
		if y > end_y:
			if bool(data.get("recycle", false)):
				if prop_type == DLConfig.PROP_POST or prop_type == DLConfig.PROP_POST_LEFT:
					# V0.13.7.2: postes reciclam imediatamente para o fundo, mantendo 3 profundidades fixas.
					data["active"] = true
					data["spawn_at"] = g.drive_elapsed
					data["y"] = _side_prop_start_y(prop_type, side, viewport_size)
					data["speed"] = _side_prop_base_speed(prop_type)
					data["phase"] = randf() * TAU
				else:
					data["active"] = false
					data["spawn_at"] = g.drive_elapsed + _side_prop_recycle_delay(prop_type)
					data["y"] = _side_prop_start_y(prop_type, side, viewport_size)
			else:
				data["active"] = false
				data["expired"] = true
		else:
			data["y"] = y
		side_props[i] = data

func _side_prop_activation_blocked(_prop_type: String, _side: int) -> bool:
	# V0.13.7.2: postes e ciclista podem coexistir; a prioridade visual é resolvida por z/ordem de desenho.
	return false

func _side_prop_retry_delay(prop_type: String) -> float:
	if prop_type == DLConfig.PROP_POST_LEFT:
		return DLConfig.LEFT_POST_RETRY_DELAY
	if prop_type == DLConfig.PROP_CYCLIST:
		return 1.35
	return 1.0

func _left_post_spacing_conflict() -> bool:
	for data in side_props:
		if bool(data.get("expired", false)) or not bool(data.get("active", false)):
			continue
		if str(data.get("type", "")) != DLConfig.PROP_POST_LEFT:
			continue
		var y: float = float(data.get("y", 0.0))
		var t: float = _side_prop_depth_t(DLConfig.PROP_POST_LEFT, -1, y)
		if t >= 0.0 and t <= DLConfig.LEFT_POST_VISIBLE_MAX_T:
			return true
	return false

func _left_side_visual_conflict(prop_type: String) -> bool:
	if prop_type != DLConfig.PROP_CYCLIST and prop_type != DLConfig.PROP_POST_LEFT:
		return false
	var blocked_type: String = DLConfig.PROP_POST_LEFT if prop_type == DLConfig.PROP_CYCLIST else DLConfig.PROP_CYCLIST
	for data in side_props:
		if bool(data.get("expired", false)) or not bool(data.get("active", false)):
			continue
		if str(data.get("type", "")) != blocked_type:
			continue
		var y: float = float(data.get("y", 0.0))
		var t: float = _side_prop_depth_t(blocked_type, -1, y)
		if t >= 0.02 and t <= 1.04:
			return true
	return false

func _on_side_props_layer_draw() -> void:
	if g.side_props_layer == null:
		return
	var viewport_size: Vector2 = g.get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	_draw_fixed_bifurcation_sign(viewport_size)
	if not g._animations_enabled():
		return
	# V0.13.7.2: tutorial limpo. Postes e ciclista só aparecem depois do tutorial.
	if g._is_tutorial_state():
		return
	for draw_cyclists in [false, true]:
		for data in side_props:
			if not bool(data.get("active", true)) or bool(data.get("expired", false)):
				continue
			var prop_type: String = str(data.get("type", DLConfig.PROP_POST))
			var is_cyclist: bool = prop_type == DLConfig.PROP_CYCLIST
			if is_cyclist != bool(draw_cyclists):
				continue
			var side: int = int(data.get("side", 1))
			var y: float = float(data.get("y", viewport_size.y * 0.45))
			var t: float = _side_prop_depth_t(prop_type, side, y)
			if t <= 0.0:
				continue
			var base_pos: Vector2 = _side_prop_position_at_y(prop_type, side, y, viewport_size)
			var bob: float = 0.0
			# Postes ficam plantados; ciclista oscila e é desenhado por último para passar na frente.
			if prop_type == DLConfig.PROP_CYCLIST:
				bob = sin(side_prop_time * 2.3 + float(data.get("phase", 0.0))) * 1.8 * clampf(t, 0.2, 1.0)
				bob += sin(side_prop_time * 7.0 + float(data.get("phase", 0.0))) * 1.5
			_draw_side_prop_sprite(prop_type, base_pos + Vector2(0.0, bob), t, side)

func _draw_fixed_bifurcation_sign(viewport_size: Vector2) -> void:
	var texture: Texture2D = prop_textures.get(DLConfig.PROP_SIGN, null)
	if texture == null:
		return
	var tex_size: Vector2 = texture.get_size()
	if tex_size.x <= 0.0 or tex_size.y <= 0.0:
		return
	var progress: float = g._route_progress_ratio()
	var eased: float = progress * progress * (3.0 - 2.0 * progress)
	var scale_factor: float = clampf(minf(viewport_size.x / 1280.0, viewport_size.y / 720.0), 0.75, 1.18)
	var target_height: float = lerpf(28.0, 96.0, eased) * scale_factor
	var target_size: Vector2 = Vector2(target_height * tex_size.x / tex_size.y, target_height)
	var anchor: Vector2 = _fixed_bifurcation_sign_anchor(viewport_size)
	var rect := Rect2(anchor - Vector2(target_size.x * 0.5, target_size.y), target_size)
	var alpha: float = clampf(lerpf(0.18, 1.0, eased), 0.15, 1.0)
	if g.current_round >= 4:
		var glow_center: Vector2 = rect.position + Vector2(rect.size.x * 0.50, rect.size.y * 0.25)
		g.side_props_layer.draw_circle(glow_center, lerpf(5.0, 16.0, eased) * scale_factor, Color(1.0, 0.78, 0.22, 0.08 + 0.10 * eased))
	g.side_props_layer.draw_texture_rect(texture, rect, false, Color(1.0, 1.0, 1.0, alpha))

func _fixed_bifurcation_sign_anchor(viewport_size: Vector2) -> Vector2:
	var marker: Node = g.get_node_or_null("FixedSceneMarkers/BifurcationSignAnchor")
	if marker == null:
		marker = g.get_node_or_null("SidePropMarkers/SignRightStart")
	if marker != null:
		return g._canvas_item_global_position(marker)
	return Vector2(viewport_size.x * 0.50, viewport_size.y * 0.365)

func _draw_side_prop_sprite(prop_type: String, base: Vector2, depth_t: float, side: int) -> void:
	if g.side_props_layer == null:
		return
	var texture: Texture2D = prop_textures.get(prop_type, null)
	if texture == null:
		_draw_side_prop_fallback(prop_type, base, depth_t, side)
		return
	var viewport_size: Vector2 = g.get_viewport_rect().size
	var scale_factor: float = clampf(minf(viewport_size.x / 1280.0, viewport_size.y / 720.0), 0.75, 1.18)
	var target_height: float = 62.0 * scale_factor
	if prop_type == DLConfig.PROP_POST or prop_type == DLConfig.PROP_POST_LEFT:
		# V0.13.4.15: poste alto cresce por perspectiva e sai naturalmente como os demais props.
		var post_t: float = minf(depth_t, 0.90)
		target_height = lerpf(72.0, 212.0, post_t) * scale_factor
	elif prop_type == DLConfig.PROP_SIGN:
		target_height = lerpf(34.0, 132.0, depth_t) * scale_factor
	elif prop_type == DLConfig.PROP_CYCLIST:
		target_height = lerpf(38.0, 126.0, depth_t) * scale_factor
	var tex_size: Vector2 = texture.get_size()
	if tex_size.x <= 0.0 or tex_size.y <= 0.0:
		return
	var target_size: Vector2 = Vector2(target_height * tex_size.x / tex_size.y, target_height)
	var anchor_x: float = 0.50
	var anchor_y: float = 1.00
	var draw_base: Vector2 = base
	if prop_type == DLConfig.PROP_POST:
		# O sprite direito aponta para a esquerda e a haste fica na metade direita da imagem.
		anchor_x = 0.675
		anchor_y = 0.985
		draw_base.y += lerpf(3.0, 10.0, minf(depth_t, 0.82)) * scale_factor
	elif prop_type == DLConfig.PROP_POST_LEFT:
		# Sprite espelhado: a haste fica na metade esquerda e a luminária aponta para a direita.
		anchor_x = 0.325
		anchor_y = 0.985
		draw_base.y += lerpf(3.0, 10.0, minf(depth_t, 0.82)) * scale_factor
	var rect := Rect2(draw_base - Vector2(target_size.x * anchor_x, target_size.y * anchor_y), target_size)
	var alpha: float = clampf(0.52 + depth_t * 0.48, 0.38, 1.0)
	# Sem fade artificial no poste: ele segue a mesma leitura de ultrapassagem dos NPCs/ciclista
	# e só é reciclado quando sai naturalmente da rota lateral.
	if (prop_type == DLConfig.PROP_POST or prop_type == DLConfig.PROP_POST_LEFT) and g.current_round >= 3:
		var glow_x_ratio: float = 0.26 if prop_type == DLConfig.PROP_POST else 0.74
		var glow_pos: Vector2 = rect.position + Vector2(rect.size.x * glow_x_ratio, rect.size.y * 0.145)
		var glow_alpha: float = (0.08 + 0.11 * depth_t + 0.04 * sin(g.waterfx.water_time * 4.2 + depth_t * 3.0)) * alpha
		g.side_props_layer.draw_circle(glow_pos, lerpf(6.0, 17.0, minf(depth_t, 0.82)) * scale_factor, Color(1.0, 0.48, 0.34, glow_alpha))
	g.side_props_layer.draw_texture_rect(texture, rect, false, Color(1.0, 1.0, 1.0, alpha))

func _draw_side_prop_fallback(prop_type: String, base: Vector2, depth_t: float, _side: int) -> void:
	var h: float = lerpf(18.0, 70.0, depth_t)
	if prop_type == DLConfig.PROP_POST or prop_type == DLConfig.PROP_POST_LEFT:
		g.side_props_layer.draw_line(base, base + Vector2(0.0, -h), Color(0.55, 0.60, 0.68, 0.85), maxf(2.0, 4.0 * depth_t))
		g.side_props_layer.draw_rect(Rect2(base + Vector2(-4.0, -h - 8.0), Vector2(8.0, 8.0)), Color(0.0, 0.85, 1.0, 0.82), true)
	elif prop_type == DLConfig.PROP_SIGN:
		g.side_props_layer.draw_line(base, base + Vector2(0.0, -h), Color(0.45, 0.45, 0.48, 0.9), maxf(2.0, 3.0 * depth_t))
		g.side_props_layer.draw_rect(Rect2(base + Vector2(-10.0, -h - 22.0), Vector2(20.0, 20.0)), Color(1.0, 0.82, 0.05, 0.88), true)
	else:
		g.side_props_layer.draw_circle(base + Vector2(0.0, -h * 0.40), maxf(4.0, h * 0.18), Color(0.0, 0.78, 0.95, 0.82))
