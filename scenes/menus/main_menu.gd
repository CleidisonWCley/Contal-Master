extends Control

const BrandText := preload("res://scripts/ui/BrandText.gd")

const MENU_PARTICLE_COUNT := 34

@onready var btn_start: Button = get_node_or_null("CenterContainer/MenuButtons/btnstart")
@onready var btn_settings: Button = get_node_or_null("CenterContainer/MenuButtons/btnSettings")
@onready var btn_scores: Button = get_node_or_null("CenterContainer/MenuButtons/btnScores")
@onready var btn_achievements: Button = get_node_or_null("CenterContainer/MenuButtons/btnAchievements")
@onready var btn_exit: Button = get_node_or_null("CenterContainer/MenuButtons/btnexit")
@onready var logo: TextureRect = get_node_or_null("Logo")
@onready var center_container: CenterContainer = get_node_or_null("CenterContainer")
@onready var menu_buttons: VBoxContainer = get_node_or_null("CenterContainer/MenuButtons")

var particles: Array[Dictionary] = []
var effects_canvas: Control
var version_label: RichTextLabel
var elapsed: float = 0.0
var menu_button_list: Array[Button] = []

func _ready() -> void:
	randomize()
	if has_node("/root/AudioManager"):
		AudioManager.play_music("menu")
	_connect_button(btn_start, _on_btnstart_pressed)
	_connect_button(btn_settings, _on_btn_settings_pressed)
	_connect_button(btn_scores, _on_btn_scores_pressed)
	_connect_button(btn_achievements, _on_btn_achievements_pressed)
	_connect_button(btn_exit, _on_btnexit_pressed)
	_apply_responsive_layout()
	_apply_button_icons()
	_apply_button_styles()
	_prepare_button_hover_effects()
	_prepare_visual_layers()
	_ensure_version_badge()
	_reset_particles()
	_connect_settings_signal()
	if btn_start != null:
		btn_start.call_deferred("grab_focus")

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_responsive_layout()
		_apply_button_styles()
		_apply_version_badge_layout()
		if _animations_enabled():
			_reset_particles()

func _process(delta: float) -> void:
	elapsed += delta
	_update_button_hover_animation(delta)
	if not _animations_enabled():
		if effects_canvas != null:
			effects_canvas.visible = false
		return
	if effects_canvas != null:
		effects_canvas.visible = true
	_update_particles(delta)
	_update_logo_animation()
	effects_canvas.queue_redraw()

func _prepare_visual_layers() -> void:
	if logo != null:
		logo.z_index = 10
	if center_container != null:
		center_container.z_index = 10
	effects_canvas = Control.new()
	effects_canvas.name = "MenuEffectsCanvas"
	effects_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	effects_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effects_canvas.z_index = 2
	effects_canvas.draw.connect(_on_effects_canvas_draw)
	add_child(effects_canvas)

func _apply_button_icons() -> void:
	_set_menu_button(btn_start, "INICIAR JOGO", Paths.ICON_UI_PLAY)
	_set_menu_button(btn_settings, "CONFIGURAÇÕES", Paths.ICON_UI_SETTINGS)
	_set_menu_button(btn_scores, "PONTUAÇÃO", Paths.ICON_UI_TROPHY)
	_set_menu_button(btn_achievements, "CONQUISTAS", Paths.ICON_UI_STAR)
	_set_menu_button(btn_exit, "SAIR", Paths.ICON_UI_EXIT)

func _set_menu_button(button: Button, label: String, icon_path: String) -> void:
	if button == null:
		return
	button.text = label
	button.icon = load(icon_path) as Texture2D
	button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.expand_icon = false

func _ensure_version_badge() -> void:
	if version_label != null:
		return
	var badge_bbcode: String = GameManager.get_app_version_bbcode() if has_node("/root/GameManager") else BrandText.version_bbcode()
	version_label = BrandText.make_label(badge_bbcode, 16, "right", false)
	version_label.name = "VersionBadge"
	version_label.z_index = 20
	add_child(version_label)
	_apply_version_badge_layout()

func _apply_version_badge_layout() -> void:
	if version_label == null:
		return
	var compact: bool = ScreenTools.is_compact(self)
	version_label.anchor_left = 1.0
	version_label.anchor_right = 1.0
	version_label.anchor_top = 1.0
	version_label.anchor_bottom = 1.0
	version_label.offset_left = -260.0 if compact else -300.0
	version_label.offset_right = -18.0 if compact else -28.0
	version_label.offset_top = -38.0 if compact else -44.0
	version_label.offset_bottom = -12.0 if compact else -16.0
	BrandText.set_font_size(version_label, 14 if compact else 16)

func _connect_settings_signal() -> void:
	if has_node("/root/SettingsManager"):
		var callable: Callable = Callable(self, "_on_settings_changed")
		if not SettingsManager.settings_changed.is_connected(callable):
			SettingsManager.settings_changed.connect(callable)

func _on_settings_changed(_settings: Dictionary) -> void:
	if _animations_enabled():
		_reset_particles()
	if effects_canvas != null:
		effects_canvas.queue_redraw()

func _connect_button(button: Button, callable: Callable) -> void:
	if button != null and not button.pressed.is_connected(callable):
		button.pressed.connect(callable)


func _prepare_button_hover_effects() -> void:
	menu_button_list = []
	for button in [btn_start, btn_settings, btn_scores, btn_achievements, btn_exit]:
		if button == null:
			continue
		menu_button_list.append(button)
		button.set_meta("hovered", false)
		button.set_meta("target_scale", 1.0)
		_connect_button_hover_signal(button.mouse_entered, Callable(self, "_on_menu_button_hovered").bind(button, true))
		_connect_button_hover_signal(button.mouse_exited, Callable(self, "_on_menu_button_hovered").bind(button, false))
		_connect_button_hover_signal(button.focus_entered, Callable(self, "_on_menu_button_hovered").bind(button, true))
		_connect_button_hover_signal(button.focus_exited, Callable(self, "_on_menu_button_hovered").bind(button, false))

func _connect_button_hover_signal(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _on_menu_button_hovered(button: Button, is_hovered: bool) -> void:
	if button == null:
		return
	button.set_meta("hovered", is_hovered)
	button.set_meta("target_scale", 1.045 if is_hovered else 1.0)

func _update_button_hover_animation(delta: float) -> void:
	for button in menu_button_list:
		if button == null:
			continue
		button.pivot_offset = button.size * 0.5
		var target_scale: float = float(button.get_meta("target_scale", 1.0))
		var current_scale: float = button.scale.x
		var next_scale: float = lerpf(current_scale, target_scale, clampf(delta * 10.0, 0.0, 1.0))
		button.scale = Vector2(next_scale, next_scale)

func _apply_button_styles() -> void:
	ScreenTools.apply_button(btn_start, self, "menu_play", Vector2(340, 66), Vector2(282, 54), 24, 20)
	ScreenTools.apply_button(btn_settings, self, "menu_settings", Vector2(340, 56), Vector2(282, 48), 20, 18)
	ScreenTools.apply_button(btn_scores, self, "menu_scores", Vector2(340, 56), Vector2(282, 48), 20, 18)
	ScreenTools.apply_button(btn_achievements, self, "menu_achievements", Vector2(340, 56), Vector2(282, 48), 20, 18)
	ScreenTools.apply_button(btn_exit, self, "menu_exit", Vector2(340, 56), Vector2(282, 48), 20, 18)

func _apply_responsive_layout() -> void:
	var viewport_size: Vector2 = ScreenTools.get_viewport_size(self)
	var compact: bool = ScreenTools.is_compact(self)
	if menu_buttons != null:
		menu_buttons.add_theme_constant_override("separation", 13 if compact else 18)
		menu_buttons.custom_minimum_size = Vector2(282, 330) if compact else Vector2(340, 390)
	if center_container != null:
		center_container.offset_top = clampf(viewport_size.y * (0.22 if compact else 0.24), 118.0, 188.0)
	if logo != null:
		var logo_width: float = clampf(viewport_size.x * (0.38 if compact else 0.42), 330.0, 560.0)
		var logo_height: float = clampf(logo_width * 0.46, 150.0, 260.0)
		var logo_top: float = clampf(viewport_size.y * 0.025, 10.0, 30.0)
		logo.anchor_left = 0.5
		logo.anchor_right = 0.5
		logo.anchor_top = 0.0
		logo.anchor_bottom = 0.0
		logo.offset_left = -logo_width * 0.5
		logo.offset_right = logo_width * 0.5
		logo.offset_top = logo_top
		logo.offset_bottom = logo_top + logo_height
		logo.custom_minimum_size = Vector2(logo_width, logo_height)

func _on_btnstart_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	GameManager.open_mode_select()

func _on_btn_settings_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	GameManager.open_settings()

func _on_btn_scores_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	GameManager.open_scores()

func _on_btn_achievements_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	GameManager.open_achievements()

func _on_btnSttings_pressed() -> void:
	_on_btn_settings_pressed()

func _on_btnexit_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	# V0.14.1: na web quit() derruba o runtime; WebBridge encerra com seguranca em qualquer plataforma.
	WebBridge.request_exit()

func _animations_enabled() -> bool:
	return not has_node("/root/SettingsManager") or SettingsManager.animations_enabled()

func _reset_particles() -> void:
	particles.clear()
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(1280, 720)
	for i in range(MENU_PARTICLE_COUNT):
		particles.append({
			"position": Vector2(randf_range(0.0, viewport_size.x), randf_range(0.0, viewport_size.y)),
			"speed": randf_range(18.0, 54.0),
			"radius": randf_range(1.8, 4.8),
			"alpha": randf_range(0.26, 0.82),
			"wave": randf_range(0.0, TAU),
			"kind": i % 3
		})

func _update_particles(delta: float) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	for i in range(particles.size()):
		var particle: Dictionary = particles[i]
		var pos: Vector2 = _dict_vec2(particle, "position", Vector2.ZERO)
		pos.y -= float(particle.get("speed", 30.0)) * delta
		pos.x += sin(elapsed * 1.2 + float(particle.get("wave", 0.0))) * 18.0 * delta
		if pos.y < -28.0:
			pos.y = viewport_size.y + randf_range(20.0, 120.0)
			pos.x = randf_range(0.0, viewport_size.x)
		particle["position"] = pos
		particles[i] = particle

func _update_logo_animation() -> void:
	if logo == null:
		return
	var pulse: float = 0.5 + absf(sin(elapsed * 2.2)) * 0.5
	logo.modulate = Color(1.0, 1.0, 1.0, 0.90 + pulse * 0.10)
	logo.scale = Vector2.ONE * (1.0 + pulse * 0.012)

func _on_effects_canvas_draw() -> void:
	if not _animations_enabled():
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	var pulse: float = (sin(elapsed * 2.4) + 1.0) * 0.5
	effects_canvas.draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.12, 0.06, 0.20, 0.035 + pulse * 0.025), true)
	for particle in particles:
		var pos: Vector2 = _dict_vec2(particle, "position", Vector2.ZERO)
		var radius: float = float(particle.get("radius", 3.0))
		var alpha: float = float(particle.get("alpha", 0.55))
		var kind: int = int(particle.get("kind", 0))
		var color: Color = Color(1.0, 0.82, 0.20, alpha)
		if kind == 1:
			color = Color(0.54, 0.76, 1.0, alpha * 0.72)
		elif kind == 2:
			color = Color(1.0, 1.0, 1.0, alpha * 0.58)
		effects_canvas.draw_circle(pos, radius, color)
		effects_canvas.draw_circle(pos, radius * 2.4, Color(color.r, color.g, color.b, alpha * 0.08))

func _dict_vec2(data: Dictionary, key: String, fallback: Vector2) -> Vector2:
	var value: Variant = data.get(key, fallback)
	if value is Vector2:
		return value
	return fallback
