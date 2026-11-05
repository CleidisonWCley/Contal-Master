extends Control

const BrandText := preload("res://scripts/ui/BrandText.gd")

const BACKGROUND_PATH := Paths.BG_CUTSCENE_FINAL
const JALES_PATH := Paths.SPRITE_JALES_RECEPTIVO
const CREDIT_SCROLL_SPEED := 48.0

var particles: Array[Dictionary] = []
var elapsed: float = 0.0
var act: String = "dialog"
var char_index: int = 0
var char_timer: float = 0.0
var final_score: int = 0
var final_title: String = ""
var final_body: String = ""
var final_pages: Array[Dictionary] = []
var final_page_index: int = 0
var can_click: bool = true

var background_rect: TextureRect
var dimmer: ColorRect
var effects_canvas: Control
var jales_sprite: TextureRect
var dialog_panel: PanelContainer
var dialog_margin: MarginContainer
var dialog_box: VBoxContainer
var score_panel: PanelContainer
var title_label: Label
var body_label: Label
var hint_label: Label
var score_layer: Control
var score_value_label: Label
var difficulty_label: Label
var motivation_label: Label
var credits_layer: Control
var credits_box: VBoxContainer
var gameover_layer: Control
var gameover_label: Label
var menu_button: Button
var fade_rect: ColorRect

func _ready() -> void:
	randomize()
	final_score = ScoreManager.get_score()
	_prepare_final_message()
	_build_scene()
	_reset_particles(42)
	_show_dialog_act(0)
	if has_node("/root/AudioManager"):
		AudioManager.play_music("musica_final")
	_fade_from_black()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_responsive_layout()
		if _animations_enabled():
			_reset_particles(42)

func _process(delta: float) -> void:
	elapsed += delta
	if _animations_enabled():
		_update_particles(delta)
		_update_jales_animation()
		_update_hint()
		if effects_canvas != null:
			effects_canvas.visible = true
			effects_canvas.queue_redraw()
	else:
		_update_jales_static()
		if effects_canvas != null:
			effects_canvas.visible = false
	_update_typewriter(delta)
	_update_credits(delta)
	_update_gameover()

func _input(event: InputEvent) -> void:
	if not can_click:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_pointer_advance(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_handle_pointer_advance(event.position)
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:
				_return_to_menu()
			KEY_SPACE, KEY_ENTER, KEY_KP_ENTER:
				_advance_act()

func _handle_pointer_advance(position: Vector2) -> void:
	if _is_pointer_on_menu_button(position):
		return
	_advance_act()

func _is_pointer_on_menu_button(position: Vector2) -> bool:
	return menu_button != null and menu_button.is_visible_in_tree() and menu_button.get_global_rect().has_point(position)

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
	if jales_sprite == null or not jales_sprite.visible:
		return
	var rect: Rect2 = _jales_rect(get_viewport_rect().size)
	jales_sprite.size = rect.size
	jales_sprite.position = rect.position
	jales_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _prepare_final_message() -> void:
	var opening_title: String = "A jornada continua."
	if final_score >= 450:
		opening_title = "Jornada concluída com maestria!"
	elif final_score >= 250:
		opening_title = "Boa jornada!"

	final_pages = [
		{
			"title": opening_title,
			"body": "Parabéns! Seu desempenho em Contal Master foi inspirador."
		},
		{
			"title": "um passo por vez",
			"body": "Passar pelos Desafios mostrou seu comprometimento, postura técnica e excelente capacidade de análise."
		},
		{
			"title": "O Aprendizado não para por aqui",
			"body": "O mundo corporativo se transforma todos os dias. Encare cada novo desafio como uma oportunidade de evoluir, aprimorar seus conhecimentos e fazer a diferença na sociedade."
		}
	]
	final_page_index = 0
	_set_current_dialog_page()

func _set_current_dialog_page() -> void:
	if final_pages.is_empty():
		final_title = "A jornada continua."
		final_body = "Você concluiu os desafios do Contal Master."
		return
	final_page_index = clampi(final_page_index, 0, final_pages.size() - 1)
	var page: Dictionary = final_pages[final_page_index]
	final_title = str(page.get("title", "A jornada continua."))
	final_body = str(page.get("body", ""))

func _build_scene() -> void:
	background_rect = TextureRect.new()
	background_rect.name = "Background"
	background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_rect.expand_mode = 1
	background_rect.stretch_mode = 6
	var bg_texture: Resource = load(BACKGROUND_PATH)
	if bg_texture is Texture2D:
		background_rect.texture = bg_texture as Texture2D
	add_child(background_rect)

	dimmer = ColorRect.new()
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.0, 0.0, 0.0, 0.55)
	add_child(dimmer)

	effects_canvas = Control.new()
	effects_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	effects_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effects_canvas.draw.connect(_on_effects_canvas_draw)
	add_child(effects_canvas)

	jales_sprite = TextureRect.new()
	jales_sprite.custom_minimum_size = Vector2.ZERO
	jales_sprite.expand_mode = 1
	jales_sprite.stretch_mode = 5
	var jales_texture: Resource = load(JALES_PATH)
	if jales_texture is Texture2D:
		jales_sprite.texture = jales_texture as Texture2D
	add_child(jales_sprite)

	_build_dialog_panel()
	_build_score_layer()
	_build_credits_layer()
	_build_gameover_layer()

	fade_rect = ColorRect.new()
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.color = Color(0.0, 0.0, 0.0, 1.0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.z_index = 500
	add_child(fade_rect)
	_apply_responsive_layout()

func _build_dialog_panel() -> void:
	dialog_panel = PanelContainer.new()
	dialog_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	dialog_panel.offset_left = 54
	dialog_panel.offset_right = -54
	dialog_panel.offset_top = -315
	dialog_panel.offset_bottom = -118
	dialog_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.04, 0.09, 0.90), Color(1.0, 0.78, 0.16, 0.88), 18, 2))
	add_child(dialog_panel)

	dialog_margin = MarginContainer.new()
	dialog_margin.add_theme_constant_override("margin_left", 34)
	dialog_margin.add_theme_constant_override("margin_top", 22)
	dialog_margin.add_theme_constant_override("margin_right", 34)
	dialog_margin.add_theme_constant_override("margin_bottom", 16)
	dialog_panel.add_child(dialog_margin)

	dialog_box = VBoxContainer.new()
	dialog_box.add_theme_constant_override("separation", 12)
	dialog_margin.add_child(dialog_box)

	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 34)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.30))
	title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
	title_label.add_theme_constant_override("shadow_offset_x", 2)
	title_label.add_theme_constant_override("shadow_offset_y", 2)
	dialog_box.add_child(title_label)

	body_label = Label.new()
	body_label.custom_minimum_size = Vector2(0, 76)
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.add_theme_font_size_override("font_size", 23)
	body_label.add_theme_color_override("font_color", Color(0.94, 0.96, 1.0))
	dialog_box.add_child(body_label)

	hint_label = Label.new()
	hint_label.text = "Clique na tela, Espaço ou Enter para continuar"
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 17)
	hint_label.add_theme_color_override("font_color", Color(0.86, 0.88, 0.95, 0.82))
	dialog_box.add_child(hint_label)

func _build_score_layer() -> void:
	score_layer = Control.new()
	score_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	score_layer.visible = false
	add_child(score_layer)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	score_layer.add_child(center)

	score_panel = PanelContainer.new()
	score_panel.custom_minimum_size = Vector2(760, 390)
	score_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.05, 0.11, 0.94), Color(1.0, 0.78, 0.16), 22, 3))
	center.add_child(score_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 42)
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_right", 42)
	margin.add_theme_constant_override("margin_bottom", 32)
	score_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	margin.add_child(box)

	var score_title: Label = Label.new()
	score_title.text = "PONTUAÇÃO FINAL DA JORNADA"
	score_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_title.add_theme_font_size_override("font_size", 29)
	score_title.add_theme_color_override("font_color", Color(0.82, 0.84, 0.92))
	box.add_child(score_title)

	score_value_label = Label.new()
	score_value_label.text = str(final_score)
	score_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_value_label.add_theme_font_size_override("font_size", 86)
	score_value_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.14))
	score_value_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.8))
	score_value_label.add_theme_constant_override("shadow_offset_x", 4)
	score_value_label.add_theme_constant_override("shadow_offset_y", 4)
	box.add_child(score_value_label)

	difficulty_label = Label.new()
	difficulty_label.text = "Dificuldade: %s" % DifficultyManager.get_label()
	difficulty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	difficulty_label.add_theme_font_size_override("font_size", 25)
	difficulty_label.add_theme_color_override("font_color", Color(0.42, 0.78, 1.0))
	box.add_child(difficulty_label)

	motivation_label = Label.new()
	motivation_label.text = "\"%s\"" % _get_motivation()
	motivation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	motivation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	motivation_label.add_theme_font_size_override("font_size", 22)
	motivation_label.add_theme_color_override("font_color", Color(0.82, 0.82, 0.86))
	box.add_child(motivation_label)

func _build_credits_layer() -> void:
	credits_layer = Control.new()
	credits_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	credits_layer.visible = false
	add_child(credits_layer)

	credits_box = VBoxContainer.new()
	credits_box.alignment = BoxContainer.ALIGNMENT_CENTER
	credits_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	credits_box.add_theme_constant_override("separation", 12)
	credits_layer.add_child(credits_box)

	_add_credit_rich(BrandText.brand_bbcode(true), 48)
	_add_credit_rich(GameManager.get_app_version_bbcode() if has_node("/root/GameManager") else BrandText.version_bbcode("0.9.2.1"), 24)
	_add_credit_space(22)
	_add_credit_label("Game Design & Idealização", 22, Color(0.62, 0.62, 0.68))
	_add_credit_label("Marcelo Felipe Beckman", 32, Color(1.0, 1.0, 1.0))
	_add_credit_space(18)
	_add_credit_label("UI / UX Design", 22, Color(0.62, 0.62, 0.68))
	_add_credit_label("Cleidison Raimundo dos Santos Lima", 32, Color(1.0, 1.0, 1.0))
	_add_credit_space(18)
	_add_credit_label("Desenvolvimento & Plataformas", 22, Color(0.62, 0.62, 0.68))
	_add_credit_label("Victor Gabriel Cabral da Silva", 32, Color(1.0, 1.0, 1.0))
	_add_credit_space(18)
	_add_credit_label("Música & Efeitos Sonoros", 22, Color(0.62, 0.62, 0.68))
	_add_credit_label("Marcos França Gino Gonçalves", 32, Color(1.0, 1.0, 1.0))
	_add_credit_space(18)
	_add_credit_label("Suporte da Equipe", 22, Color(0.62, 0.62, 0.68))
	_add_credit_label("Fernando Luiz Jales Da Rocha", 32, Color(1.0, 1.0, 1.0))
	_add_credit_space(26)
	_add_credit_rich("Obrigado por jogar " + BrandText.brand_bbcode(true) + "!", 44)

func _build_gameover_layer() -> void:
	gameover_layer = Control.new()
	gameover_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	gameover_layer.visible = false
	add_child(gameover_layer)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	gameover_layer.add_child(center)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 24)
	center.add_child(box)

	gameover_label = Label.new()
	gameover_label.text = "GAME OVER"
	gameover_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gameover_label.add_theme_font_size_override("font_size", 86)
	gameover_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	gameover_label.add_theme_color_override("font_shadow_color", Color(0.45, 0.72, 1.0, 0.95))
	gameover_label.add_theme_constant_override("shadow_offset_x", 4)
	gameover_label.add_theme_constant_override("shadow_offset_y", 4)
	box.add_child(gameover_label)

	var thanks: Label = Label.new()
	thanks.text = "agradecemos por sua aventura neste Desafio!"
	thanks.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	thanks.add_theme_font_size_override("font_size", 24)
	thanks.add_theme_color_override("font_color", Color(0.78, 0.82, 0.92))
	box.add_child(thanks)

	menu_button = Button.new()
	menu_button.text = "VOLTAR AO MENU"
	ButtonStyles.apply(menu_button, "cutscene_return", ScreenTools.button_size(self, Vector2(320, 58), Vector2(260, 50)), ScreenTools.responsive_font(self, 22, 18))
	menu_button.pressed.connect(_return_to_menu)
	box.add_child(menu_button)

func _apply_responsive_layout() -> void:
	var compact: bool = ScreenTools.is_compact(self)
	if dialog_panel != null:
		dialog_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		dialog_panel.offset_left = 34.0 if compact else 54.0
		dialog_panel.offset_right = -dialog_panel.offset_left
		dialog_panel.offset_top = -245.0 if compact else -315.0
		dialog_panel.offset_bottom = -58.0 if compact else -118.0
	if dialog_margin != null:
		var side: int = 22 if compact else 34
		dialog_margin.add_theme_constant_override("margin_left", side)
		dialog_margin.add_theme_constant_override("margin_top", 16 if compact else 22)
		dialog_margin.add_theme_constant_override("margin_right", side)
		dialog_margin.add_theme_constant_override("margin_bottom", 12 if compact else 16)
	if dialog_box != null:
		dialog_box.add_theme_constant_override("separation", 8 if compact else 12)
	ScreenTools.apply_label_font(title_label, self, 34, 26)
	ScreenTools.apply_label_font(body_label, self, 23, 19)
	ScreenTools.apply_label_font(hint_label, self, 17, 14)
	if body_label != null:
		body_label.custom_minimum_size = Vector2(0, 64 if compact else 76)
	if score_panel != null:
		score_panel.custom_minimum_size = ScreenTools.panel_size(self, Vector2(760, 390), Vector2(340, 330), 70.0, 70.0)
	ScreenTools.apply_label_font(score_value_label, self, 86, 62)
	ScreenTools.apply_label_font(difficulty_label, self, 25, 20)
	ScreenTools.apply_label_font(motivation_label, self, 22, 18)
	if menu_button != null:
		ButtonStyles.apply(menu_button, "cutscene_return", ScreenTools.button_size(self, Vector2(320, 58), Vector2(260, 50)), ScreenTools.responsive_font(self, 22, 18))
	_update_jales_static()

func _add_credit_label(text_value: String, font_size: int, color: Color) -> void:
	var label: Label = Label.new()
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	credits_box.add_child(label)

func _add_credit_rich(bbcode: String, font_size: int) -> void:
	var label: RichTextLabel = BrandText.make_label(bbcode, font_size, "center", true)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	credits_box.add_child(label)

func _add_credit_space(height: int) -> void:
	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, height)
	credits_box.add_child(spacer)

func _show_dialog_act(page_index: int = -1) -> void:
	act = "dialog"
	elapsed = 0.0
	char_index = 0
	char_timer = 0.0
	if page_index >= 0:
		final_page_index = page_index
	_set_current_dialog_page()
	background_rect.visible = true
	dimmer.color = Color(0.0, 0.0, 0.0, 0.55)
	jales_sprite.visible = true
	dialog_panel.visible = true
	score_layer.visible = false
	credits_layer.visible = false
	gameover_layer.visible = false
	title_label.text = final_title
	body_label.text = ""

func _show_score_act() -> void:
	act = "score"
	elapsed = 0.0
	jales_sprite.visible = false
	dialog_panel.visible = false
	score_layer.visible = true
	credits_layer.visible = false
	gameover_layer.visible = false
	dimmer.color = Color(0.0, 0.0, 0.0, 0.72)

func _show_credits_act() -> void:
	act = "credits"
	elapsed = 0.0
	_reset_particles(28)
	jales_sprite.visible = false
	dialog_panel.visible = false
	score_layer.visible = false
	credits_layer.visible = true
	gameover_layer.visible = false
	dimmer.color = Color(0.0, 0.0, 0.0, 0.92)
	var viewport_size: Vector2 = get_viewport_rect().size
	credits_box.size = Vector2(viewport_size.x, 900)
	credits_box.position = Vector2(0.0, viewport_size.y + 60.0)

func _show_gameover_act() -> void:
	act = "gameover"
	elapsed = 0.0
	_reset_particles(40)
	jales_sprite.visible = false
	dialog_panel.visible = false
	score_layer.visible = false
	credits_layer.visible = false
	gameover_layer.visible = true
	dimmer.color = Color(0.0, 0.0, 0.0, 0.96)

func _advance_act() -> void:
	if act == "dialog":
		var done: bool = char_index >= final_body.length()
		if not done:
			char_index = final_body.length()
			body_label.text = final_body
		elif final_page_index < final_pages.size() - 1:
			final_page_index += 1
			_show_dialog_act()
		else:
			_show_score_act()
	elif act == "score":
		_show_credits_act()
	elif act == "credits":
		_show_gameover_act()
	elif act == "gameover":
		_return_to_menu()

func _update_typewriter(delta: float) -> void:
	if act != "dialog":
		return
	if char_index >= final_body.length():
		return
	char_timer += delta
	while char_timer >= 0.018 and char_index < final_body.length():
		char_index += 1
		char_timer -= 0.018
	body_label.text = final_body.substr(0, char_index)

func _update_jales_animation() -> void:
	if jales_sprite == null or not jales_sprite.visible:
		return
	var rect: Rect2 = _jales_rect(get_viewport_rect().size)
	var breathing: float = sin(elapsed * 2.1) * 6.0
	jales_sprite.size = rect.size
	jales_sprite.position = rect.position + Vector2(0.0, breathing)

func _update_hint() -> void:
	if hint_label == null:
		return
	var alpha: float = 0.42 + absf(sin(elapsed * 2.8)) * 0.48
	hint_label.add_theme_color_override("font_color", Color(0.86, 0.88, 0.95, alpha))

func _update_credits(delta: float) -> void:
	if act != "credits" or credits_box == null:
		return
	credits_box.position.y -= CREDIT_SCROLL_SPEED * delta
	if credits_box.position.y + credits_box.size.y < -40.0:
		_show_gameover_act()

func _update_gameover() -> void:
	if act != "gameover" or gameover_label == null:
		return
	var pulse: float = 0.50 + absf(sin(elapsed * 3.4)) * 0.50
	gameover_label.add_theme_color_override("font_shadow_color", Color(0.36, 0.68, 1.0, 0.45 + pulse * 0.55))

func _reset_particles(amount: int) -> void:
	particles.clear()
	var viewport_size: Vector2 = get_viewport_rect().size
	for _i in range(amount):
		particles.append({
			"position": Vector2(randf_range(0.0, viewport_size.x), randf_range(0.0, viewport_size.y)),
			"speed": randf_range(18.0, 58.0),
			"radius": randf_range(1.6, 4.4),
			"alpha": randf_range(0.34, 0.95)
		})

func _update_particles(delta: float) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	for i in range(particles.size()):
		var particle: Dictionary = particles[i]
		var position: Vector2 = _dict_vec2(particle, "position", Vector2.ZERO)
		position.y -= float(particle.get("speed", 26.0)) * delta
		position.x += sin(elapsed * 0.9 + float(i)) * 8.0 * delta
		if position.y < -18.0:
			position.y = viewport_size.y + randf_range(15.0, 110.0)
			position.x = randf_range(0.0, viewport_size.x)
		particle["position"] = position
		particles[i] = particle

func _on_effects_canvas_draw() -> void:
	if not _animations_enabled():
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	var accent: Color = Color(1.0, 0.82, 0.16)
	if act == "score":
		accent = Color(0.35, 0.70, 1.0)
	elif act == "gameover":
		accent = Color(0.78, 0.86, 1.0)
	effects_canvas.draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(accent.r, accent.g, accent.b, 0.045), true)
	for particle in particles:
		var position: Vector2 = _dict_vec2(particle, "position", Vector2.ZERO)
		var radius: float = float(particle.get("radius", 2.4))
		var alpha: float = float(particle.get("alpha", 0.6))
		effects_canvas.draw_circle(position, radius, Color(1.0, 1.0, 1.0, alpha))

func _dict_vec2(data: Dictionary, key: String, fallback: Vector2) -> Vector2:
	var value: Variant = data.get(key, fallback)
	if value is Vector2:
		return value
	return fallback

func _get_motivation() -> String:
	var diff: String = DifficultyManager.get_difficulty()
	if diff == "facil":
		return "Toda grande jornada começa por uma boa escolha."
	if diff == "dificil":
		return "Nos caminhos mais difíceis, o conhecimento mostra seu valor."
	return "Cada desafio vencido revela uma nova forma de pensar."

func _return_to_menu() -> void:
	if not can_click:
		return
	can_click = false
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	var tween: Tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0.0, 0.0, 0.0, 1.0), 0.36)
	await tween.finished
	if is_inside_tree():
		GameManager.go_to_main_menu()

func _fade_from_black() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0.0, 0.0, 0.0, 0.0), 0.50)

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
