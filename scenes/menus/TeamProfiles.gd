extends Control
## V0.15.2 - PERFIS DA EQUIPE. Mesmo padrao da tela de Pontuacao (cartoes lado a lado): a esquerda a grade dos 9 personagens
## (selecionar), a direita o cartao de previa com o CENARIO do minigame do personagem, cargo, confianca e progresso da ficha.
## "Abrir ficha completa" leva a ArchiveEntry. Celular em pe: a previa vem PRIMEIRO e a grade logo abaixo; ao escolher alguem a tela
## volta sozinha para a previa. Tudo montado por codigo com UiPalette/ButtonStyles.

const SIDE_BY_SIDE_MIN_WIDTH := 980.0
const GRID_COLUMNS := 3
const GRID_GAP := 10

var _selected: String = ""
var _safe: MarginContainer
var _scroll: ScrollContainer
var _main_box: VBoxContainer
var _title_label: Label
var _summary_label: Label
var _columns: BoxContainer
var _grid_card: PanelContainer
var _grid: GridContainer
var _preview_card: PanelContainer
var _preview_box: VBoxContainer
var _back_button: Button
var _tiles: Dictionary = {}   # character_id -> {"button", "portrait", "name", "stars"}
var _side_by_side: bool = true


func _ready() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_music("menu")
	UiBackdrop.attach(self)
	_selected = GameManager.profile_selected_character
	if not LoreManager.CHARACTER_ORDER.has(_selected):
		_selected = str(LoreManager.CHARACTER_ORDER[0])
	_build_ui()
	_refresh_preview()
	_update_tile_styles()
	_apply_layout()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_layout()


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

	var title_row: HBoxContainer = UiKit.screen_title("PERFIS DA EQUIPE", UiPalette.FONT_TITLE.x, "team", UiPalette.ACCENT_REWARDS)
	_title_label = title_row.get_node("TitleLabel") as Label
	_main_box.add_child(title_row)
	_main_box.add_child(ArchiveArt.make_switch("perfis"))

	var profiles: Dictionary = LoreManager.count_profiles()
	_summary_label = UiKit.label("Você já conhece %d de %d pessoas. Toque em alguém para ver o perfil." % [int(profiles.get("met", 0)), int(profiles.get("total", 0))],
		15, UiPalette.TEXT_MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_main_box.add_child(_summary_label)

	_columns = BoxContainer.new()
	_columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_columns.add_theme_constant_override("separation", 18)
	_main_box.add_child(_columns)

	_grid_card = PanelContainer.new()
	_grid_card.add_theme_stylebox_override("panel", UiKit.card_style(22))
	_grid_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid_card.size_flags_stretch_ratio = 1.0
	_columns.add_child(_grid_card)
	var grid_margin: MarginContainer = UiKit.margin(18, 18, 16, 16)
	_grid_card.add_child(grid_margin)
	var grid_box: VBoxContainer = VBoxContainer.new()
	grid_box.add_theme_constant_override("separation", 10)
	grid_margin.add_child(grid_box)
	grid_box.add_child(UiKit.label("A EQUIPE", 22, UiPalette.HIGHLIGHT))
	_grid = GridContainer.new()
	_grid.columns = GRID_COLUMNS
	_grid.add_theme_constant_override("h_separation", GRID_GAP)
	_grid.add_theme_constant_override("v_separation", GRID_GAP)
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_box.add_child(_grid)
	for character_id in LoreManager.CHARACTER_ORDER:
		_make_tile(str(character_id))

	_preview_card = PanelContainer.new()
	_preview_card.add_theme_stylebox_override("panel", UiKit.card_style(22))
	_preview_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_preview_card.size_flags_stretch_ratio = 1.2
	_columns.add_child(_preview_card)
	var preview_margin: MarginContainer = UiKit.margin(16, 16, 16, 16)
	_preview_card.add_child(preview_margin)
	_preview_box = VBoxContainer.new()
	_preview_box.add_theme_constant_override("separation", 10)
	preview_margin.add_child(_preview_box)

	var holder: CenterContainer = CenterContainer.new()
	_main_box.add_child(holder)
	_back_button = UiKit.back_button()
	_back_button.pressed.connect(_on_back_pressed)
	holder.add_child(_back_button)


func _make_tile(character_id: String) -> void:
	var level: int = LoreManager.get_character_level(character_id)
	var button: Button = Button.new()
	button.name = "tile_" + character_id
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_stylebox_override("focus", ButtonStyles.make_focus_ring(16))
	button.pressed.connect(_on_tile_pressed.bind(character_id))
	_grid.add_child(button)

	var column: VBoxContainer = VBoxContainer.new()
	column.set_anchors_preset(Control.PRESET_FULL_RECT)
	column.offset_left = 6
	column.offset_right = -6
	column.offset_top = 6
	column.offset_bottom = -6
	column.add_theme_constant_override("separation", 2)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	button.add_child(column)

	var portrait: FaceAvatar = FaceAvatar.create(character_id, 80.0, level < 1)
	column.add_child(portrait)

	var shown_name: String = str(LoreManager.CHARACTER_NAMES.get(character_id, character_id.capitalize()))
	var name_label: Label = UiKit.label(shown_name if level >= 1 else "???", 16, UiPalette.TEXT_ON_DARK, HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(name_label)
	var stars: Label = UiKit.label(ArchiveArt.stars_text(level), 13, UiPalette.DIFF_NORMAL, HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(stars)
	UiKit.ignore_mouse(column)
	_tiles[character_id] = {"button": button, "portrait": portrait, "name": name_label, "stars": stars}


func _update_tile_styles() -> void:
	for key in _tiles.keys():
		var entry: Dictionary = _tiles[key] as Dictionary
		var button: Button = entry["button"] as Button
		var selected: bool = str(key) == _selected
		var border: Color = UiPalette.ACCENT_REWARDS if selected else UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.35)
		var fill: Color = UiPalette.CARD_RAISED if selected else UiPalette.CARD
		var width: int = 3 if selected else 1
		button.add_theme_stylebox_override("normal", UiKit.panel_style(UiPalette.with_alpha(fill, 0.97), border, 16, width, 6))
		button.add_theme_stylebox_override("hover", UiKit.panel_style(UiPalette.with_alpha(UiPalette.CARD_RAISED, 1.0), UiPalette.ACCENT_REWARDS, 16, 2, 8))
		button.add_theme_stylebox_override("pressed", UiKit.panel_style(UiPalette.CARD.darkened(0.25), UiPalette.ACCENT_REWARDS, 16, 2, 3))


# ---------------------------------------------------------------- previa
func _refresh_preview() -> void:
	for child in _preview_box.get_children():
		_preview_box.remove_child(child)
		child.queue_free()
	var dossier: Dictionary = LoreManager.get_dossier(_selected)
	var level: int = LoreManager.get_character_level(_selected)
	var compact: bool = ScreenTools.is_compact(self)

	# Cenario do minigame do personagem
	_preview_box.add_child(ArchiveArt.make_banner(_selected, 120.0 if compact else 170.0, level < 1))

	# Retrato + nome + cargo + confianca
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	_preview_box.add_child(row)
	var portrait: FaceAvatar = FaceAvatar.create(_selected, 96.0, level < 1)
	portrait.backdrop = UiPalette.with_alpha(UiPalette.CARD, 0.9)
	row.add_child(portrait)
	var column: VBoxContainer = VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 2)
	row.add_child(column)
	var shown_name: String = str(dossier.get("name", _selected.capitalize()))
	column.add_child(UiKit.label(shown_name if level >= 1 else "???", 28, UiPalette.TEXT_ON_DARK))
	var role: Label = UiKit.label(str(dossier.get("role", "")) if level >= 1 else "Ainda não nos conhecemos bem.", 15, UiPalette.TEXT_MUTED)
	role.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(role)
	column.add_child(UiKit.label("Confiança: %s  %s" % [ArchiveArt.stars_text(level), LoreManager.get_level_name(level)], 15, UiPalette.DIFF_NORMAL))

	# Minigame / estacao do personagem
	var station_row: HBoxContainer = HBoxContainer.new()
	station_row.add_theme_constant_override("separation", 12)
	_preview_box.add_child(station_row)
	var badge: PanelContainer = UiKit.icon_badge(ArchiveArt.minigame_icon(_selected), 44, UiPalette.PRIMARY, UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.55), 12, 0.55)
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	station_row.add_child(badge)
	var station_col: VBoxContainer = VBoxContainer.new()
	station_col.alignment = BoxContainer.ALIGNMENT_CENTER
	station_col.add_theme_constant_override("separation", 0)
	station_row.add_child(station_col)
	station_col.add_child(UiKit.label("Minigame" if _selected != "jales" else "Papel no jogo", 13, UiPalette.TEXT_MUTED))
	station_col.add_child(UiKit.label(ArchiveArt.minigame_name(_selected), 19, UiPalette.TEXT_ON_DARK))

	# Progresso da ficha
	var total_tabs: int = 0
	var open_tabs: int = 0
	for tab in LoreManager.DOSSIER_TABS:
		if str(tab.get("id", "")) == "lembrancas":
			continue
		total_tabs += 1
		if LoreManager.is_tab_unlocked(_selected, tab):
			open_tabs += 1
	_preview_box.add_child(UiKit.label("Ficha liberada: %d de %d seções" % [open_tabs, total_tabs], 15, UiPalette.TEXT_ON_DARK))
	_preview_box.add_child(ArchiveArt.make_progress(open_tabs, total_tabs))
	var trust: Dictionary = LoreManager.trust_progress(_selected)
	if bool(trust.get("maxed", false)):
		_preview_box.add_child(UiKit.label("Confiança máxima", 15, UiPalette.ACCENT_REWARDS))
	else:
		var span: int = maxi(int(trust.get("next", 1)) - int(trust.get("previous", 0)), 1)
		_preview_box.add_child(UiKit.label("Próxima estrela: %d / %d pontos" % [int(trust.get("points", 0)), int(trust.get("next", 0))], 15, UiPalette.TEXT_ON_DARK))
		_preview_box.add_child(ArchiveArt.make_progress(clampi(int(trust.get("points", 0)) - int(trust.get("previous", 0)), 0, span), span))
	var memories: int = LoreManager.seen_fragments_of(_selected).size()
	_preview_box.add_child(UiKit.label("Conversas guardadas: %d" % memories, 14, UiPalette.TEXT_MUTED))
	if true:
		var hint: Label = UiKit.label(LoreManager.unlock_hint_for_character(_selected), 14, UiPalette.TEXT_MUTED)
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_preview_box.add_child(hint)

	var open_button: Button = Button.new()
	open_button.name = "OpenSheetButton"
	open_button.text = "Abrir ficha completa"
	ButtonStyles.apply(open_button, "ui_primary", Vector2(0, 48 if compact else 54), 18)
	open_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	open_button.pressed.connect(_on_open_sheet_pressed)
	_preview_box.add_child(open_button)


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

	var side: bool = view.x >= SIDE_BY_SIDE_MIN_WIDTH
	_side_by_side = side
	_columns.vertical = not side
	# lado a lado: grade a esquerda, previa a direita. Empilhado: previa primeiro, grade embaixo.
	_columns.move_child(_grid_card if side else _preview_card, 0)

	var usable: float = view.x - 2.0 * margin_x - 20.0
	var grid_width: float = usable * 0.45 if side else usable
	var cell: float = (grid_width - 36.0 - GRID_GAP * (GRID_COLUMNS - 1)) / GRID_COLUMNS
	if side:
		cell = minf(cell, (view.y - 330.0) / 3.0 - 46.0)
	cell = clampf(cell, 72.0, 128.0)
	var small: bool = cell < 100.0
	for key in _tiles.keys():
		var entry: Dictionary = _tiles[key] as Dictionary
		(entry["button"] as Button).custom_minimum_size = Vector2(cell, cell + (40.0 if small else 46.0))
		(entry["portrait"] as FaceAvatar).custom_minimum_size = Vector2(cell - 14.0, cell - 14.0)
		(entry["name"] as Label).add_theme_font_size_override("font_size", 13 if small else 16)
		(entry["stars"] as Label).add_theme_font_size_override("font_size", 11 if small else 13)
	ButtonStyles.apply(_back_button, "ui_ghost", Vector2(222, 46 if compact else 52), 18)


# ---------------------------------------------------------------- acoes
func _on_tile_pressed(character_id: String) -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	_selected = character_id
	GameManager.profile_selected_character = character_id
	_refresh_preview()
	_update_tile_styles()
	if not _side_by_side:
		# celular: volta para a previa (que fica no topo)
		if has_node("/root/SettingsManager") and not SettingsManager.animations_enabled():
			_scroll.scroll_vertical = 0
		else:
			create_tween().tween_property(_scroll, "scroll_vertical", 0, 0.25)


func _on_open_sheet_pressed() -> void:
	GameManager.profile_selected_character = _selected
	GameManager.open_archive_entry("char:" + _selected)


func _on_back_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	GameManager.open_team_archive()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()
