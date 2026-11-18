extends Control
## V0.15.2 - ARQUIVOS DA FIRMA. Mesmo padrao da tela de Pontuacao: a esquerda a lista de capitulos (cada um mostra se esta aberto
## ou o que falta), a direita o cartao de leitura do capitulo escolhido, com "Anterior / Proximo". Celular em pe: capitulos em
## 2 colunas no topo e a leitura logo abaixo. Os capitulos vem de scripts/data/lore/firma.json (LoreManager.get_chapters()).

const SIDE_BY_SIDE_MIN_WIDTH := 980.0

var _selected: String = ""
var _safe: MarginContainer
var _scroll: ScrollContainer
var _main_box: VBoxContainer
var _title_label: Label
var _summary_label: Label
var _columns: BoxContainer
var _list_card: PanelContainer
var _list_grid: GridContainer
var _reader_card: PanelContainer
var _reader_box: VBoxContainer
var _back_button: Button
var _chapter_buttons: Dictionary = {}   # chapter_id -> Button
var _side_by_side: bool = true


func _ready() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_music("menu")
	UiBackdrop.attach(self)
	_selected = GameManager.firma_selected_chapter
	if _chapter(_selected).is_empty():
		_selected = _first_open_or_first()
	_build_ui()
	_refresh_reader()
	_update_chapter_styles()
	_apply_layout()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_layout()


func _chapter(chapter_id: String) -> Dictionary:
	for item in LoreManager.get_chapters():
		if str((item as Dictionary).get("id", "")) == chapter_id:
			return item as Dictionary
	return {}


func _first_open_or_first() -> String:
	var chapters: Array = LoreManager.get_chapters()
	if chapters.is_empty():
		return ""
	return str((chapters[0] as Dictionary).get("id", ""))


func _chapter_ids() -> Array[String]:
	var ids: Array[String] = []
	for item in LoreManager.get_chapters():
		ids.append(str((item as Dictionary).get("id", "")))
	return ids


# ---------------------------------------------------------------- construcao
func _build_ui() -> void:
	_safe = MarginContainer.new()
	_safe.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_safe)
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_safe.add_child(_scroll)
	var pad: MarginContainer = UiKit.margin(10, 10, 10, 10)
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(pad)
	_main_box = VBoxContainer.new()
	_main_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_main_box.add_theme_constant_override("separation", 12)
	pad.add_child(_main_box)

	var title_row: HBoxContainer = UiKit.screen_title("ARQUIVOS DA FIRMA", UiPalette.FONT_TITLE.x, "archive", UiPalette.ACCENT_REWARDS)
	_title_label = title_row.get_node("TitleLabel") as Label
	_main_box.add_child(title_row)
	_main_box.add_child(ArchiveArt.make_switch("firma"))

	var counts: Dictionary = LoreManager.count_chapters()
	_summary_label = UiKit.label("Capítulos abertos: %d de %d. Supere recordes (campanha ou Modo Livre, em qualquer dificuldade) para abrir os próximos." % [int(counts.get("unlocked", 0)), int(counts.get("total", 0))],
		15, UiPalette.TEXT_MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_main_box.add_child(_summary_label)

	_columns = BoxContainer.new()
	_columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_columns.add_theme_constant_override("separation", 18)
	_main_box.add_child(_columns)

	_list_card = PanelContainer.new()
	_list_card.add_theme_stylebox_override("panel", UiKit.card_style(22))
	_list_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list_card.size_flags_stretch_ratio = 0.8
	_columns.add_child(_list_card)
	var list_margin: MarginContainer = UiKit.margin(18, 18, 16, 16)
	_list_card.add_child(list_margin)
	var list_box: VBoxContainer = VBoxContainer.new()
	list_box.add_theme_constant_override("separation", 10)
	list_margin.add_child(list_box)
	list_box.add_child(UiKit.label("CAPÍTULOS", 22, UiPalette.HIGHLIGHT))
	_list_grid = GridContainer.new()
	_list_grid.columns = 1
	_list_grid.add_theme_constant_override("h_separation", 10)
	_list_grid.add_theme_constant_override("v_separation", 10)
	_list_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_box.add_child(_list_grid)
	var number: int = 0
	for item in LoreManager.get_chapters():
		number += 1
		_make_chapter_button(item as Dictionary, number)

	_reader_card = PanelContainer.new()
	_reader_card.add_theme_stylebox_override("panel", UiKit.card_style(22))
	_reader_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reader_card.size_flags_stretch_ratio = 1.4
	_columns.add_child(_reader_card)
	var reader_margin: MarginContainer = UiKit.margin(22, 22, 18, 18)
	_reader_card.add_child(reader_margin)
	_reader_box = VBoxContainer.new()
	_reader_box.add_theme_constant_override("separation", 10)
	reader_margin.add_child(_reader_box)

	var holder: CenterContainer = CenterContainer.new()
	_main_box.add_child(holder)
	_back_button = UiKit.back_button()
	_back_button.pressed.connect(_on_back_pressed)
	holder.add_child(_back_button)


func _make_chapter_button(chapter: Dictionary, number: int) -> void:
	var chapter_id: String = str(chapter.get("id", ""))
	var unlocked: bool = LoreManager.is_chapter_unlocked(chapter)
	var button: Button = Button.new()
	button.name = "chapter_" + chapter_id
	button.text = "%d.  %s" % [number, str(chapter.get("title", ""))]
	button.icon = UiIcons.texture("archive" if unlocked else "lock")
	button.expand_icon = true
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.tooltip_text = "" if unlocked else "Alcance %s pontos de recorde para abrir." % UiKit.format_points(LoreManager.chapter_target(chapter)).replace(" pts", "")
	button.pressed.connect(_on_chapter_pressed.bind(chapter_id))
	_list_grid.add_child(button)
	_chapter_buttons[chapter_id] = button


func _update_chapter_styles() -> void:
	for key in _chapter_buttons.keys():
		var button: Button = _chapter_buttons[key] as Button
		var chapter: Dictionary = _chapter(str(key))
		var unlocked: bool = LoreManager.is_chapter_unlocked(chapter)
		var variant: String = "ui_toggle_on" if str(key) == _selected else ("ui_secondary" if unlocked else "ui_ghost")
		ButtonStyles.apply(button, variant, Vector2(0, 54), 17)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


# ---------------------------------------------------------------- leitura
func _para(text: String, muted: bool = false, size_px: int = 17) -> Label:
	var label: Label = UiKit.label(text, size_px, UiPalette.TEXT_MUTED if muted else UiPalette.TEXT_ON_DARK)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label


func _refresh_reader() -> void:
	for child in _reader_box.get_children():
		_reader_box.remove_child(child)
		child.queue_free()
	var chapter: Dictionary = _chapter(_selected)
	if chapter.is_empty():
		_reader_box.add_child(_para("Nenhum capítulo disponível.", true))
		return
	var ids: Array[String] = _chapter_ids()
	var index: int = ids.find(_selected)
	_reader_box.add_child(UiKit.label("Capítulo %d de %d" % [index + 1, ids.size()], 14, UiPalette.TEXT_MUTED))
	var heading: Label = UiKit.label(str(chapter.get("title", "")), 28, UiPalette.ACCENT_REWARDS)
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_reader_box.add_child(heading)

	if not LoreManager.is_chapter_unlocked(chapter):
		var needed: int = LoreManager.chapter_target(chapter)
		var done: int = mini(LoreManager.archive_points(), needed)
		var lock_row: HBoxContainer = HBoxContainer.new()
		lock_row.add_theme_constant_override("separation", 12)
		lock_row.add_child(UiIcons.make_rect("lock", 30, UiPalette.TEXT_MUTED))
		lock_row.add_child(_para("Capítulo bloqueado. Supere os recordes (campanha ou Modo Livre) até somar %s pontos. Dificuldades maiores rendem mais pontos." % UiKit.format_points(needed).replace(" pts", ""), true))
		_reader_box.add_child(lock_row)
		_reader_box.add_child(UiKit.label("Pontos de recorde: %s de %s" % [UiKit.format_points(done).replace(" pts", ""), UiKit.format_points(needed).replace(" pts", "")], 15, UiPalette.TEXT_ON_DARK))
		_reader_box.add_child(ArchiveArt.make_progress(done, needed))
	else:
		for text in chapter.get("paragraphs", []) as Array:
			_reader_box.add_child(_para(str(text)))
		for item in chapter.get("list", []) as Array:
			_reader_box.add_child(_para("•  " + str(item)))
		for pair in chapter.get("pairs", []) as Array:
			var row: Array = pair as Array
			_reader_box.add_child(_para("%s: %s" % [str(row[0]), str(row[1])]))

	var nav: HBoxContainer = HBoxContainer.new()
	nav.add_theme_constant_override("separation", 10)
	_reader_box.add_child(nav)
	var previous: Button = Button.new()
	previous.name = "PreviousChapter"
	previous.text = "<  Anterior"
	previous.disabled = index <= 0
	previous.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ButtonStyles.apply(previous, "ui_ghost", Vector2(0, 46), 16)
	previous.pressed.connect(_on_step_pressed.bind(-1))
	nav.add_child(previous)
	var next: Button = Button.new()
	next.name = "NextChapter"
	next.text = "Próximo  >"
	next.disabled = index >= ids.size() - 1
	next.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ButtonStyles.apply(next, "ui_secondary", Vector2(0, 46), 16)
	next.pressed.connect(_on_step_pressed.bind(1))
	nav.add_child(next)


# ---------------------------------------------------------------- layout
func _apply_layout() -> void:
	if _safe == null:
		return
	var view: Vector2 = ScreenTools.get_viewport_size(self)
	var compact: bool = ScreenTools.is_compact(self)
	var margin_x: int = 8 if view.x < 560.0 else (16 if compact else 28)
	_safe.add_theme_constant_override("margin_left", margin_x)
	_safe.add_theme_constant_override("margin_right", margin_x)
	_safe.add_theme_constant_override("margin_top", 6 if compact else 22)
	_safe.add_theme_constant_override("margin_bottom", 6 if compact else 22)
	_main_box.add_theme_constant_override("separation", 8 if compact else 12)
	ScreenTools.apply_label_font(_title_label, self, UiPalette.FONT_TITLE.x, UiPalette.FONT_TITLE.y)
	ScreenTools.apply_label_font(_summary_label, self, 15, 13)
	_main_box.custom_minimum_size = Vector2(maxf(240.0, view.x - 2.0 * margin_x - 20.0), 0)
	_side_by_side = view.x >= SIDE_BY_SIDE_MIN_WIDTH
	_columns.vertical = not _side_by_side
	_columns.move_child(_list_card, 0)
	# lado a lado: 1 coluna de capitulos; empilhado: 2 colunas (cabe mais na tela do celular)
	_list_grid.columns = 1 if _side_by_side else 2
	ButtonStyles.apply(_back_button, "ui_ghost", Vector2(222, 46 if compact else 52), 18)


# ---------------------------------------------------------------- acoes
func _on_chapter_pressed(chapter_id: String) -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	_selected = chapter_id
	GameManager.firma_selected_chapter = chapter_id
	_refresh_reader()
	_update_chapter_styles()


func _on_step_pressed(direction: int) -> void:
	var ids: Array[String] = _chapter_ids()
	var index: int = clampi(ids.find(_selected) + direction, 0, ids.size() - 1)
	_on_chapter_pressed(ids[index])


func _on_back_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	GameManager.open_team_archive()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()
