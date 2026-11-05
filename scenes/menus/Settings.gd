extends Control

const SETTINGS_PARTICLE_COUNT := 30
const PANEL_BG_MAGIC := Color(0.035, 0.045, 0.105, 0.92)
const PANEL_BORDER_MAGIC := Color(1.0, 0.84, 0.22, 0.82)
const PANEL_BORDER_CYAN := Color(0.38, 0.92, 1.0, 0.58)
const MUSIC_ACCENT := Color(1.0, 0.84, 0.22, 1.0)
const SFX_ACCENT := Color(0.34, 0.92, 1.0, 1.0)
const TEXT_MAIN := Color(1.0, 1.0, 1.0, 1.0)
const TEXT_MUTED := Color(0.82, 0.86, 1.0, 1.0)


@onready var music_slider: HSlider = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MusicRow/MusicSlider")
@onready var sfx_slider: HSlider = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SfxRow/SfxSlider")
@onready var fullscreen_button: Button = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/FullscreenToggle")
@onready var animations_button: Button = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/AnimationsToggle")
@onready var difficulty_option: OptionButton = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/DifficultyRow/DifficultyOption")
@onready var btn_back: Button = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonRow/BtnVoltar")
@onready var safe_area: MarginContainer = get_node_or_null("SafeArea")
@onready var panel: PanelContainer = get_node_or_null("SafeArea/CenterContainer/PanelContainer")
@onready var inner_margin: MarginContainer = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer")
@onready var main_box: VBoxContainer = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer")
@onready var title_label: Label = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Title")
@onready var music_label: Label = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MusicRow/MusicLabel")
@onready var sfx_label: Label = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SfxRow/SfxLabel")
@onready var difficulty_label: Label = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/DifficultyRow/DifficultyLabel")
@onready var music_row: HBoxContainer = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MusicRow")
@onready var sfx_row: HBoxContainer = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SfxRow")
@onready var difficulty_row: HBoxContainer = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/DifficultyRow")

const DIFFICULTY_OPTIONS := [
	{"label": "Fácil", "value": "facil"},
	{"label": "Normal", "value": "normal"},
	{"label": "Difícil", "value": "dificil"}
]

var particles: Array[Dictionary] = []
var effects_canvas: Control
var elapsed: float = 0.0

func _ready() -> void:
	randomize()
	if has_node("/root/AudioManager"):
		AudioManager.play_music("menu")
	_apply_static_texts()
	_apply_platform_visibility()
	_apply_responsive_layout()
	_prepare_effects_layer()
	_setup_difficulty_options()
	_load_current_settings()
	_apply_button_styles()
	_connect_signals()
	_reset_particles()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_platform_visibility()
		_apply_responsive_layout()
		_apply_button_styles()
		if _animations_enabled():
			_reset_particles()

func _process(delta: float) -> void:
	elapsed += delta
	_apply_magic_motion()
	if not _animations_enabled():
		if effects_canvas != null:
			effects_canvas.visible = false
		return
	if effects_canvas != null:
		effects_canvas.visible = true
	_update_particles(delta)
	effects_canvas.queue_redraw()

func _prepare_effects_layer() -> void:
	if safe_area != null:
		safe_area.z_index = 10
	effects_canvas = Control.new()
	effects_canvas.name = "SettingsEffectsCanvas"
	effects_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	effects_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effects_canvas.z_index = 2
	effects_canvas.draw.connect(_on_effects_canvas_draw)
	add_child(effects_canvas)

func _setup_difficulty_options() -> void:
	if difficulty_option == null:
		return
	difficulty_option.clear()
	for item in DIFFICULTY_OPTIONS:
		difficulty_option.add_item(str(item["label"]))
		difficulty_option.set_item_metadata(difficulty_option.get_item_count() - 1, item["value"])

func _load_current_settings() -> void:
	if music_slider != null:
		music_slider.value = SettingsManager.get_music_volume()
	if sfx_slider != null:
		sfx_slider.value = SettingsManager.get_sfx_volume()
	_select_difficulty(SettingsManager.get_difficulty())
	_update_fullscreen_button()
	_update_animations_button()

func _select_difficulty(value: String) -> void:
	if difficulty_option == null:
		return
	for index in range(difficulty_option.get_item_count()):
		if str(difficulty_option.get_item_metadata(index)) == value:
			difficulty_option.select(index)
			_update_difficulty_option_style(value)
			return
	difficulty_option.select(1)
	_update_difficulty_option_style("normal")

func _apply_button_styles() -> void:
	_apply_panel_style()
	_apply_text_styles()
	_apply_slider_style(music_slider, MUSIC_ACCENT)
	_apply_slider_style(sfx_slider, SFX_ACCENT)
	_update_difficulty_option_style(SettingsManager.get_difficulty())
	_update_fullscreen_button()
	_update_animations_button()
	ScreenTools.apply_button(btn_back, self, "mode_back", Vector2(210, 46), Vector2(180, 42), 17, 15)
	if btn_back != null:
		btn_back.text = "↩ VOLTAR"

func _apply_static_texts() -> void:
	if title_label != null:
		title_label.text = "⚙ CONFIGURAÇÕES"
	if music_label != null:
		music_label.text = "🎵 Música"
	if sfx_label != null:
		sfx_label.text = "🔊 Efeitos"
	if difficulty_label != null:
		difficulty_label.text = "🎚 Dificuldade"
	if btn_back != null:
		btn_back.text = "↩ VOLTAR"

func _apply_panel_style() -> void:
	if panel == null:
		return
	panel.add_theme_stylebox_override("panel", _make_panel_style(PANEL_BG_MAGIC, PANEL_BORDER_MAGIC, 28, 2))

func _apply_text_styles() -> void:
	if title_label != null:
		title_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.68, 1.0))
		title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.92))
		title_label.add_theme_constant_override("shadow_offset_x", 2)
		title_label.add_theme_constant_override("shadow_offset_y", 2)
	for label in [music_label, sfx_label, difficulty_label]:
		if label is Label:
			(label as Label).add_theme_color_override("font_color", TEXT_MAIN)
			(label as Label).add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
			(label as Label).add_theme_constant_override("shadow_offset_x", 1)
			(label as Label).add_theme_constant_override("shadow_offset_y", 1)

func _apply_slider_style(slider: HSlider, accent: Color) -> void:
	if slider == null:
		return
	var rail: StyleBoxFlat = _make_slider_rail(Color(0.08, 0.08, 0.12, 0.86), Color(accent.r, accent.g, accent.b, 0.42), 8)
	var fill: StyleBoxFlat = _make_slider_rail(Color(accent.r, accent.g, accent.b, 0.62), Color(accent.r, accent.g, accent.b, 0.92), 8)
	slider.add_theme_stylebox_override("slider", rail)
	slider.add_theme_stylebox_override("grabber_area", fill)
	slider.add_theme_stylebox_override("grabber_area_highlight", fill)
	slider.add_theme_color_override("font_color", TEXT_MAIN)

func _apply_magic_motion() -> void:
	var pulse: float = 0.5 + 0.5 * sin(elapsed * 2.0)
	if title_label != null:
		title_label.modulate = Color(1.0, 0.93 + pulse * 0.07, 0.72 + pulse * 0.16, 1.0)
	if panel != null:
		panel.modulate = Color(1.0, 1.0, 1.0, 0.96 + pulse * 0.04)

func _apply_platform_visibility() -> void:
	if fullscreen_button == null:
		return
	fullscreen_button.visible = not ScreenTools.is_mobile_platform()
	fullscreen_button.disabled = ScreenTools.is_mobile_platform()

func _apply_responsive_layout() -> void:
	var compact: bool = ScreenTools.is_compact(self)
	ScreenTools.apply_safe_margins(safe_area, self, 48, 18)
	ScreenTools.apply_inner_margins(inner_margin, self, 32, 18)
	if panel != null:
		panel.custom_minimum_size = ScreenTools.panel_size(self, Vector2(620, 500), Vector2(360, 510), 64.0, 64.0)
	if main_box != null:
		main_box.add_theme_constant_override("separation", 9 if compact else 13)
	ScreenTools.apply_label_font(title_label, self, 30, 25)
	ScreenTools.apply_label_font(music_label, self, 20, 16)
	ScreenTools.apply_label_font(sfx_label, self, 20, 16)
	ScreenTools.apply_label_font(difficulty_label, self, 20, 16)
	if music_slider != null:
		music_slider.custom_minimum_size = ScreenTools.responsive_size(self, Vector2(300, 42), Vector2(220, 38))
	if sfx_slider != null:
		sfx_slider.custom_minimum_size = ScreenTools.responsive_size(self, Vector2(300, 42), Vector2(220, 38))

func _connect_signals() -> void:
	if music_slider != null and not music_slider.value_changed.is_connected(_on_music_volume_changed):
		music_slider.value_changed.connect(_on_music_volume_changed)
	if sfx_slider != null and not sfx_slider.value_changed.is_connected(_on_sfx_volume_changed):
		sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	if difficulty_option != null and not difficulty_option.item_selected.is_connected(_on_difficulty_selected):
		difficulty_option.item_selected.connect(_on_difficulty_selected)
	if fullscreen_button != null and not fullscreen_button.pressed.is_connected(_on_fullscreen_pressed):
		fullscreen_button.pressed.connect(_on_fullscreen_pressed)
	if animations_button != null and not animations_button.pressed.is_connected(_on_animations_pressed):
		animations_button.pressed.connect(_on_animations_pressed)
	if btn_back != null and not btn_back.pressed.is_connected(_on_back_pressed):
		btn_back.pressed.connect(_on_back_pressed)

func _on_music_volume_changed(value: float) -> void:
	SettingsManager.set_music_volume(value)

func _on_sfx_volume_changed(value: float) -> void:
	SettingsManager.set_sfx_volume(value)
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("click")

func _on_difficulty_selected(index: int) -> void:
	if difficulty_option == null or index < 0:
		return
	var difficulty: String = str(difficulty_option.get_item_metadata(index))
	DifficultyManager.set_difficulty(difficulty)
	_update_difficulty_option_style(difficulty)
	if has_node("/root/AudioManager"):
		AudioManager.play_click()

func _on_fullscreen_pressed() -> void:
	if ScreenTools.is_mobile_platform():
		return
	SettingsManager.toggle_fullscreen()
	_update_fullscreen_button()
	if has_node("/root/AudioManager"):
		AudioManager.play_click()

func _on_animations_pressed() -> void:
	SettingsManager.toggle_animations_enabled()
	_update_animations_button()
	if SettingsManager.animations_enabled():
		_reset_particles()
	if effects_canvas != null:
		effects_canvas.visible = SettingsManager.animations_enabled()
		effects_canvas.queue_redraw()
	if has_node("/root/AudioManager"):
		AudioManager.play_click()

func _update_fullscreen_button() -> void:
	_update_toggle_button(fullscreen_button, "🖥 Tela cheia", SettingsManager.is_fullscreen())

func _update_animations_button() -> void:
	_update_toggle_button(animations_button, "✨ Animações visuais", SettingsManager.animations_enabled())

func _update_toggle_button(button: Button, label: String, value: bool) -> void:
	var toggle_size: Vector2 = ScreenTools.button_size(self, Vector2(280, 48), Vector2(230, 44))
	var toggle_font: int = ScreenTools.responsive_font(self, 18, 16)
	ButtonStyles.apply_toggle(button, label, value, toggle_size, toggle_font)

func _update_difficulty_option_style(value: String) -> void:
	ButtonStyles.apply_difficulty(difficulty_option, value, ScreenTools.button_size(self, Vector2(220, 42), Vector2(190, 40)), ScreenTools.responsive_font(self, 17, 15))

func _on_back_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	GameManager.go_to_main_menu()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F11 and not ScreenTools.is_mobile_platform():
			SettingsManager.toggle_fullscreen()
			_update_fullscreen_button()

func _animations_enabled() -> bool:
	return SettingsManager.animations_enabled()

func _reset_particles() -> void:
	particles.clear()
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(1280, 720)
	for i in range(SETTINGS_PARTICLE_COUNT):
		particles.append({
			"position": Vector2(randf_range(0.0, viewport_size.x), randf_range(0.0, viewport_size.y)),
			"velocity": Vector2(randf_range(-16.0, 16.0), randf_range(-34.0, -12.0)),
			"radius": randf_range(1.8, 4.8),
			"alpha": randf_range(0.26, 0.76),
			"wave": randf_range(0.0, TAU),
			"kind": i % 2
		})

func _update_particles(delta: float) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	for i in range(particles.size()):
		var particle: Dictionary = particles[i]
		var particle_pos: Vector2 = _dict_vec2(particle, "position", Vector2.ZERO)
		var velocity: Vector2 = _dict_vec2(particle, "velocity", Vector2.ZERO)
		particle_pos += velocity * delta
		particle_pos.x += sin(elapsed * 1.3 + float(particle.get("wave", 0.0))) * 18.0 * delta
		if particle_pos.y < -32.0:
			particle_pos.y = viewport_size.y + randf_range(20.0, 120.0)
			particle_pos.x = randf_range(0.0, viewport_size.x)
		particle["position"] = particle_pos
		particles[i] = particle

func _on_effects_canvas_draw() -> void:
	if not _animations_enabled():
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	var pulse: float = (sin(elapsed * 2.1) + 1.0) * 0.5
	effects_canvas.draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.04, 0.08, 0.18, 0.045 + pulse * 0.025), true)
	for particle in particles:
		var particle_pos: Vector2 = _dict_vec2(particle, "position", Vector2.ZERO)
		var radius: float = float(particle.get("radius", 3.0))
		var alpha: float = float(particle.get("alpha", 0.55))
		var kind: int = int(particle.get("kind", 0))
		var color: Color = Color(1.0, 0.82, 0.25, alpha)
		if kind == 1:
			color = Color(0.50, 0.78, 1.0, alpha * 0.72)
		effects_canvas.draw_circle(particle_pos, radius, color)
		effects_canvas.draw_arc(particle_pos, radius * 3.5, 0.0, TAU, 16, Color(color.r, color.g, color.b, alpha * 0.09), 1.4)

func _make_panel_style(bg_color: Color, border_color: Color, radius: int = 24, border_width: int = 2) -> StyleBoxFlat:
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
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.42)
	style.shadow_size = 12
	return style

func _make_slider_rail(bg_color: Color, border_color: Color, radius: int = 8) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.set_corner_radius_all(radius)
	style.content_margin_top = 3
	style.content_margin_bottom = 3
	style.shadow_color = Color(border_color.r, border_color.g, border_color.b, 0.20)
	style.shadow_size = 4
	return style

func _make_toggle_style(bg_color: Color, border_color: Color, border_width: int = 2) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.set_corner_radius_all(14)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.28)
	style.shadow_size = 6
	return style

func _dict_vec2(data: Dictionary, key: String, fallback: Vector2) -> Vector2:
	var value: Variant = data.get(key, fallback)
	if value is Vector2:
		return value
	return fallback
