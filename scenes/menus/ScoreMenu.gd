extends Control

class PartyParticles:
	extends Control

	const PARTICLE_COUNT := 58
	const DOT_COLORS := [
		Color(1.0, 0.84, 0.25, 0.70),
		Color(0.42, 0.92, 1.0, 0.55),
		Color(1.0, 0.35, 0.55, 0.45),
		Color(1.0, 1.0, 1.0, 0.40)
	]

	var particles: Array[Dictionary] = []
	var elapsed: float = 0.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_preset(Control.PRESET_FULL_RECT)
		_build_particles()
		set_process(true)

	func _notification(what: int) -> void:
		if what == NOTIFICATION_RESIZED:
			_build_particles()
			queue_redraw()

	func _process(delta: float) -> void:
		elapsed += delta
		if elapsed > 1000.0:
			elapsed = 0.0
		queue_redraw()

	func _build_particles() -> void:
		particles.clear()
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = 140200
		var area: Vector2 = get_viewport_rect().size
		if area.x <= 0.0 or area.y <= 0.0:
			area = Vector2(1280, 720)
		for i in range(PARTICLE_COUNT):
			particles.append({
				"pos": Vector2(rng.randf_range(0.0, area.x), rng.randf_range(0.0, area.y)),
				"radius": rng.randf_range(1.0, 2.4),
				"speed": rng.randf_range(6.0, 18.0),
				"phase": rng.randf_range(0.0, TAU),
				"sway": rng.randf_range(3.0, 12.0),
				"color": DOT_COLORS[rng.randi_range(0, DOT_COLORS.size() - 1)]
			})

	func _draw() -> void:
		var area: Vector2 = get_viewport_rect().size
		if area.x <= 0.0 or area.y <= 0.0:
			return
		for raw_data in particles:
			var data: Dictionary = raw_data as Dictionary
			var base: Vector2 = data.get("pos", Vector2.ZERO) as Vector2
			var speed: float = float(data.get("speed", 8.0))
			var phase: float = float(data.get("phase", 0.0))
			var sway: float = float(data.get("sway", 6.0))
			var y_pos: float = fmod(base.y - elapsed * speed + area.y + 24.0, area.y + 48.0) - 24.0
			var x_pos: float = base.x + sin(elapsed * 0.9 + phase) * sway
			var pulse: float = 0.55 + 0.45 * sin(elapsed * 2.0 + phase)
			var color: Color = data.get("color", Color.WHITE) as Color
			color.a *= clampf(pulse, 0.25, 1.0)
			draw_circle(Vector2(x_pos, y_pos), float(data.get("radius", 1.4)), color)

class MagicSparks:
	extends Control

	const SPARK_COLORS := [
		Color(1.0, 0.86, 0.25, 0.95),
		Color(0.45, 0.95, 1.0, 0.85),
		Color(1.0, 1.0, 1.0, 0.90),
		Color(1.0, 0.50, 0.85, 0.72)
	]

	var sparks: Array[Dictionary] = []
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_preset(Control.PRESET_FULL_RECT)
		rng.randomize()
		set_process(true)

	func spawn_at(click_position: Vector2) -> void:
		for i in range(12):
			var angle: float = rng.randf_range(0.0, TAU)
			var speed: float = rng.randf_range(38.0, 118.0)
			sparks.append({
				"pos": click_position,
				"vel": Vector2(cos(angle), sin(angle)) * speed,
				"life": 0.0,
				"ttl": rng.randf_range(0.30, 0.56),
				"radius": rng.randf_range(1.4, 3.3),
				"color": SPARK_COLORS[rng.randi_range(0, SPARK_COLORS.size() - 1)]
			})
		queue_redraw()

	func _process(delta: float) -> void:
		if sparks.is_empty():
			return
		for i in range(sparks.size() - 1, -1, -1):
			var spark: Dictionary = sparks[i]
			spark["life"] = float(spark.get("life", 0.0)) + delta
			var vel: Vector2 = spark.get("vel", Vector2.ZERO) as Vector2
			vel *= 0.90
			spark["vel"] = vel
			var current_pos: Vector2 = spark.get("pos", Vector2.ZERO) as Vector2
			spark["pos"] = current_pos + vel * delta
			if float(spark.get("life", 0.0)) >= float(spark.get("ttl", 0.4)):
				sparks.remove_at(i)
			else:
				sparks[i] = spark
		queue_redraw()

	func _draw() -> void:
		for raw_spark in sparks:
			var spark: Dictionary = raw_spark as Dictionary
			var ttl: float = float(spark.get("ttl", 0.4))
			var life: float = float(spark.get("life", 0.0))
			var t: float = clampf(1.0 - life / maxf(ttl, 0.01), 0.0, 1.0)
			var pos: Vector2 = spark.get("pos", Vector2.ZERO) as Vector2
			var color: Color = spark.get("color", Color.WHITE) as Color
			color.a *= t
			var radius: float = float(spark.get("radius", 2.0)) * (0.65 + t * 0.85)
			draw_circle(pos, radius, color)
			draw_line(pos + Vector2(-radius * 2.2, 0), pos + Vector2(radius * 2.2, 0), color, 1.0)
			draw_line(pos + Vector2(0, -radius * 2.2), pos + Vector2(0, radius * 2.2), color, 1.0)

## Indicador de dificuldade que NAO depende de cor: 1, 2 ou 3 pontos preenchidos.
class DifficultyPips:
	extends Control

	var level: int = 1:
		set(value):
			level = value
			queue_redraw()
	var color: Color = Color.WHITE:
		set(value):
			color = value
			queue_redraw()

	func _init() -> void:
		custom_minimum_size = Vector2(60, 24)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var radius: float = 7.0
		var gap: float = 7.0
		var total: float = 6.0 * radius + 2.0 * gap
		var x: float = (size.x - total) * 0.5 + radius
		var y: float = size.y * 0.5
		for i in range(3):
			var center: Vector2 = Vector2(x + i * (radius * 2.0 + gap), y)
			if i < level:
				draw_circle(center, radius, color)
			else:
				draw_arc(center, radius - 1.0, 0.0, TAU, 24, color, 2.0)

const BACKGROUND_PATH := Paths.BG_MENU_MAIN
const DIFF_EASY_KEY := "facil"
const DIFF_NORMAL_KEY := "normal"
const DIFF_HARD_KEY := "dificil"
const FREE_MODE_EXCLUDED_MINIGAMES := ["roleta_risco"]
const MINIGAME_LABEL_OVERRIDES := {
	"forca_tecnica": "Força Técnica"
}
const SIDE_BY_SIDE_MIN_WIDTH := 1000.0

var selected_free_minigame: String = ""

var title_icon: TextureRect
var title_label: Label
var player_prefix_label: Label
var nickname_label: Label
var nickname_card: PanelContainer
var nickname_edit: LineEdit
var edit_button: Button
var save_nick_button: Button
var cancel_nick_button: Button
var campaign_card: PanelContainer
var best_campaign_value: Label
var current_campaign_value: Label
var campaign_score_labels: Dictionary = {}
var free_score_labels: Dictionary = {}
var free_section_card: PanelContainer
var free_result_card: PanelContainer
var free_result_content: VBoxContainer
var free_result_title: Label
var free_chips_grid: GridContainer
var minigame_chip_buttons: Dictionary = {}
var clear_free_button: Button
var free_placeholder: Label
var back_button: Button
var safe_area: MarginContainer
var page_scroll: ScrollContainer
var inner_margin: MarginContainer
var main_box: VBoxContainer
var columns_box: BoxContainer
var magic_sparks: MagicSparks
var campaign_score_grid: VBoxContainer
var free_score_grid: GridContainer

# Elementos cuja fonte/altura mudam com o tamanho da tela: [controle, desktop, compacto]
var _font_targets: Array = []
var _height_targets: Array = []
var _stretch_rows: Array = []

func _ready() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_music("menu")
	_select_first_free_minigame()
	_build_ui()
	_fill_free_minigame_chips()
	_connect_signals()
	_apply_responsive_layout()
	_apply_styles()
	_refresh_view()
	if back_button != null:
		back_button.call_deferred("grab_focus")

func _select_first_free_minigame() -> void:
	for key in ScoreManager.get_minigame_keys():
		if not _is_free_mode_minigame_hidden(str(key)):
			selected_free_minigame = str(key)
			return

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_responsive_layout()
		_apply_styles()

func _animations_enabled() -> bool:
	return not has_node("/root/SettingsManager") or SettingsManager.animations_enabled()

# ---------------------------------------------------------------- construcao
func _build_ui() -> void:
	var background := TextureRect.new()
	background.name = "Background"
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.texture = load(BACKGROUND_PATH)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(background)

	# Escurece e "acalma" o cenario: o conteudo nunca compete com os detalhes do fundo.
	var dimmer := ColorRect.new()
	dimmer.name = "Dimmer"
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = UiPalette.with_alpha(UiPalette.BG, 0.70)
	dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dimmer)

	if _animations_enabled():
		var particles := PartyParticles.new()
		particles.name = "PartyParticles"
		particles.z_index = 2
		add_child(particles)

	magic_sparks = MagicSparks.new()
	magic_sparks.name = "MagicClickSparks"
	magic_sparks.z_index = 30
	add_child(magic_sparks)

	safe_area = MarginContainer.new()
	safe_area.name = "SafeArea"
	safe_area.set_anchors_preset(Control.PRESET_FULL_RECT)
	safe_area.z_index = 10
	add_child(safe_area)

	page_scroll = ScrollContainer.new()
	page_scroll.name = "DashboardScroll"
	page_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	page_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	safe_area.add_child(page_scroll)

	inner_margin = MarginContainer.new()
	inner_margin.name = "DashboardMargin"
	inner_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page_scroll.add_child(inner_margin)

	main_box = VBoxContainer.new()
	main_box.name = "DashboardBox"
	main_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_box.add_theme_constant_override("separation", 14)
	inner_margin.add_child(main_box)

	main_box.add_child(_make_header())

	columns_box = BoxContainer.new()
	columns_box.name = "Columns"
	columns_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns_box.add_theme_constant_override("separation", 18)
	main_box.add_child(columns_box)

	campaign_card = _make_campaign_summary_card()
	campaign_card.size_flags_stretch_ratio = 0.8
	columns_box.add_child(campaign_card)

	free_section_card = _make_free_mode_section()
	free_section_card.size_flags_stretch_ratio = 1.2
	columns_box.add_child(free_section_card)

	var back_holder := CenterContainer.new()
	back_holder.name = "BackButtonHolder"
	main_box.add_child(back_holder)

	back_button = UiKit.back_button()
	back_holder.add_child(back_button)

func _make_header() -> Control:
	var row := HBoxContainer.new()
	row.name = "Header"
	row.add_theme_constant_override("separation", 16)

	var title_box := HBoxContainer.new()
	title_box.name = "TitleBox"
	title_box.add_theme_constant_override("separation", 12)
	title_box.alignment = BoxContainer.ALIGNMENT_BEGIN
	row.add_child(title_box)

	title_icon = TextureRect.new()
	title_icon.name = "TitleIcon"
	title_icon.texture = load(Paths.ICON_UI_TROPHY)
	title_icon.custom_minimum_size = Vector2(44, 44)
	title_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	title_icon.modulate = UiPalette.ACCENT_REWARDS
	title_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	title_box.add_child(title_icon)

	title_label = Label.new()
	title_label.name = "Title"
	title_label.text = "PONTUAÇÃO"
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_box.add_child(title_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)

	var nickname_row := HBoxContainer.new()
	nickname_row.name = "NicknameRow"
	nickname_row.alignment = BoxContainer.ALIGNMENT_END
	nickname_row.add_theme_constant_override("separation", 10)
	row.add_child(nickname_row)

	nickname_card = PanelContainer.new()
	nickname_card.name = "NicknameCard"
	nickname_row.add_child(nickname_card)

	var nickname_margin := _make_margin(16, 16, 6, 6)
	nickname_card.add_child(nickname_margin)

	var pill := HBoxContainer.new()
	pill.add_theme_constant_override("separation", 10)
	nickname_margin.add_child(pill)

	player_prefix_label = Label.new()
	player_prefix_label.name = "PlayerPrefixLabel"
	player_prefix_label.text = "Jogador"
	player_prefix_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pill.add_child(player_prefix_label)

	nickname_label = Label.new()
	nickname_label.name = "NicknameLabel"
	nickname_label.text = ScoreManager.get_player_nickname()
	nickname_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pill.add_child(nickname_label)

	edit_button = Button.new()
	edit_button.name = "EditNicknameButton"
	edit_button.text = "Editar"
	edit_button.tooltip_text = "Editar nick"
	nickname_row.add_child(edit_button)

	nickname_edit = LineEdit.new()
	nickname_edit.name = "NicknameEdit"
	nickname_edit.visible = false
	nickname_edit.max_length = 18
	nickname_edit.placeholder_text = "Digite seu nick"
	nickname_edit.custom_minimum_size = Vector2(220, 46)
	nickname_row.add_child(nickname_edit)

	save_nick_button = Button.new()
	save_nick_button.name = "SaveNicknameButton"
	save_nick_button.text = "Salvar"
	save_nick_button.visible = false
	nickname_row.add_child(save_nick_button)

	cancel_nick_button = Button.new()
	cancel_nick_button.name = "CancelNicknameButton"
	cancel_nick_button.text = "Cancelar"
	cancel_nick_button.visible = false
	nickname_row.add_child(cancel_nick_button)
	return row

func _make_campaign_summary_card() -> PanelContainer:
	var card := _make_card("CampaignSummary", UiPalette.CARD)
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var margin := _make_margin(22, 22, 18, 18)
	card.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)

	box.add_child(_make_section_title("CAMPANHA"))

	var stats := HBoxContainer.new()
	stats.name = "CampaignStats"
	stats.add_theme_constant_override("separation", 28)
	box.add_child(stats)
	best_campaign_value = _make_stat(stats, "Melhor campanha", UiPalette.ACCENT_REWARDS, UiPalette.FONT_HERO)
	current_campaign_value = _make_stat(stats, "Pontuação atual", UiPalette.SECONDARY, UiPalette.FONT_VALUE)

	var caption := Label.new()
	caption.text = "Melhor campanha por dificuldade"
	caption.add_theme_color_override("font_color", UiPalette.TEXT_MUTED)
	_track_font(caption, UiPalette.FONT_BODY)
	box.add_child(caption)

	campaign_score_grid = VBoxContainer.new()
	campaign_score_grid.name = "CampaignDifficultyRows"
	campaign_score_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	campaign_score_grid.add_theme_constant_override("separation", 10)
	box.add_child(campaign_score_grid)

	campaign_score_labels.clear()
	for difficulty_key in ScoreManager.get_difficulty_keys():
		var key := str(difficulty_key)
		campaign_score_labels[key] = _make_score_row(campaign_score_grid, key)
	return card

func _make_free_mode_section() -> PanelContainer:
	var card := _make_card("FreeModeSection", UiPalette.CARD)
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var margin := _make_margin(22, 22, 18, 18)
	card.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)

	box.add_child(_make_section_title("MODO LIVRE"))

	var caption := Label.new()
	caption.text = "Escolha um minigame para ver seus melhores resultados"
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.add_theme_color_override("font_color", UiPalette.TEXT_MUTED)
	_track_font(caption, UiPalette.FONT_BODY)
	box.add_child(caption)

	free_chips_grid = GridContainer.new()
	free_chips_grid.name = "FreeMinigameChips"
	free_chips_grid.columns = 3
	free_chips_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	free_chips_grid.add_theme_constant_override("h_separation", 10)
	free_chips_grid.add_theme_constant_override("v_separation", 10)
	box.add_child(free_chips_grid)

	free_result_card = _make_free_result_card()
	free_result_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(free_result_card)
	return card

## Area de resultado com altura fixa: mostra o estado vazio OU os resultados (sem "pulo" de layout).
func _make_free_result_card() -> PanelContainer:
	var card := PanelContainer.new()
	card.name = "FreeResultCard"
	card.custom_minimum_size = Vector2(0, 148)
	card.add_theme_stylebox_override("panel", _panel_style(UiPalette.CARD_RAISED, UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.45), 14, 1))
	var margin := _make_margin(16, 16, 12, 12)
	card.add_child(margin)

	var stack := VBoxContainer.new()
	margin.add_child(stack)

	free_placeholder = Label.new()
	free_placeholder.name = "FreePlaceholder"
	free_placeholder.text = "Nenhum minigame selecionado"
	free_placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	free_placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	free_placeholder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	free_placeholder.add_theme_color_override("font_color", UiPalette.TEXT_MUTED)
	_track_font(free_placeholder, UiPalette.FONT_BODY)
	stack.add_child(free_placeholder)

	free_result_content = VBoxContainer.new()
	free_result_content.name = "FreeResultContent"
	free_result_content.add_theme_constant_override("separation", 8)
	free_result_content.visible = false
	stack.add_child(free_result_content)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	free_result_content.add_child(header)

	free_result_title = Label.new()
	free_result_title.text = "Minigame"
	free_result_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	free_result_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	free_result_title.add_theme_color_override("font_color", UiPalette.TEXT_ON_DARK)
	_track_font(free_result_title, UiPalette.FONT_ROW)
	header.add_child(free_result_title)

	clear_free_button = Button.new()
	clear_free_button.name = "ClearFreeSelectionButton"
	clear_free_button.text = "Fechar"
	clear_free_button.tooltip_text = "Fechar pontuação do minigame"
	header.add_child(clear_free_button)

	free_score_grid = GridContainer.new()
	free_score_grid.name = "FreeDifficultyTiles"
	free_score_grid.columns = 3
	free_score_grid.add_theme_constant_override("h_separation", 10)
	free_score_grid.add_theme_constant_override("v_separation", 8)
	free_result_content.add_child(free_score_grid)

	free_score_labels.clear()
	for difficulty_key in ScoreManager.get_difficulty_keys():
		var key := str(difficulty_key)
		free_score_labels[key] = _make_score_tile(free_score_grid, key)
	return card

func _make_section_title(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", UiPalette.HIGHLIGHT)
	_track_font(label, UiPalette.FONT_SECTION)
	return label

## Rotulo + valor em coluna. O valor e o elemento dominante (hierarquia: numero > rotulo).
func _make_stat(parent: HBoxContainer, label: String, accent: Color, value_font: Vector2i) -> Label:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	box.size_flags_vertical = Control.SIZE_SHRINK_END
	parent.add_child(box)

	var label_node := Label.new()
	label_node.text = label
	label_node.add_theme_color_override("font_color", UiPalette.TEXT_MUTED)
	_track_font(label_node, UiPalette.FONT_BODY)
	box.add_child(label_node)

	var value_node := Label.new()
	value_node.text = "0 pts"
	value_node.add_theme_color_override("font_color", accent)
	_track_font(value_node, value_font)
	box.add_child(value_node)
	return value_node

## Linha de pontuacao por dificuldade: [pontos de nivel] [nome] ........ [valor alinhado a direita]
func _make_score_row(parent: Control, difficulty_key: String, compact_row: bool = false) -> Label:
	var accent: Color = _difficulty_accent_color(difficulty_key)
	var row := PanelContainer.new()
	row.name = "%sRow" % difficulty_key.capitalize()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if not compact_row:
		_stretch_rows.append(row)  # esticam para preencher o cartao (so em telas baixas)
	row.add_theme_stylebox_override("panel", _row_style(accent, compact_row))
	_track_height(row, 46.0 if compact_row else 58.0, 40.0 if compact_row else 48.0)
	parent.add_child(row)

	var margin := _make_margin(16, 18, 4, 4)
	row.add_child(margin)

	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 14)
	margin.add_child(line)

	var pips := DifficultyPips.new()
	pips.level = _difficulty_level(difficulty_key)
	pips.color = accent
	pips.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.add_child(pips)

	var name_label := Label.new()
	name_label.text = ScoreManager.get_difficulty_label(difficulty_key)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.add_theme_color_override("font_color", UiPalette.TEXT_ON_DARK)
	_track_font(name_label, UiPalette.FONT_ROW)
	line.add_child(name_label)

	var value_node := Label.new()
	value_node.text = "0 pts"
	value_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	value_node.custom_minimum_size = Vector2(130, 0)
	value_node.add_theme_color_override("font_color", accent)
	_track_font(value_node, Vector2i(26, 22) if compact_row else UiPalette.FONT_VALUE)
	line.add_child(value_node)
	return value_node

## Bloco compacto por dificuldade (modo livre): [pontos] nome  /  valor.
func _make_score_tile(parent: Control, difficulty_key: String) -> Label:
	var accent: Color = _difficulty_accent_color(difficulty_key)
	var tile := PanelContainer.new()
	tile.name = "%sTile" % difficulty_key.capitalize()
	tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tile.add_theme_stylebox_override("panel", _row_style(accent, true))
	parent.add_child(tile)

	var margin := _make_margin(14, 12, 8, 8)
	tile.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	margin.add_child(box)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	box.add_child(head)

	var pips := DifficultyPips.new()
	pips.level = _difficulty_level(difficulty_key)
	pips.color = accent
	pips.custom_minimum_size = Vector2(52, 22)
	head.add_child(pips)

	var name_label := Label.new()
	name_label.text = ScoreManager.get_difficulty_label(difficulty_key)
	name_label.add_theme_color_override("font_color", UiPalette.TEXT_ON_DARK)
	_track_font(name_label, UiPalette.FONT_BODY)
	head.add_child(name_label)

	var value_node := Label.new()
	value_node.text = "0 pts"
	value_node.add_theme_color_override("font_color", accent)
	_track_font(value_node, UiPalette.FONT_VALUE)
	box.add_child(value_node)
	return value_node

func _fill_free_minigame_chips() -> void:
	if free_chips_grid == null:
		return
	minigame_chip_buttons.clear()
	for child in free_chips_grid.get_children():
		free_chips_grid.remove_child(child)
		child.queue_free()

	for key in ScoreManager.get_minigame_keys():
		var minigame_key: String = str(key)
		if _is_free_mode_minigame_hidden(minigame_key):
			continue
		var button := Button.new()
		button.name = "Chip_%s" % minigame_key
		button.text = _get_minigame_label(minigame_key)
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_ALL
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.clip_text = true
		button.tooltip_text = "Ver melhores resultados de %s" % _get_minigame_label(minigame_key)
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.pressed.connect(_on_free_minigame_chip_pressed.bind(minigame_key))
		free_chips_grid.add_child(button)
		minigame_chip_buttons[minigame_key] = button
	_update_free_chip_states()

func _get_minigame_label(minigame_key: String) -> String:
	return str(MINIGAME_LABEL_OVERRIDES.get(minigame_key, ScoreManager.get_minigame_label(minigame_key)))

func _is_free_mode_minigame_hidden(minigame_key: String) -> bool:
	return FREE_MODE_EXCLUDED_MINIGAMES.has(minigame_key)

func _connect_signals() -> void:
	if not clear_free_button.pressed.is_connected(_on_clear_free_selection_pressed):
		clear_free_button.pressed.connect(_on_clear_free_selection_pressed)
	if not edit_button.pressed.is_connected(_on_edit_nickname_pressed):
		edit_button.pressed.connect(_on_edit_nickname_pressed)
	if not save_nick_button.pressed.is_connected(_on_save_nickname_pressed):
		save_nick_button.pressed.connect(_on_save_nickname_pressed)
	if not cancel_nick_button.pressed.is_connected(_on_cancel_nickname_pressed):
		cancel_nick_button.pressed.connect(_on_cancel_nickname_pressed)
	if not nickname_edit.text_submitted.is_connected(_on_nickname_submitted):
		nickname_edit.text_submitted.connect(_on_nickname_submitted)
	if not back_button.pressed.is_connected(_on_back_pressed):
		back_button.pressed.connect(_on_back_pressed)
	if not ScoreManager.profile_changed.is_connected(_on_profile_changed):
		ScoreManager.profile_changed.connect(_on_profile_changed)
	if not ScoreManager.records_changed.is_connected(_on_records_changed):
		ScoreManager.records_changed.connect(_on_records_changed)

# ---------------------------------------------------------------- layout responsivo
func _track_font(control: Control, sizes: Vector2i) -> void:
	_font_targets.append([control, sizes.x, sizes.y])

func _track_height(control: Control, desktop: float, compact: float) -> void:
	_height_targets.append([control, desktop, compact])

func _apply_responsive_layout() -> void:
	var compact: bool = ScreenTools.is_compact(self)
	var view_size: Vector2 = get_viewport_rect().size
	var window_size: Vector2 = Vector2(get_window().size) if get_window() != null else view_size
	var portrait: bool = window_size.y > window_size.x * 0.95
	var side_by_side: bool = view_size.x >= SIDE_BY_SIDE_MIN_WIDTH and not portrait
	ScreenTools.apply_safe_margins(safe_area, self, 28, 10)
	ScreenTools.apply_inner_margins(inner_margin, self, 4, 4)
	if main_box != null:
		main_box.add_theme_constant_override("separation", 10 if compact else 14)
	if columns_box != null:
		columns_box.vertical = not side_by_side
	var stretch: bool = side_by_side and view_size.y <= 800.0
	for row in _stretch_rows:
		if row != null:
			(row as Control).size_flags_vertical = Control.SIZE_EXPAND_FILL if stretch else Control.SIZE_FILL
	if campaign_score_grid != null:
		campaign_score_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL if stretch else Control.SIZE_FILL
	for entry in _font_targets:
		var control: Control = entry[0] as Control
		if control != null:
			control.add_theme_font_size_override("font_size", ScreenTools.responsive_font(self, int(entry[1]), int(entry[2])))
	for entry in _height_targets:
		var control: Control = entry[0] as Control
		if control != null:
			control.custom_minimum_size.y = ScreenTools.responsive_value(self, float(entry[1]), float(entry[2]))
	if title_label != null:
		ScreenTools.apply_label_font(title_label, self, UiPalette.FONT_TITLE.x, UiPalette.FONT_TITLE.y)
	if title_icon != null:
		var icon_size: float = 34.0 if compact else 44.0
		title_icon.custom_minimum_size = Vector2(icon_size, icon_size)
	if player_prefix_label != null:
		ScreenTools.apply_label_font(player_prefix_label, self, UiPalette.FONT_BODY.x, UiPalette.FONT_BODY.y)
	if nickname_label != null:
		ScreenTools.apply_label_font(nickname_label, self, UiPalette.FONT_ROW.x, UiPalette.FONT_ROW.y)
	if nickname_edit != null:
		nickname_edit.add_theme_font_size_override("font_size", ScreenTools.responsive_font(self, 20, 18))
	if free_chips_grid != null:
		var chip_columns: int = 3
		if view_size.x < 420.0:
			chip_columns = 1
		elif view_size.x < 720.0:
			chip_columns = 2
		free_chips_grid.columns = chip_columns
	if free_score_grid != null:
		free_score_grid.columns = 1 if view_size.x < 560.0 else 3
	if free_result_card != null:
		free_result_card.custom_minimum_size.y = 136.0 if compact else 148.0

func _apply_styles() -> void:
	var compact: bool = ScreenTools.is_compact(self)
	var title_color: Color = UiPalette.TEXT_ON_DARK
	if title_label != null:
		title_label.add_theme_color_override("font_color", title_color)
	if player_prefix_label != null:
		player_prefix_label.add_theme_color_override("font_color", UiPalette.TEXT_MUTED)
	if nickname_label != null:
		nickname_label.add_theme_color_override("font_color", UiPalette.TEXT_ON_DARK)
	if nickname_card != null:
		nickname_card.add_theme_stylebox_override("panel", _panel_style(UiPalette.CARD, UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.55), 14, 1))
	if campaign_card != null:
		campaign_card.add_theme_stylebox_override("panel", _card_style())
	if free_section_card != null:
		free_section_card.add_theme_stylebox_override("panel", _card_style())
	_apply_line_edit_style()
	var action_h: float = 44.0 if compact else 48.0
	ButtonStyles.apply(edit_button, "ui_ghost", Vector2(100, action_h), ScreenTools.responsive_font(self, 18, 16))
	ButtonStyles.apply(save_nick_button, "ui_primary", Vector2(100, action_h), ScreenTools.responsive_font(self, 18, 16))
	ButtonStyles.apply(cancel_nick_button, "ui_ghost", Vector2(110, action_h), ScreenTools.responsive_font(self, 18, 16))
	ButtonStyles.apply(clear_free_button, "ui_ghost", Vector2(96, 40), ScreenTools.responsive_font(self, 16, 14))
	ButtonStyles.apply(back_button, "ui_ghost", Vector2(222, 52 if not compact else 46), 18)
	_apply_free_chip_styles()

func _apply_line_edit_style() -> void:
	if nickname_edit == null:
		return
	var normal: StyleBoxFlat = _panel_style(UiPalette.CARD, UiPalette.HIGHLIGHT, 12, 2)
	normal.content_margin_left = 14
	normal.content_margin_right = 14
	var focus: StyleBoxFlat = _panel_style(UiPalette.CARD, UiPalette.TEXT_ON_DARK, 12, 3)
	focus.content_margin_left = 14
	focus.content_margin_right = 14
	nickname_edit.add_theme_stylebox_override("normal", normal)
	nickname_edit.add_theme_stylebox_override("focus", focus)
	nickname_edit.add_theme_color_override("font_color", UiPalette.TEXT_ON_DARK)
	nickname_edit.add_theme_color_override("font_placeholder_color", UiPalette.TEXT_MUTED)
	nickname_edit.add_theme_color_override("caret_color", UiPalette.TEXT_ON_DARK)
	nickname_edit.add_theme_color_override("selection_color", UiPalette.with_alpha(UiPalette.PRIMARY, 0.75))

## Chip: selecionado = fundo lilas CLARO + texto ESCURO (muda luminosidade, nao so a cor).
func _apply_free_chip_styles() -> void:
	var compact: bool = ScreenTools.is_compact(self)
	for key in minigame_chip_buttons.keys():
		var button: Button = minigame_chip_buttons.get(key, null) as Button
		if button == null:
			continue
		var idle: StyleBoxFlat = _panel_style(UiPalette.CARD_RAISED, UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.60), 12, 2)
		var hover: StyleBoxFlat = _panel_style(UiPalette.CARD_RAISED.lightened(0.10), UiPalette.HIGHLIGHT, 12, 2)
		var selected: StyleBoxFlat = _panel_style(UiPalette.HIGHLIGHT, UiPalette.TEXT_ON_DARK, 12, 3)
		for style in [idle, hover, selected]:
			(style as StyleBoxFlat).shadow_size = 0
			(style as StyleBoxFlat).content_margin_left = 10
			(style as StyleBoxFlat).content_margin_right = 10
		button.add_theme_stylebox_override("normal", idle)
		button.add_theme_stylebox_override("hover", hover)
		button.add_theme_stylebox_override("pressed", selected)
		button.add_theme_stylebox_override("hover_pressed", selected)
		button.add_theme_stylebox_override("focus", ButtonStyles.make_focus_ring(12))
		var selected_text: Color = UiPalette.readable_text_on(UiPalette.HIGHLIGHT)
		button.add_theme_color_override("font_color", UiPalette.TEXT_ON_DARK)
		button.add_theme_color_override("font_hover_color", UiPalette.TEXT_ON_DARK)
		button.add_theme_color_override("font_focus_color", UiPalette.TEXT_ON_DARK)
		button.add_theme_color_override("font_pressed_color", selected_text)
		button.add_theme_color_override("font_hover_pressed_color", selected_text)
		button.add_theme_font_size_override("font_size", ScreenTools.responsive_font(self, UiPalette.FONT_BODY.x, UiPalette.FONT_BODY.y))
		button.custom_minimum_size = Vector2(0, 38.0 if compact else 42.0)

func _update_free_chip_states() -> void:
	for key in minigame_chip_buttons.keys():
		var button: Button = minigame_chip_buttons.get(key, null) as Button
		if button != null:
			button.set_pressed_no_signal(str(key) == selected_free_minigame)
	_apply_free_chip_styles()

# ---------------------------------------------------------------- dados
func _refresh_view() -> void:
	_update_nickname_label()
	_update_campaign_summary()
	_update_free_chip_states()
	_update_free_result_card()

func _update_nickname_label() -> void:
	if nickname_label != null:
		nickname_label.text = ScoreManager.get_player_nickname()

func _update_campaign_summary() -> void:
	for raw_difficulty_key in ScoreManager.get_difficulty_keys():
		var difficulty_key: String = str(raw_difficulty_key)
		var label: Label = campaign_score_labels.get(difficulty_key, null) as Label
		if label != null:
			label.text = _format_points(ScoreManager.get_campaign_total_score(difficulty_key))
	if best_campaign_value != null:
		best_campaign_value.text = _format_points(ScoreManager.get_campaign_best_total())
	if current_campaign_value != null:
		current_campaign_value.text = _format_points(ScoreManager.get_campaign_latest_total())

func _update_free_result_card() -> void:
	var has_selection: bool = selected_free_minigame != ""
	if free_placeholder != null:
		free_placeholder.visible = not has_selection
	if free_result_content != null:
		free_result_content.visible = has_selection
	if not has_selection:
		return
	if free_result_title != null:
		free_result_title.text = _get_minigame_label(selected_free_minigame)
	for raw_difficulty_key in ScoreManager.get_difficulty_keys():
		var difficulty_key: String = str(raw_difficulty_key)
		var label: Label = free_score_labels.get(difficulty_key, null) as Label
		if label != null:
			label.text = _format_points(ScoreManager.get_free_mode_best_score(selected_free_minigame, difficulty_key))

func _on_free_minigame_chip_pressed(minigame_key: String) -> void:
	selected_free_minigame = minigame_key
	_play_click()
	_update_free_chip_states()
	_update_free_result_card()

func _on_clear_free_selection_pressed() -> void:
	_play_click()
	selected_free_minigame = ""
	_update_free_chip_states()
	_update_free_result_card()

func _on_edit_nickname_pressed() -> void:
	_play_click()
	nickname_edit.text = ScoreManager.get_player_nickname()
	_set_nickname_editing(true)
	nickname_edit.grab_focus()
	nickname_edit.select_all()

func _on_save_nickname_pressed() -> void:
	_save_nickname_from_input()

func _on_nickname_submitted(_text: String) -> void:
	_save_nickname_from_input()

func _save_nickname_from_input() -> void:
	_play_click()
	ScoreManager.set_player_nickname(nickname_edit.text)
	_set_nickname_editing(false)
	_refresh_view()

func _on_cancel_nickname_pressed() -> void:
	_play_click()
	_set_nickname_editing(false)

func _set_nickname_editing(enabled: bool) -> void:
	nickname_card.visible = not enabled
	nickname_edit.visible = enabled
	save_nick_button.visible = enabled
	cancel_nick_button.visible = enabled
	edit_button.visible = not enabled
	if not enabled:
		edit_button.grab_focus()

func _on_profile_changed(_nickname: String) -> void:
	_update_nickname_label()

func _on_records_changed() -> void:
	_refresh_view()

func _on_back_pressed() -> void:
	_play_click()
	GameManager.go_to_main_menu()

func _play_click() -> void:
	if magic_sparks != null and _animations_enabled():
		magic_sparks.spawn_at(get_viewport().get_mouse_position())
	if has_node("/root/AudioManager"):
		AudioManager.play_click()

# ---------------------------------------------------------------- estilo / helpers
## Dificuldade = cor da paleta + quantidade de pontos (1/2/3). Nunca so cor.
func _difficulty_accent_color(key: String) -> Color:
	return UiPalette.difficulty_color(key)

func _difficulty_level(key: String) -> int:
	match key:
		DIFF_EASY_KEY:
			return 1
		DIFF_NORMAL_KEY:
			return 2
		DIFF_HARD_KEY:
			return 3
		_:
			return 1

func _format_points(points: int) -> String:
	return "%s pts" % _group_thousands(maxi(points, 0))

## 1900 -> "1.900" (separador de milhar pt-BR: facilita ler numeros grandes de relance)
func _group_thousands(value: int) -> String:
	var digits: String = str(value)
	var out: String = ""
	var count: int = 0
	for i in range(digits.length() - 1, -1, -1):
		out = digits[i] + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = "." + out
	return out

func _card_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = _panel_style(UiPalette.with_alpha(UiPalette.CARD, 0.96), UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.45), 20, 2)
	style.shadow_size = 12
	return style

func _row_style(accent: Color, _compact_row: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = _panel_style(UiPalette.CARD_RAISED, accent, 12, 0)
	style.border_width_left = 6
	style.shadow_size = 0
	return style

func _make_card(card_name: String, bg: Color) -> PanelContainer:
	var card := PanelContainer.new()
	card.name = card_name
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _panel_style(bg, UiPalette.HIGHLIGHT, 20, 2))
	return card

func _make_margin(left: int, right: int, top: int, bottom: int) -> MarginContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", left)
	margin.add_theme_constant_override("margin_right", right)
	margin.add_theme_constant_override("margin_top", top)
	margin.add_theme_constant_override("margin_bottom", bottom)
	return margin

func _panel_style(bg_color: Color, border_color: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.set_corner_radius_all(radius)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.34)
	style.shadow_size = 10
	return style
