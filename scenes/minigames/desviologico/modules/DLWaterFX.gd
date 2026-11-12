extends RefCounted
class_name DLWaterFX
## Efeito visual do mar (ondas, brilho, reflexo). Desenha na camada water_layer do jogo.

var g: DesvioLogicoGame

func _init(game: DesvioLogicoGame) -> void:
	g = game

# ---- estado ----
var water_time: float = 0.0
var water_redraw_accumulator: float = 0.0
var water_mask_shader_layer: ColorRect

func _water_x_range_at_y(side: int, y: float, viewport_size: Vector2) -> Vector2:
	# V0.13.12.6: máscara ainda mais restritiva para o background único.
	# Como gramado/mureta/pista não são camadas separadas, o overlay evita a
	# borda interna do mar com uma margem extra, principalmente na faixa média
	# onde as ondas ainda encostavam no gramado.
	var horizon_y: float = viewport_size.y * 0.382
	var max_y: float = viewport_size.y * 0.715
	var depth_t: float = clampf((y - horizon_y) / maxf(max_y - horizon_y, 1.0), 0.0, 1.0)
	var curve_to_road: float = pow(depth_t, 0.70)
	var lower_lock: float = pow(depth_t, 1.72)
	var mid_guard: float = sin(clampf(depth_t, 0.0, 1.0) * PI) * 0.050
	var inner_ratio: float = lerpf(0.430, 0.030, curve_to_road)
	var safety_ratio: float = lerpf(0.048, 0.150, lower_lock) + mid_guard
	var safety_px: float = viewport_size.x * safety_ratio
	var edge_margin: float = viewport_size.x * 0.014
	var min_width: float = viewport_size.x * lerpf(0.044, 0.013, lower_lock)
	if side < 0:
		var end_x: float = viewport_size.x * inner_ratio - safety_px
		end_x = clampf(end_x, edge_margin + min_width, viewport_size.x * 0.385)
		return Vector2(edge_margin, end_x)
	var start_x: float = viewport_size.x * (1.0 - inner_ratio) + safety_px
	start_x = clampf(start_x, viewport_size.x * 0.615, viewport_size.x - edge_margin - min_width)
	return Vector2(start_x, viewport_size.x - edge_margin)

func _create_water_mask_shader_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
render_mode blend_mix;

uniform float water_time = 0.0;
uniform float intensity = 1.0;

float water_mask(vec2 uv) {
	float horizon_y = 0.382;
	float max_y = 0.715;
	float depth_t = clamp((uv.y - horizon_y) / max(max_y - horizon_y, 0.001), 0.0, 1.0);
	float y_mask = smoothstep(horizon_y, horizon_y + 0.018, uv.y) * (1.0 - smoothstep(max_y - 0.018, max_y, uv.y));
	float curve_to_road = pow(depth_t, 0.70);
	float lower_lock = pow(depth_t, 1.72);
	float mid_guard = sin(clamp(depth_t, 0.0, 1.0) * 3.14159265) * 0.050;
	float inner_ratio = mix(0.430, 0.030, curve_to_road);
	float safety_ratio = mix(0.048, 0.150, lower_lock) + mid_guard;
	float edge_margin = 0.014;
	float left_inner = clamp(inner_ratio - safety_ratio, edge_margin + 0.030, 0.385);
	float right_inner = clamp(1.0 - inner_ratio + safety_ratio, 0.615, 1.0 - edge_margin - 0.030);
	float left_mask = step(edge_margin, uv.x) * (1.0 - step(left_inner, uv.x));
	float right_mask = step(right_inner, uv.x) * (1.0 - step(1.0 - edge_margin, uv.x));
	return y_mask * max(left_mask, right_mask);
}

void fragment() {
	vec2 uv = UV;
	float mask = water_mask(uv);
	if (mask <= 0.001) {
		COLOR = vec4(0.0);
		return;
	}
	float depth = clamp((uv.y - 0.382) / max(0.715 - 0.382, 0.001), 0.0, 1.0);
	float horizontal_lines = smoothstep(0.955, 1.0, sin(uv.y * 720.0 * mix(0.34, 0.62, depth) + water_time * 2.15 + sin(uv.x * 28.0) * 0.55));
	float broken = smoothstep(0.34, 0.96, sin(uv.x * 86.0 + water_time * 0.82 + sin(uv.y * 18.0) * 1.6));
	float sparkle = smoothstep(0.90, 1.0, sin((uv.x + uv.y) * 115.0 + water_time * 1.75));
	float pulse = 0.58 + 0.42 * sin(water_time * 1.05 + uv.x * 8.0 + uv.y * 6.0);
	float alpha = mask * intensity * (horizontal_lines * broken * 0.105 + sparkle * 0.030) * pulse;
	alpha *= mix(1.10, 0.55, depth);
	vec3 water_light = mix(vec3(0.20, 0.88, 1.0), vec3(0.70, 0.98, 1.0), horizontal_lines);
	COLOR = vec4(water_light, clamp(alpha, 0.0, 0.18));
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("water_time", 0.0)
	material.set_shader_parameter("intensity", 0.0)
	return material

func _update_water_mask_shader() -> void:
	# Shader cancelado; garante que a camada de brilhos por linhas continue ativa.
	if water_mask_shader_layer != null:
		water_mask_shader_layer.visible = false
	if g.water_layer != null:
		g.water_layer.visible = true

func _on_water_layer_draw() -> void:
	if DLConfig.WATER_EFFECT_QUALITY <= 0:
		return
	if not g._animations_enabled():
		return
	var viewport_size: Vector2 = g.get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	# V0.13.12.2: Mar Vivo. Em vez de tentar filtrar o background inteiro,
	# desenha uma pele animada apenas nas faixas laterais seguras de água.
	_draw_living_water_surface(viewport_size)

func _draw_living_water_surface(viewport_size: Vector2) -> void:
	var scale_factor: float = clampf(minf(viewport_size.x / 1280.0, viewport_size.y / 720.0), 0.75, 1.18)
	var horizon_y: float = viewport_size.y * 0.382
	var max_y: float = viewport_size.y * 0.715
	var stage_intensity: float = _water_stage_intensity()
	if stage_intensity <= 0.0:
		return
	for side in [-1, 1]:
		_draw_water_horizon_glow(side, viewport_size, horizon_y, max_y, scale_factor, stage_intensity)
		_draw_water_soft_surface(side, viewport_size, horizon_y, max_y, scale_factor, stage_intensity)
		_draw_water_animated_waves(side, viewport_size, horizon_y, max_y, scale_factor, stage_intensity)
		_draw_water_light_reflection_zone(side, viewport_size, horizon_y, max_y, scale_factor, stage_intensity)
		_draw_water_surface_glints(side, viewport_size, horizon_y, max_y, scale_factor, stage_intensity)
		_draw_water_peripheral_shimmers(side, viewport_size, horizon_y, max_y, scale_factor, stage_intensity)
		if DLConfig.DEBUG_WATER_POINTS:
			_draw_water_debug_bounds(side, viewport_size, horizon_y, max_y)

func _draw_water_horizon_glow(side: int, viewport_size: Vector2, horizon_y: float, max_y: float, scale_factor: float, stage_intensity: float) -> void:
	# Brilho orgânico no topo do mar, próximo da cidade/reflexo do horizonte.
	# São linhas quebradas e pulsantes, não um retângulo global.
	var glow_rows: int = _lod(9 if DLConfig.WATER_EFFECT_QUALITY == 1 else 12, 4)
	for row in range(glow_rows):
		var row_t: float = float(row) / maxf(float(glow_rows - 1), 1.0)
		var y: float = lerpf(horizon_y + viewport_size.y * 0.010, horizon_y + viewport_size.y * 0.115, row_t)
		if y > max_y:
			continue
		var x_range: Vector2 = _water_x_range_at_y(side, y, viewport_size)
		var available_w: float = x_range.y - x_range.x
		if available_w < viewport_size.x * 0.050:
			continue
		var segment_count: int = 3 + int(row_t * 2.0)
		for seg in range(segment_count):
			var glow_key: float = float(row * 7 + seg * 13) + (29.0 if side > 0 else 3.0)
			var center_ratio: float = fmod(0.13 + glow_key * 0.217 + water_time * 0.006 * float(side), 0.78)
			var phase: float = water_time * (0.95 + row_t * 0.35) + glow_key * 0.53
			var length: float = available_w * lerpf(0.090, 0.195, 1.0 - row_t) * (0.76 + 0.18 * sin(phase * 0.7))
			var min_length: float = minf(viewport_size.x * 0.030, available_w * 0.30)
			length = clampf(length, min_length, available_w * 0.245)
			var center_x: float = lerpf(x_range.x + available_w * 0.08, x_range.y - available_w * 0.08, center_ratio)
			var start_x: float = maxf(x_range.x, center_x - length * 0.5)
			var end_x: float = minf(x_range.y, center_x + length * 0.5)
			if end_x <= start_x + 5.0:
				continue
			var pulse: float = 0.56 + 0.44 * sin(phase)
			var alpha: float = lerpf(0.14, 0.34, 1.0 - row_t) * stage_intensity * pulse * _water_horizon_glow_strength()
			var line_y: float = y + sin(phase * 0.42) * 0.45 * scale_factor
			g.water_layer.draw_line(Vector2(start_x, line_y), Vector2(end_x, line_y), _water_horizon_glow_color(alpha), lerpf(0.75, 1.20, 1.0 - row_t) * scale_factor)

func _draw_water_soft_surface(side: int, viewport_size: Vector2, horizon_y: float, max_y: float, scale_factor: float, stage_intensity: float) -> void:
	# Faixas suaves agora são micro-segmentadas. Evita uma linha inteira
	# atravessar visualmente o gramado/mureta do background único.
	var band_count: int = _lod(19 if DLConfig.WATER_EFFECT_QUALITY == 1 else 25, 8)
	for i in range(band_count):
		var band_key: float = float(i) + (31.0 if side > 0 else 7.0)
		var depth_t: float = float(i) / maxf(float(band_count - 1), 1.0)
		var y: float = lerpf(horizon_y + viewport_size.y * 0.012, max_y - viewport_size.y * 0.020, depth_t)
		var x_range: Vector2 = _water_x_range_at_y(side, y, viewport_size)
		var available_w: float = x_range.y - x_range.x
		if available_w < viewport_size.x * 0.032:
			continue
		var wave_offset: float = sin(water_time * (0.44 + depth_t * 0.28) + band_key * 0.73) * lerpf(1.15, 0.35, depth_t) * scale_factor
		var band_alpha: float = lerpf(0.052, 0.014, depth_t) * stage_intensity
		if depth_t > 0.30 and depth_t < 0.72:
			band_alpha *= 1.16
		var band_color: Color = _water_surface_color(band_alpha)
		var top_y: float = y + wave_offset
		var height: float = lerpf(1.42, 0.42, depth_t) * scale_factor
		var segment_count: int = 5 if depth_t < 0.48 else (4 if depth_t < 0.72 else 2)
		for seg in range(segment_count):
			var segment_key: float = band_key + float(seg) * 5.37
			var center_ratio: float = fmod(0.10 + segment_key * 0.211 + water_time * 0.004 * float(side), 0.82)
			var seg_w: float = available_w * lerpf(0.096, 0.028, depth_t) * (0.86 + 0.14 * sin(segment_key + water_time * 0.35))
			seg_w = minf(seg_w, available_w * 0.135)
			var center_x: float = lerpf(x_range.x + available_w * 0.08, x_range.y - available_w * 0.08, center_ratio)
			var start_x: float = maxf(x_range.x + available_w * 0.018, center_x - seg_w * 0.5)
			var end_x: float = minf(x_range.y - available_w * 0.018, center_x + seg_w * 0.5)
			if end_x > start_x + 4.0:
				g.water_layer.draw_rect(Rect2(Vector2(start_x, top_y), Vector2(end_x - start_x, height)), band_color, true)

func _draw_water_animated_waves(side: int, viewport_size: Vector2, horizon_y: float, max_y: float, scale_factor: float, stage_intensity: float) -> void:
	# V1.0.2.3: o mar usa brilhos horizontais curtos, não ondas senoidais.
	# As linhas aparecem e somem em pontos diferentes para dar vida sem invadir estrada/HUD.
	var shimmer_count: int = _lod(64 if DLConfig.WATER_EFFECT_QUALITY == 1 else 88, 20)
	for i in range(shimmer_count):
		var shimmer_key: float = float(i) + (19.0 if side > 0 else 5.0)
		var raw_depth: float = fmod(shimmer_key * 0.61803398875, 1.0)
		var depth_t: float = clampf(pow(raw_depth, 1.06) * 0.96, 0.0, 0.96)
		var y: float = lerpf(horizon_y + viewport_size.y * 0.014, max_y - viewport_size.y * 0.026, depth_t)
		var x_range: Vector2 = _water_x_range_at_y(side, y, viewport_size)
		var available_w: float = x_range.y - x_range.x
		if available_w < viewport_size.x * 0.026:
			continue
		var phase: float = water_time * (1.04 + float(i % 6) * 0.08) + shimmer_key * 1.31
		var pulse: float = 0.5 + 0.5 * sin(phase)
		if pulse < 0.18:
			continue
		var drift: float = fmod(100.0 + shimmer_key * 0.251 + water_time * 0.009 * float(side), 1.0)
		var local_x: float = fmod(0.06 + shimmer_key * 0.173 + drift, 0.88)
		var length: float = minf(available_w * lerpf(0.070, 0.020, depth_t), viewport_size.x * lerpf(0.046, 0.012, depth_t)) * scale_factor
		length *= 0.84 + 0.16 * sin(phase * 0.37)
		var inner_padding: float = available_w * lerpf(0.075, 0.155, depth_t)
		var center_x: float = lerpf(x_range.x + inner_padding, x_range.y - inner_padding, local_x)
		var line_y: float = y + sin(phase * 0.33) * lerpf(0.85, 0.25, depth_t) * scale_factor
		var start_x: float = maxf(x_range.x + available_w * 0.012, center_x - length * 0.5)
		var end_x: float = minf(x_range.y - available_w * 0.012, center_x + length * 0.5)
		if end_x <= start_x + 3.0:
			continue
		var alpha: float = lerpf(0.40, 0.16, depth_t) * stage_intensity * pulse
		if depth_t < 0.18 or depth_t > 0.82:
			alpha *= 0.88
		var thickness: float = maxf(0.55, lerpf(0.82, 0.24, depth_t) * scale_factor)
		g.water_layer.draw_line(Vector2(start_x, line_y), Vector2(end_x, line_y), _water_shimmer_color(alpha), thickness)
		if i % 5 == 0 and length > viewport_size.x * 0.018:
			var offset_y: float = line_y + lerpf(2.2, 0.8, depth_t) * scale_factor
			var mini_len: float = length * 0.38
			var mini_start: float = clampf(center_x - mini_len * 0.5 + length * 0.30, x_range.x, x_range.y)
			var mini_end: float = minf(mini_start + mini_len, x_range.y)
			if mini_end > mini_start + 2.0:
				g.water_layer.draw_line(Vector2(mini_start, offset_y), Vector2(mini_end, offset_y), _water_shimmer_color(alpha * 0.55), maxf(0.45, thickness * 0.72))

func _draw_water_light_reflection_zone(side: int, viewport_size: Vector2, horizon_y: float, max_y: float, scale_factor: float, stage_intensity: float) -> void:
	var light_ratio: float = _water_light_x_ratio()
	var side_min: float = 0.0 if side < 0 else 0.5
	var side_max: float = 0.5 if side < 0 else 1.0
	if light_ratio < side_min or light_ratio > side_max:
		if absf(light_ratio - (0.25 if side < 0 else 0.75)) > 0.34:
			return
	var center_x: float = viewport_size.x * light_ratio
	var ray_count: int = _lod(12 if DLConfig.WATER_EFFECT_QUALITY == 1 else 18, 5)
	for i in range(ray_count):
		var depth: float = float(i) / maxf(float(ray_count - 1), 1.0)
		var y: float = lerpf(horizon_y + viewport_size.y * 0.006, max_y - viewport_size.y * 0.055, depth)
		var x_range: Vector2 = _water_x_range_at_y(side, y, viewport_size)
		var available_w: float = x_range.y - x_range.x
		if available_w < viewport_size.x * 0.036:
			continue
		var spread: float = minf(available_w * lerpf(0.074, 0.018, depth), viewport_size.x * lerpf(0.046, 0.009, depth)) * scale_factor
		var phase: float = water_time * (1.18 + depth * 0.34) + float(i) * 0.91 + float(side) * 0.40
		var pulse: float = 0.52 + 0.48 * sin(phase)
		if pulse < 0.16:
			continue
		var center_shift: float = sin(phase * 0.72) * lerpf(4.8, 1.8, depth) * scale_factor
		var line_center: float = clampf(center_x + center_shift, x_range.x + spread * 0.34, x_range.y - spread * 0.34)
		var start_x: float = maxf(x_range.x, line_center - spread * (0.52 + 0.10 * sin(phase * 0.7)))
		var end_x: float = minf(x_range.y, line_center + spread * (0.52 + 0.09 * cos(phase * 0.6)))
		if end_x <= start_x + 5.0:
			continue
		var alpha: float = lerpf(0.42, 0.12, depth) * stage_intensity * pulse * _water_light_reflection_strength()
		g.water_layer.draw_line(Vector2(start_x, y), Vector2(end_x, y), _water_glint_color(alpha), maxf(0.45, lerpf(0.64, 0.22, depth) * scale_factor))

func _draw_water_surface_glints(side: int, viewport_size: Vector2, horizon_y: float, max_y: float, scale_factor: float, stage_intensity: float) -> void:
	var glint_count: int = _lod(42 if DLConfig.WATER_EFFECT_QUALITY == 1 else 62, 14)
	for i in range(glint_count):
		var glint_key: float = float(i) + (43.0 if side > 0 else 11.0)
		var depth_t: float = fmod(glint_key * 0.41421356237, 1.0)
		var y: float = lerpf(horizon_y + viewport_size.y * 0.015, max_y - viewport_size.y * 0.018, depth_t)
		var x_range: Vector2 = _water_x_range_at_y(side, y, viewport_size)
		var available_w: float = x_range.y - x_range.x
		if available_w < viewport_size.x * 0.040:
			continue
		var phase: float = water_time * (1.20 + float(i % 3) * 0.18) + glint_key * 0.89
		var pulse: float = 0.5 + 0.5 * sin(phase)
		if pulse < 0.10:
			continue
		var x: float = lerpf(x_range.x + available_w * 0.08, x_range.y - available_w * 0.08, fmod(100.0 + glint_key * 0.263 + water_time * 0.016 * float(side), 1.0))
		var size_value: float = lerpf(4.2, 1.4, depth_t) * scale_factor
		var alpha: float = lerpf(0.70, 0.30, depth_t) * stage_intensity * pulse
		var center := Vector2(x, y + sin(phase * 0.68) * lerpf(1.6, 0.6, depth_t) * scale_factor)
		var half_w: float = size_value * lerpf(2.4, 0.9, depth_t)
		var start_x: float = maxf(center.x - half_w, x_range.x)
		var end_x: float = minf(center.x + half_w, x_range.y)
		if end_x > start_x + 2.0:
			g.water_layer.draw_line(Vector2(start_x, center.y), Vector2(end_x, center.y), _water_glint_color(alpha), maxf(0.55, lerpf(0.78, 0.30, depth_t) * scale_factor))
			if i % 4 == 0:
				var short_end: float = minf(start_x + (end_x - start_x) * 0.42, x_range.y)
				g.water_layer.draw_line(Vector2(start_x, center.y + size_value * 0.72), Vector2(short_end, center.y + size_value * 0.72), _water_glint_color(alpha * 0.46), maxf(0.40, lerpf(0.56, 0.22, depth_t) * scale_factor))

func _draw_water_peripheral_shimmers(side: int, viewport_size: Vector2, horizon_y: float, max_y: float, scale_factor: float, stage_intensity: float) -> void:
	# V1.0.2.4: reforço discreto nos cantos superiores/inferiores do mar.
	# Mantém linhas curtas e horizontais, sem voltar para ondas grandes.
	var extra_count: int = _lod(24 if DLConfig.WATER_EFFECT_QUALITY == 1 else 34, 8)
	for i in range(extra_count):
		var extra_key: float = float(i) + (71.0 if side > 0 else 23.0)
		var cluster: float = fmod(extra_key * 0.73205080757, 1.0)
		var depth_t: float = 0.0
		if cluster < 0.38:
			depth_t = lerpf(0.06, 0.25, fmod(extra_key * 0.31830988618, 1.0))
		elif cluster < 0.72:
			depth_t = lerpf(0.70, 0.94, fmod(extra_key * 0.41421356237, 1.0))
		else:
			depth_t = lerpf(0.30, 0.66, fmod(extra_key * 0.27182818284, 1.0))
		var y: float = lerpf(horizon_y + viewport_size.y * 0.010, max_y - viewport_size.y * 0.016, depth_t)
		var x_range: Vector2 = _water_x_range_at_y(side, y, viewport_size)
		var available_w: float = x_range.y - x_range.x
		if available_w < viewport_size.x * 0.035:
			continue
		var phase: float = water_time * (1.08 + float(i % 5) * 0.10) + extra_key * 0.77
		var pulse: float = 0.5 + 0.5 * sin(phase)
		if pulse < 0.20:
			continue
		var margin_ratio: float = 0.06 if cluster < 0.5 else 0.18
		var local_ratio: float = fmod(0.04 + extra_key * 0.193 + water_time * 0.012 * float(side), 0.92)
		var center_x: float = lerpf(x_range.x + available_w * margin_ratio, x_range.y - available_w * margin_ratio, local_ratio)
		var length: float = minf(available_w * lerpf(0.052, 0.018, depth_t), viewport_size.x * lerpf(0.032, 0.010, depth_t)) * scale_factor
		length *= 0.88 + 0.14 * sin(phase * 0.41)
		var line_y: float = y + sin(phase * 0.29) * lerpf(0.55, 0.18, depth_t) * scale_factor
		var start_x: float = maxf(x_range.x + available_w * 0.010, center_x - length * 0.5)
		var end_x: float = minf(x_range.y - available_w * 0.010, center_x + length * 0.5)
		if end_x <= start_x + 3.0:
			continue
		var alpha: float = lerpf(0.32, 0.13, depth_t) * stage_intensity * pulse
		if depth_t < 0.24 or depth_t > 0.70:
			alpha *= 1.18
		g.water_layer.draw_line(Vector2(start_x, line_y), Vector2(end_x, line_y), _water_shimmer_color(alpha), maxf(0.50, lerpf(0.68, 0.22, depth_t) * scale_factor))
		if i % 6 == 0:
			var short_len: float = (end_x - start_x) * 0.42
			var short_start: float = clampf(start_x + (end_x - start_x) * 0.54, x_range.x, x_range.y)
			var short_end: float = minf(short_start + short_len, x_range.y)
			if short_end > short_start + 2.0:
				g.water_layer.draw_line(Vector2(short_start, line_y + 2.0 * scale_factor), Vector2(short_end, line_y + 2.0 * scale_factor), _water_glint_color(alpha * 0.50), maxf(0.38, lerpf(0.48, 0.18, depth_t) * scale_factor))

func _draw_water_broken_wave(start_x: float, end_x: float, base_y: float, amplitude: float, phase: float, color: Color, width: float, piece_count: int) -> void:
	var span: float = end_x - start_x
	if span <= 3.0:
		return
	var pieces: int = clampi(piece_count, 1, 4)
	for piece in range(pieces):
		var piece_span: float = span / float(pieces)
		var gap_ratio: float = 0.42 if pieces > 1 else 0.0
		var piece_start: float = start_x + piece_span * float(piece) + piece_span * gap_ratio * 0.5
		var piece_end: float = minf(start_x + piece_span * float(piece + 1) - piece_span * gap_ratio * 0.5, end_x)
		if piece_end > piece_start + 3.0:
			_draw_water_poly_wave(piece_start, piece_end, base_y, amplitude, phase + float(piece) * 0.47, color, width)

func _draw_water_poly_wave(start_x: float, end_x: float, base_y: float, amplitude: float, phase: float, color: Color, width: float) -> void:
	var points := PackedVector2Array()
	var segments: int = 4
	var span: float = end_x - start_x
	for p_i in range(segments + 1):
		var t: float = float(p_i) / float(segments)
		var x: float = start_x + span * t
		var y: float = base_y + sin(phase + t * TAU) * amplitude
		points.append(Vector2(x, y))
	g.water_layer.draw_polyline(points, color, width, not WebLite.lite())

## V0.14.5: quantidade de elementos da agua ajustada ao perfil (web = 60 %, aparelho fraco = 35 %), com minimo.
func _lod(base: int, minimum: int) -> int:
	return maxi(int(round(float(base) * WebLite.water_density())), minimum)

func _water_stage_intensity() -> float:
	match g.current_round:
		0:
			return 1.22
		1:
			return 1.28
		2:
			return 1.18
		3:
			return 1.18
		4:
			return 1.05
		_:
			return 0.92

func _water_light_x_ratio() -> float:
	match g.current_round:
		0:
			return 0.13
		1:
			return 0.53
		2:
			return 0.88
		3:
			return 0.14
		4:
			return 0.12
		_:
			return 0.84

func _water_light_reflection_strength() -> float:
	match g.current_round:
		0, 1, 2:
			return 1.14
		3:
			return 1.25
		4:
			return 0.96
		_:
			return 0.82

func _water_surface_color(alpha: float) -> Color:
	match g.current_round:
		0:
			return Color(0.34, 0.78, 0.98, alpha)
		1:
			return Color(0.42, 0.92, 1.0, alpha)
		2:
			return Color(0.34, 0.78, 1.0, alpha)
		3:
			return Color(0.35, 0.56, 0.95, alpha)
		4:
			return Color(0.26, 0.40, 0.82, alpha)
		_:
			return Color(0.18, 0.34, 0.78, alpha)

func _water_shimmer_color(alpha: float) -> Color:
	match g.current_round:
		0:
			return Color(1.0, 0.78, 0.28, alpha)
		1:
			return Color(0.78, 1.0, 1.0, alpha)
		2:
			return Color(1.0, 0.88, 0.34, alpha)
		3:
			return Color(1.0, 0.56, 0.22, alpha)
		4:
			return Color(0.85, 0.60, 1.0, alpha)
		_:
			return Color(0.50, 0.84, 1.0, alpha)

func _water_glint_color(alpha: float) -> Color:
	match g.current_round:
		0, 2:
			return Color(1.0, 0.88, 0.36, alpha)
		1:
			return Color(0.94, 1.0, 1.0, alpha)
		3:
			return Color(1.0, 0.62, 0.30, alpha)
		4:
			return Color(0.98, 0.62, 1.0, alpha)
		_:
			return Color(0.66, 0.90, 1.0, alpha)

func _water_horizon_glow_strength() -> float:
	match g.current_round:
		0:
			return 1.18
		1:
			return 1.28
		2:
			return 1.22
		3:
			return 1.32
		4:
			return 1.18
		_:
			return 0.92

func _water_horizon_glow_color(alpha: float) -> Color:
	match g.current_round:
		0:
			return Color(1.0, 0.76, 0.30, alpha)
		1:
			return Color(0.84, 1.0, 1.0, alpha)
		2:
			return Color(1.0, 0.90, 0.42, alpha)
		3:
			return Color(1.0, 0.50, 0.24, alpha)
		4:
			return Color(1.0, 0.56, 0.86, alpha)
		_:
			return Color(0.48, 0.74, 1.0, alpha)

func _draw_water_debug_bounds(side: int, viewport_size: Vector2, horizon_y: float, max_y: float) -> void:
	var prev_point: Vector2 = Vector2.ZERO
	for i in range(16):
		var depth_t: float = float(i) / 15.0
		var y: float = lerpf(horizon_y, max_y, depth_t)
		var x_range: Vector2 = _water_x_range_at_y(side, y, viewport_size)
		var point := Vector2(x_range.y if side < 0 else x_range.x, y)
		g.water_layer.draw_circle(point, 3.0, Color(1.0, 0.05, 0.05, 0.82))
		if i > 0:
			g.water_layer.draw_line(prev_point, point, Color(1.0, 0.05, 0.05, 0.45), 1.5)
		prev_point = point
