extends Control
## ContalMaster - STOP (V0.14.4.2)
## Uma letra e sorteada; o jogador escolhe, entre 6 opcoes FIXAS (grade 3x2) que comecam com
## essa letra, a que responde a categoria e a dica. Perguntas e opcoes vem de question_bank.gd
## (dicionario.json): este script nao guarda mais conteudo proprio.

const DynamicQuestionBank := preload("res://scripts/core/question_bank.gd")

const BACKGROUND_PATH := Paths.BG_STOP
const STOP_ICON_PATH := Paths.ICON_STOP
const STOP_TITLE := "STOP - CONTROLE NORMATIVO"
const ROUNDS := 6
const OPTION_COUNT := 6
const OPTION_COLUMNS := 3
const ROULETTE_STEPS := 18
const LETTER_PARTICLE_COUNT := 28
const LETTERS := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const PARTICLE_CHARS: Array[String] = ["S", "T", "O", "P", "?", "!", "$", "%"]

var pause_menu: MinigamePause

var questions: Array = []
var option_buttons: Array[Button] = []
var letter_particles: Array = []
var current_question: Dictionary = {}
var current_question_index: int = 0
var correct_points: int = 10
var wrong_points: int = -12
var correct_answers_count: int = 0
var input_locked: bool = true
var finish_visible: bool = false
var round_start_msec: int = 0
var shake_strength: float = 0.0
var base_root_position: Vector2 = Vector2.ZERO

var stop_icon: Texture2D
var disabled_option_style: StyleBoxFlat
var root_margin: MarginContainer
var particle_layer: Control
var title_label: Label
var question_counter_label: Label
var score_label: Label
var difficulty_label: Label
var roulette_label: Label
var category_label: Label
var tip_label: Label
var options_grid: GridContainer
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
	_prepare_questions()
	_on_score_changed(ScoreManager.get_score())
	if has_node("/root/AudioManager"):
		AudioManager.play_music("musica_stop")
	await _start_question(0)
	# Tutorial do Cleiton depois da 1a letra sorteada; o relogio da rodada so comeca depois dele.
	input_locked = true
	await TutorialManager.play(self, "stop")
	if not is_inside_tree():
		return
	round_start_msec = Time.get_ticks_msec()
	input_locked = false


func _process(delta: float) -> void:
	var animate: bool = _animations_enabled()
	if particle_layer != null:
		particle_layer.visible = animate
	if not animate:
		if root_margin != null:
			root_margin.position = base_root_position
		return
	_update_letter_particles(delta)
	_update_screen_shake(delta)


func _unhandled_input(event: InputEvent) -> void:
	if finish_visible or not (event is InputEventKey):
		return
	var key_event: InputEventKey = event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	match key_event.keycode:
		KEY_1, KEY_KP_1, KEY_A: _press_option_by_index(0)
		KEY_2, KEY_KP_2, KEY_B: _press_option_by_index(1)
		KEY_3, KEY_KP_3, KEY_C: _press_option_by_index(2)
		KEY_4, KEY_KP_4, KEY_D: _press_option_by_index(3)
		KEY_5, KEY_KP_5, KEY_E: _press_option_by_index(4)
		KEY_6, KEY_KP_6, KEY_F: _press_option_by_index(5)


# ======================================================================
# CONSTRUCAO DA CENA
# ======================================================================

func _build_scene() -> void:
	var icon_resource: Resource = load(STOP_ICON_PATH)
	if icon_resource is Texture2D:
		stop_icon = icon_resource as Texture2D

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
	dimmer.color = Color(0.02, 0.02, 0.08, 0.58)
	dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dimmer)

	particle_layer = Control.new()
	particle_layer.name = "StopParticles"
	particle_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	particle_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(particle_layer)
	_create_letter_particles()

	root_margin = MarginContainer.new()
	root_margin.name = "SafeArea"
	root_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 44)
	root_margin.add_theme_constant_override("margin_top", 16)
	root_margin.add_theme_constant_override("margin_right", 44)
	root_margin.add_theme_constant_override("margin_bottom", 16)
	add_child(root_margin)
	base_root_position = root_margin.position

	var main_box: VBoxContainer = VBoxContainer.new()
	main_box.name = "MainLayout"
	main_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_box.alignment = BoxContainer.ALIGNMENT_CENTER
	main_box.add_theme_constant_override("separation", 8)
	root_margin.add_child(main_box)

	_build_title_row(main_box)
	_build_status_row(main_box)
	_build_roulette(main_box)
	_build_question_panel(main_box)
	_build_options_grid(main_box)
	_build_feedback_layer()
	_build_finish_layer()


func _build_title_row(parent: Control) -> void:
	var top_row: HBoxContainer = HBoxContainer.new()
	top_row.name = "TopRow"
	top_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.alignment = BoxContainer.ALIGNMENT_CENTER
	top_row.add_theme_constant_override("separation", 12)
	parent.add_child(top_row)

	top_row.add_child(_create_stop_icon(Vector2(52, 52)))
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = STOP_TITLE
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 42)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.05))
	title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	title_label.add_theme_constant_override("shadow_offset_x", 3)
	title_label.add_theme_constant_override("shadow_offset_y", 3)
	top_row.add_child(title_label)
	top_row.add_child(_create_stop_icon(Vector2(52, 52)))


func _build_status_row(parent: Control) -> void:
	var status_row: HBoxContainer = HBoxContainer.new()
	status_row.name = "StatusRow"
	status_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_row.alignment = BoxContainer.ALIGNMENT_CENTER
	status_row.add_theme_constant_override("separation", 12)
	parent.add_child(status_row)

	var dark: Color = Color(0.04, 0.07, 0.16, 0.95)
	question_counter_label = _create_chip_label("RODADA 1/%d" % ROUNDS, Color(0.78, 0.05, 0.08, 0.96))
	score_label = _create_chip_label("Pontuação: 0", dark)
	difficulty_label = _create_chip_label("Dificuldade: Normal", dark)
	status_row.add_child(question_counter_label)
	status_row.add_child(score_label)
	status_row.add_child(difficulty_label)


func _build_roulette(parent: Control) -> void:
	roulette_label = Label.new()
	roulette_label.name = "RouletteLetter"
	roulette_label.text = "?"
	roulette_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	roulette_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	roulette_label.custom_minimum_size = Vector2(190, 150)
	roulette_label.pivot_offset = Vector2(95, 75)
	roulette_label.add_theme_font_size_override("font_size", 118)
	roulette_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.05))
	roulette_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.92))
	roulette_label.add_theme_constant_override("shadow_offset_x", 4)
	roulette_label.add_theme_constant_override("shadow_offset_y", 4)
	roulette_label.add_theme_stylebox_override("normal", _make_panel_style(Color(0.04, 0.04, 0.12, 0.74), Color(1.0, 0.84, 0.05), 26, 3))
	parent.add_child(roulette_label)


func _build_question_panel(parent: Control) -> void:
	var question_panel: PanelContainer = PanelContainer.new()
	question_panel.name = "QuestionPanel"
	question_panel.custom_minimum_size = Vector2(880, 128)
	question_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	question_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.08, 0.18, 0.88), Color(0.34, 0.90, 1.0), 18, 2))
	parent.add_child(question_panel)

	var question_margin: MarginContainer = MarginContainer.new()
	question_margin.add_theme_constant_override("margin_left", 28)
	question_margin.add_theme_constant_override("margin_top", 14)
	question_margin.add_theme_constant_override("margin_right", 28)
	question_margin.add_theme_constant_override("margin_bottom", 14)
	question_panel.add_child(question_margin)

	var question_box: VBoxContainer = VBoxContainer.new()
	question_box.alignment = BoxContainer.ALIGNMENT_CENTER
	question_box.add_theme_constant_override("separation", 7)
	question_margin.add_child(question_box)

	category_label = Label.new()
	category_label.name = "CategoryLabel"
	category_label.text = "Categoria:"
	category_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	category_label.add_theme_font_size_override("font_size", 23)
	category_label.add_theme_color_override("font_color", Color(0.93, 0.96, 1.0))
	question_box.add_child(category_label)

	tip_label = Label.new()
	tip_label.name = "TipLabel"
	tip_label.text = "Dica:"
	tip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip_label.add_theme_font_size_override("font_size", 21)
	tip_label.add_theme_color_override("font_color", Color(0.80, 0.90, 1.0))
	tip_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	question_box.add_child(tip_label)


## Grade FIXA de 6 botoes (3 em cima, 3 embaixo), criada uma unica vez e reaproveitada a cada rodada.
func _build_options_grid(parent: Control) -> void:
	options_grid = GridContainer.new()
	options_grid.name = "OptionsGrid"
	options_grid.columns = OPTION_COLUMNS
	options_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	options_grid.add_theme_constant_override("h_separation", 18)
	options_grid.add_theme_constant_override("v_separation", 10)
	parent.add_child(options_grid)

	var idle: StyleBoxFlat = _make_option_button_style(Color(0.06, 0.10, 0.24, 0.94), Color(0.38, 0.72, 1.0))
	var hover: StyleBoxFlat = _make_option_button_style(Color(0.14, 0.22, 0.46, 1.0), Color(1.0, 1.0, 1.0), 3)
	var pressed: StyleBoxFlat = _make_option_button_style(Color(0.22, 0.30, 0.56, 1.0), Color(1, 1, 1), 3)
	disabled_option_style = _make_option_button_style(Color(0.04, 0.07, 0.14, 0.68), Color(0.25, 0.35, 0.48))

	for i in range(OPTION_COUNT):
		var button: Button = Button.new()
		button.name = "Option%d" % (i + 1)
		button.custom_minimum_size = Vector2(250, 66)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.add_theme_font_size_override("font_size", 20)
		button.add_theme_stylebox_override("normal", idle)
		button.add_theme_stylebox_override("hover", hover)
		button.add_theme_stylebox_override("pressed", pressed)
		button.add_theme_stylebox_override("disabled", disabled_option_style)
		button.add_theme_color_override("font_color", Color(1, 1, 1))
		button.add_theme_color_override("font_hover_color", Color(1, 1, 1))
		button.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
		button.add_theme_color_override("font_disabled_color", Color(0.85, 0.90, 1.0))
		button.pressed.connect(_on_option_pressed.bind(i))
		options_grid.add_child(button)
		option_buttons.append(button)
	_reset_options()


func _create_stop_icon(min_size: Vector2) -> TextureRect:
	var icon: TextureRect = TextureRect.new()
	icon.custom_minimum_size = min_size
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = stop_icon
	return icon


func _create_chip_label(text_value: String, bg_color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(220, 36)
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	label.add_theme_stylebox_override("normal", _make_panel_style(bg_color, Color(1, 1, 1, 0.20), 12, 1))
	return label


func _build_feedback_layer() -> void:
	feedback_layer = _make_overlay_layer("FeedbackLayer", 0.74)
	var box: VBoxContainer = _make_overlay_panel(feedback_layer, Vector2(760, 330), 20)

	var title_row: HBoxContainer = HBoxContainer.new()
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	title_row.add_theme_constant_override("separation", 12)
	box.add_child(title_row)
	title_row.add_child(_create_stop_icon(Vector2(44, 44)))

	feedback_title_label = Label.new()
	feedback_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_title_label.add_theme_font_size_override("font_size", 40)
	title_row.add_child(feedback_title_label)

	feedback_body_label = Label.new()
	feedback_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	feedback_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_body_label.add_theme_font_size_override("font_size", 22)
	feedback_body_label.add_theme_color_override("font_color", Color(0.94, 0.96, 1.0))
	box.add_child(feedback_body_label)

	feedback_continue_button = Button.new()
	feedback_continue_button.text = "Continuar"
	feedback_continue_button.custom_minimum_size = Vector2(260, 48)
	feedback_continue_button.add_theme_font_size_override("font_size", 20)
	feedback_continue_button.add_theme_stylebox_override("normal", _make_button_style(Color(0.06, 0.16, 0.24, 0.96), Color(0.34, 0.90, 1.0)))
	feedback_continue_button.add_theme_stylebox_override("hover", _make_button_style(Color(0.10, 0.28, 0.38, 0.98), Color(0.70, 1.0, 1.0)))
	feedback_continue_button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.03, 0.10, 0.16, 1.0), Color(0.34, 0.90, 1.0)))
	box.add_child(feedback_continue_button)


func _build_finish_layer() -> void:
	finish_layer = _make_overlay_layer("FinishLayer", 0.82)
	var box: VBoxContainer = _make_overlay_panel(finish_layer, Vector2(720, 330), 22)

	var title: Label = Label.new()
	title.text = "Fim do Desafio STOP!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.05))
	box.add_child(title)

	finish_score_label = Label.new()
	finish_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	finish_score_label.add_theme_font_size_override("font_size", 26)
	box.add_child(finish_score_label)

	var continue_button: Button = Button.new()
	continue_button.text = "Continuar"
	continue_button.custom_minimum_size = Vector2(260, 58)
	continue_button.add_theme_font_size_override("font_size", 22)
	continue_button.pressed.connect(_on_finish_continue_pressed)
	box.add_child(continue_button)


## Camada escura de tela cheia (bloqueia cliques) usada pelo feedback e pelo fim.
func _make_overlay_layer(layer_name: String, dim_alpha: float) -> Control:
	var layer: Control = Control.new()
	layer.name = layer_name
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.visible = false
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(layer)
	var overlay: ColorRect = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, dim_alpha)
	layer.add_child(overlay)
	return layer


## Painel central dourado; devolve a caixa vertical onde o conteudo entra.
func _make_overlay_panel(layer: Control, min_size: Vector2, radius: int) -> VBoxContainer:
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = min_size
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.06, 0.12, 0.98), Color(1.0, 0.84, 0.05), radius, 3))
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
	return box


# ======================================================================
# RODADAS
# ======================================================================

func _connect_score_signal() -> void:
	var callable: Callable = Callable(self, "_on_score_changed")
	if not ScoreManager.score_changed.is_connected(callable):
		ScoreManager.score_changed.connect(callable)


func _prepare_questions() -> void:
	correct_answers_count = 0
	var rules: Dictionary = DifficultyManager.get_rules()
	var question_type: String = str(rules.get("pergunta_tipo", "normal"))
	questions = DynamicQuestionBank.pick_rounds("stop", question_type, ROUNDS)
	if questions.is_empty():
		push_warning("[STOP] Nenhuma pergunta carregada de dicionario.json.")
	correct_points = DifficultyManager.get_correct_points("stop")
	wrong_points = DifficultyManager.get_wrong_points("stop")
	if difficulty_label != null:
		difficulty_label.text = "Dificuldade: %s" % DifficultyManager.get_label()
		DifficultyManager.apply_difficulty_chip(difficulty_label)


func _start_question(index: int) -> void:
	if index >= questions.size():
		_show_finish()
		return

	input_locked = true
	current_question_index = index
	current_question = questions[index] as Dictionary
	question_counter_label.text = "RODADA %s/%s" % [index + 1, questions.size()]
	category_label.text = "Categoria: %s" % str(current_question.get("categoria", ""))
	tip_label.text = "Dica: %s" % str(current_question.get("dica", ""))
	_reset_options()

	await _play_roulette(str(current_question.get("letra", "?")))
	if not is_inside_tree():
		return
	_fill_options()
	round_start_msec = Time.get_ticks_msec()
	input_locked = false


func _play_roulette(target_letter: String) -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	for i in range(ROULETTE_STEPS):
		if i == ROULETTE_STEPS - 1:
			roulette_label.text = target_letter
			roulette_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.05))
		else:
			var random_index: int = randi_range(0, LETTERS.length() - 1)
			roulette_label.text = LETTERS.substr(random_index, 1)
			roulette_label.add_theme_color_override("font_color", Color(0.78, 0.82, 0.90))
		await get_tree().create_timer(0.035 + float(i) * 0.006, false).timeout
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("explosion")
	_flash_letter()


func _flash_letter() -> void:
	roulette_label.scale = Vector2.ONE
	if not _animations_enabled():
		return
	var tween: Tween = create_tween()
	tween.tween_property(roulette_label, "scale", Vector2(1.12, 1.12), 0.07)
	tween.tween_property(roulette_label, "scale", Vector2.ONE, 0.10)


## Deixa os 6 botoes no lugar, vazios e desabilitados, enquanto a letra gira.
func _reset_options() -> void:
	for button in option_buttons:
		button.visible = true
		button.disabled = true
		button.text = ""
		button.set_meta("answer_text", "")
		button.add_theme_stylebox_override("disabled", disabled_option_style)


## Preenche os 6 botoes com as opcoes da rodada (ja embaralhadas pelo banco de perguntas).
func _fill_options() -> void:
	var options: Array = current_question.get("opcoes", []) as Array
	if options.size() < OPTION_COUNT:
		push_warning("[STOP] Letra %s tem so %d opcoes (esperado %d)." % [str(current_question.get("letra", "?")), options.size(), OPTION_COUNT])
	for i in range(OPTION_COUNT):
		var button: Button = option_buttons[i]
		if i >= options.size():
			button.visible = false
			continue
		var option_text: String = str(options[i])
		button.text = option_text
		button.set_meta("answer_text", option_text)
		button.disabled = false


func _on_option_pressed(index: int) -> void:
	if input_locked or finish_visible or index < 0 or index >= option_buttons.size():
		return
	var selected_button: Button = option_buttons[index]
	if selected_button.disabled or not selected_button.visible:
		return
	input_locked = true
	for button in option_buttons:
		button.disabled = true

	var selected_text: String = str(selected_button.get_meta("answer_text"))
	var correct_text: String = str(current_question.get("correta", ""))
	var is_correct: bool = selected_text == correct_text
	var elapsed_seconds: float = float(Time.get_ticks_msec() - round_start_msec) / 1000.0
	var awarded_points: int = 0
	_highlight_answer(selected_button, correct_text, is_correct)

	if is_correct:
		awarded_points = DifficultyManager.get_time_adjusted_points(correct_points, elapsed_seconds)
		correct_answers_count += 1
		ScoreManager.add_points(awarded_points)
		if has_node("/root/AudioManager"):
			AudioManager.play_sfx("correto")
	else:
		ScoreManager.subtract_points(abs(wrong_points), true)
		if has_node("/root/AudioManager"):
			AudioManager.play_sfx("errado")
		if _animations_enabled():
			shake_strength = 13.0

	await _show_feedback(is_correct, selected_text, correct_text, awarded_points)
	if not is_inside_tree():
		return
	feedback_layer.visible = false
	_start_question(current_question_index + 1)


func _highlight_answer(selected_button: Button, correct_text: String, is_correct: bool) -> void:
	for button in option_buttons:
		if str(button.get_meta("answer_text")) == correct_text:
			button.add_theme_stylebox_override("disabled", _make_option_button_style(Color(0.0, 0.43, 0.14, 0.98), Color(0.56, 1.0, 0.62), 3))
		elif button == selected_button and not is_correct:
			button.add_theme_stylebox_override("disabled", _make_option_button_style(Color(0.56, 0.02, 0.02, 0.98), Color(1.0, 0.52, 0.52), 3))


func _show_feedback(is_correct: bool, selected_text: String, correct_text: String, awarded_points: int) -> void:
	var explanation: String = str(current_question.get("explanation", "")).strip_edges()
	if explanation == "" or explanation.to_lower() == correct_text.to_lower():
		explanation = "%s atende à categoria e à dica apresentadas nesta rodada." % correct_text
	if is_correct:
		feedback_title_label.text = "CORRETO"
		feedback_title_label.add_theme_color_override("font_color", Color(0.42, 1.0, 0.48))
		feedback_body_label.text = "Resposta correta: %s\n%s\nPontuação adquirida: +%s" % [correct_text, explanation, awarded_points]
	else:
		feedback_title_label.text = "INCORRETO"
		feedback_title_label.add_theme_color_override("font_color", Color(1.0, 0.24, 0.20))
		feedback_body_label.text = "Você escolheu: %s\nEssa opção não combina com a categoria e a dica da rodada.\n\nResposta correta: %s\n%s\nPontuação perdida: %s" % [selected_text, correct_text, explanation, wrong_points]
	feedback_layer.visible = true
	feedback_continue_button.disabled = false
	feedback_continue_button.call_deferred("grab_focus")
	await feedback_continue_button.pressed


func _show_finish() -> void:
	input_locked = true
	finish_visible = true
	if has_node("/root/AchievementManager") and not questions.is_empty() and correct_answers_count >= questions.size():
		AchievementManager.unlock("mestre_stop")
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("correto")
	finish_score_label.text = "Pontuação atual: %s pontos" % ScoreManager.get_score()
	finish_layer.visible = true


func _on_finish_continue_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	GameManager.complete_current_stage(0)


func _press_option_by_index(index: int) -> void:
	_on_option_pressed(index)


func _on_score_changed(new_score: int) -> void:
	if score_label != null:
		score_label.text = "Pontuação: %s" % new_score


# ======================================================================
# EFEITOS (letras flutuantes e tremor de tela)
# ======================================================================

func _viewport_size() -> Vector2:
	var size_now: Vector2 = get_viewport_rect().size
	if size_now.x <= 0.0 or size_now.y <= 0.0:
		return Vector2(1280, 720)
	return size_now


func _create_letter_particles() -> void:
	letter_particles.clear()
	var palette: Array[Color] = [
		Color(1.0, 0.22, 0.22, 0.32),
		Color(0.22, 0.94, 1.0, 0.30),
		Color(1.0, 0.84, 0.10, 0.30),
		Color(0.72, 0.30, 1.0, 0.28)
	]
	for i in range(WebLite.scaled_count(LETTER_PARTICLE_COUNT)):
		var label: Label = Label.new()
		label.text = PARTICLE_CHARS[randi_range(0, PARTICLE_CHARS.size() - 1)]
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_font_size_override("font_size", randi_range(28, 58))
		label.add_theme_color_override("font_color", palette[randi_range(0, palette.size() - 1)])
		particle_layer.add_child(label)
		var data: Dictionary = {
			"node": label,
			"speed": randf_range(22.0, 74.0),
			"drift": randf_range(-18.0, 18.0),
			"phase": randf_range(0.0, 6.28)
		}
		letter_particles.append(data)
		_reset_letter_particle(data, true)


func _reset_letter_particle(data: Dictionary, random_y: bool = false) -> void:
	var view: Vector2 = _viewport_size()
	var label: Label = data["node"] as Label
	var next_y: float = randf_range(0.0, view.y) if random_y else view.y + randf_range(20.0, 100.0)
	label.position = Vector2(randf_range(20.0, view.x - 40.0), next_y)
	label.rotation = randf_range(-0.35, 0.35)


func _update_letter_particles(delta: float) -> void:
	if letter_particles.is_empty():
		return
	var view: Vector2 = _viewport_size()
	var time_sec: float = float(Time.get_ticks_msec()) * 0.001
	for data in letter_particles:
		var label: Label = data["node"] as Label
		var pos: Vector2 = label.position
		pos.y -= float(data["speed"]) * delta
		pos.x += sin(time_sec + float(data["phase"])) * float(data["drift"]) * delta
		label.position = pos
		label.rotation += delta * 0.45
		if pos.y < -80.0 or pos.x < -90.0 or pos.x > view.x + 90.0:
			_reset_letter_particle(data)


func _update_screen_shake(delta: float) -> void:
	if root_margin == null:
		return
	if shake_strength <= 0.0:
		root_margin.position = base_root_position
		return
	shake_strength = maxf(0.0, shake_strength - 36.0 * delta)
	root_margin.position = base_root_position + Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength * 0.65, shake_strength * 0.65))


func _animations_enabled() -> bool:
	return not has_node("/root/SettingsManager") or SettingsManager.animations_enabled()


# ======================================================================
# ESTILOS
# ======================================================================

func _make_panel_style(bg_color: Color, border_color: Color, radius: int = 14, border_width: int = 1) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0, 0, 0, 0.35)
	style.shadow_size = 8
	return style


func _make_button_style(bg_color: Color, border_color: Color, border_width: int = 2) -> StyleBoxFlat:
	var style: StyleBoxFlat = _make_panel_style(bg_color, border_color, 12, border_width)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _make_option_button_style(bg_color: Color, border_color: Color, border_width: int = 2) -> StyleBoxFlat:
	var style: StyleBoxFlat = _make_button_style(bg_color, border_color, border_width)
	style.set_corner_radius_all(16)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style
