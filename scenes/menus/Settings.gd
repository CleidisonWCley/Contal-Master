extends Control
## Tela "Configuracoes" (UI/UX v4): secoes AUDIO / JOGO / TELA dentro de um painel unico.
## - Sliders com valor em % ao lado; dificuldade em 3 botoes (cor + pontos 1/2/3, nunca so cor);
## - interruptores com texto LIGADO/DESLIGADO; icones brancos no lugar dos emojis.

const DIFFICULTY_KEYS := ["facil", "normal", "dificil"]
const LABEL_WIDTH := 132.0

var music_slider: HSlider
var sfx_slider: HSlider
var fullscreen_button: Button
var animations_button: Button
var tutorials_button: Button
var back_button: Button

var _safe_area: MarginContainer
var _panel: PanelContainer
var _content: VBoxContainer
var _title_label: Label
var _music_value: Label
var _sfx_value: Label
var _difficulty_buttons: Dictionary = {}   # key -> Button
var _difficulty_parts: Dictionary = {}     # key -> {"pips": UiPips, "label": Label}
var _scroll: ScrollContainer
var _grabber: Texture2D

func _ready() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_music("menu")
	UiBackdrop.attach(self)
	_grabber = UiKit.circle_texture(28, UiPalette.TEXT_ON_DARK)
	_build_ui()
	_load_current_settings()
	_apply_responsive_layout()
	back_button.call_deferred("grab_focus")

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_responsive_layout()

# ---------------------------------------------------------------- construcao
func _build_ui() -> void:
	_safe_area = MarginContainer.new()
	_safe_area.name = "SafeArea"
	_safe_area.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_safe_area)

	_scroll = ScrollContainer.new()
	_scroll.name = "Scroll"
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_safe_area.add_child(_scroll)

	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.add_child(center)

	_panel = PanelContainer.new()
	_panel.name = "Panel"
	_panel.add_theme_stylebox_override("panel", UiKit.panel_style(UiPalette.with_alpha(UiPalette.CARD, 0.95), UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.50), 28, 2, 16))
	center.add_child(_panel)

	var pad := UiKit.margin(42, 42, 30, 28)
	_panel.add_child(pad)

	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", 10)
	pad.add_child(_content)

	var title_row: HBoxContainer = UiKit.screen_title("CONFIGURAÇÕES", 32, "settings")
	_title_label = title_row.get_node("TitleLabel") as Label
	_content.add_child(title_row)

	# ---- ÁUDIO
	_content.add_child(_make_section_header("ÁUDIO"))
	var music_row: Array = _make_slider_row("music", "Música")
	music_slider = music_row[0] as HSlider
	_music_value = music_row[1] as Label
	var sfx_row: Array = _make_slider_row("speaker", "Efeitos")
	sfx_slider = sfx_row[0] as HSlider
	_sfx_value = sfx_row[1] as Label

	# ---- JOGO
	_content.add_child(_make_section_header("JOGO"))
	_content.add_child(_make_difficulty_row())

	# ---- TELA
	_content.add_child(_make_section_header("TELA"))
	var toggles := HBoxContainer.new()
	toggles.add_theme_constant_override("separation", 12)
	_content.add_child(toggles)
	fullscreen_button = Button.new()
	fullscreen_button.name = "FullscreenToggle"
	fullscreen_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toggles.add_child(fullscreen_button)
	animations_button = Button.new()
	animations_button.name = "AnimationsToggle"
	animations_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toggles.add_child(animations_button)
	var toggles_row_2 := HBoxContainer.new()
	toggles_row_2.add_theme_constant_override("separation", 12)
	_content.add_child(toggles_row_2)
	tutorials_button = Button.new()
	tutorials_button.name = "TutorialsToggle"
	tutorials_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toggles_row_2.add_child(tutorials_button)

	var back_holder := CenterContainer.new()
	back_holder.add_theme_constant_override("separation", 0)
	_content.add_child(UiKit.margin(0, 0, 4, 0))
	_content.add_child(back_holder)
	back_button = UiKit.back_button()
	back_holder.add_child(back_button)

	_connect_signals()

## Cabecalho de secao: TITULO lilas + linha fina.
func _make_section_header(text: String) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	box.add_child(UiKit.label(text, 15, UiPalette.HIGHLIGHT))
	var line := Panel.new()
	line.custom_minimum_size = Vector2(0, 2)
	var style := StyleBoxFlat.new()
	style.bg_color = UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.38)
	line.add_theme_stylebox_override("panel", style)
	box.add_child(line)
	return box

## Linha [icone] Rotulo ----slider---- 50%. Retorna [slider, rotulo_do_valor].
func _make_slider_row(icon_name: String, text: String) -> Array:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	_content.add_child(row)

	var label_box := HBoxContainer.new()
	label_box.custom_minimum_size = Vector2(LABEL_WIDTH, 0)
	label_box.add_theme_constant_override("separation", 12)
	var icon := UiIcons.make_rect(icon_name, 24, UiPalette.TEXT_ON_DARK)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	label_box.add_child(icon)
	var label: Label = UiKit.label(text, 19, UiPalette.TEXT_ON_DARK)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label_box.add_child(label)
	row.add_child(label_box)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.custom_minimum_size = Vector2(160, 34)
	_style_slider(slider)
	row.add_child(slider)

	var value_label: Label = UiKit.label("0%", 17, UiPalette.TEXT_ON_DARK, HORIZONTAL_ALIGNMENT_RIGHT)
	value_label.custom_minimum_size = Vector2(58, 0)
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(value_label)
	return [slider, value_label]

func _style_slider(slider: HSlider) -> void:
	var rail := StyleBoxFlat.new()
	rail.bg_color = UiPalette.with_alpha(UiPalette.BG, 0.85)
	rail.border_color = UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.30)
	rail.set_border_width_all(1)
	rail.set_corner_radius_all(6)
	rail.content_margin_top = 4
	rail.content_margin_bottom = 4
	var fill := StyleBoxFlat.new()
	fill.bg_color = UiPalette.HIGHLIGHT
	fill.set_corner_radius_all(6)
	fill.content_margin_top = 4
	fill.content_margin_bottom = 4
	slider.add_theme_stylebox_override("slider", rail)
	slider.add_theme_stylebox_override("grabber_area", fill)
	slider.add_theme_stylebox_override("grabber_area_highlight", fill)
	slider.add_theme_icon_override("grabber", _grabber)
	slider.add_theme_icon_override("grabber_highlight", _grabber)
	slider.add_theme_icon_override("grabber_disabled", _grabber)

func _make_difficulty_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "DifficultyRow"
	row.add_theme_constant_override("separation", 12)

	var label_box := HBoxContainer.new()
	label_box.custom_minimum_size = Vector2(LABEL_WIDTH + 14, 0)
	label_box.add_theme_constant_override("separation", 12)
	var icon := UiIcons.make_rect("sliders", 24, UiPalette.TEXT_ON_DARK)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	label_box.add_child(icon)
	var label: Label = UiKit.label("Dificuldade", 19, UiPalette.TEXT_ON_DARK)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label_box.add_child(label)
	row.add_child(label_box)

	for key in DIFFICULTY_KEYS:
		var button := Button.new()
		button.name = "Difficulty_%s" % key
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(110, 46)
		button.focus_mode = Control.FOCUS_ALL
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.tooltip_text = "Dificuldade %s" % ScoreManager.get_difficulty_label(key)
		row.add_child(button)

		# conteudo: pontos de nivel (1/2/3) + nome
		var center := CenterContainer.new()
		center.set_anchors_preset(Control.PRESET_FULL_RECT)
		button.add_child(center)
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 8)
		center.add_child(line)
		var pips := UiPips.new()
		pips.level = UiPalette.difficulty_level(key)
		line.add_child(pips)
		var name_label: Label = UiKit.label(ScoreManager.get_difficulty_label(key), 18, UiPalette.TEXT_ON_DARK)
		line.add_child(name_label)
		UiKit.ignore_mouse(center)

		button.pressed.connect(_on_difficulty_pressed.bind(key))
		_difficulty_buttons[key] = button
		_difficulty_parts[key] = {"pips": pips, "label": name_label}
	return row

# ---------------------------------------------------------------- estado
func _load_current_settings() -> void:
	music_slider.set_value_no_signal(SettingsManager.get_music_volume())
	sfx_slider.set_value_no_signal(SettingsManager.get_sfx_volume())
	_update_volume_labels()
	_refresh_difficulty_buttons()
	_refresh_toggles()
	fullscreen_button.visible = not ScreenTools.is_mobile_platform()

func _update_volume_labels() -> void:
	_music_value.text = "%d%%" % int(round(music_slider.value * 100.0))
	_sfx_value.text = "%d%%" % int(round(sfx_slider.value * 100.0))

## Selecionado = preenchido na cor da dificuldade + texto escuro. Nao selecionado = so contorno.
func _refresh_difficulty_buttons() -> void:
	var current: String = DifficultyManager.get_difficulty()
	for key in DIFFICULTY_KEYS:
		var button: Button = _difficulty_buttons[key] as Button
		var accent: Color = UiPalette.difficulty_color(key)
		var selected: bool = key == current
		var fill: Color = accent if selected else UiPalette.with_alpha(UiPalette.CARD_RAISED, 0.55)
		var hover_fill: Color = accent.lightened(0.08) if selected else UiPalette.with_alpha(UiPalette.CARD_RAISED, 0.95)
		var border: Color = UiPalette.TEXT_ON_DARK if selected else accent
		button.add_theme_stylebox_override("normal", _option_style(fill, border))
		button.add_theme_stylebox_override("hover", _option_style(hover_fill, UiPalette.TEXT_ON_DARK))
		button.add_theme_stylebox_override("pressed", _option_style(accent.darkened(0.12), UiPalette.TEXT_ON_DARK))
		button.add_theme_stylebox_override("focus", ButtonStyles.make_focus_ring(14))
		var parts: Dictionary = _difficulty_parts[key]
		var text_color: Color = UiPalette.TEXT_ON_BRIGHT if selected else UiPalette.TEXT_ON_DARK
		(parts["label"] as Label).add_theme_color_override("font_color", text_color)
		(parts["pips"] as UiPips).color = UiPalette.TEXT_ON_BRIGHT if selected else accent

func _option_style(fill: Color, border: Color) -> StyleBoxFlat:
	return UiKit.panel_style(fill, border, 14, 2, 4)

func _refresh_toggles() -> void:
	_set_toggle(fullscreen_button, "monitor", "Tela cheia", SettingsManager.is_fullscreen())
	_set_toggle(animations_button, "sparkles", "Animações visuais", SettingsManager.animations_enabled())
	_set_toggle(tutorials_button, "compass", "Tutoriais", SettingsManager.tutorials_enabled())

func _set_toggle(button: Button, icon_name: String, label: String, enabled: bool) -> void:
	button.text = "%s: %s" % [label, "LIGADO" if enabled else "DESLIGADO"]
	button.icon = UiIcons.texture(icon_name)
	button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.expand_icon = false
	var height: float = 46.0 if ScreenTools.is_compact(self) else 54.0
	ButtonStyles.apply(button, "ui_toggle_on" if enabled else "ui_ghost", Vector2(0, height), 17)

# ---------------------------------------------------------------- layout
func _apply_responsive_layout() -> void:
	if _safe_area == null:
		return
	var view: Vector2 = ScreenTools.get_viewport_size(self)
	var compact: bool = ScreenTools.is_compact(self)
	var margin: int = 8 if compact else 24
	_safe_area.add_theme_constant_override("margin_left", margin)
	_safe_area.add_theme_constant_override("margin_right", margin)
	_safe_area.add_theme_constant_override("margin_top", margin)
	_safe_area.add_theme_constant_override("margin_bottom", margin)
	_panel.custom_minimum_size.x = minf(745.0, maxf(300.0, view.x - 2.0 * margin - 20.0))
	_content.add_theme_constant_override("separation", 7 if compact else 11)
	ScreenTools.apply_label_font(_title_label, self, 32, 26)
	for key in DIFFICULTY_KEYS:
		(_difficulty_buttons[key] as Button).custom_minimum_size.y = 40.0 if compact else 48.0
	_refresh_toggles()
	ButtonStyles.apply(back_button, "ui_ghost", Vector2(222, 46 if compact else 54), 18)

# ---------------------------------------------------------------- sinais
func _connect_signals() -> void:
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	fullscreen_button.pressed.connect(_on_fullscreen_pressed)
	animations_button.pressed.connect(_on_animations_pressed)
	tutorials_button.pressed.connect(_on_tutorials_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_music_volume_changed(value: float) -> void:
	SettingsManager.set_music_volume(value)
	_update_volume_labels()

func _on_sfx_volume_changed(value: float) -> void:
	SettingsManager.set_sfx_volume(value)
	_update_volume_labels()
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("click")

func _on_difficulty_pressed(key: String) -> void:
	DifficultyManager.set_difficulty(key)
	_refresh_difficulty_buttons()
	_click()

func _on_fullscreen_pressed() -> void:
	if ScreenTools.is_mobile_platform():
		return
	SettingsManager.toggle_fullscreen()
	_refresh_toggles()
	_click()

func _on_tutorials_pressed() -> void:
	SettingsManager.toggle_tutorials_enabled()
	_refresh_toggles()
	_click()

func _on_animations_pressed() -> void:
	SettingsManager.toggle_animations_enabled()
	_refresh_toggles()
	_click()

func _on_back_pressed() -> void:
	_click()
	GameManager.go_to_main_menu()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F11 and not ScreenTools.is_mobile_platform():
			SettingsManager.toggle_fullscreen()
			_refresh_toggles()

func _click() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
