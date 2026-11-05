extends Control

const MODE_PARTICLE_COUNT := 30
const PANEL_BG_MAGIC := Color(0.035, 0.045, 0.105, 0.92)
const PANEL_BORDER_MAGIC := Color(1.0, 0.84, 0.22, 0.84)
const TEXT_TITLE_MAGIC := Color(1.0, 0.92, 0.68, 1.0)

@onready var btn_campaign: Button = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/btnCampanha")
@onready var btn_free: Button = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/btnLivre")
@onready var btn_back: Button = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/btnVoltar")
@onready var safe_area: MarginContainer = get_node_or_null("SafeArea")
@onready var panel: PanelContainer = get_node_or_null("SafeArea/CenterContainer/PanelContainer")
@onready var inner_margin: MarginContainer = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer")
@onready var title_label: Label = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Title")
@onready var main_box: VBoxContainer = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer")

var particles: Array[Dictionary] = []
var effects_canvas: Control
var elapsed: float = 0.0

func _ready() -> void:
	randomize()
	if has_node("/root/AudioManager"):
		AudioManager.play_music("menu")
	_apply_card_labels()
	_apply_responsive_layout()
	_prepare_effects_layer()
	_reset_particles()
	_connect_button(btn_campaign, _on_btn_campanha_pressed)
	_connect_button(btn_free, _on_btn_livre_pressed)
	_connect_button(btn_back, _on_btn_voltar_pressed)
	_connect_card_hover(btn_campaign)
	_connect_card_hover(btn_free)
	_apply_button_styles()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_responsive_layout()
		_apply_button_styles()
		if _animations_enabled():
			_reset_particles()

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
	effects_canvas.name = "ModeSelectEffectsCanvas"
	effects_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	effects_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effects_canvas.z_index = 2
	effects_canvas.draw.connect(_on_effects_canvas_draw)
	add_child(effects_canvas)

func _apply_card_labels() -> void:
	if title_label != null:
		title_label.text = "SELECIONE O MODO DE JOGO"
	if btn_campaign != null:
		btn_campaign.text = "🧭  MODO CAMPANHA\nJogue a jornada completa."
	if btn_free != null:
		btn_free.text = "🎮  MODO LIVRE\nEscolha um minigame direto."
	if btn_back != null:
		btn_back.text = "↩  VOLTAR"

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

func _connect_button(button: Button, callable: Callable) -> void:
	if button != null and not button.pressed.is_connected(callable):
		button.pressed.connect(callable)

func _apply_button_styles() -> void:
	_apply_panel_style()
	_apply_text_styles()
	ScreenTools.apply_button(btn_campaign, self, "mode_campaign_card", Vector2(430, 92), Vector2(300, 74), 20, 16)
	ScreenTools.apply_button(btn_free, self, "mode_free_card", Vector2(430, 92), Vector2(300, 74), 20, 16)
	ScreenTools.apply_button(btn_back, self, "magic_back", Vector2(270, 48), Vector2(220, 42), 18, 16)

func _apply_responsive_layout() -> void:
	var compact: bool = ScreenTools.is_compact(self)
	ScreenTools.apply_safe_margins(safe_area, self, 48, 22)
	ScreenTools.apply_inner_margins(inner_margin, self, 32, 20)
	if panel != null:
		panel.custom_minimum_size = ScreenTools.panel_size(self, Vector2(560, 430), Vector2(340, 360), 64.0, 64.0)
	if main_box != null:
		main_box.add_theme_constant_override("separation", 11 if compact else 16)
	ScreenTools.apply_label_font(title_label, self, 30, 24)

func _apply_panel_style() -> void:
	if panel == null:
		return
	panel.add_theme_stylebox_override("panel", _make_magic_panel_style(PANEL_BG_MAGIC, PANEL_BORDER_MAGIC, 28, 2))

func _apply_text_styles() -> void:
	if title_label == null:
		return
	title_label.add_theme_color_override("font_color", TEXT_TITLE_MAGIC)
	title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.92))
	title_label.add_theme_constant_override("shadow_offset_x", 2)
	title_label.add_theme_constant_override("shadow_offset_y", 2)

func _apply_magic_motion() -> void:
	var pulse: float = 0.5 + 0.5 * sin(elapsed * 2.0)
	if title_label != null:
		title_label.modulate = Color(1.0, 0.93 + pulse * 0.07, 0.72 + pulse * 0.16, 1.0)
	if panel != null:
		panel.modulate = Color(1.0, 1.0, 1.0, 0.96 + pulse * 0.04)

func _on_btn_campanha_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	GameManager.start_campaign()

func _on_btn_livre_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	GameManager.open_free_menu()

func _on_btn_voltar_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	GameManager.go_to_main_menu()

func _animations_enabled() -> bool:
	return not has_node("/root/SettingsManager") or SettingsManager.animations_enabled()

func _reset_particles() -> void:
	particles.clear()
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(1280, 720)
	for i in range(MODE_PARTICLE_COUNT):
		particles.append({
			"position": Vector2(randf_range(0.0, viewport_size.x), randf_range(0.0, viewport_size.y)),
			"speed": randf_range(14.0, 42.0),
			"radius": randf_range(1.8, 4.2),
			"alpha": randf_range(0.22, 0.72),
			"wave": randf_range(0.0, TAU),
			"kind": i % 2
		})

func _update_particles(delta: float) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	for i in range(particles.size()):
		var particle: Dictionary = particles[i]
		var particle_pos: Vector2 = _dict_vec2(particle, "position", Vector2.ZERO)
		particle_pos.y -= float(particle.get("speed", 24.0)) * delta
		particle_pos.x += sin(elapsed * 1.1 + float(particle.get("wave", 0.0))) * 14.0 * delta
		if particle_pos.y < -28.0:
			particle_pos.y = viewport_size.y + randf_range(18.0, 110.0)
			particle_pos.x = randf_range(0.0, viewport_size.x)
		particle["position"] = particle_pos
		particles[i] = particle

func _on_effects_canvas_draw() -> void:
	if not _animations_enabled():
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	var pulse: float = (sin(elapsed * 2.0) + 1.0) * 0.5
	effects_canvas.draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.10, 0.04, 0.20, 0.045 + pulse * 0.025), true)
	for particle in particles:
		var particle_pos: Vector2 = _dict_vec2(particle, "position", Vector2.ZERO)
		var radius: float = float(particle.get("radius", 3.0))
		var alpha: float = float(particle.get("alpha", 0.52))
		var kind: int = int(particle.get("kind", 0))
		var color: Color = Color(1.0, 0.82, 0.25, alpha) if kind == 0 else Color(0.46, 0.72, 1.0, alpha * 0.76)
		effects_canvas.draw_circle(particle_pos, radius, color)
		effects_canvas.draw_circle(particle_pos, radius * 2.6, Color(color.r, color.g, color.b, alpha * 0.08))

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
