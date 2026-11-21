extends RefCounted
class_name DLSideProps
## Props laterais da estrada: ciclista (esquerda) e placa fixa de bifurcacao. Spawn, movimento em perspectiva e desenho.
##
## V0.16.11: os POSTES foram removidos de vez (ficavam ruins na resolucao de longe). Sumiram o desenho por script, os PNGs,
## a luz noturna e os previews do editor. Os markers PostLeft*/PostRight* da cena continuam, mas agora so servem de
## TRILHA para as listras decorativas do gramado (PROP_TRAIL_LEFT / PROP_TRAIL_RIGHT) - nao desenham mais nada.
## A trilha (markers do editor) e lida uma vez e guardada em cache (pesado no WASM single-thread).
## Sentinela "sem trilha" = NO_PATH_X (x negativo e valido: a trilha esquerda sai pela borda da tela).

var g: DesvioLogicoGame

## Retornado por _side_prop_path_x_at_y quando o prop nao tem trilha (markers ausentes).
const NO_PATH_X: float = -100000.0

func _init(game: DesvioLogicoGame) -> void:
	g = game

# ---- estado ----
var side_props: Array = []
var prop_textures: Dictionary = {}
var side_prop_time: float = 0.0
var _path_cache: Dictionary = {}

func _load_side_prop_textures() -> void:
	prop_textures.clear()
	for prop_type in DLConfig.PROP_SPRITES.keys():
		prop_textures[prop_type] = g._load_texture(str(DLConfig.PROP_SPRITES[prop_type]))

# ---- trilhas (markers do editor) ----

## Descarta o cache das trilhas (chamado ao iniciar cada desafio e quando a janela muda de tamanho).
func _invalidate_path_cache() -> void:
	_path_cache.clear()

## Resolve a trilha de um prop a partir dos markers Start/Mid/End da cena. Devolve {} se nao houver markers.
## Resultado: {"start": Vector2, "end": Vector2, "has_mid": bool, "mid": Vector2}. Fica em cache (a placa depende do lado).
func _side_prop_path(prop_type: String, side: int) -> Dictionary:
	var cache_key: String = prop_type
	if prop_type == DLConfig.PROP_SIGN:
		cache_key = "%s_%d" % [prop_type, side]
	if _path_cache.has(cache_key):
		return _path_cache[cache_key]
	var start_node: Node = _side_prop_marker(prop_type, side, true)
	var end_node: Node = _side_prop_marker(prop_type, side, false)
	if start_node == null or end_node == null:
		return {}
	if not start_node.is_inside_tree() or not end_node.is_inside_tree():
		return {}
	var start_pos: Vector2 = g._canvas_item_global_position(start_node)
	var end_pos: Vector2 = g._canvas_item_global_position(end_node)
	var path: Dictionary = {"start": start_pos, "end": end_pos, "has_mid": false, "mid": Vector2.ZERO}
	if _is_trail(prop_type):
		var mid_node: Node = _side_prop_marker_named(prop_type, side, "Mid")
		if mid_node != null and mid_node.is_inside_tree():
			var mid_pos: Vector2 = g._canvas_item_global_position(mid_node)
			if mid_pos.y > start_pos.y + 1.0 and end_pos.y > mid_pos.y + 1.0:
				path["has_mid"] = true
				path["mid"] = mid_pos
	_path_cache[cache_key] = path
	return path

func _side_grass_x_at_y(side: int, y: float, viewport_size: Vector2) -> float:
	var prop_type: String = DLConfig.PROP_CYCLIST if side < 0 else DLConfig.PROP_TRAIL_RIGHT
	var marker_x: float = _side_prop_path_x_at_y(prop_type, side, y)
	if marker_x > NO_PATH_X:
		return marker_x
	var t: float = clampf((y - viewport_size.y * 0.345) / maxf(viewport_size.y * 0.64, 1.0), 0.0, 1.0)
	var top_x: float = 0.435 if side < 0 else 0.565
	var bottom_x: float = 0.075 if side < 0 else 0.925
	return viewport_size.x * lerpf(top_x, bottom_x, t)

## X da trilha na altura y. Devolve NO_PATH_X se nao ha trilha (x negativo e valido: o poste proximo sai pela borda da tela).
func _side_prop_path_x_at_y(prop_type: String, side: int, y: float) -> float:
	var path: Dictionary = _side_prop_path(prop_type, side)
	if path.is_empty():
		return NO_PATH_X
	var start_pos: Vector2 = path["start"]
	var end_pos: Vector2 = path["end"]
	if bool(path["has_mid"]):
		var mid_pos: Vector2 = path["mid"]
		if y <= mid_pos.y:
			var t_a: float = clampf((y - start_pos.y) / (mid_pos.y - start_pos.y), 0.0, 1.0)
			return lerpf(start_pos.x, mid_pos.x, t_a)
		var t_b: float = clampf((y - mid_pos.y) / (end_pos.y - mid_pos.y), 0.0, 1.0)
		return lerpf(mid_pos.x, end_pos.x, t_b)
	if absf(end_pos.y - start_pos.y) < 1.0:
		return NO_PATH_X
	var t: float = clampf((y - start_pos.y) / (end_pos.y - start_pos.y), 0.0, 1.0)
	return lerpf(start_pos.x, end_pos.x, t)

func _side_prop_position_at_y(prop_type: String, side: int, y: float, viewport_size: Vector2) -> Vector2:
	var x: float = _side_prop_path_x_at_y(prop_type, side, y)
	if x <= NO_PATH_X:
		x = _side_grass_x_at_y(side, y, viewport_size)
	return Vector2(x, y)

func _side_prop_depth_t(prop_type: String, side: int, y: float) -> float:
	var path: Dictionary = _side_prop_path(prop_type, side)
	if path.is_empty():
		return g._depth_t(y)
	var start_pos: Vector2 = path["start"]
	var end_pos: Vector2 = path["end"]
	if absf(end_pos.y - start_pos.y) < 1.0:
		return g._depth_t(y)
	return clampf((y - start_pos.y) / (end_pos.y - start_pos.y), 0.0, 1.0)

func _side_prop_start_y(prop_type: String, side: int, viewport_size: Vector2) -> float:
	var path: Dictionary = _side_prop_path(prop_type, side)
	if not path.is_empty():
		var start_pos: Vector2 = path["start"]
		return start_pos.y
	return viewport_size.y * 0.415

func _side_prop_end_y(prop_type: String, side: int, viewport_size: Vector2) -> float:
	var path: Dictionary = _side_prop_path(prop_type, side)
	if not path.is_empty():
		var end_pos: Vector2 = path["end"]
		return end_pos.y
	return viewport_size.y * 1.10

func _side_prop_exit_y(prop_type: String, side: int, viewport_size: Vector2) -> float:
	var end_y: float = _side_prop_end_y(prop_type, side, viewport_size)
	return end_y + viewport_size.y * 0.10

func _side_prop_marker(prop_type: String, side: int, is_start: bool) -> Node:
	var point_name: String = "Start" if is_start else "End"
	return _side_prop_marker_named(prop_type, side, point_name)

func _side_prop_marker_named(prop_type: String, side: int, point_name: String) -> Node:
	if prop_type == DLConfig.PROP_TRAIL_RIGHT:
		return g.get_node_or_null("SidePropMarkers/PostRight%s" % point_name)
	if prop_type == DLConfig.PROP_TRAIL_LEFT:
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

func _is_trail(prop_type: String) -> bool:
	return prop_type == DLConfig.PROP_TRAIL_LEFT or prop_type == DLConfig.PROP_TRAIL_RIGHT

func _reset_side_props() -> void:
	side_props.clear()
	# Le os markers de novo a cada desafio (barato, uma vez) e depois usa o cache.
	_invalidate_path_cache()
	var viewport_size: Vector2 = g.STAGE_SIZE
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(1280, 720)
	# V0.16.11: sem postes. So o ciclista continua passando pelo lado esquerdo.
	_add_side_prop(DLConfig.PROP_CYCLIST, -1, _side_prop_start_y(DLConfig.PROP_CYCLIST, -1, viewport_size), _side_prop_base_speed(DLConfig.PROP_CYCLIST), false, false, 10.0)
	_add_side_prop(DLConfig.PROP_CYCLIST, -1, _side_prop_start_y(DLConfig.PROP_CYCLIST, -1, viewport_size), _side_prop_base_speed(DLConfig.PROP_CYCLIST), false, false, 27.0)
	# V0.13.4.8: a placa Y deixou de ser prop em movimento (e desenhada fixa em _draw_fixed_bifurcation_sign()).

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
	if prop_type == DLConfig.PROP_CYCLIST:
		return randf_range(56.0, 74.0) * factor
	if prop_type == DLConfig.PROP_SIGN:
		return randf_range(50.0, 66.0) * factor
	return randf_range(62.0, 84.0) * factor

func _side_prop_recycle_delay(prop_type: String) -> float:
	return randf_range(5.0, 7.0)

func _side_prop_spawn_y(prop_type: String, side: int, viewport_size: Vector2) -> float:
	var start_y: float = _side_prop_start_y(prop_type, side, viewport_size)
	var end_y: float = _side_prop_end_y(prop_type, side, viewport_size)
	if prop_type == DLConfig.PROP_SIGN:
		return lerpf(start_y, end_y, 0.08)
	if prop_type == DLConfig.PROP_CYCLIST:
		return start_y + randf_range(4.0, 16.0)
	return start_y

func _update_side_motion_props(delta: float) -> void:
	if side_props.is_empty():
		_reset_side_props()
	var viewport_size: Vector2 = g.STAGE_SIZE
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(1280, 720)
	for i in range(side_props.size()):
		var data: Dictionary = side_props[i]
		if bool(data.get("expired", false)):
			continue
		var prop_type: String = str(data.get("type", DLConfig.PROP_CYCLIST))
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
	return false

func _side_prop_retry_delay(prop_type: String) -> float:
	if prop_type == DLConfig.PROP_CYCLIST:
		return 1.35
	return 1.0

# ---- desenho ----

func _on_side_props_layer_draw() -> void:
	if g.side_props_layer == null:
		return
	var viewport_size: Vector2 = g.STAGE_SIZE
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	_draw_fixed_bifurcation_sign(viewport_size)
	if not g._animations_enabled():
		return
	# Tutorial limpo: o ciclista só aparece depois do tutorial.
	if g._is_tutorial_state():
		return
	for data in side_props:
		if not bool(data.get("active", true)) or bool(data.get("expired", false)):
			continue
		var prop_type: String = str(data.get("type", DLConfig.PROP_CYCLIST))
		if prop_type != DLConfig.PROP_CYCLIST:
			continue
		var side: int = int(data.get("side", -1))
		var y: float = float(data.get("y", viewport_size.y * 0.45))
		var t: float = _side_prop_depth_t(prop_type, side, y)
		if t <= 0.0:
			continue
		var base_pos: Vector2 = _side_prop_position_at_y(prop_type, side, y, viewport_size)
		# Ciclista oscila levemente (pedalada).
		var bob: float = sin(side_prop_time * 2.3 + float(data.get("phase", 0.0))) * 1.8 * clampf(t, 0.2, 1.0)
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

## Desenho em sprite (PNG) do ciclista.
func _draw_side_prop_sprite(prop_type: String, base: Vector2, depth_t: float, side: int) -> void:
	if g.side_props_layer == null:
		return
	var texture: Texture2D = prop_textures.get(prop_type, null)
	if texture == null:
		_draw_side_prop_fallback(prop_type, base, depth_t, side)
		return
	var viewport_size: Vector2 = g.STAGE_SIZE
	var scale_factor: float = clampf(minf(viewport_size.x / 1280.0, viewport_size.y / 720.0), 0.75, 1.18)
	var target_height: float = 62.0 * scale_factor
	if prop_type == DLConfig.PROP_SIGN:
		target_height = lerpf(34.0, 132.0, depth_t) * scale_factor
	elif prop_type == DLConfig.PROP_CYCLIST:
		target_height = lerpf(38.0, 126.0, depth_t) * scale_factor
	var tex_size: Vector2 = texture.get_size()
	if tex_size.x <= 0.0 or tex_size.y <= 0.0:
		return
	var target_size: Vector2 = Vector2(target_height * tex_size.x / tex_size.y, target_height)
	var rect := Rect2(base - Vector2(target_size.x * 0.5, target_size.y), target_size)
	var alpha: float = clampf(0.52 + depth_t * 0.48, 0.38, 1.0)
	g.side_props_layer.draw_texture_rect(texture, rect, false, Color(1.0, 1.0, 1.0, alpha))

func _draw_side_prop_fallback(prop_type: String, base: Vector2, depth_t: float, _side: int) -> void:
	var h: float = lerpf(18.0, 70.0, depth_t)
	if prop_type == DLConfig.PROP_SIGN:
		g.side_props_layer.draw_line(base, base + Vector2(0.0, -h), Color(0.45, 0.45, 0.48, 0.9), maxf(2.0, 3.0 * depth_t))
		g.side_props_layer.draw_rect(Rect2(base + Vector2(-10.0, -h - 22.0), Vector2(20.0, 20.0)), Color(1.0, 0.82, 0.05, 0.88), true)
	else:
		g.side_props_layer.draw_circle(base + Vector2(0.0, -h * 0.40), maxf(4.0, h * 0.18), Color(0.0, 0.78, 0.95, 0.82))
