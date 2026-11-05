extends Control

const BACKGROUND_PATH := Paths.BG_CUTSCENE_INTRO
const JALES_PATH := Paths.SPRITE_JALES_RECEPTIVO
const PARTICLE_COUNT := 42
const TYPE_SPEED := 0.018

const SCRIPT_PAGES := [
	{
		"title": "Bem-vindo ao 	Contal Master",
		"body": "Olá! Seja muito bem-vindo, sou Jales o Apresentador da Contal Master, e terei o prazer de acompanhar você nesta experiência de aprendizagem."
	},
	{
		"title": "Uma aventura de conhecimento",
		"body": "Conhecimento não se resume a memorizar conceitos e normas. É preciso compreender informações, interpretar situações e saber aplicar aquilo que aprendemos."
	},
	{
		"title": "Uma nova Jornada",
		"body": "Pensando nisso, o Contal Master reúne diferentes atividades gamificadas para transformar a revisão de conhecimentos em uma experiência mais dinâmica, interativa e desafiadora"
	},
	{
		"title": "Escolhas também ensinam",
		"body": "Cada modalidade possui uma dinâmica própria. Você encontrará desafios de perguntas e respostas, estratégia, tomada de decisões, associação de conceitos e raciocínio lógico."
	},
	{
		"title": "Os eixos da aventura",
		"body": "Sua jornada no ContalMaster foca na Revisão pelos Pares! A cada minigame, examine papéis de trabalho, garanta a independência do time e proteja dados sigilosos. Ao final, interprete o relatório e ajude a construir um plano de ação para a firma!"
	},
	{
		"title": "Sua jornada começa agora",
		"body": "Não importa se você está revisando conhecimentos ou dando seus primeiros passos na área. Cada desafio é uma oportunidade de aprender, exercitar suas habilidades e descobrir novas maneiras de pensar. Vamos começar!"
	}
]

var particles: Array[Dictionary] = []
var page_index: int = 0
var char_index: int = 0
var char_timer: float = 0.0
var elapsed: float = 0.0
var finishing: bool = false

var effects_canvas: Control
var fade_rect: ColorRect
var jales_sprite: TextureRect
var title_label: Label
var body_label: Label
var hint_label: Label
var page_label: Label
var skip_button: Button
var back_button: Button
var top_buttons: HBoxContainer
var dialog_panel: PanelContainer
var dialog_margin: MarginContainer
var dialog_box: VBoxContainer

func _ready() -> void:
	randomize()
	_build_scene()
	_reset_particles()
	_update_page(true)
	if has_node("/root/AudioManager"):
		AudioManager.play_music("intro_jornada", true)
	_fade_from_black()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_responsive_layout()
		if _animations_enabled():
			_reset_particles()

func _process(delta: float) -> void:
	elapsed += delta
	if _animations_enabled():
		_update_particles(delta)
		_update_jales_animation()
		_update_hint_animation()
		if effects_canvas != null:
			effects_canvas.visible = true
			effects_canvas.queue_redraw()
	else:
		_update_jales_static()
		if effects_canvas != null:
			effects_canvas.visible = false
	_update_typewriter(delta)

func _input(event: InputEvent) -> void:
	if finishing:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_pointer_advance(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_handle_pointer_advance(event.position)
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:
				_on_back_pressed()
			KEY_SPACE, KEY_ENTER, KEY_KP_ENTER:
				_advance_or_complete_text()

func _handle_pointer_advance(position: Vector2) -> void:
	if _is_pointer_on_action_button(position):
		return
	_advance_or_complete_text()

func _is_pointer_on_action_button(position: Vector2) -> bool:
	for button in [back_button, skip_button]:
		if button != null and button.is_visible_in_tree() and button.get_global_rect().has_point(position):
			return true
	return false

func _build_scene() -> void:
	_clear_scene_children()

	var background: TextureRect = TextureRect.new()
	background.name = "Background"
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = 1
	background.stretch_mode = 6
	var bg_texture: Resource = load(BACKGROUND_PATH)
	if bg_texture is Texture2D:
		background.texture = bg_texture as Texture2D
	add_child(background)

	var blur_dimmer: ColorRect = ColorRect.new()
	blur_dimmer.name = "Dimmer"
	blur_dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	blur_dimmer.color = Color(0.02, 0.02, 0.08, 0.43)
	add_child(blur_dimmer)

	effects_canvas = Control.new()
	effects_canvas.name = "EffectsCanvas"
	effects_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	effects_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effects_canvas.draw.connect(_on_effects_canvas_draw)
	add_child(effects_canvas)

	jales_sprite = TextureRect.new()
	jales_sprite.name = "Jales"
	jales_sprite.custom_minimum_size = Vector2.ZERO
	jales_sprite.expand_mode = 1
	jales_sprite.stretch_mode = 5
	jales_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var jales_texture: Resource = load(JALES_PATH)
	if jales_texture is Texture2D:
		jales_sprite.texture = jales_texture as Texture2D
	add_child(jales_sprite)

	top_buttons = HBoxContainer.new()
	top_buttons.name = "TopButtons"
	top_buttons.anchor_left = 1.0
	top_buttons.anchor_right = 1.0
	top_buttons.anchor_top = 0.0
	top_buttons.anchor_bottom = 0.0
	top_buttons.offset_left = -258.0
	top_buttons.offset_top = 24.0
	top_buttons.offset_right = -34.0
	top_buttons.offset_bottom = 66.0
	top_buttons.alignment = BoxContainer.ALIGNMENT_END
	top_buttons.add_theme_constant_override("separation", 10)
	top_buttons.z_index = 80
	add_child(top_buttons)

	back_button = _create_cutscene_button("Menu", Color(0.05, 0.05, 0.08, 0.74), Color(1.0, 0.82, 0.18, 0.74))
	back_button.pressed.connect(_on_back_pressed)
	top_buttons.add_child(back_button)

	skip_button = _create_cutscene_button("Pular", Color(0.56, 0.02, 0.05, 0.86), Color(1.0, 0.82, 0.18, 0.92))
	skip_button.pressed.connect(_on_skip_pressed)
	top_buttons.add_child(skip_button)

	dialog_panel = PanelContainer.new()
	dialog_panel.name = "DialogPanel"
	dialog_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	dialog_panel.offset_left = 54
	dialog_panel.offset_right = -54
	dialog_panel.offset_top = -265
	dialog_panel.offset_bottom = -74
	dialog_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.04, 0.09, 0.88), Color(1.0, 0.78, 0.16, 0.85), 18, 2))
	add_child(dialog_panel)

	dialog_margin = MarginContainer.new()
	dialog_margin.add_theme_constant_override("margin_left", 34)
	dialog_margin.add_theme_constant_override("margin_top", 22)
	dialog_margin.add_theme_constant_override("margin_right", 34)
	dialog_margin.add_theme_constant_override("margin_bottom", 16)
	dialog_panel.add_child(dialog_margin)

	dialog_box = VBoxContainer.new()
	dialog_box.add_theme_constant_override("separation", 10)
	dialog_margin.add_child(dialog_box)

	var header_row: HBoxContainer = HBoxContainer.new()
	header_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dialog_box.add_child(header_row)

	title_label = Label.new()
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.add_theme_font_size_override("font_size", 31)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.30))
	title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
	title_label.add_theme_constant_override("shadow_offset_x", 2)
	title_label.add_theme_constant_override("shadow_offset_y", 2)
	header_row.add_child(title_label)

	page_label = Label.new()
	page_label.custom_minimum_size = Vector2(90, 0)
	page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	page_label.add_theme_font_size_override("font_size", 17)
	page_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0, 0.72))
	header_row.add_child(page_label)

	body_label = Label.new()
	body_label.custom_minimum_size = Vector2(0, 92)
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	body_label.add_theme_font_size_override("font_size", 24)
	body_label.add_theme_color_override("font_color", Color(0.94, 0.96, 1.0))
	dialog_box.add_child(body_label)

	hint_label = Label.new()
	hint_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint_label.text = "Clique na tela, Espaço ou Enter para avançar"
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 17)
	hint_label.add_theme_color_override("font_color", Color(0.86, 0.88, 0.95, 0.90))
	dialog_box.add_child(hint_label)

	fade_rect = ColorRect.new()
	fade_rect.name = "FadeRect"
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.color = Color(0.0, 0.0, 0.0, 1.0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.z_index = 500
	add_child(fade_rect)
	_apply_responsive_layout()

func _apply_responsive_layout() -> void:
	var compact: bool = ScreenTools.is_compact(self)
	if top_buttons != null:
		var row_width: float = 204.0 if compact else 224.0
		top_buttons.anchor_left = 1.0
		top_buttons.anchor_right = 1.0
		top_buttons.anchor_top = 0.0
		top_buttons.anchor_bottom = 0.0
		top_buttons.offset_left = -row_width - (18.0 if compact else 34.0)
		top_buttons.offset_right = -(18.0 if compact else 34.0)
		top_buttons.offset_top = 16.0 if compact else 24.0
		top_buttons.offset_bottom = top_buttons.offset_top + (38.0 if compact else 42.0)
		top_buttons.add_theme_constant_override("separation", 8 if compact else 10)
	if back_button != null:
		ButtonStyles.apply_cutscene(back_button, "cutscene_menu", ScreenTools.button_size(self, Vector2(106, 40), Vector2(92, 36)), ScreenTools.responsive_font(self, 16, 14))
	if skip_button != null:
		ButtonStyles.apply_cutscene(skip_button, "cutscene_skip", ScreenTools.button_size(self, Vector2(106, 40), Vector2(92, 36)), ScreenTools.responsive_font(self, 16, 14))
	if dialog_panel != null:
		dialog_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		dialog_panel.offset_left = 34.0 if compact else 54.0
		dialog_panel.offset_right = -dialog_panel.offset_left
		dialog_panel.offset_top = -240.0 if compact else -275.0
		dialog_panel.offset_bottom = -56.0 if compact else -82.0
	if dialog_margin != null:
		var side: int = 22 if compact else 34
		dialog_margin.add_theme_constant_override("margin_left", side)
		dialog_margin.add_theme_constant_override("margin_top", 16 if compact else 22)
		dialog_margin.add_theme_constant_override("margin_right", side)
		dialog_margin.add_theme_constant_override("margin_bottom", 12 if compact else 16)
	if dialog_box != null:
		dialog_box.add_theme_constant_override("separation", 8 if compact else 10)
	ScreenTools.apply_label_font(title_label, self, 31, 25)
	ScreenTools.apply_label_font(page_label, self, 17, 14)
	ScreenTools.apply_label_font(body_label, self, 24, 19)
	ScreenTools.apply_label_font(hint_label, self, 17, 14)
	if body_label != null:
		body_label.custom_minimum_size = Vector2(0, 74 if compact else 92)
	_update_jales_static()

func _clear_scene_children() -> void:
	for child in get_children():
		child.queue_free()

func _create_cutscene_button(text_value: String, bg_color: Color, border_color: Color) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var variant: String = "cutscene_skip" if text_value.to_lower() == "pular" else "cutscene_menu"
	ButtonStyles.apply_cutscene(button, variant, ScreenTools.button_size(self, Vector2(106, 40), Vector2(92, 36)), ScreenTools.responsive_font(self, 16, 14))
	return button

func _animations_enabled() -> bool:
	return not has_node("/root/SettingsManager") or SettingsManager.animations_enabled()

func _jales_rect(viewport_size: Vector2) -> Rect2:
	# Jales na area DIREITA e com zoom: cabeca e torso em destaque; o resto fica atras do painel de
	# dialogo e do limite da tela (enquadramento de busto).
	var aspect: float = 0.62
	if jales_sprite != null and jales_sprite.texture != null:
		var tex_size: Vector2 = jales_sprite.texture.get_size()
		if tex_size.y > 0.0:
			aspect = tex_size.x / tex_size.y
	var height: float = viewport_size.y * (0.98 if ScreenTools.is_compact(self) else 1.10)
	var width: float = height * aspect
	var position_x: float = viewport_size.x - width - viewport_size.x * 0.035
	return Rect2(Vector2(position_x, viewport_size.y * 0.015), Vector2(width, height))

func _update_jales_static() -> void:
	if jales_sprite == null:
		return
	var rect: Rect2 = _jales_rect(get_viewport_rect().size)
	jales_sprite.size = rect.size
	jales_sprite.position = rect.position
	jales_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _reset_particles() -> void:
	particles.clear()
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(1280, 720)
	for _i in range(PARTICLE_COUNT):
		particles.append({
			"position": Vector2(randf_range(0.0, viewport_size.x), randf_range(0.0, viewport_size.y)),
			"speed": randf_range(18.0, 48.0),
			"radius": randf_range(1.6, 4.0),
			"alpha": randf_range(0.35, 0.95)
		})

func _update_particles(delta: float) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	for i in range(particles.size()):
		var particle: Dictionary = particles[i]
		var position_value: Variant = particle.get("position", Vector2.ZERO)
		var position: Vector2 = Vector2.ZERO
		if position_value is Vector2:
			position = position_value
		position.y -= float(particle.get("speed", 24.0)) * delta
		position.x += sin(elapsed * 0.8 + float(i)) * 8.0 * delta
		if position.y < -18.0:
			position.y = viewport_size.y + randf_range(20.0, 120.0)
			position.x = randf_range(0.0, viewport_size.x)
		particle["position"] = position
		particles[i] = particle

func _on_effects_canvas_draw() -> void:
	if not _animations_enabled():
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	var pulse: float = (sin(elapsed * 2.4) + 1.0) * 0.5
	effects_canvas.draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.12, 0.18, 0.38, 0.10 + pulse * 0.05), true)
	for particle in particles:
		var position_value: Variant = particle.get("position", Vector2.ZERO)
		var position: Vector2 = Vector2.ZERO
		if position_value is Vector2:
			position = position_value
		var radius: float = float(particle.get("radius", 2.5))
		var alpha: float = float(particle.get("alpha", 0.6))
		effects_canvas.draw_circle(position, radius, Color(1.0, 0.86, 0.45, alpha))

func _update_typewriter(delta: float) -> void:
	if finishing or page_index < 0 or page_index >= SCRIPT_PAGES.size():
		return
	var current_body: String = str(SCRIPT_PAGES[page_index].get("body", ""))
	if char_index >= current_body.length():
		return
	char_timer += delta
	while char_timer >= TYPE_SPEED and char_index < current_body.length():
		char_index += 1
		char_timer -= TYPE_SPEED
	body_label.text = current_body.substr(0, char_index)

func _update_jales_animation() -> void:
	if jales_sprite == null:
		return
	var rect: Rect2 = _jales_rect(get_viewport_rect().size)
	var breathing: float = sin(elapsed * 2.1) * 6.0
	jales_sprite.size = rect.size
	jales_sprite.position = rect.position + Vector2(0.0, breathing)
	jales_sprite.modulate = Color(1.0, 1.0, 1.0, minf(1.0, elapsed * 0.9))

func _update_hint_animation() -> void:
	if hint_label == null:
		return
	var alpha: float = 0.50 + absf(sin(elapsed * 3.0)) * 0.42
	hint_label.add_theme_color_override("font_color", Color(0.86, 0.88, 0.95, alpha))

func _update_page(reset_text: bool) -> void:
	if page_index < 0 or page_index >= SCRIPT_PAGES.size():
		return
	var page: Dictionary = SCRIPT_PAGES[page_index]
	title_label.text = str(page.get("title", ""))
	page_label.text = "%s/%s" % [page_index + 1, SCRIPT_PAGES.size()]
	if reset_text:
		char_index = 0
		char_timer = 0.0
		body_label.text = ""
	else:
		var current_body: String = str(page.get("body", ""))
		char_index = current_body.length()
		body_label.text = current_body
	if page_index == SCRIPT_PAGES.size() - 1:
		hint_label.text = "Clique na tela, Espaço ou Enter para começar"
	else:
		hint_label.text = "Clique na tela, Espaço ou Enter para avançar"

func _advance_or_complete_text() -> void:
	if finishing:
		return
	var current_body: String = str(SCRIPT_PAGES[page_index].get("body", ""))
	if char_index < current_body.length():
		char_index = current_body.length()
		body_label.text = current_body
		return
	page_index += 1
	if page_index >= SCRIPT_PAGES.size():
		_finish_intro(false)
	else:
		_update_page(true)

func _finish_intro(play_button_sound: bool) -> void:
	if finishing:
		return
	finishing = true
	if play_button_sound and has_node("/root/AudioManager"):
		AudioManager.play_click()
	var tween: Tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0.0, 0.0, 0.0, 1.0), 0.45)
	await tween.finished
	if is_inside_tree():
		GameManager.start_campaign_after_intro()

func _on_skip_pressed() -> void:
	_finish_intro(true)

func _on_back_pressed() -> void:
	if finishing:
		return
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	GameManager.go_to_main_menu()

func _fade_from_black() -> void:
	if fade_rect == null:
		return
	var tween: Tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0.0, 0.0, 0.0, 0.0), 0.55)

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
	style.shadow_size = 10
	return style
