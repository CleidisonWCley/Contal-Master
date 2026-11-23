extends RefCounted
class_name DLSideProps
## Props laterais da estrada: ciclista (esquerda) e placa fixa de bifurcacao. Spawn, movimento em perspectiva e desenho.
##
## V0.16.11.1: POSTES FIXOS de volta, agora desenhados por script e parados (nao nascem nem se movem; o cenario e estatico).
## 4 postes (V0.16.11.1d: o poste dinamico do canto inferior foi retirado): 2 de cada lado, sobre a CALCADA (markers PostLeft*/PostRight*): Start (perto da placa), Mid (meio) e End (canto inferior).
## O lado direito e ESPELHADO do esquerdo (mesma distancia). Os postes ficam ABAIXO dos sprites da pista (carros, ciclista): nada some atras deles.
## Do Entardecer a Noite cada poste ganha uma bolinha branca alinhada com a lampada (DLConfig.POLE_LIGHT_BY_ROUND), sem luz grande no chao.
## Os markers PostLeft*/PostRight* continuam guiando tambem as listras decorativas do gramado (PROP_TRAIL_LEFT / PROP_TRAIL_RIGHT).
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
var _pole_cache: Array = []   # V0.16.11.1: [{pos: Vector2, height: float, dir: float}] (lido uma vez; invalidado com as trilhas)

func _load_side_prop_textures() -> void:
	prop_textures.clear()
	for prop_type in DLConfig.PROP_SPRITES.keys():
		prop_textures[prop_type] = g._load_texture(str(DLConfig.PROP_SPRITES[prop_type]))

# ---- trilhas (markers do editor) ----

## Descarta o cache das trilhas (chamado ao iniciar cada desafio e quando a janela muda de tamanho).
func _invalidate_path_cache() -> void:
	_path_cache.clear()
	_pole_cache.clear()

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
	# V0.16.11.1: postes sao fixos (desenhados direto, nao entram em side_props). So o ciclista se move, pelo lado esquerdo da pista.
	# Dois ciclistas por partida (mantido). Os instantes sao proporcionais a duracao do percurso (18 s): o 2o ainda cruza a tela antes da parada.
	var drive_len: float = g._drive_duration()
	_add_side_prop(DLConfig.PROP_CYCLIST, -1, _side_prop_start_y(DLConfig.PROP_CYCLIST, -1, viewport_size), _side_prop_base_speed(DLConfig.PROP_CYCLIST), false, false, drive_len * 0.12)
	_add_side_prop(DLConfig.PROP_CYCLIST, -1, _side_prop_start_y(DLConfig.PROP_CYCLIST, -1, viewport_size), _side_prop_base_speed(DLConfig.PROP_CYCLIST), false, false, drive_len * 0.46)
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
	# Postes primeiro: tudo que e desenhado depois (placa, ciclista) e os carros (camada acima) ficam NA FRENTE deles.
	_draw_fixed_poles(viewport_size)
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

# ---- postes fixos (V0.16.11.1) ----

## Pontos dos 6 postes (cache). Lado esquerdo = markers PostLeftStart/Mid/End; lado direito = espelho (x = largura - x). O poste do canto inferior
## fica um pouco para dentro da tela, ainda SOBRE a linha da calcada (a marker End esta na borda).
func _pole_points(viewport_size: Vector2) -> Array:
	if not _pole_cache.is_empty():
		return _pole_cache
	var width: float = viewport_size.x
	var start_pos: Vector2 = _pole_marker_pos("Start", Vector2(555.0, 250.0))
	var mid_pos: Vector2 = _pole_marker_pos("Mid", Vector2(284.0, 440.0))
	var heights: Array = [DLConfig.POLE_HEIGHT_FAR, DLConfig.POLE_HEIGHT_MID]
	var lefts: Array = [start_pos, mid_pos]
	for i in range(lefts.size()):
		var left_pos: Vector2 = lefts[i]
		_pole_cache.append({"pos": left_pos, "height": float(heights[i]), "dir": 1.0})
		_pole_cache.append({"pos": Vector2(width - left_pos.x, left_pos.y), "height": float(heights[i]), "dir": -1.0})
	return _pole_cache

func _pole_marker_pos(point_name: String, fallback: Vector2) -> Vector2:
	var marker: Node = g.get_node_or_null("SidePropMarkers/PostLeft%s" % point_name)
	if marker != null and marker.is_inside_tree():
		return g._canvas_item_global_position(marker)
	return fallback

func _draw_fixed_poles(viewport_size: Vector2) -> void:
	var points: Array = _pole_points(viewport_size)
	var scale_factor: float = clampf(minf(viewport_size.x / 1280.0, viewport_size.y / 720.0), 0.75, 1.18)
	var light: float = 0.0
	var round_table: Array = DLConfig.POLE_LIGHT_BY_ROUND
	if not round_table.is_empty():
		light = clampf(float(round_table[clampi(g.current_round, 0, round_table.size() - 1)]), 0.0, 1.0)
	# Do mais longe (y menor) para o mais perto: o poste proximo cobre o distante, como na perspectiva.
	var order: Array = points.duplicate()
	order.sort_custom(func(a, b): return float(a["pos"].y) < float(b["pos"].y))
	for data in order:
		_draw_pole(data["pos"], float(data["height"]) * scale_factor, float(data["dir"]), light)

## Um poste: sombra, base, haste, braco curvo apontando para a pista e cabeca da lampada. Tudo por script (sem PNG).
## `light` (0..1) acende a bolinha branca, centrada na lampada (alinhada com o poste).
func _draw_pole(base: Vector2, h: float, dir: float, light: float) -> void:
	var layer: Control = g.side_props_layer
	var night: float = clampf(light, 0.0, 1.0)
	var shaft_color: Color = Color(0.22, 0.22, 0.27).lerp(Color(0.10, 0.10, 0.15), night * 0.8)
	var edge_color: Color = shaft_color.lightened(0.28)
	var w: float = maxf(3.0, h * 0.022)
	var top_y: float = base.y - h
	# sombra no chao
	var sw: float = maxf(8.0, h * 0.09)
	var sh: float = maxf(2.0, h * 0.018)
	var shadow := PackedVector2Array()
	for k in range(12):
		var a: float = TAU * float(k) / 12.0
		shadow.append(base + Vector2(cos(a) * sw, sin(a) * sh))
	layer.draw_colored_polygon(shadow, Color(0.0, 0.0, 0.0, 0.26))
	# base (sapata) e haste
	layer.draw_rect(Rect2(base.x - w * 1.25, base.y - h * 0.035, w * 2.5, h * 0.035), shaft_color.darkened(0.15), true)
	layer.draw_rect(Rect2(base.x - w * 0.5, top_y, w, h), shaft_color, true)
	layer.draw_rect(Rect2(base.x - w * 0.5, top_y, maxf(1.0, w * 0.32), h), edge_color, true)
	# braco: sobe um pouco e vai em direcao a pista
	var arm_len: float = h * DLConfig.POLE_ARM_RATIO
	var p0: Vector2 = Vector2(base.x, top_y)
	var p1: Vector2 = p0 + Vector2(dir * arm_len * 0.30, -h * 0.032)
	var p2: Vector2 = p0 + Vector2(dir * arm_len, -h * 0.026)
	var arm_w: float = maxf(2.0, w * 0.75)
	layer.draw_polyline(PackedVector2Array([p0, p1, p2]), shaft_color, arm_w)
	# cabeca da lampada (caixa curta) e a lente embaixo
	var head_w: float = maxf(6.0, h * 0.065)
	var head_h: float = maxf(2.5, h * 0.022)
	var head_rect := Rect2(p2.x - head_w * 0.5, p2.y - head_h * 0.5, head_w, head_h)
	layer.draw_rect(head_rect, shaft_color.darkened(0.1), true)
	var lens_c: Vector2 = Vector2(p2.x, p2.y + head_h * 0.5 + maxf(1.0, h * 0.004))
	var ball_r: float = maxf(2.2, h * 0.018)
	if night > 0.01:
		# bolinha branca perfeitamente centrada na lampada (um halo curto so para ela nao "sumir" no fundo claro do entardecer)
		layer.draw_circle(lens_c, ball_r * 2.0, Color(1.0, 1.0, 0.95, 0.16 * night))
		layer.draw_circle(lens_c, ball_r, Color(1.0, 1.0, 0.97, 0.98 * night))
	else:
		layer.draw_circle(lens_c, ball_r * 0.7, Color(0.62, 0.62, 0.66, 0.9))

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
