extends Control

const FREE_PARTICLE_COUNT := 38
const FREE_SYMBOLS := ["$", "⚓", "💼", "🚨", "🧩", "🛑", "🚗"]
const PANEL_BG_MAGIC := Color(0.035, 0.045, 0.105, 0.92)
const PANEL_BORDER_MAGIC := Color(1.0, 0.84, 0.22, 0.84)
const TEXT_TITLE_MAGIC := Color(1.0, 0.92, 0.68, 1.0)
const TEXT_MUTED_MAGIC := Color(0.82, 0.88, 1.0, 1.0)

@onready var buttons: Array = [
	get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CardsBox/BtnShow"),
	get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CardsBox/BtnNaval"),
	get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CardsBox/BtnMaleta"),
	get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CardsBox/BtnPerseguicao"),
	get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CardsBox/BtnForca"),
	get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CardsBox/BtnStop"),
	get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CardsBox/BtnDesvio")
]
@onready var btn_back: Button = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BtnVoltar")
@onready var safe_area: MarginContainer = get_node_or_null("SafeArea")
@onready var panel: PanelContainer = get_node_or_null("SafeArea/CenterContainer/PanelContainer")
@onready var inner_margin: MarginContainer = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer")
@onready var main_box: VBoxContainer = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer")
@onready var cards_box: VBoxContainer = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CardsBox")
@onready var title_label: Label = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Title")
@onready var subtitle_label: Label = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Subtitle")

var particles: Array[Dictionary] = []
var effects_canvas: Control
var elapsed: float = 0.0

const MINIGAME_CARD_DATA: Array[Dictionary] = [
	{"icon": "$", "title": "Show do Bilhão", "description": "Responda e acumule pontos."},
	{"icon": "⚓", "title": "Batalha Naval", "description": "Acerte posições por estratégia."},
	{"icon": "💼", "title": "Maleta Certa", "description": "Escolha com cuidado e arrisque."},
	{"icon": "🚨", "title": "Perseguição", "description": "Escape dos perigos e mantenha o controle."},
	{"icon": "🧩", "title": "Forca Tecnica", "description": "Descubra termos técnicos."},
	{"icon": "🛑", "title": "STOP", "description": "Pense rápido e complete categorias."},
	{"icon": "🚗", "title": "Desvio Lógico", "description": "Desvie, escolha rotas e teste sua lógica."}
]

func _ready() -> void:
	randomize()
	if has_node("/root/AudioManager"):
		AudioManager.play_music("menu")
	_apply_card_labels()
	_rebuild_card_rows()
	_apply_responsive_layout()
	_prepare_effects_layer()
	_reset_particles()
	for index in range(buttons.size()):
		var button: Button = buttons[index] as Button
		if button != null and not button.pressed.is_connected(_on_minigame_pressed):
			button.pressed.connect(_on_minigame_pressed.bind(index))
		_connect_card_hover(button)
	if btn_back != null and not btn_back.pressed.is_connected(_on_back_pressed):
		btn_back.pressed.connect(_on_back_pressed)
	_apply_button_styles()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_rebuild_card_rows()
		_apply_responsive_layout()
		_apply_button_styles()
		if _animations_enabled():
			_reset_particles()

func _apply_card_labels() -> void:
	if title_label != null:
		title_label.text = "SELECIONE UM MINIGAME"
	if subtitle_label != null:
		subtitle_label.text = "Escolha um desafio do Modo Livre. A Roleta de Risco fica como bônus surpresa da campanha."
	for index in range(buttons.size()):
		var button: Button = buttons[index] as Button
		if button == null or index >= MINIGAME_CARD_DATA.size():
			continue
		var data: Dictionary = MINIGAME_CARD_DATA[index]
		button.text = "%s\n%s\n%s" % [str(data.get("icon", "?")), str(data.get("title", "Minigame")), str(data.get("description", ""))]

func _rebuild_card_rows() -> void:
	if cards_box == null:
		return
	var old_children: Array[Node] = []
	for child in cards_box.get_children():
		old_children.append(child)
	for button_item in buttons:
		var button: Button = button_item as Button
		if button != null and button.get_parent() != null:
			button.get_parent().remove_child(button)
	for child in old_children:
		if child.get_parent() == cards_box:
			cards_box.remove_child(child)
		if child is HBoxContainer:
			child.queue_free()
	var pattern: Array[int] = _row_pattern()
	var button_index: int = 0
	for count in pattern:
		if button_index >= buttons.size():
			break
		var row := HBoxContainer.new()
		row.name = "CardsRow%d" % (cards_box.get_child_count() + 1)
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_theme_constant_override("separation", 12 if ScreenTools.is_compact(self) else 16)
		cards_box.add_child(row)
		for i in range(count):
			if button_index >= buttons.size():
				break
			var button: Button = buttons[button_index] as Button
			if button != null:
				row.add_child(button)
			button_index += 1

func _row_pattern() -> Array[int]:
	var viewport_width: float = get_viewport_rect().size.x
	if viewport_width >= 1040.0:
		return [4, 3]
	if viewport_width >= 760.0:
		return [3, 2, 2]
	return [1, 1, 1, 1, 1, 1, 1]

func _connect_card_hover(button: Button) -> void:
	if button == null:
		return
	if not button.mouse_entered.is_connected(_on_card_mouse_entered):
		button.mouse_entered.connect(_on_card_mouse_entered.bind(button))
	if not button.mouse_exited.is_connected(_on_card_mouse_exited):
		button.mouse_exited.connect(_on_card_mouse_exited.bind(button))

func _on_card_mouse_entered(button: Button) -> void:
	_animate_card(button, true)

func _on_card_mouse_exited(button: Button) -> void:
	_animate_card(button, false)

func _animate_card(button: Button, hovered: bool) -> void:
	if button == null or not _animations_enabled():
		return
	button.pivot_offset = button.size * 0.5
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2.ONE * (1.035 if hovered else 1.0), 0.10)

func _apply_button_styles() -> void:
	_apply_panel_style()
	_apply_text_styles()
	var viewport_width: float = get_viewport_rect().size.x
	var wide: bool = viewport_width >= 1040.0
	var medium: bool = viewport_width >= 760.0 and viewport_width < 1040.0
	var option_size: Vector2 = Vector2(220, 128) if wide else (Vector2(210, 118) if medium else Vector2(270, 92))
	var option_font: int = ScreenTools.responsive_font(self, 16, 13)
	for index in range(buttons.size()):
		var button: Button = buttons[index] as Button
		if button != null:
			ButtonStyles.apply(button, "minigame_card_gold" if index == 0 else "minigame_card", option_size, option_font)
			button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	ScreenTools.apply_button(btn_back, self, "magic_back", Vector2(250, 46), Vector2(220, 42), 17, 15)

func _apply_responsive_layout() -> void:
	var compact: bool = ScreenTools.is_compact(self)
	ScreenTools.apply_safe_margins(safe_area, self, 38, 14)
	ScreenTools.apply_inner_margins(inner_margin, self, 26, 14)
	if panel != null:
		panel.custom_minimum_size = ScreenTools.panel_size(self, Vector2(1040, 610), Vector2(340, 600), 56.0, 48.0)
	if main_box != null:
		main_box.add_theme_constant_override("separation", 8 if compact else 14)
	if cards_box != null:
		cards_box.add_theme_constant_override("separation", 10 if compact else 14)
	ScreenTools.apply_label_font(title_label, self, 30, 24)
	ScreenTools.apply_label_font(subtitle_label, self, 17, 14)

func _apply_panel_style() -> void:
	if panel == null:
		return
	panel.add_theme_stylebox_override("panel", _make_magic_panel_style(PANEL_BG_MAGIC, PANEL_BORDER_MAGIC, 28, 2))

func _apply_text_styles() -> void:
	if title_label != null:
		title_label.add_theme_color_override("font_color", TEXT_TITLE_MAGIC)
		title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.92))
		title_label.add_theme_constant_override("shadow_offset_x", 2)
		title_label.add_theme_constant_override("shadow_offset_y", 2)
	if subtitle_label != null:
		subtitle_label.add_theme_color_override("font_color", TEXT_MUTED_MAGIC)
		subtitle_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.80))
		subtitle_label.add_theme_constant_override("shadow_offset_x", 1)
		subtitle_label.add_theme_constant_override("shadow_offset_y", 1)

func _apply_magic_motion() -> void:
	var pulse: float = 0.5 + 0.5 * sin(elapsed * 2.0)
	if title_label != null:
		title_label.modulate = Color(1.0, 0.93 + pulse * 0.07, 0.72 + pulse * 0.16, 1.0)
	if panel != null:
		panel.modulate = Color(1.0, 1.0, 1.0, 0.96 + pulse * 0.04)

func _process(delta: float) -> void:
	elapsed += delta
	if not _animations_enabled():
		if effects_canvas != null:
			effects_canvas.visible = false
		if panel != null:
			panel.modulate = Color.WHITE
		if title_label != null:
			title_label.modulate = Color.WHITE
		return
	_apply_magic_motion()
	if effects_canvas != null:
		effects_canvas.visible = true
	_update_particles(delta)
	effects_canvas.queue_redraw()

func _prepare_effects_layer() -> void:
	if safe_area != null:
		safe_area.z_index = 10
	effects_canvas = Control.new()
	effects_canvas.name = "FreeModeEffectsCanvas"
	effects_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	effects_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effects_canvas.z_index = 2
	effects_canvas.draw.connect(_on_effects_canvas_draw)
	add_child(effects_canvas)

func _on_minigame_pressed(index: int) -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	GameManager.start_free_minigame(index)

func _on_back_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	GameManager.open_mode_select()

func _animations_enabled() -> bool:
	return not has_node("/root/SettingsManager") or SettingsManager.animations_enabled()

func _reset_particles() -> void:
	particles.clear()
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(1280, 720)
	for i in range(FREE_PARTICLE_COUNT):
		particles.append({
			"position": Vector2(randf_range(0.0, viewport_size.x), randf_range(0.0, viewport_size.y)),
			"speed": randf_range(12.0, 38.0),
			"font_size": randi_range(18, 34),
			"alpha": randf_range(0.18, 0.58),
			"wave": randf_range(0.0, TAU),
			"symbol": FREE_SYMBOLS[i % FREE_SYMBOLS.size()]
		})

func _update_particles(delta: float) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	for i in range(particles.size()):
		var particle: Dictionary = particles[i]
		var particle_pos: Vector2 = _dict_vec2(particle, "position", Vector2.ZERO)
		particle_pos.y -= float(particle.get("speed", 22.0)) * delta
		particle_pos.x += sin(elapsed * 1.0 + float(particle.get("wave", 0.0))) * 16.0 * delta
		if particle_pos.y < -36.0:
			particle_pos.y = viewport_size.y + randf_range(20.0, 120.0)
			particle_pos.x = randf_range(0.0, viewport_size.x)
		particle["position"] = particle_pos
		particles[i] = particle

func _on_effects_canvas_draw() -> void:
	if not _animations_enabled():
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	var pulse: float = (sin(elapsed * 2.2) + 1.0) * 0.5
	effects_canvas.draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.05, 0.03, 0.12, 0.040 + pulse * 0.020), true)
	for particle in particles:
		var particle_pos: Vector2 = _dict_vec2(particle, "position", Vector2.ZERO)
		var alpha: float = float(particle.get("alpha", 0.42))
		var font_size: int = int(particle.get("font_size", 24))
		var symbol: String = str(particle.get("symbol", "$"))
		var color: Color = _symbol_color(symbol, alpha)
		effects_canvas.draw_string(get_theme_default_font(), particle_pos, symbol, HORIZONTAL_ALIGNMENT_CENTER, -1.0, font_size, color)

func _symbol_color(symbol: String, alpha: float) -> Color:
	match symbol:
		"$":
			return Color(1.0, 0.82, 0.18, alpha)
		"⚓":
			return Color(0.35, 0.78, 1.0, alpha)
		"💼":
			return Color(1.0, 0.58, 0.22, alpha)
		"🚨":
			return Color(1.0, 0.26, 0.20, alpha)
		"🧩":
			return Color(0.70, 1.0, 0.70, alpha)
		"🛑":
			return Color(1.0, 0.22, 0.22, alpha)
		"🚗":
			return Color(0.80, 0.92, 1.0, alpha)
		_:
			return Color(0.74, 1.0, 0.74, alpha)

func _make_magic_panel_style(bg_color: Color, border_color: Color, radius: int = 24, border_width: int = 2) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.set_corner_radius_all(radius)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.46)
	style.shadow_size = 14
	return style

func _dict_vec2(data: Dictionary, key: String, fallback: Vector2) -> Vector2:
	var value: Variant = data.get(key, fallback)
	if value is Vector2:
		return value
	return fallback
