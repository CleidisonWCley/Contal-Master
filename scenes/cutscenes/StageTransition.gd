extends Control

const ICON_PATHS := {
	"show_do_bilhao": Paths.ICON_MONEY,
	"batalha_naval": Paths.ICON_NAVAL,
	"maleta_certa": Paths.ICON_SUITCASE,
	"roleta_risco": Paths.ICON_DANGER,
	"perseguicao": Paths.ICON_LOCK,
	"forca_tecnica": Paths.ICON_LOCK,
	"stop": Paths.ICON_STOP,
	"desvio_logico": Paths.ICON_PLAY
}

const STYLE_MAP := {
	"show_do_bilhao": {"bg": Color(0.025, 0.018, 0.080), "accent": Color(1.0, 0.82, 0.12), "secondary": Color(1.0, 0.52, 0.08), "symbol": "$"},
	"batalha_naval": {"bg": Color(0.015, 0.060, 0.170), "accent": Color(0.25, 0.78, 1.0), "secondary": Color(0.14, 0.42, 1.0), "symbol": "@anchor"},
	"maleta_certa": {"bg": Color(0.110, 0.035, 0.020), "accent": Color(1.0, 0.66, 0.20), "secondary": Color(1.0, 0.28, 0.18), "symbol": "@briefcase"},
	"roleta_risco": {"bg": Color(0.105, 0.012, 0.155), "accent": Color(1.0, 0.35, 1.0), "secondary": Color(0.12, 0.16, 1.0), "symbol": "!"},
	"perseguicao": {"bg": Color(0.025, 0.025, 0.035), "accent": Color(1.0, 0.22, 0.18), "secondary": Color(0.12, 0.25, 1.0), "symbol": "@danger"},
	"forca_tecnica": {"bg": Color(0.010, 0.060, 0.085), "accent": Color(0.46, 1.0, 0.82), "secondary": Color(0.22, 0.64, 1.0), "symbol": "@puzzle"},
	"stop": {"bg": Color(0.018, 0.110, 0.040), "accent": Color(0.82, 1.0, 0.82), "secondary": Color(0.22, 0.72, 0.28), "symbol": "@stop"},
	"desvio_logico": {"bg": Color(0.020, 0.008, 0.070), "accent": Color(0.0, 0.88, 1.0), "secondary": Color(1.0, 0.42, 0.05), "symbol": "@car"}
}

const PARTICLE_AMOUNT := 14
const AUTO_START_SECONDS := 3.65
const CAN_CONTINUE_SECONDS := 1.15

var theme_particles: Array[Dictionary] = []
var particle_labels: Array[Label] = []
var elapsed: float = 0.0
var can_continue: bool = false
var started: bool = false
var phase_info: Dictionary = {}
var phase_key: String = "show_do_bilhao"

var effects_canvas: Control
var title_label: Label
var subtitle_label: Label
var score_label: Label
var hint_label: Label
var stage_label: Label
var icon_rect: TextureRect
var fade_rect: ColorRect

func _ready() -> void:
	randomize()
	phase_info = GameManager.get_current_phase_info()
	phase_key = str(phase_info.get("key", "show_do_bilhao"))
	_build_scene()
	if _animations_enabled():
		_reset_theme_particles()
	if has_node("/root/AudioManager"):
		AudioManager.play_music("loop_start")
	_fade_from_black()

func _process(delta: float) -> void:
	elapsed += delta
	if _animations_enabled():
		_update_theme_particles(delta)
		_update_ui_animation()
		if effects_canvas != null:
			effects_canvas.visible = true
			effects_canvas.queue_redraw()
	else:
		if effects_canvas != null:
			effects_canvas.visible = false
	if elapsed >= CAN_CONTINUE_SECONDS:
		can_continue = true
	if elapsed >= AUTO_START_SECONDS:
		_start_stage()

func _input(event: InputEvent) -> void:
	if started:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if can_continue:
			_start_stage()
	elif event is InputEventScreenTouch and event.pressed:
		if can_continue:
			_start_stage()
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:
				GameManager.go_to_main_menu()
			KEY_SPACE, KEY_ENTER, KEY_KP_ENTER:
				if can_continue:
					_start_stage()

func _animations_enabled() -> bool:
	return not has_node("/root/SettingsManager") or SettingsManager.animations_enabled()

func _build_scene() -> void:
	var bg_color: Color = _get_style_color("bg", Color(0.02, 0.02, 0.12))
	var accent: Color = _get_style_color("accent", Color(1.0, 0.84, 0.12))
	var secondary: Color = _get_style_color("secondary", accent.darkened(0.2))

	var background: ColorRect = ColorRect.new()
	background.name = "Background"
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.color = bg_color
	add_child(background)

	effects_canvas = Control.new()
	effects_canvas.name = "EffectsCanvas"
	effects_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	effects_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effects_canvas.draw.connect(_on_effects_canvas_draw)
	add_child(effects_canvas)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.z_index = 10
	add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = ScreenTools.panel_size(self, Vector2(880, 470), Vector2(360, 440), 70.0, 70.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.02, 0.025, 0.055, 0.66), Color(accent.r, accent.g, accent.b, 0.74), 28, 2))
	center.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	var inner_margin: int = 20 if ScreenTools.is_compact(self) else 34
	margin.add_theme_constant_override("margin_left", inner_margin)
	margin.add_theme_constant_override("margin_top", 20 if ScreenTools.is_compact(self) else 28)
	margin.add_theme_constant_override("margin_right", inner_margin)
	margin.add_theme_constant_override("margin_bottom", 20 if ScreenTools.is_compact(self) else 28)
	panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12 if ScreenTools.is_compact(self) else 18)
	margin.add_child(box)

	stage_label = Label.new()
	stage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stage_label.text = _get_stage_header()
	stage_label.add_theme_font_size_override("font_size", ScreenTools.responsive_font(self, 28, 22))
	stage_label.add_theme_color_override("font_color", Color(0.82, 0.84, 0.92))
	box.add_child(stage_label)

	icon_rect = TextureRect.new()
	icon_rect.custom_minimum_size = ScreenTools.responsive_size(self, Vector2(104, 104), Vector2(74, 74))
	icon_rect.expand_mode = 1
	icon_rect.stretch_mode = 5
	var icon_path: String = str(ICON_PATHS.get(phase_key, ICON_PATHS["show_do_bilhao"]))
	var texture: Resource = load(icon_path)
	if texture is Texture2D:
		icon_rect.texture = texture as Texture2D
	box.add_child(icon_rect)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.text = str(phase_info.get("name", "Próxima Fase"))
	title_label.add_theme_font_size_override("font_size", ScreenTools.responsive_font(self, _get_title_font_size(), 32))
	title_label.add_theme_color_override("font_color", accent)
	title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.88))
	title_label.add_theme_constant_override("shadow_offset_x", 4)
	title_label.add_theme_constant_override("shadow_offset_y", 4)
	box.add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle_label.custom_minimum_size = ScreenTools.responsive_size(self, Vector2(760, 62), Vector2(300, 74))
	subtitle_label.text = _get_phase_subtitle(phase_key)
	subtitle_label.add_theme_font_size_override("font_size", ScreenTools.responsive_font(self, 24, 18))
	subtitle_label.add_theme_color_override("font_color", Color(0.92, 0.94, 1.0))
	box.add_child(subtitle_label)

	score_label = Label.new()
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.text = "Pontuação total: %s" % ScoreManager.get_score()
	score_label.add_theme_font_size_override("font_size", ScreenTools.responsive_font(self, 24, 18))
	score_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.92))
	score_label.add_theme_stylebox_override("normal", _make_panel_style(Color(0.0, 0.0, 0.0, 0.30), Color(secondary.r, secondary.g, secondary.b, 0.38), 14, 1))
	score_label.custom_minimum_size = ScreenTools.responsive_size(self, Vector2(360, 42), Vector2(280, 38))
	box.add_child(score_label)

	hint_label = Label.new()
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.text = "Clique, Espaço ou Enter para iniciar"
	hint_label.add_theme_font_size_override("font_size", ScreenTools.responsive_font(self, 19, 15))
	hint_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.72))
	box.add_child(hint_label)

	fade_rect = ColorRect.new()
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.color = Color(0.0, 0.0, 0.0, 1.0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.z_index = 100
	add_child(fade_rect)

func _reset_theme_particles() -> void:
	theme_particles.clear()
	particle_labels.clear()
	if not _animations_enabled():
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(1280, 720)
	for i in range(PARTICLE_AMOUNT):
		var label: Label = Label.new()
		label.text = _get_particle_symbol(i)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.z_index = 2
		label.add_theme_font_size_override("font_size", randi_range(14, 22) if ScreenTools.is_compact(self) else randi_range(18, 28))
		label.add_theme_color_override("font_color", _get_style_color("accent", Color(1.0, 0.84, 0.12)))
		label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.75))
		label.add_theme_constant_override("shadow_offset_x", 2)
		label.add_theme_constant_override("shadow_offset_y", 2)
		label.size = Vector2(60, 52)
		var symbol: String = label.text
		if symbol.begins_with("@"):
			# Simbolo em icone (imagem branca tingida): vai dentro do Label, herdando posicao/rotacao/alpha.
			label.text = ""
			var icon_size: float = randf_range(26.0, 36.0) if ScreenTools.is_compact(self) else randf_range(32.0, 46.0)
			var icon_rect: TextureRect = UiIcons.make_rect(symbol.substr(1), icon_size, _get_style_color("accent", Color(1.0, 0.84, 0.12)))
			label.add_child(icon_rect)
		add_child(label)
		particle_labels.append(label)
		var columns: int = 4
		var rows: int = 4
		var column: int = i % columns
		var row: int = floori(float(i) / float(columns)) % rows
		var base_position: Vector2 = Vector2(
			(float(column) + randf_range(0.22, 0.78)) * viewport_size.x / float(columns),
			(float(row) + randf_range(0.22, 0.78)) * viewport_size.y / float(rows)
		)
		theme_particles.append({
			"label": label,
			"position": base_position,
			"velocity": _get_particle_velocity(i) * 0.55,
			"rotation_speed": randf_range(-0.72, 0.72),
			"alpha": randf_range(0.12, 0.36),
			"wave": randf_range(0.0, TAU)
		})

func _get_particle_velocity(index: int) -> Vector2:
	match phase_key:
		"show_do_bilhao":
			return Vector2(randf_range(-18.0, 18.0), randf_range(54.0, 116.0))
		"batalha_naval":
			return Vector2(randf_range(-34.0, 34.0), randf_range(-48.0, -18.0))
		"maleta_certa":
			return Vector2(randf_range(-28.0, 28.0), randf_range(18.0, 54.0))
		"roleta_risco":
			var angle: float = float(index) * 0.55
			return Vector2(cos(angle), sin(angle)) * randf_range(24.0, 62.0)
		"perseguicao":
			return Vector2(randf_range(-180.0, -80.0), randf_range(-18.0, 18.0))
		"forca_tecnica":
			return Vector2(randf_range(-30.0, 30.0), randf_range(-42.0, 34.0))
		"stop":
			return Vector2(randf_range(-36.0, 36.0), randf_range(-28.0, 46.0))
		_:
			return Vector2(randf_range(-20.0, 20.0), randf_range(30.0, 80.0))

func _update_theme_particles(delta: float) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	for i in range(theme_particles.size()):
		var data: Dictionary = theme_particles[i]
		var label_value: Variant = data.get("label", null)
		if not label_value is Label:
			continue
		var label: Label = label_value as Label
		var position: Vector2 = _dictionary_vector2(data, "position", Vector2.ZERO)
		var velocity: Vector2 = _dictionary_vector2(data, "velocity", Vector2.ZERO)
		var wave: float = float(data.get("wave", 0.0))
		position += velocity * delta
		position.x += sin(elapsed * 1.8 + wave) * 22.0 * delta

		if position.y > viewport_size.y + 90.0:
			position.y = -90.0
			position.x = randf_range(-80.0, viewport_size.x + 80.0)
		elif position.y < -110.0:
			position.y = viewport_size.y + 90.0
			position.x = randf_range(-80.0, viewport_size.x + 80.0)
		if position.x < -120.0:
			position.x = viewport_size.x + 90.0
		elif position.x > viewport_size.x + 120.0:
			position.x = -90.0

		label.position = position
		label.rotation += float(data.get("rotation_speed", 0.0)) * delta
		var alpha: float = float(data.get("alpha", 0.65))
		var pulse: float = 0.72 + absf(sin(elapsed * 2.2 + wave)) * 0.28
		label.modulate = Color(1.0, 1.0, 1.0, alpha * pulse)
		data["position"] = position
		theme_particles[i] = data

func _on_effects_canvas_draw() -> void:
	if not _animations_enabled():
		return
	var accent: Color = _get_style_color("accent", Color(1.0, 0.84, 0.12))
	var secondary: Color = _get_style_color("secondary", accent.darkened(0.2))
	var viewport_size: Vector2 = get_viewport_rect().size
	var pulse: float = (sin(elapsed * 3.2) + 1.0) * 0.5
	effects_canvas.draw_circle(viewport_size * 0.5, 270.0 + pulse * 42.0, Color(accent.r, accent.g, accent.b, 0.075))
	effects_canvas.draw_circle(viewport_size * 0.5, 170.0 + pulse * 22.0, Color(secondary.r, secondary.g, secondary.b, 0.055))
	_draw_theme_effects(viewport_size, accent, secondary, pulse)

func _draw_theme_effects(viewport_size: Vector2, accent: Color, secondary: Color, pulse: float) -> void:
	match phase_key:
		"batalha_naval":
			for i in range(4):
				var y: float = viewport_size.y * (0.22 + float(i) * 0.17) + sin(elapsed * 2.0 + float(i)) * 11.0
				effects_canvas.draw_arc(Vector2(viewport_size.x * 0.5, y), viewport_size.x * 0.44, 0.05, PI - 0.05, 96, Color(accent.r, accent.g, accent.b, 0.055), 2.0)
		"perseguicao":
			var siren_alpha: float = 0.14 + pulse * 0.14
			effects_canvas.draw_rect(Rect2(Vector2.ZERO, Vector2(viewport_size.x, 42.0)), Color(1.0, 0.0, 0.0, siren_alpha), true)
			effects_canvas.draw_rect(Rect2(Vector2(0.0, viewport_size.y - 42.0), Vector2(viewport_size.x, 42.0)), Color(0.0, 0.18, 1.0, siren_alpha), true)
			for i in range(4):
				var start: Vector2 = Vector2(viewport_size.x + 60.0 - float(i) * 280.0 + fposmod(elapsed * 160.0, 280.0), viewport_size.y * 0.28 + float(i % 2) * 150.0)
				effects_canvas.draw_line(start, start + Vector2(-120.0, 0.0), Color(1.0, 1.0, 1.0, 0.085), 2.0)
		"roleta_risco":
			var center: Vector2 = viewport_size * 0.5
			for i in range(5):
				var angle: float = elapsed * 1.2 + float(i) * TAU / 5.0
				var a: Vector2 = center + Vector2(cos(angle), sin(angle)) * (180.0 + pulse * 20.0)
				var b: Vector2 = center + Vector2(cos(angle + 0.38), sin(angle + 0.38)) * (210.0 + pulse * 20.0)
				effects_canvas.draw_line(a, b, Color(accent.r, accent.g, accent.b, 0.12), 3.0)
		"stop":
			var stamp_rect: Rect2 = Rect2(Vector2(viewport_size.x * 0.50 - 145.0, viewport_size.y * 0.50 - 145.0), Vector2(290.0, 290.0))
			effects_canvas.draw_arc(stamp_rect.get_center(), 145.0 + pulse * 8.0, 0.0, TAU, 96, Color(accent.r, accent.g, accent.b, 0.18), 7.0)
		"forca_tecnica":
			for i in range(7):
				var y: float = viewport_size.y * (0.18 + float(i) * 0.10)
				effects_canvas.draw_line(Vector2(0.0, y), Vector2(viewport_size.x, y + sin(elapsed * 1.7 + float(i)) * 18.0), Color(accent.r, accent.g, accent.b, 0.055), 2.0)
			for i in range(6):
				var x: float = viewport_size.x * (0.16 + float(i) * 0.13)
				effects_canvas.draw_line(Vector2(x, 0.0), Vector2(x + sin(elapsed * 1.4 + float(i)) * 16.0, viewport_size.y), Color(secondary.r, secondary.g, secondary.b, 0.07), 1.0)
		"maleta_certa":
			for i in range(5):
				var x: float = viewport_size.x * 0.18 + float(i) * viewport_size.x * 0.16
				var y: float = viewport_size.y * 0.78 + sin(elapsed * 2.0 + float(i)) * 18.0
				effects_canvas.draw_rect(Rect2(Vector2(x, y), Vector2(82.0, 48.0)), Color(accent.r, accent.g, accent.b, 0.10), false, 3.0)
		"show_do_bilhao":
			for i in range(4):
				var radius: float = 90.0 + float(i) * 46.0 + pulse * 6.0
				effects_canvas.draw_arc(viewport_size * 0.5, radius, 0.0, TAU, 96, Color(accent.r, accent.g, accent.b, 0.04), 2.0)

func _update_ui_animation() -> void:
	var pulse: float = 0.5 + absf(sin(elapsed * 2.8)) * 0.5
	if icon_rect != null:
		icon_rect.modulate = Color(1.0, 1.0, 1.0, 0.78 + pulse * 0.22)
		icon_rect.rotation = sin(elapsed * 2.0) * 0.045
	if hint_label != null:
		hint_label.modulate = Color(1.0, 1.0, 1.0, 0.38 + pulse * 0.62)
	if title_label != null:
		title_label.scale = Vector2.ONE * (1.0 + pulse * 0.018)

func _start_stage() -> void:
	if not can_continue or started:
		return
	started = true
	can_continue = false
	var tween: Tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0.0, 0.0, 0.0, 1.0), 0.28)
	await tween.finished
	if is_inside_tree():
		GameManager.start_current_campaign_stage()

func _fade_from_black() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0.0, 0.0, 0.0, 0.0), 0.35)

func _get_stage_header() -> String:
	if phase_key == "roleta_risco":
		return "RODADA BÔNUS"
	return "FASE %s/%s" % [GameManager.get_current_stage_number(), GameManager.get_total_stages()]

func _get_title_font_size() -> int:
	if phase_key == "show_do_bilhao":
		return 66
	if phase_key == "roleta_risco":
		return 64
	if phase_key == "desvio_logico":
		return 62
	return 70

func _get_particle_symbol(index: int) -> String:
	match phase_key:
		"show_do_bilhao":
			return "$"
		"batalha_naval":
			return "@anchor"
		"maleta_certa":
			return "@briefcase"
		"roleta_risco":
			return "?" if index % 2 == 0 else "!"
		"perseguicao":
			return "@danger"
		"forca_tecnica":
			var symbols: Array[String] = ["@puzzle", "{}", "[]", "SQL", "API", "DB", "01"]
			return symbols[index % symbols.size()]
		"stop":
			return "@stop"
		"desvio_logico":
			var road_symbols: Array[String] = ["@car", "A", "B", "404", "BUG", "{ }", "</>"]
			return road_symbols[index % road_symbols.size()]
		_:
			return str(_get_style_string("symbol", "*"))

func _get_phase_subtitle(key: String) -> String:
	match key:
		"show_do_bilhao":
			return "Jales abre a trilha com uma revisão geral sobre revisão pelos pares: independência, sigilo e organização do trabalho."
		"batalha_naval":
			return "Nem todo problema aparece na superfície. Encontre falhas escondidas antes que elas afundem o projeto."
		"maleta_certa":
			return "Cada maleta guarda uma decisão técnica. Escolha o caminho que melhor resolve o cenário apresentado."
		"roleta_risco":
			return "Rodada bônus: a vida acadêmica e profissional também tem imprevistos. A sorte gira... e o risco também."
		"perseguicao":
			return "Agora é pressão: leia o incidente, escolha rápido e mantenha a jornada em movimento."
		"forca_tecnica":
			return "A integridade do sistema depende do seu vocabulário técnico: descubra termos de SI antes da falha."
		"stop":
			return "A reta final testa associação rápida, vocabulário técnico e memória de conceitos essenciais."
		"desvio_logico":
			return "Desafio final: dirija, desvie dos bugs e escolha a rota lógica correta para concluir a Jornada SI."
		_:
			return "Prepare-se para a próxima etapa da Jornada SI."

func _get_style_color(field: String, fallback: Color) -> Color:
	var style: Dictionary = STYLE_MAP.get(phase_key, STYLE_MAP["show_do_bilhao"])
	var value: Variant = style.get(field, fallback)
	if value is Color:
		return value
	return fallback

func _get_style_string(field: String, fallback: String) -> String:
	var style: Dictionary = STYLE_MAP.get(phase_key, STYLE_MAP["show_do_bilhao"])
	return str(style.get(field, fallback))

func _dictionary_vector2(data: Dictionary, key: String, fallback: Vector2) -> Vector2:
	var value: Variant = data.get(key, fallback)
	if value is Vector2:
		return value
	return fallback

func _make_panel_style(bg_color: Color, border_color: Color, radius: int = 14, border_width: int = 1) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.38)
	style.shadow_size = 14
	return style
