extends Control
var pause_menu: MinigamePause

const DynamicQuestionBank := preload("res://scripts/core/question_bank.gd")

const BACKGROUND_PATH: String = Paths.BG_BATALHA_NAVAL
const NAVAL_ICON_PATH: String = Paths.ICON_NAVAL
const GRID_SIZE: int = 5
const CELL_COUNT: int = GRID_SIZE * GRID_SIZE
const BOARD_GAP: int = 8
const BOARD_PADDING: int = 12
const WATER_PARTICLE_COUNT: int = 42
const FEEDBACK_SECONDS: float = 1.15

const THREAT_BANK: Array[Dictionary] = [
	{"ameaca": "Loop Infinito", "controle": "Revisar condição de parada"},
	{"ameaca": "SQL Sem WHERE", "controle": "Validar filtros da consulta"},
	{"ameaca": "Sem Chave Primária", "controle": "Definir identificador único"},
	{"ameaca": "Requisito Ambíguo", "controle": "Refinar com o usuário"},
	{"ameaca": "Tela Confusa", "controle": "Teste de usabilidade"},
	{"ameaca": "Senha Fraca", "controle": "MFA e política de senhas"},
	{"ameaca": "Backup Ausente", "controle": "Plano de backup e restauração"},
	{"ameaca": "Rede Instável", "controle": "Diagnóstico de infraestrutura"},
	{"ameaca": "Sem Logs", "controle": "Registrar eventos críticos"},
	{"ameaca": "Deploy Sem Teste", "controle": "Pipeline de validação"},
	{"ameaca": "Dados Duplicados", "controle": "Normalização e constraints"},
	{"ameaca": "API Exposta", "controle": "Autenticação e gateway"},
	{"ameaca": "Escopo Crescente", "controle": "Gestão de mudanças"},
	{"ameaca": "Falha de Acessibilidade", "controle": "Critérios WCAG"},
	{"ameaca": "CPU Saturada", "controle": "Monitoramento de recursos"},
	{"ameaca": "Código Repetido", "controle": "Refatoração"},
	{"ameaca": "Phishing", "controle": "Conscientização e filtros"},
	{"ameaca": "Sem Documentação", "controle": "Documentar decisões"},
	{"ameaca": "Permissão Excessiva", "controle": "Princípio do menor privilégio"},
	{"ameaca": "Impacto Ignorado", "controle": "Avaliar ética e sociedade"}
]

var threats_by_index: Dictionary = {}
var revealed_indices: Array[int] = []
var missed_indices: Array[int] = []
var cell_buttons: Array[Button] = []
var water_particles: Array[Dictionary] = []
var splash_particles: Array[Dictionary] = []

var threat_total: int = 12
var found_total: int = 0
var correct_points: int = 10
var wrong_points: int = -5
var input_locked: bool = false
var finish_visible: bool = false
var title_base_y: float = 0.0

var root_margin: MarginContainer
var particle_layer: Control
var splash_layer: Control
var title_label: Label
var threat_counter_label: Label
var score_label: Label
var difficulty_label: Label
var grid_container: GridContainer
var board_panel: PanelContainer
var info_label: Label
var feedback_layer: Control
var feedback_title_label: Label
var feedback_body_label: Label
var feedback_continue_button: Button
var finish_layer: Control
var finish_score_label: Label

func _ready() -> void:
	randomize()
	_build_scene()
	pause_menu = MinigamePause.attach(self)
	_connect_score_signal()
	_prepare_board()
	_on_score_changed(ScoreManager.get_score())
	if has_node("/root/AudioManager"):
		AudioManager.play_music("musica_batalha_naval")
	# V0.10: tutorial do Anderson ANTES do primeiro disparo.
	input_locked = true
	await TutorialManager.play(self, "batalha_naval", {"placeholders": {"threats": threat_total}})
	if not is_inside_tree():
		return
	input_locked = false

func _process(delta: float) -> void:
	if not _animations_enabled():
		if particle_layer != null:
			particle_layer.visible = false
		if splash_layer != null:
			splash_layer.visible = false
		if title_label != null:
			title_label.position.y = title_base_y
		return
	if particle_layer != null:
		particle_layer.visible = true
	if splash_layer != null:
		splash_layer.visible = true
	_update_water_particles(delta)
	_update_splash_particles(delta)
	_update_title_float()

func _build_scene() -> void:
	_clear_scene_children()

	var background_rect: TextureRect = TextureRect.new()
	background_rect.name = "Background"
	background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	var bg_texture: Resource = load(BACKGROUND_PATH)
	if bg_texture is Texture2D:
		background_rect.texture = bg_texture
	add_child(background_rect)

	var dimmer: ColorRect = ColorRect.new()
	dimmer.name = "Dimmer"
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.0, 0.04, 0.11, 0.54)
	add_child(dimmer)

	particle_layer = Control.new()
	particle_layer.name = "WaterParticles"
	particle_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	particle_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(particle_layer)
	_create_water_particles()

	splash_layer = Control.new()
	splash_layer.name = "SplashParticles"
	splash_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	splash_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(splash_layer)

	root_margin = MarginContainer.new()
	root_margin.name = "SafeArea"
	root_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 36)
	root_margin.add_theme_constant_override("margin_top", 12)
	root_margin.add_theme_constant_override("margin_right", 36)
	root_margin.add_theme_constant_override("margin_bottom", 12)
	add_child(root_margin)

	var main_box: VBoxContainer = VBoxContainer.new()
	main_box.name = "MainLayout"
	main_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_box.alignment = BoxContainer.ALIGNMENT_CENTER
	main_box.add_theme_constant_override("separation", 6)
	root_margin.add_child(main_box)

	var top_row: HBoxContainer = HBoxContainer.new()
	top_row.name = "TitleRow"
	top_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.alignment = BoxContainer.ALIGNMENT_CENTER
	top_row.add_theme_constant_override("separation", 12)
	main_box.add_child(top_row)

	top_row.add_child(_create_icon(Vector2(44, 44)))

	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "Batalha Naval"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 40)
	title_label.add_theme_color_override("font_color", Color(0.90, 0.96, 1.0))
	title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.88))
	title_label.add_theme_constant_override("shadow_offset_x", 3)
	title_label.add_theme_constant_override("shadow_offset_y", 3)
	top_row.add_child(title_label)

	top_row.add_child(_create_icon(Vector2(44, 44)))
	title_base_y = title_label.position.y

	var status_row: HBoxContainer = HBoxContainer.new()
	status_row.name = "StatusRow"
	status_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_row.alignment = BoxContainer.ALIGNMENT_CENTER
	status_row.add_theme_constant_override("separation", 14)
	main_box.add_child(status_row)

	threat_counter_label = _create_chip_label("Ameaças: 0/0", 18, Color(0.03, 0.12, 0.24, 0.94), Color(0.90, 0.98, 1.0))
	status_row.add_child(threat_counter_label)

	score_label = _create_chip_label("Pontuação: 0", 18, Color(0.03, 0.06, 0.12, 0.94), Color(1, 1, 1))
	status_row.add_child(score_label)

	difficulty_label = _create_chip_label("Dificuldade: Normal", 18, Color(0.03, 0.06, 0.12, 0.94), Color(1, 1, 1))
	status_row.add_child(difficulty_label)

	board_panel = PanelContainer.new()
	board_panel.name = "BoardPanel"
	board_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	board_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.01, 0.05, 0.12, 0.86), Color(0.45, 0.80, 1.0), 18, 3))
	main_box.add_child(board_panel)

	var board_margin: MarginContainer = MarginContainer.new()
	board_margin.add_theme_constant_override("margin_left", 12)
	board_margin.add_theme_constant_override("margin_top", 12)
	board_margin.add_theme_constant_override("margin_right", 12)
	board_margin.add_theme_constant_override("margin_bottom", 12)
	board_panel.add_child(board_margin)

	grid_container = GridContainer.new()
	grid_container.name = "Grid"
	grid_container.columns = GRID_SIZE
	grid_container.add_theme_constant_override("h_separation", BOARD_GAP)
	grid_container.add_theme_constant_override("v_separation", BOARD_GAP)
	board_margin.add_child(grid_container)

	info_label = Label.new()
	info_label.name = "InfoLabel"
	info_label.text = "Encontre os riscos escondidos. Fácil tem mais ameaças; Difícil tem menos margem."
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_label.add_theme_font_size_override("font_size", 15)
	info_label.add_theme_color_override("font_color", Color(0.86, 0.93, 1.0, 0.96))
	main_box.add_child(info_label)


	_build_feedback_layer()
	_build_finish_layer()

func _clear_scene_children() -> void:
	for child in get_children():
		child.queue_free()

func _create_icon(min_size: Vector2) -> TextureRect:
	var icon: TextureRect = TextureRect.new()
	icon.custom_minimum_size = min_size
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var texture: Resource = load(NAVAL_ICON_PATH)
	if texture is Texture2D:
		icon.texture = texture
	return icon

func _create_chip_label(text_value: String, font_size: int, bg_color: Color, text_color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(230, 38)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", text_color)
	label.add_theme_stylebox_override("normal", _make_panel_style(bg_color, Color(1, 1, 1, 0.18), 12, 1))
	return label

func _prepare_board() -> void:
	var rules: Dictionary = DifficultyManager.get_rules()
	var threat_type: String = str(rules.get("pergunta_tipo", "normal"))
	var requested_threats: int = clampi(int(rules.get("naval_qtd", 6)), 1, CELL_COUNT)
	correct_points = DifficultyManager.get_correct_points("batalha_naval")
	wrong_points = DifficultyManager.get_wrong_points("batalha_naval")
	var threat_pool: Array = DynamicQuestionBank.pick_rounds("batalha_naval", threat_type, requested_threats)
	if threat_pool.is_empty():
		threat_pool = THREAT_BANK.duplicate(true)
		threat_pool.shuffle()
	threat_total = mini(CELL_COUNT, mini(threat_pool.size(), requested_threats))
	found_total = 0
	input_locked = false
	finish_visible = false
	threats_by_index.clear()
	revealed_indices.clear()
	missed_indices.clear()
	cell_buttons.clear()

	if difficulty_label != null:
		difficulty_label.text = "Dificuldade: %s" % DifficultyManager.get_label()
		DifficultyManager.apply_difficulty_chip(difficulty_label)

	var all_indices: Array[int] = []
	for i in range(CELL_COUNT):
		all_indices.append(i)
	all_indices.shuffle()

	for i in range(threat_total):
		threats_by_index[all_indices[i]] = threat_pool[i]

	_build_grid_buttons()
	_update_threat_counter()

func _build_grid_buttons() -> void:
	for child in grid_container.get_children():
		child.queue_free()
	cell_buttons.clear()

	for index in range(CELL_COUNT):
		var row: int = floori(float(index) / float(GRID_SIZE))
		var col: int = index % GRID_SIZE
		var cell_button: Button = Button.new()
		cell_button.name = "Cell_%s_%s" % [row + 1, col + 1]
		cell_button.text = "%s%s" % ["ABCDE".substr(col, 1), row + 1]
		cell_button.custom_minimum_size = _board_cell_size()
		cell_button.size_flags_horizontal = Control.SIZE_FILL
		cell_button.size_flags_vertical = Control.SIZE_FILL
		cell_button.clip_text = true
		cell_button.text_overrun_behavior = TextServer.OVERRUN_TRIM_CHAR
		cell_button.add_theme_font_size_override("font_size", 20)
		cell_button.add_theme_stylebox_override("normal", _make_cell_style(Color(0.06, 0.26, 0.60, 0.94), Color(0.68, 0.90, 1.0), 2))
		cell_button.add_theme_stylebox_override("hover", _make_cell_style(Color(0.18, 0.46, 0.86, 1.0), Color(1.0, 1.0, 1.0), 3))
		cell_button.add_theme_stylebox_override("pressed", _make_cell_style(Color(0.08, 0.18, 0.44, 1.0), Color(1.0, 1.0, 1.0), 3))
		cell_button.add_theme_stylebox_override("disabled", _make_cell_style(Color(0.08, 0.14, 0.24, 0.88), Color(0.35, 0.44, 0.58), 2))
		cell_button.add_theme_color_override("font_color", Color(0.92, 0.98, 1.0))
		cell_button.add_theme_color_override("font_hover_color", Color(1, 1, 1))
		cell_button.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
		cell_button.add_theme_color_override("font_disabled_color", Color(0.90, 0.94, 1.0))
		cell_button.pressed.connect(_on_cell_pressed.bind(index, cell_button))
		grid_container.add_child(cell_button)
		cell_buttons.append(cell_button)
	_apply_board_metrics()

## Tamanho UNICO das celulas: grandes e mais LARGAS que altas (tabuleiro largo), proporcional a tela.
func _board_cell_size() -> Vector2:
	var view: Vector2 = get_viewport_rect().size
	var cell_w: float = clampf(view.x * 0.092, 84.0, 128.0)
	var cell_h: float = clampf(view.y * 0.118, 60.0, 88.0)
	return Vector2(floorf(cell_w), floorf(cell_h))

func _apply_board_metrics() -> void:
	if grid_container == null or board_panel == null:
		return
	var cell: Vector2 = _board_cell_size()
	for cell_button in cell_buttons:
		cell_button.custom_minimum_size = cell
	var grid_w: float = cell.x * GRID_SIZE + BOARD_GAP * (GRID_SIZE - 1)
	var grid_h: float = cell.y * GRID_SIZE + BOARD_GAP * (GRID_SIZE - 1)
	board_panel.custom_minimum_size = Vector2(grid_w + BOARD_PADDING * 2 + 6, grid_h + BOARD_PADDING * 2 + 6)
	for cell_button in cell_buttons:
		cell_button.add_theme_font_size_override("font_size", 22 if cell.y >= 72.0 else 18)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_board_metrics()

func _create_feedback_continue_button(parent: VBoxContainer) -> void:
	feedback_continue_button = Button.new()
	feedback_continue_button.text = "Continuar"
	feedback_continue_button.custom_minimum_size = Vector2(260, 48)
	feedback_continue_button.focus_mode = Control.FOCUS_ALL
	feedback_continue_button.add_theme_font_size_override("font_size", 20)
	feedback_continue_button.add_theme_stylebox_override("normal", _make_button_style(Color(0.04, 0.14, 0.24, 0.96), Color(0.36, 0.80, 1.0), 2))
	feedback_continue_button.add_theme_stylebox_override("hover", _make_button_style(Color(0.08, 0.24, 0.36, 0.98), Color(0.72, 1.0, 1.0), 2))
	feedback_continue_button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.02, 0.08, 0.16, 1.0), Color(0.36, 0.80, 1.0), 2))
	parent.add_child(feedback_continue_button)

func _wait_for_feedback_continue() -> void:
	if feedback_continue_button == null:
		await get_tree().process_frame
		return
	feedback_continue_button.disabled = false
	feedback_continue_button.call_deferred("grab_focus")
	await feedback_continue_button.pressed

func _on_cell_pressed(index: int, cell_button: Button) -> void:
	if input_locked or finish_visible:
		return
	if revealed_indices.has(index) or missed_indices.has(index):
		return

	input_locked = true
	var center_pos: Vector2 = _get_button_center(cell_button)
	if threats_by_index.has(index):
		var threat_data: Dictionary = threats_by_index[index]
		revealed_indices.append(index)
		found_total += 1
		ScoreManager.add_points(correct_points)
		_set_cell_as_threat(cell_button)
		_create_splash(center_pos, true)
		if has_node("/root/AudioManager"):
			AudioManager.play_sfx("explosion")
		await _show_feedback(true, str(threat_data.get("ameaca", "Ameaça")), str(threat_data.get("controle", "Controle recomendado")), str(threat_data.get("explanation", "")))
	else:
		missed_indices.append(index)
		ScoreManager.subtract_points(abs(wrong_points), true)
		_set_cell_as_miss(cell_button)
		_create_splash(center_pos, false)
		if has_node("/root/AudioManager"):
			AudioManager.play_sfx("errado")
		await _show_feedback(false, "Água", "Nenhum risco detectado nessa coordenada.")

	if not is_inside_tree():
		return
	feedback_layer.visible = false
	_update_threat_counter()
	if found_total >= threat_total:
		_show_finish()
	else:
		input_locked = false

func _set_cell_as_threat(cell_button: Button) -> void:
	cell_button.disabled = true
	cell_button.text = "RISCO"
	cell_button.icon = UiIcons.texture("burst")
	# Icone ao LADO do texto (nunca empilhado): a celula revelada continua com o mesmo tamanho das outras.
	cell_button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	cell_button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	cell_button.expand_icon = false
	cell_button.add_theme_constant_override("icon_max_width", 20)
	cell_button.add_theme_constant_override("h_separation", 4)
	cell_button.add_theme_font_size_override("font_size", 18)
	cell_button.add_theme_color_override("icon_disabled_color", Color(1.0, 0.96, 0.86))
	cell_button.add_theme_stylebox_override("disabled", _make_cell_style(Color(0.58, 0.05, 0.05, 0.98), Color(1.0, 0.68, 0.32), 3))
	cell_button.add_theme_color_override("font_disabled_color", Color(1.0, 0.96, 0.86))

func _set_cell_as_miss(cell_button: Button) -> void:
	cell_button.disabled = true
	cell_button.text = "ÁGUA"
	cell_button.add_theme_stylebox_override("disabled", _make_cell_style(Color(0.25, 0.28, 0.36, 0.90), Color(0.56, 0.66, 0.82), 2))
	cell_button.add_theme_color_override("font_disabled_color", Color(0.86, 0.92, 1.0))

func _show_feedback(is_threat: bool, main_text: String, secondary_text: String, explanation_text: String = "") -> void:
	if is_threat:
		feedback_title_label.text = "Risco Detectado!"
		feedback_title_label.add_theme_color_override("font_color", Color(1.0, 0.72, 0.28))
		var explanation: String = _clean_feedback_explanation(secondary_text, explanation_text if explanation_text != "" else _get_threat_explanation(main_text, secondary_text))
		feedback_body_label.text = "Ameaça: %s\nControle correto: %s\n%s\n+%s pontos" % [main_text, secondary_text, explanation, correct_points]
	else:
		feedback_title_label.text = "Água..."
		feedback_title_label.add_theme_color_override("font_color", Color(0.50, 0.74, 1.0))
		feedback_body_label.text = "%s\nEssa coordenada não tinha ameaça; continue procurando riscos reais no tabuleiro.\n%s pontos" % [secondary_text, wrong_points]
	feedback_layer.visible = true
	await _wait_for_feedback_continue()

func _clean_feedback_explanation(answer_text: String, explanation_text: String) -> String:
	var answer := answer_text.strip_edges()
	var explanation := explanation_text.strip_edges()
	if explanation == "" or explanation.to_lower() == answer.to_lower():
		return "%s reduz ou neutraliza o risco apresentado." % answer
	return explanation

func _get_threat_explanation(threat_name: String, control_text: String) -> String:
	return "%s reduz ou neutraliza o risco de %s." % [control_text, threat_name]

func _show_finish() -> void:
	input_locked = true
	finish_visible = true
	if has_node("/root/AchievementManager") and missed_indices.size() <= 3:
		AchievementManager.unlock("estrategia_naval")
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("correto")
	finish_score_label.text = "Todas as ameaças foram neutralizadas.\nPontuação atual: %s pontos" % ScoreManager.get_score()
	finish_layer.visible = true

func _build_feedback_layer() -> void:
	feedback_layer = Control.new()
	feedback_layer.name = "FeedbackLayer"
	feedback_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	feedback_layer.visible = false
	feedback_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(feedback_layer)

	var overlay: ColorRect = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.68)
	feedback_layer.add_child(overlay)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	feedback_layer.add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(760, 330)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.07, 0.13, 0.98), Color(0.60, 0.85, 1.0), 20, 3))
	center.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_bottom", 30)
	panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 18)
	margin.add_child(box)

	feedback_title_label = Label.new()
	feedback_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_title_label.add_theme_font_size_override("font_size", 42)
	box.add_child(feedback_title_label)

	feedback_body_label = Label.new()
	feedback_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	feedback_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_body_label.add_theme_font_size_override("font_size", 23)
	feedback_body_label.add_theme_color_override("font_color", Color(0.93, 0.97, 1.0))
	box.add_child(feedback_body_label)
	_create_feedback_continue_button(box)

func _build_finish_layer() -> void:
	finish_layer = Control.new()
	finish_layer.name = "FinishLayer"
	finish_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	finish_layer.visible = false
	finish_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(finish_layer)

	var overlay: ColorRect = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.82)
	finish_layer.add_child(overlay)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	finish_layer.add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 330)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.07, 0.13, 0.98), Color(0.45, 0.90, 1.0), 22, 3))
	center.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_bottom", 30)
	panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 18)
	margin.add_child(box)

	var title: Label = Label.new()
	title.text = "Ambiente Seguro!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Color(0.58, 0.88, 1.0))
	box.add_child(title)

	finish_score_label = Label.new()
	finish_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	finish_score_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	finish_score_label.add_theme_font_size_override("font_size", 25)
	finish_score_label.add_theme_color_override("font_color", Color(1, 1, 1))
	box.add_child(finish_score_label)

	var continue_button: Button = Button.new()
	continue_button.text = "Continuar"
	continue_button.custom_minimum_size = Vector2(260, 58)
	continue_button.add_theme_font_size_override("font_size", 22)
	continue_button.pressed.connect(_on_finish_continue_pressed)
	box.add_child(continue_button)

func _connect_score_signal() -> void:
	var callable: Callable = Callable(self, "_on_score_changed")
	if not ScoreManager.score_changed.is_connected(callable):
		ScoreManager.score_changed.connect(callable)

func _on_score_changed(new_score: int) -> void:
	if score_label != null:
		score_label.text = "Pontuação: %s" % new_score

func _update_threat_counter() -> void:
	if threat_counter_label != null:
		threat_counter_label.text = "Ameaças: %s/%s" % [found_total, threat_total]

func _on_finish_continue_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	GameManager.complete_current_stage(0)


func _get_button_center(button: Button) -> Vector2:
	return button.global_position + button.size * 0.5

func _create_water_particles() -> void:
	water_particles.clear()
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(1280, 720)
	for _i in range(WATER_PARTICLE_COUNT):
		var particle: ColorRect = ColorRect.new()
		particle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var radius: float = randf_range(3.0, 8.0)
		particle.size = Vector2(radius, radius)
		particle.color = Color(0.45, 0.78, 1.0, randf_range(0.18, 0.42))
		particle.position = Vector2(randf_range(0.0, viewport_size.x), randf_range(0.0, viewport_size.y))
		particle_layer.add_child(particle)
		water_particles.append({
			"node": particle,
			"dir": Vector2(randf_range(-14.0, 14.0), randf_range(-6.0, 18.0)),
			"osc": randf_range(0.0, TAU),
			"speed": randf_range(0.45, 1.15)
		})

func _update_water_particles(delta: float) -> void:
	if water_particles.is_empty():
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(1280, 720)
	for i in range(water_particles.size()):
		var data: Dictionary = water_particles[i]
		var particle: ColorRect = data["node"] as ColorRect
		if particle == null:
			continue
		var direction: Vector2 = data["dir"] as Vector2
		var osc: float = float(data["osc"])
		var speed: float = float(data["speed"])
		osc += delta * speed
		data["osc"] = osc
		particle.position += (direction * delta) + Vector2(sin(osc) * 18.0 * delta, cos(osc) * 6.0 * delta)
		if particle.position.x < -20.0:
			particle.position.x = viewport_size.x + 20.0
		elif particle.position.x > viewport_size.x + 20.0:
			particle.position.x = -20.0
		if particle.position.y < -20.0:
			particle.position.y = viewport_size.y + 20.0
		elif particle.position.y > viewport_size.y + 20.0:
			particle.position.y = -20.0
		water_particles[i] = data

func _create_splash(global_center: Vector2, strong: bool) -> void:
	if not _animations_enabled():
		return
	var local_center: Vector2 = splash_layer.get_global_transform().affine_inverse() * global_center
	var wave: ColorRect = ColorRect.new()
	wave.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wave.position = local_center - Vector2(10, 10)
	wave.size = Vector2(20, 20)
	wave.color = Color(1, 1, 1, 0.60) if strong else Color(0.55, 0.78, 1.0, 0.42)
	splash_layer.add_child(wave)
	splash_particles.append({"node": wave, "velocity": Vector2.ZERO, "life": 0.0, "max_life": 0.42, "wave": true})

	var count: int = 12 if strong else 6
	for _i in range(count):
		var drop: ColorRect = ColorRect.new()
		drop.mouse_filter = Control.MOUSE_FILTER_IGNORE
		drop.position = local_center
		drop.size = Vector2(randf_range(4.0, 8.0), randf_range(4.0, 8.0))
		drop.color = Color(0.78, 0.92, 1.0, 0.86) if strong else Color(0.40, 0.70, 1.0, 0.66)
		splash_layer.add_child(drop)
		var angle: float = randf_range(0.0, TAU)
		var velocity: Vector2 = Vector2(cos(angle), sin(angle)) * randf_range(110.0, 260.0)
		velocity.y -= randf_range(50.0, 160.0)
		splash_particles.append({"node": drop, "velocity": velocity, "life": 0.0, "max_life": randf_range(0.38, 0.62), "wave": false})

func _update_splash_particles(delta: float) -> void:
	if splash_particles.is_empty():
		return
	for i in range(splash_particles.size() - 1, -1, -1):
		var data: Dictionary = splash_particles[i]
		var node: ColorRect = data["node"] as ColorRect
		if node == null:
			splash_particles.remove_at(i)
			continue
		var life: float = float(data["life"]) + delta
		var max_life: float = float(data["max_life"])
		if life >= max_life:
			node.queue_free()
			splash_particles.remove_at(i)
			continue
		data["life"] = life
		var ratio: float = clampf(life / max_life, 0.0, 1.0)
		if bool(data["wave"]):
			var scale_value: float = 1.0 + ratio * 3.2
			node.scale = Vector2(scale_value, scale_value)
		else:
			var velocity: Vector2 = data["velocity"] as Vector2
			velocity.y += 360.0 * delta
			node.position += velocity * delta
			data["velocity"] = velocity
		var color: Color = node.color
		color.a = maxf(0.0, 1.0 - ratio)
		node.color = color
		splash_particles[i] = data

func _update_title_float() -> void:
	if title_label == null:
		return
	var t: float = float(Time.get_ticks_msec()) * 0.001
	title_label.position.y = title_base_y + sin(t * 1.8) * 4.0

func _animations_enabled() -> bool:
	return not has_node("/root/SettingsManager") or SettingsManager.animations_enabled()

func _make_panel_style(bg_color: Color, border_color: Color, radius: int = 14, border_width: int = 1) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0, 0, 0, 0.35)
	style.shadow_size = 8
	return style

func _make_cell_style(bg_color: Color, border_color: Color, border_width: int = 2) -> StyleBoxFlat:
	var style: StyleBoxFlat = _make_panel_style(bg_color, border_color, 12, border_width)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func _make_button_style(bg_color: Color, border_color: Color, border_width: int = 2) -> StyleBoxFlat:
	var style: StyleBoxFlat = _make_panel_style(bg_color, border_color, 14, border_width)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style
