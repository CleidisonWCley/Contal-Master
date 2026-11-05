extends Control

const BACKGROUND_PATH := Paths.BG_MENU_MAIN
const LOCK_ICON_PATH := Paths.ICON_LOCK
const UNLOCKED_ICON_PATH := Paths.ICON_TROPHY
const INSIGNIA_PATHS := {
	"Bronze": Paths.INSIGNIA_BRONZE,
	"Prata": Paths.INSIGNIA_SILVER,
	"Ouro": Paths.INSIGNIA_GOLD,
	"Platina": Paths.INSIGNIA_PLATINUM
}

var safe_area: MarginContainer
var scroll: ScrollContainer
var grid: GridContainer
var progress_label: Label
var progress_bar: ProgressBar
var insignia_texture_rect: TextureRect
var insignia_name_label: Label
var completion_label: Label
var back_button_wrap: MarginContainer
var back_button: Button
var effects_canvas: Control
var elapsed: float = 0.0
var lock_texture: Texture2D
var unlocked_texture: Texture2D
var insignia_textures: Dictionary = {}
var achievement_icon_textures: Dictionary = {}

func _ready() -> void:
	lock_texture = load(LOCK_ICON_PATH) as Texture2D
	unlocked_texture = load(UNLOCKED_ICON_PATH) as Texture2D
	_load_insignia_textures()
	_load_achievement_icon_textures()
	_build_ui()
	_connect_achievement_signal()
	_refresh_view()
	if has_node("/root/AudioManager"):
		AudioManager.play_music("menu")

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_responsive_layout()

func _process(delta: float) -> void:
	elapsed += delta
	if effects_canvas != null:
		effects_canvas.visible = _animations_enabled()
		if effects_canvas.visible:
			effects_canvas.queue_redraw()

func _build_ui() -> void:
	_clear_children()

	var background: TextureRect = TextureRect.new()
	background.name = "Background"
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = 1
	background.stretch_mode = 6
	var background_texture: Resource = load(BACKGROUND_PATH)
	if background_texture is Texture2D:
		background.texture = background_texture as Texture2D
	add_child(background)

	var dimmer: ColorRect = ColorRect.new()
	dimmer.name = "Dimmer"
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.02, 0.01, 0.08, 0.58)
	add_child(dimmer)

	effects_canvas = Control.new()
	effects_canvas.name = "AchievementsEffects"
	effects_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	effects_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effects_canvas.draw.connect(_on_effects_canvas_draw)
	add_child(effects_canvas)

	safe_area = MarginContainer.new()
	safe_area.name = "SafeArea"
	safe_area.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(safe_area)

	var main_box: VBoxContainer = VBoxContainer.new()
	main_box.name = "MainBox"
	main_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_box.add_theme_constant_override("separation", 12)
	safe_area.add_child(main_box)

	var header_panel: PanelContainer = PanelContainer.new()
	header_panel.name = "HeaderPanel"
	header_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.07, 0.04, 0.16, 0.90), Color(1.0, 0.80, 0.18, 0.95), 20, 2))
	main_box.add_child(header_panel)

	var header_margin: MarginContainer = MarginContainer.new()
	header_margin.add_theme_constant_override("margin_left", 24)
	header_margin.add_theme_constant_override("margin_top", 8)
	header_margin.add_theme_constant_override("margin_right", 24)
	header_margin.add_theme_constant_override("margin_bottom", 8)
	header_panel.add_child(header_margin)

	var header_box: VBoxContainer = VBoxContainer.new()
	header_box.add_theme_constant_override("separation", 4)
	header_margin.add_child(header_box)

	var title_label: Label = Label.new()
	title_label.text = "🏅 CONQUISTAS"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 36)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.30, 1.0))
	title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.86))
	title_label.add_theme_constant_override("shadow_offset_x", 2)
	title_label.add_theme_constant_override("shadow_offset_y", 2)
	header_box.add_child(title_label)

	insignia_texture_rect = TextureRect.new()
	insignia_texture_rect.name = "ProgressInsignia"
	insignia_texture_rect.custom_minimum_size = Vector2(90, 90)
	insignia_texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	insignia_texture_rect.expand_mode = 1
	insignia_texture_rect.stretch_mode = 5
	header_box.add_child(insignia_texture_rect)

	insignia_name_label = Label.new()
	insignia_name_label.name = "InsigniaName"
	insignia_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	insignia_name_label.add_theme_font_size_override("font_size", 18)
	insignia_name_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.42, 1.0))
	insignia_name_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.82))
	insignia_name_label.add_theme_constant_override("shadow_offset_x", 1)
	insignia_name_label.add_theme_constant_override("shadow_offset_y", 1)
	header_box.add_child(insignia_name_label)

	completion_label = Label.new()
	completion_label.name = "CompletionLabel"
	completion_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	completion_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	completion_label.add_theme_font_size_override("font_size", 17)
	completion_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.44, 1.0))
	completion_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.86))
	completion_label.add_theme_constant_override("shadow_offset_x", 1)
	completion_label.add_theme_constant_override("shadow_offset_y", 1)
	header_box.add_child(completion_label)

	progress_label = Label.new()
	progress_label.name = "ProgressLabel"
	progress_label.text = "Progresso: 0/15"
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_label.add_theme_font_size_override("font_size", 17)
	progress_label.add_theme_color_override("font_color", Color(0.95, 0.98, 1.0, 1.0))
	header_box.add_child(progress_label)

	progress_bar = ProgressBar.new()
	progress_bar.name = "ProgressBar"
	progress_bar.min_value = 0.0
	progress_bar.max_value = 15.0
	progress_bar.value = 0.0
	progress_bar.show_percentage = false
	progress_bar.custom_minimum_size = Vector2(500, 18)
	progress_bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	header_box.add_child(progress_bar)

	scroll = ScrollContainer.new()
	scroll.name = "AchievementsScroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_box.add_child(scroll)

	grid = GridContainer.new()
	grid.name = "AchievementsGrid"
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	scroll.add_child(grid)

	back_button_wrap = MarginContainer.new()
	back_button_wrap.name = "BackButtonWrap"
	back_button_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back_button_wrap.add_theme_constant_override("margin_top", 6)
	back_button_wrap.add_theme_constant_override("margin_bottom", 18)
	main_box.add_child(back_button_wrap)

	back_button = Button.new()
	back_button.name = "BackButton"
	back_button.text = "↩ VOLTAR"
	back_button.custom_minimum_size = Vector2(240, 46)
	back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back_button.add_theme_font_size_override("font_size", 20)
	back_button.add_theme_stylebox_override("normal", _make_button_style(Color(0.08, 0.05, 0.14, 0.94), Color(1.0, 0.76, 0.16, 0.96), 2))
	back_button.add_theme_stylebox_override("hover", _make_button_style(Color(0.16, 0.08, 0.25, 0.98), Color(1.0, 0.94, 0.50, 1.0), 3))
	back_button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.04, 0.02, 0.08, 1.0), Color(1.0, 0.76, 0.16, 1.0), 2))
	back_button.pressed.connect(_on_back_pressed)
	back_button_wrap.add_child(back_button)

	_apply_responsive_layout()

func _refresh_view() -> void:
	if not has_node("/root/AchievementManager"):
		return
	var unlocked_count: int = AchievementManager.get_unlocked_count()
	var total_count: int = AchievementManager.get_total_count()
	var insignia_name: String = AchievementManager.get_insignia_name()
	if progress_label != null:
		progress_label.text = "Progresso: %s/%s" % [unlocked_count, total_count]
	if progress_bar != null:
		progress_bar.max_value = float(total_count)
		progress_bar.value = float(unlocked_count)
		progress_bar.add_theme_stylebox_override("background", _make_bar_style(Color(0.05, 0.06, 0.09, 0.92), Color(1.0, 1.0, 1.0, 0.16), 10, 1))
		progress_bar.add_theme_stylebox_override("fill", _make_bar_style(_get_insignia_fill_color(insignia_name), Color(1.0, 1.0, 1.0, 0.0), 10, 0))
	if insignia_name_label != null:
		insignia_name_label.text = insignia_name
		insignia_name_label.add_theme_color_override("font_color", _get_insignia_text_color(insignia_name))
	if insignia_texture_rect != null:
		_apply_insignia_texture(insignia_name)
	if completion_label != null:
		completion_label.visible = unlocked_count >= total_count and total_count > 0
		completion_label.text = "🏆 Parabéns, todas conquistas foram desbloqueadas!\n%s/%s conquistas desbloqueadas" % [unlocked_count, total_count]
	if grid == null:
		return
	for child in grid.get_children():
		child.queue_free()
	var achievements: Array = AchievementManager.get_all_achievements()
	for item in achievements:
		if item is Dictionary:
			grid.add_child(_make_achievement_card(item as Dictionary))
	_apply_responsive_layout()

func _make_achievement_card(achievement: Dictionary) -> PanelContainer:
	var unlocked: bool = AchievementManager.is_unlocked(str(achievement.get("id", "")))
	var card: PanelContainer = PanelContainer.new()
	card.name = "Achievement_%s" % str(achievement.get("id", "item"))
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(330, 118)
	if unlocked:
		card.add_theme_stylebox_override("panel", _make_panel_style(Color(0.10, 0.08, 0.20, 0.95), Color(1.0, 0.78, 0.18, 1.0), 17, 2))
	else:
		card.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.08, 0.10, 0.88), Color(0.34, 0.34, 0.40, 0.84), 17, 1))

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	card.add_child(margin)

	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)

	var icon_rect: TextureRect = TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(46, 46)
	icon_rect.expand_mode = 1
	icon_rect.stretch_mode = 5
	if unlocked:
		var achievement_texture: Texture2D = _get_achievement_icon_texture(achievement)
		if achievement_texture != null:
			icon_rect.texture = achievement_texture
		else:
			icon_rect.texture = unlocked_texture
		icon_rect.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		icon_rect.texture = lock_texture
		icon_rect.modulate = Color(0.68, 0.70, 0.76, 0.82)
	row.add_child(icon_rect)

	var text_box: VBoxContainer = VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 5)
	row.add_child(text_box)

	var title: Label = Label.new()
	title.text = str(achievement.get("title", "Conquista")) if unlocked else "Bloqueado"
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 19)
	title.add_theme_color_override("font_color", Color(1.0, 0.90, 0.34, 1.0) if unlocked else Color(0.74, 0.76, 0.82, 0.92))
	text_box.add_child(title)

	var description: Label = Label.new()
	description.text = str(achievement.get("description", ""))
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_font_size_override("font_size", 14)
	description.add_theme_color_override("font_color", Color(0.93, 0.95, 1.0, 0.95) if unlocked else Color(0.70, 0.72, 0.80, 0.92))
	text_box.add_child(description)

	var state: Label = Label.new()
	state.text = "Desbloqueada" if unlocked else "Desafio bloqueado"
	state.add_theme_font_size_override("font_size", 12)
	state.add_theme_color_override("font_color", Color(0.58, 1.0, 0.68, 0.94) if unlocked else Color(0.62, 0.62, 0.68, 0.78))
	text_box.add_child(state)
	return card

func _apply_responsive_layout() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var compact: bool = viewport_size.x < 900.0
	var narrow: bool = viewport_size.x < 620.0
	if safe_area != null:
		safe_area.add_theme_constant_override("margin_left", 18 if compact else 34)
		safe_area.add_theme_constant_override("margin_top", 18 if compact else 24)
		safe_area.add_theme_constant_override("margin_right", 18 if compact else 34)
		safe_area.add_theme_constant_override("margin_bottom", 24 if compact else 34)
	if insignia_texture_rect != null:
		insignia_texture_rect.custom_minimum_size = Vector2(72, 72) if compact else Vector2(90, 90)
	if progress_bar != null:
		progress_bar.custom_minimum_size = Vector2(340, 16) if compact else Vector2(500, 18)
	if back_button_wrap != null:
		back_button_wrap.add_theme_constant_override("margin_top", 6 if compact else 8)
		back_button_wrap.add_theme_constant_override("margin_bottom", 18 if compact else 22)
	if back_button != null:
		back_button.custom_minimum_size = Vector2(220, 44) if compact else Vector2(240, 46)
	if grid != null:
		grid.columns = 1 if narrow else (2 if compact else 3)
		grid.add_theme_constant_override("h_separation", 10 if compact else 14)
		grid.add_theme_constant_override("v_separation", 10 if compact else 14)
		var available_width: float = maxf(260.0, viewport_size.x - (72.0 if not compact else 42.0))
		var columns_float: float = float(grid.columns)
		var h_gap: float = float(grid.get_theme_constant("h_separation")) * maxf(columns_float - 1.0, 0.0)
		var card_width: float = floor((available_width - h_gap) / columns_float)
		for child in grid.get_children():
			if child is Control:
				(child as Control).custom_minimum_size = Vector2(card_width, 116 if not compact else 108)

func _connect_achievement_signal() -> void:
	if has_node("/root/AchievementManager"):
		var callable: Callable = Callable(self, "_refresh_view")
		if not AchievementManager.achievements_changed.is_connected(callable):
			AchievementManager.achievements_changed.connect(callable)

func _on_back_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	GameManager.go_to_main_menu()

func _clear_children() -> void:
	for child in get_children():
		child.queue_free()

func _animations_enabled() -> bool:
	return not has_node("/root/SettingsManager") or SettingsManager.animations_enabled()

func _on_effects_canvas_draw() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var pulse: float = (sin(elapsed * 2.0) + 1.0) * 0.5
	effects_canvas.draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.12, 0.06, 0.22, 0.04 + pulse * 0.025), true)
	for i in range(18):
		var x: float = fposmod(float(i) * 173.0 + elapsed * (18.0 + float(i % 4) * 6.0), viewport_size.x)
		var y: float = fposmod(float(i) * 91.0 + sin(elapsed + float(i)) * 24.0, viewport_size.y)
		var alpha: float = 0.14 + 0.12 * absf(sin(elapsed * 1.7 + float(i)))
		effects_canvas.draw_circle(Vector2(x, y), 2.0 + float(i % 3), Color(1.0, 0.84, 0.28, alpha))

func _load_insignia_textures() -> void:
	insignia_textures.clear()
	for key in INSIGNIA_PATHS.keys():
		var path_value: String = str(INSIGNIA_PATHS[key])
		var loaded_texture: Resource = load(path_value)
		if loaded_texture is Texture2D:
			insignia_textures[str(key)] = loaded_texture as Texture2D

func _load_achievement_icon_textures() -> void:
	achievement_icon_textures.clear()
	if not has_node("/root/AchievementManager"):
		return
	var achievements: Array = AchievementManager.get_all_achievements()
	for item in achievements:
		if not item is Dictionary:
			continue
		var achievement: Dictionary = item as Dictionary
		var achievement_id: String = str(achievement.get("id", ""))
		var icon_path: String = str(achievement.get("icon_path", ""))
		if achievement_id == "" or icon_path == "":
			continue
		var loaded_icon: Resource = load(icon_path)
		if loaded_icon is Texture2D:
			achievement_icon_textures[achievement_id] = loaded_icon as Texture2D

func _get_achievement_icon_texture(achievement: Dictionary) -> Texture2D:
	var achievement_id: String = str(achievement.get("id", ""))
	var texture_value: Variant = achievement_icon_textures.get(achievement_id, null)
	if texture_value is Texture2D:
		return texture_value as Texture2D
	return null

func _apply_insignia_texture(insignia_name: String) -> void:
	if insignia_name == "Sem insígnia":
		insignia_texture_rect.texture = lock_texture
		insignia_texture_rect.modulate = Color(0.62, 0.64, 0.70, 0.72)
		return
	var texture_value: Variant = insignia_textures.get(insignia_name, null)
	if texture_value is Texture2D:
		insignia_texture_rect.texture = texture_value as Texture2D
	else:
		insignia_texture_rect.texture = null
	insignia_texture_rect.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _get_insignia_fill_color(insignia_name: String) -> Color:
	match insignia_name:
		"Bronze":
			return Color(0.78, 0.38, 0.14, 1.0)
		"Prata":
			return Color(0.78, 0.88, 0.96, 1.0)
		"Ouro":
			return Color(1.0, 0.78, 0.10, 1.0)
		"Platina":
			return Color(0.92, 0.96, 1.0, 1.0)
		_:
			return Color(0.34, 0.36, 0.42, 1.0)

func _get_insignia_text_color(insignia_name: String) -> Color:
	match insignia_name:
		"Bronze":
			return Color(1.0, 0.66, 0.32, 1.0)
		"Prata":
			return Color(0.86, 0.95, 1.0, 1.0)
		"Ouro":
			return Color(1.0, 0.88, 0.24, 1.0)
		"Platina":
			return Color(0.96, 0.98, 1.0, 1.0)
		_:
			return Color(0.72, 0.74, 0.82, 1.0)

func _make_chip_label(text_value: String, bg_color: Color, text_color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(230, 36)
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", text_color)
	label.add_theme_stylebox_override("normal", _make_panel_style(bg_color, Color(1.0, 1.0, 1.0, 0.18), 12, 1))
	return label

func _make_button_style(bg_color: Color, border_color: Color, border_width: int = 2) -> StyleBoxFlat:
	var style: StyleBoxFlat = _make_panel_style(bg_color, border_color, 14, border_width)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func _make_bar_style(bg_color: Color, border_color: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = _make_panel_style(bg_color, border_color, radius, border_width)
	style.shadow_size = 0
	return style

func _make_panel_style(bg_color: Color, border_color: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.set_corner_radius_all(radius)
	style.content_margin_left = 0
	style.content_margin_right = 0
	style.content_margin_top = 0
	style.content_margin_bottom = 0
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.38)
	style.shadow_size = 10
	return style
