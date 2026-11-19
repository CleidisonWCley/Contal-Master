extends Control
## Tela "Duração dos minigames" (V0.16.1): quantas questões cada minigame terá, em duas colunas.
##   CAMPANHA (padrão 2)   |   MODO LIVRE (padrão 4)
## As opções são as mesmas (2, 4, 8, 10). Cada opção é uma "bolinha" numerada (seleção única, um toque).
## Escolher já SALVA (SettingsManager grava na hora); ao voltar, as Configurações mostram o card de confirmação.

const COLUMNS := [
	{"key": "campaign", "title": "CAMPANHA", "hint": "A história completa, com um ritmo mais leve", "icon": "play"},
	{"key": "free", "title": "MODO LIVRE", "hint": "Treino e recordes em cada minigame", "icon": "star"},
]
const DOT_SIZE := 68.0
const DOT_SIZE_COMPACT := 54.0

var _safe_area: MarginContainer
var _panel: PanelContainer
var _content: VBoxContainer
var _columns_box: HBoxContainer
var _title_label: Label
var _dots: Dictionary = {"campaign": {}, "free": {}}   # modo -> {valor: Button}
var _summary: Dictionary = {}                            # modo -> Label
var back_button: Button

func _ready() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_music("menu")
	UiBackdrop.attach(self)
	_build_ui()
	_refresh_all()
	_apply_responsive_layout()
	back_button.call_deferred("grab_focus")

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_responsive_layout()

# ---------------------------------------------------------------- construcao
func _build_ui() -> void:
	_safe_area = MarginContainer.new()
	_safe_area.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_safe_area)

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_safe_area.add_child(scroll)

	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)

	_panel = PanelContainer.new()
	_panel.add_theme_stylebox_override("panel", UiKit.panel_style(UiPalette.with_alpha(UiPalette.CARD, 0.95), UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.50), 28, 2, 16))
	center.add_child(_panel)

	var pad := UiKit.margin(38, 38, 28, 26)
	_panel.add_child(pad)
	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", 12)
	pad.add_child(_content)

	var title_row: HBoxContainer = UiKit.screen_title("DURAÇÃO DOS MINIGAMES", 30, "sliders")
	_title_label = title_row.get_node("TitleLabel") as Label
	_content.add_child(title_row)

	var intro: Label = UiKit.label("Quantas questões cada minigame terá. Toque na bolinha para escolher: já fica salvo.", 17, UiPalette.TEXT_MUTED)
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_content.add_child(intro)

	_columns_box = HBoxContainer.new()
	_columns_box.add_theme_constant_override("separation", 22)
	_content.add_child(_columns_box)
	for column in COLUMNS:
		_columns_box.add_child(_make_column(column))

	var note: Label = UiKit.label("Menos questões = partidas mais curtas. Vale para Show do Bilhão, Maleta Certa, Perseguição, STOP e Forca Técnica. Roleta de Risco (1 giro), Batalha Naval e Desvio Lógico têm duração própria. A pontuação máxima é a mesma em qualquer duração.", 15, UiPalette.TEXT_MUTED)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_content.add_child(note)

	var holder := CenterContainer.new()
	_content.add_child(UiKit.margin(0, 0, 4, 0))
	_content.add_child(holder)
	back_button = UiKit.back_button()
	back_button.pressed.connect(_on_back_pressed)
	holder.add_child(back_button)

func _make_column(column: Dictionary) -> PanelContainer:
	var key: String = str(column["key"])
	var card := PanelContainer.new()
	card.name = "Column_%s" % key
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", UiKit.panel_style(UiPalette.with_alpha(UiPalette.CARD_RAISED, 0.55), UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.35), 20, 2, 6))
	var pad := UiKit.margin(16, 16, 16, 16)
	card.add_child(pad)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	pad.add_child(box)

	var head := HBoxContainer.new()
	head.alignment = BoxContainer.ALIGNMENT_CENTER
	head.add_theme_constant_override("separation", 10)
	var icon := UiIcons.make_rect(str(column["icon"]), 22, UiPalette.TEXT_ON_DARK)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(icon)
	head.add_child(UiKit.label(str(column["title"]), 20, UiPalette.HIGHLIGHT))
	box.add_child(head)

	var hint: Label = UiKit.label(str(column["hint"]), 14, UiPalette.TEXT_MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(hint)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 10)
	var grid_center := CenterContainer.new()
	grid_center.add_child(grid)
	box.add_child(grid_center)

	var group := ButtonGroup.new()
	var default_value: int = SettingsManager.DEFAULT_CAMPAIGN_QUESTIONS if key == "campaign" else SettingsManager.DEFAULT_FREE_QUESTIONS
	for value in SettingsManager.QUESTION_COUNT_OPTIONS:
		var dot := Button.new()
		dot.name = "Dot_%s_%d" % [key, value]
		dot.toggle_mode = true
		dot.button_group = group
		dot.text = str(value)
		dot.focus_mode = Control.FOCUS_ALL
		dot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		dot.tooltip_text = "%d questões%s" % [value, " (padrão)" if value == default_value else ""]
		dot.custom_minimum_size = Vector2(DOT_SIZE, DOT_SIZE)
		dot.pressed.connect(_on_dot_pressed.bind(key, value))
		grid.add_child(dot)
		(_dots[key] as Dictionary)[value] = dot

	var summary: Label = UiKit.label("", 16, UiPalette.TEXT_ON_DARK, HORIZONTAL_ALIGNMENT_CENTER)
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(summary)
	_summary[key] = summary
	return card

# ---------------------------------------------------------------- estado
func _current_value(key: String) -> int:
	return SettingsManager.get_campaign_questions_count() if key == "campaign" else SettingsManager.get_free_mode_questions_count()

func _refresh_all() -> void:
	for column in COLUMNS:
		_refresh_column(str(column["key"]))

func _refresh_column(key: String) -> void:
	var current: int = _current_value(key)
	var default_value: int = SettingsManager.DEFAULT_CAMPAIGN_QUESTIONS if key == "campaign" else SettingsManager.DEFAULT_FREE_QUESTIONS
	var compact: bool = ScreenTools.is_compact(self)
	var size_px: float = DOT_SIZE_COMPACT if compact else DOT_SIZE
	for value in SettingsManager.QUESTION_COUNT_OPTIONS:
		var dot: Button = (_dots[key] as Dictionary)[value] as Button
		var selected: bool = value == current
		dot.set_pressed_no_signal(selected)
		dot.custom_minimum_size = Vector2(size_px, size_px)
		var radius: int = int(size_px / 2.0)
		var fill: Color = UiPalette.HIGHLIGHT if selected else UiPalette.with_alpha(UiPalette.BG, 0.70)
		var border: Color = UiPalette.TEXT_ON_DARK if selected else UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.55)
		dot.add_theme_stylebox_override("normal", UiKit.panel_style(fill, border, radius, 3 if selected else 2, 4))
		dot.add_theme_stylebox_override("pressed", UiKit.panel_style(fill, UiPalette.TEXT_ON_DARK, radius, 3, 4))
		dot.add_theme_stylebox_override("hover", UiKit.panel_style(fill.lightened(0.10), UiPalette.TEXT_ON_DARK, radius, 3, 4))
		dot.add_theme_stylebox_override("focus", ButtonStyles.make_focus_ring(radius))
		var text_color: Color = UiPalette.TEXT_ON_BRIGHT if selected else UiPalette.TEXT_ON_DARK
		for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
			dot.add_theme_color_override(state, text_color)
		FontScale.set_size(dot, 26 if not compact else 22)
	var tag: String = "  (padrão)" if current == default_value else ""
	(_summary[key] as Label).text = "%d questões por minigame%s" % [current, tag]

# ---------------------------------------------------------------- layout
func _apply_responsive_layout() -> void:
	if _safe_area == null:
		return
	var view: Vector2 = ScreenTools.get_viewport_size(self)
	var compact: bool = ScreenTools.is_compact(self)
	var margin: int = 8 if compact else 24
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		_safe_area.add_theme_constant_override(side, margin)
	_panel.custom_minimum_size.x = minf(790.0, maxf(300.0, view.x - 2.0 * margin - 20.0))
	_content.add_theme_constant_override("separation", 8 if compact else 12)
	ScreenTools.apply_label_font(_title_label, self, 30, 24)
	_refresh_all()
	ButtonStyles.apply(back_button, "ui_ghost", Vector2(222, 46 if compact else 54), 18)

# ---------------------------------------------------------------- sinais
func _on_dot_pressed(key: String, value: int) -> void:
	if key == "campaign":
		SettingsManager.set_campaign_questions_count(value)
	else:
		SettingsManager.set_free_mode_questions_count(value)
	_refresh_column(key)
	_click()

func _on_back_pressed() -> void:
	_click()
	SettingsManager.flush_pending_save()
	GameManager.open_settings(true)   # volta às Configurações e mostra "Configurações salvas com sucesso"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()

func _click() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
