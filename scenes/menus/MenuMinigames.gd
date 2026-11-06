extends Control
## Tela "Modo livre" (UI/UX v4.2): grade de cartoes de minigame com selo de icone,
## descricao e recorde da dificuldade atual. Sem emojis: so icones de UiIcons.
## A dificuldade pode ser trocada aqui mesmo (seletor no topo); os recordes dos cartoes acompanham.
## A ORDEM dos cartoes precisa seguir GameManager.FREE_PHASE_KEYS (o indice inicia o minigame).

const MINIGAME_CARD_DATA: Array[Dictionary] = [
	{"key": "show_do_bilhao", "title": "Show do Bilhão", "description": "Responda e acumule pontos."},
	{"key": "batalha_naval", "title": "Batalha Naval", "description": "Acerte posições por estratégia."},
	{"key": "maleta_certa", "title": "Maleta Certa", "description": "Escolha com cuidado e arrisque."},
	{"key": "perseguicao", "title": "Perseguição", "description": "Escape dos perigos e mantenha o controle."},
	{"key": "forca_tecnica", "title": "Força Técnica", "description": "Descubra termos técnicos."},
	{"key": "stop", "title": "STOP", "description": "Pense rápido e complete categorias."},
	{"key": "desvio_logico", "title": "Desvio Lógico", "description": "Desvie, escolha rotas e teste sua lógica."}
]

var back_button: Button

var _safe_area: MarginContainer
var _main_box: VBoxContainer
var _title_label: Label
var _subtitle_label: Label
var _difficulty_selector: DifficultySelector
var _rows_box: VBoxContainer   # linhas de cartoes (cada linha e centralizada)
var _card_buttons: Array[Button] = []
var _card_titles: Array[Label] = []
var _card_descriptions: Array[Label] = []
var _card_records: Array[Label] = []
var _card_badges: Array[Control] = []

func _ready() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_music("menu")
	UiBackdrop.attach(self)
	_build_ui()
	_apply_responsive_layout()
	if not _card_buttons.is_empty():
		_card_buttons[0].call_deferred("grab_focus")

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_responsive_layout()

# ---------------------------------------------------------------- construcao
func _build_ui() -> void:
	_safe_area = MarginContainer.new()
	_safe_area.name = "SafeArea"
	_safe_area.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_safe_area)

	var scroll := ScrollContainer.new()
	scroll.name = "Scroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_safe_area.add_child(scroll)

	# Folga interna: anel de foco / zoom dos cartoes nao podem ser cortados pelo scroll.
	var inner_pad := UiKit.margin(10, 10, 10, 10)
	inner_pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner_pad.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(inner_pad)

	_main_box = VBoxContainer.new()
	_main_box.name = "MainBox"
	_main_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_main_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_main_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inner_pad.add_child(_main_box)

	var title_row: HBoxContainer = UiKit.screen_title("SELECIONE UM MINIGAME", UiPalette.FONT_TITLE.x)
	_title_label = title_row.get_node("TitleLabel") as Label
	_main_box.add_child(title_row)

	_subtitle_label = UiKit.label("Escolha um desafio do Modo Livre. A Roleta de Risco fica como bônus surpresa da campanha.", 16, UiPalette.TEXT_MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	_subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_main_box.add_child(_subtitle_label)

	var selector_holder := CenterContainer.new()
	_main_box.add_child(selector_holder)
	_difficulty_selector = DifficultySelector.new()
	_difficulty_selector.name = "DifficultySelector"
	_difficulty_selector.font_px = 16
	_difficulty_selector.v_pad = 6
	selector_holder.add_child(_difficulty_selector)
	_difficulty_selector.difficulty_selected.connect(_on_difficulty_selected)

	_rows_box = VBoxContainer.new()
	_rows_box.name = "CardsRows"
	_rows_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rows_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_rows_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_main_box.add_child(_rows_box)

	var difficulty: String = DifficultyManager.get_difficulty()
	for index in range(MINIGAME_CARD_DATA.size()):
		_make_card(index, MINIGAME_CARD_DATA[index], difficulty)

	var back_holder := CenterContainer.new()
	_main_box.add_child(back_holder)
	back_button = UiKit.back_button()
	back_button.pressed.connect(_on_back_pressed)
	back_holder.add_child(back_button)

## Cartao: [selo] Titulo / descricao / Recorde.
func _make_card(index: int, data: Dictionary, difficulty: String) -> void:
	var key: String = str(data.get("key", ""))
	var button := Button.new()
	button.name = "Btn_%s" % key
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.tooltip_text = str(data.get("description", ""))
	ButtonStyles.apply(button, "ui_card", Vector2(280, 190), 16)

	var pad := UiKit.margin(16, 16, 14, 14)
	pad.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.add_child(pad)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	pad.add_child(column)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 14)
	column.add_child(head)

	var badge: PanelContainer = UiKit.icon_badge(UiIcons.for_minigame(key), 62, UiPalette.PRIMARY, UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.55), 18, 0.52)
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(badge)

	var title_label: Label = UiKit.label(str(data.get("title", "Minigame")), 21, UiPalette.TEXT_ON_DARK)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	head.add_child(title_label)

	var description_label: Label = UiKit.label(str(data.get("description", "")), 15, UiPalette.TEXT_MUTED)
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(description_label)

	var record_label: Label = UiKit.label("Recorde: %s" % UiKit.format_points(ScoreManager.get_free_mode_best_score(key, difficulty)), 15, UiPalette.TEXT_ON_DARK)
	column.add_child(record_label)

	UiKit.ignore_mouse(pad)
	button.pressed.connect(_on_minigame_pressed.bind(index))
	button.mouse_entered.connect(_animate_card.bind(button, true))
	button.mouse_exited.connect(_animate_card.bind(button, false))
	button.focus_entered.connect(_animate_card.bind(button, true))
	button.focus_exited.connect(_animate_card.bind(button, false))
	_card_buttons.append(button)
	_card_titles.append(title_label)
	_card_descriptions.append(description_label)
	_card_records.append(record_label)
	_card_badges.append(badge)

# ---------------------------------------------------------------- layout
func _apply_responsive_layout() -> void:
	if _safe_area == null or _difficulty_selector == null or back_button == null:
		return
	var view: Vector2 = ScreenTools.get_viewport_size(self)
	var compact: bool = ScreenTools.is_compact(self)
	var margin_x: int = 6 if compact else 24
	var margin_y: int = 2 if compact else 22
	_safe_area.add_theme_constant_override("margin_left", margin_x)
	_safe_area.add_theme_constant_override("margin_right", margin_x)
	_safe_area.add_theme_constant_override("margin_top", margin_y)
	_safe_area.add_theme_constant_override("margin_bottom", margin_y)
	_main_box.add_theme_constant_override("separation", 8 if compact else 12)
	var gap: int = 12 if compact else 16
	_rows_box.add_theme_constant_override("separation", gap)

	var columns: int = 4
	if view.x < 520.0:
		columns = 1
	elif view.x < 760.0:
		columns = 2
	elif view.x < 1040.0:
		columns = 3
	var available: float = maxf(220.0, view.x - 2.0 * margin_x - 20.0)
	var card_width: float = clampf(floor((available - float(gap) * float(columns - 1)) / float(columns)), 200.0, 300.0)

	ScreenTools.apply_label_font(_title_label, self, UiPalette.FONT_TITLE.x, UiPalette.FONT_TITLE.y)
	ScreenTools.apply_label_font(_subtitle_label, self, 16, 14)
	_difficulty_selector.set_compact(view.x < 560.0)
	var card_height: float = 150.0 if compact else 190.0
	for i in range(_card_buttons.size()):
		_card_buttons[i].custom_minimum_size = Vector2(card_width, card_height)
		_card_titles[i].add_theme_font_size_override("font_size", 18 if compact else 21)
		_card_descriptions[i].add_theme_font_size_override("font_size", 14 if compact else 15)
		_card_records[i].add_theme_font_size_override("font_size", 14 if compact else 15)
		var badge_size: float = 50.0 if compact else 62.0
		_card_badges[i].custom_minimum_size = Vector2(badge_size, badge_size)
	_layout_rows(columns, gap)
	ButtonStyles.apply(back_button, "ui_ghost", Vector2(222, 46 if compact else 52), 18)

## Distribui os cartoes em linhas de `columns` itens; cada linha e centralizada,
## entao a ultima (incompleta) fica centralizada: 4 em cima, 3 embaixo.
func _layout_rows(columns: int, gap: int) -> void:
	for row in _rows_box.get_children():
		for card in row.get_children():
			row.remove_child(card)
		_rows_box.remove_child(row)
		row.queue_free()
	var row_box: HBoxContainer = null
	for i in range(_card_buttons.size()):
		if i % columns == 0:
			row_box = HBoxContainer.new()
			row_box.alignment = BoxContainer.ALIGNMENT_CENTER
			row_box.add_theme_constant_override("separation", gap)
			_rows_box.add_child(row_box)
		row_box.add_child(_card_buttons[i])

func _animate_card(button: Button, raised: bool) -> void:
	if not _animations_enabled():
		return
	button.pivot_offset = button.size * 0.5
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2.ONE * (1.02 if raised else 1.0), 0.10)

# ---------------------------------------------------------------- acoes
## Troca de dificuldade: atualiza o "Recorde" de cada cartao para a dificuldade escolhida.
func _on_difficulty_selected(_key: String) -> void:
	var difficulty: String = DifficultyManager.get_difficulty()
	for i in range(_card_records.size()):
		var minigame_key: String = str(MINIGAME_CARD_DATA[i].get("key", ""))
		_card_records[i].text = "Recorde: %s" % UiKit.format_points(ScoreManager.get_free_mode_best_score(minigame_key, difficulty))

func _on_minigame_pressed(index: int) -> void:
	_click()
	GameManager.start_free_minigame(index)

func _on_back_pressed() -> void:
	_click()
	GameManager.open_mode_select()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()

func _click() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()

func _animations_enabled() -> bool:
	return not has_node("/root/SettingsManager") or SettingsManager.animations_enabled()
