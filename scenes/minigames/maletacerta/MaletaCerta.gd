extends Control
var pause_menu: MinigamePause

const DynamicQuestionBank := preload("res://scripts/core/question_bank.gd")

const BACKGROUND_PATH := Paths.BG_MALETA_CERTA
const ICON_PATH := Paths.ICON_SUITCASE
const FEEDBACK_SECONDS := 1.15
const MALA_PARTICLE_COUNT := 14

const SOLUTION_EXPLANATIONS := {
	"Diagrama ER": "Diagrama ER representa entidades, atributos e relacionamentos de um domínio.",
	"Scrum": "Scrum organiza o trabalho em ciclos curtos, com priorização e entregas incrementais.",
	"Laço de repetição": "Laços executam instruções repetidamente enquanto uma condição for verdadeira.",
	"SELECT": "SELECT é o comando usado para consultar registros em tabelas SQL.",
	"Melhorar usabilidade": "Usabilidade reduz confusão e torna a interação mais clara para o usuário.",
	"Autenticação multifator": "MFA adiciona uma segunda verificação além da senha, reduzindo acesso indevido.",
	"Normalização": "Normalização organiza tabelas para reduzir repetição e inconsistência nos dados.",
	"Gestão de mudanças": "Gestão de mudanças registra impactos quando requisitos mudam durante o projeto.",
	"Monitorar e otimizar recursos": "Monitoramento identifica gargalos e orienta ajustes de desempenho.",
	"Plano de testes": "Um plano de testes define verificações para reduzir defeitos antes da entrega.",
	"Privacidade por projeto": "Privacidade por projeto considera proteção de dados desde a concepção do sistema.",
	"Diagrama de arquitetura": "Diagrama de arquitetura mostra componentes e comunicação entre módulos.",
	"Redundância": "Redundância mantém o serviço disponível mesmo se um componente falhar.",
	"Analisar complexidade": "Análise de complexidade avalia custo de tempo e memória do algoritmo.",
	"Autenticação e autorização": "Autenticação confirma identidade; autorização define o que pode ser acessado.",
	"Acessibilidade": "Acessibilidade permite que pessoas com diferentes necessidades usem o produto.",
	"Governança e indicadores": "Governança usa indicadores para alinhar TI aos objetivos da organização.",
	"Gestão do conhecimento": "Gestão do conhecimento preserva decisões e aprendizados técnicos da equipe."
}

const ALL_CHALLENGES := {
	"facil": [
		{"problema": "O aluno precisa representar entidades, atributos e relacionamentos de um sistema acadêmico.", "opcoes": ["Diagrama ER", "Gráfico de pizza", "Mapa mental"], "correta": "Diagrama ER"},
		{"problema": "Uma turma precisa organizar tarefas curtas em ciclos de entrega.", "opcoes": ["Scrum", "Cascata sem revisão", "Improviso total"], "correta": "Scrum"},
		{"problema": "Um algoritmo precisa repetir passos enquanto uma condição for verdadeira.", "opcoes": ["Laço de repetição", "Comentário", "Imagem PNG"], "correta": "Laço de repetição"},
		{"problema": "Um sistema deve consultar registros de alunos em uma tabela.", "opcoes": ["SELECT", "DROP", "DELETE sem filtro"], "correta": "SELECT"},
		{"problema": "Um usuário está confuso com muitos botões parecidos na tela.", "opcoes": ["Melhorar usabilidade", "Aumentar ruído visual", "Remover feedback"], "correta": "Melhorar usabilidade"},
		{"problema": "Um projeto precisa proteger contas contra acesso indevido.", "opcoes": ["Autenticação multifator", "Senha compartilhada", "Desativar auditoria"], "correta": "Autenticação multifator"}
	],
	"normal": [
		{"problema": "Um banco de dados possui dados repetidos e inconsistentes em várias tabelas.", "opcoes": ["Normalização", "Duplicar mais campos", "Remover chaves"], "correta": "Normalização"},
		{"problema": "O cliente muda requisitos durante o projeto e a equipe precisa controlar impactos.", "opcoes": ["Gestão de mudanças", "Ignorar o cliente", "Fazer sem registrar"], "correta": "Gestão de mudanças"},
		{"problema": "Um sistema apresenta lentidão por excesso de processamento no servidor.", "opcoes": ["Monitorar e otimizar recursos", "Culpar o usuário", "Apagar logs"], "correta": "Monitorar e otimizar recursos"},
		{"problema": "A equipe precisa garantir que o sistema funcione antes da entrega final.", "opcoes": ["Plano de testes", "Teste só em produção", "Excluir requisitos"], "correta": "Plano de testes"},
		{"problema": "Dados pessoais serão coletados em um aplicativo acadêmico.", "opcoes": ["Privacidade por projeto", "Coletar tudo sem aviso", "Publicar dados crus"], "correta": "Privacidade por projeto"},
		{"problema": "O projeto precisa explicar como módulos se comunicam.", "opcoes": ["Diagrama de arquitetura", "Lista de compras", "Print solto"], "correta": "Diagrama de arquitetura"}
	],
	"dificil": [
		{"problema": "Uma aplicação precisa continuar disponível mesmo com falha em um servidor.", "opcoes": ["Redundância", "Servidor único", "Sem backup"], "correta": "Redundância"},
		{"problema": "Um algoritmo está correto, mas demora demais com grande volume de dados.", "opcoes": ["Analisar complexidade", "Adicionar cores", "Trocar fonte"], "correta": "Analisar complexidade"},
		{"problema": "Uma API precisa limitar acessos e proteger endpoints sensíveis.", "opcoes": ["Autenticação e autorização", "Liberar tudo", "Remover tokens"], "correta": "Autenticação e autorização"},
		{"problema": "Um produto digital precisa ser usado por pessoas com deficiência visual.", "opcoes": ["Acessibilidade", "Texto minúsculo", "Contraste baixo"], "correta": "Acessibilidade"},
		{"problema": "A organização quer saber se a TI gera valor para suas metas.", "opcoes": ["Governança e indicadores", "Comprar hardware aleatório", "Ignorar métricas"], "correta": "Governança e indicadores"},
		{"problema": "A equipe precisa preservar conhecimento técnico mesmo com saída de membros.", "opcoes": ["Gestão do conhecimento", "Guardar tudo na memória", "Não documentar"], "correta": "Gestão do conhecimento"}
	]
}

var root_margin: MarginContainer
var particles_layer: Control
var title_label: Label
var challenge_counter_label: Label
var score_label: Label
var difficulty_label: Label
var problem_label: Label
var options_box: GridContainer
var feedback_layer: Control
var feedback_title_label: Label
var feedback_body_label: Label
var feedback_continue_button: Button
var finish_layer: Control
var finish_score_label: Label

var challenges: Array = []
var option_buttons: Array[Button] = []
var mala_particles: Array = []
var current_challenge_index := 0
var correct_points := 10
var wrong_points := -12
var input_locked := false
var challenge_start_msec: int = 0
var correct_answers_count: int = 0

func _ready() -> void:
	randomize()
	_build_scene()
	pause_menu = MinigamePause.attach(self)
	_connect_score_signal()
	_prepare_challenges()
	_on_score_changed(ScoreManager.get_score())
	if has_node("/root/AudioManager"):
		AudioManager.play_music("musica_maleta_certa")
	_load_challenge(0)
	# V0.10: tutorial do Tiago ANTES da rodada; o relogio do desafio so comeca depois dele.
	input_locked = true
	await TutorialManager.play(self, "maleta_certa")
	if not is_inside_tree():
		return
	challenge_start_msec = Time.get_ticks_msec()
	input_locked = false

func _process(delta: float) -> void:
	if not _animations_enabled():
		if particles_layer != null:
			particles_layer.visible = false
		return
	if particles_layer != null:
		particles_layer.visible = true
	_update_mala_particles(delta)

func _unhandled_input(event: InputEvent) -> void:
	if input_locked or finish_layer.visible or feedback_layer.visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1, KEY_KP_1, KEY_A:
				_press_option_by_index(0)
			KEY_2, KEY_KP_2, KEY_B:
				_press_option_by_index(1)
			KEY_3, KEY_KP_3, KEY_C:
				_press_option_by_index(2)

func _build_scene() -> void:
	_clear_scene_children()

	var background_rect := TextureRect.new()
	background_rect.name = "Background"
	background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	var bg_texture = load(BACKGROUND_PATH)
	if bg_texture is Texture2D:
		background_rect.texture = bg_texture
	add_child(background_rect)

	var dimmer := ColorRect.new()
	dimmer.name = "Dimmer"
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0, 0, 0, 0.42)
	add_child(dimmer)

	particles_layer = Control.new()
	particles_layer.name = "MalaParticles"
	particles_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	particles_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(particles_layer)
	_create_mala_particles()

	root_margin = MarginContainer.new()
	root_margin.name = "SafeArea"
	root_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 46)
	root_margin.add_theme_constant_override("margin_top", 32)
	root_margin.add_theme_constant_override("margin_right", 46)
	root_margin.add_theme_constant_override("margin_bottom", 32)
	add_child(root_margin)

	var main_box := VBoxContainer.new()
	main_box.name = "MainLayout"
	main_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_box.alignment = BoxContainer.ALIGNMENT_CENTER
	main_box.add_theme_constant_override("separation", 16)
	root_margin.add_child(main_box)

	var top_row := HBoxContainer.new()
	top_row.name = "TopRow"
	top_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.alignment = BoxContainer.ALIGNMENT_CENTER
	top_row.add_theme_constant_override("separation", 16)
	main_box.add_child(top_row)

	top_row.add_child(_create_mala_icon(Vector2(72, 72)))

	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "QUAL É A MALETA CERTA?"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 48)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.16))
	title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.82))
	title_label.add_theme_constant_override("shadow_offset_x", 3)
	title_label.add_theme_constant_override("shadow_offset_y", 3)
	top_row.add_child(title_label)

	top_row.add_child(_create_mala_icon(Vector2(72, 72)))

	var status_row := HBoxContainer.new()
	status_row.name = "StatusRow"
	status_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_row.alignment = BoxContainer.ALIGNMENT_CENTER
	status_row.add_theme_constant_override("separation", 14)
	main_box.add_child(status_row)

	challenge_counter_label = _create_chip_label("DESAFIO 1/6", 18, Color(0.95, 0.64, 0.12), Color(0.08, 0.06, 0.02))
	status_row.add_child(challenge_counter_label)

	score_label = _create_chip_label("Pontuação: 0", 18, Color(0.04, 0.08, 0.17, 0.94), Color(1, 1, 1))
	status_row.add_child(score_label)

	difficulty_label = _create_chip_label("Dificuldade: Normal", 18, Color(0.04, 0.08, 0.17, 0.94), Color(1, 1, 1))
	status_row.add_child(difficulty_label)

	var problem_panel := PanelContainer.new()
	problem_panel.name = "ProblemPanel"
	problem_panel.custom_minimum_size = Vector2(820, 160)
	problem_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	problem_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.04, 0.08, 0.17, 0.86), Color(0.31, 0.86, 1.0), 18, 2))
	main_box.add_child(problem_panel)

	var problem_margin := MarginContainer.new()
	problem_margin.name = "ProblemMargin"
	problem_margin.add_theme_constant_override("margin_left", 30)
	problem_margin.add_theme_constant_override("margin_top", 24)
	problem_margin.add_theme_constant_override("margin_right", 30)
	problem_margin.add_theme_constant_override("margin_bottom", 24)
	problem_panel.add_child(problem_margin)

	var problem_box := VBoxContainer.new()
	problem_box.alignment = BoxContainer.ALIGNMENT_CENTER
	problem_box.add_theme_constant_override("separation", 8)
	problem_margin.add_child(problem_box)

	var badge := Label.new()
	badge.text = "PROBLEMA"
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.custom_minimum_size = Vector2(160, 32)
	badge.add_theme_font_size_override("font_size", 18)
	badge.add_theme_color_override("font_color", Color(0.04, 0.08, 0.17))
	badge.add_theme_stylebox_override("normal", _make_panel_style(Color(0.31, 0.86, 1.0), Color(0.85, 1.0, 1.0), 9, 1))
	problem_box.add_child(badge)

	problem_label = Label.new()
	problem_label.name = "ProblemText"
	problem_label.text = ""
	problem_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	problem_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	problem_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	problem_label.add_theme_font_size_override("font_size", 27)
	problem_label.add_theme_color_override("font_color", Color(1, 1, 1))
	problem_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	problem_box.add_child(problem_label)

	options_box = GridContainer.new()
	options_box.name = "OptionsBox"
	options_box.columns = 3
	options_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	options_box.add_theme_constant_override("h_separation", 22)
	options_box.add_theme_constant_override("v_separation", 14)
	main_box.add_child(options_box)

	var hint_label := Label.new()
	hint_label.text = "Escolha a maleta com a solução correta. Atalhos: 1, 2, 3 ou A, B, C."
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 17)
	hint_label.add_theme_color_override("font_color", Color(0.86, 0.92, 1.0, 0.92))
	main_box.add_child(hint_label)


	_build_feedback_layer()
	_build_finish_layer()

func _clear_scene_children() -> void:
	for child in get_children():
		child.queue_free()

func _create_mala_icon(min_size: Vector2) -> TextureRect:
	var icon := TextureRect.new()
	icon.custom_minimum_size = min_size
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var texture = load(ICON_PATH)
	if texture is Texture2D:
		icon.texture = texture
	return icon

func _create_chip_label(text_value: String, font_size: int, bg_color: Color, text_color: Color) -> Label:
	var label := Label.new()
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(220, 38)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", text_color)
	label.add_theme_stylebox_override("normal", _make_panel_style(bg_color, Color(1, 1, 1, 0.18), 12, 1))
	return label

func _build_feedback_layer() -> void:
	feedback_layer = Control.new()
	feedback_layer.name = "FeedbackLayer"
	feedback_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	feedback_layer.visible = false
	feedback_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(feedback_layer)

	var overlay := ColorRect.new()
	overlay.name = "Overlay"
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.70)
	feedback_layer.add_child(overlay)

	var center := CenterContainer.new()
	center.name = "FeedbackCenter"
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	feedback_layer.add_child(center)

	var panel := PanelContainer.new()
	panel.name = "FeedbackPanel"
	panel.custom_minimum_size = Vector2(720, 330)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.07, 0.12, 0.98), Color(0.31, 0.86, 1.0), 22, 3))
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_bottom", 30)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 18)
	margin.add_child(box)

	feedback_title_label = Label.new()
	feedback_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_title_label.add_theme_font_size_override("font_size", 44)
	box.add_child(feedback_title_label)

	feedback_body_label = Label.new()
	feedback_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	feedback_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_body_label.add_theme_font_size_override("font_size", 22)
	feedback_body_label.add_theme_color_override("font_color", Color(0.92, 0.94, 1.0))
	box.add_child(feedback_body_label)
	_create_feedback_continue_button(box)

func _create_feedback_continue_button(parent: VBoxContainer) -> void:
	feedback_continue_button = Button.new()
	feedback_continue_button.text = "Continuar"
	feedback_continue_button.custom_minimum_size = Vector2(260, 48)
	feedback_continue_button.focus_mode = Control.FOCUS_ALL
	feedback_continue_button.add_theme_font_size_override("font_size", 20)
	feedback_continue_button.add_theme_stylebox_override("normal", _make_button_style(Color(0.06, 0.16, 0.24, 0.96), Color(0.34, 0.90, 1.0), 2))
	feedback_continue_button.add_theme_stylebox_override("hover", _make_button_style(Color(0.10, 0.28, 0.38, 0.98), Color(0.70, 1.0, 1.0), 2))
	feedback_continue_button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.03, 0.10, 0.16, 1.0), Color(0.34, 0.90, 1.0), 2))
	parent.add_child(feedback_continue_button)

func _wait_for_feedback_continue() -> void:
	if feedback_continue_button == null:
		await get_tree().process_frame
		return
	feedback_continue_button.disabled = false
	feedback_continue_button.call_deferred("grab_focus")
	await feedback_continue_button.pressed

func _build_finish_layer() -> void:
	finish_layer = Control.new()
	finish_layer.name = "FinishLayer"
	finish_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	finish_layer.visible = false
	finish_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(finish_layer)

	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.78)
	finish_layer.add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	finish_layer.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(700, 330)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.07, 0.12, 0.98), Color(1.0, 0.74, 0.12), 22, 3))
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_bottom", 30)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 18)
	margin.add_child(box)

	var title := Label.new()
	title.text = "Desafio Completo!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 46)
	title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.0))
	box.add_child(title)

	finish_score_label = Label.new()
	finish_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	finish_score_label.add_theme_font_size_override("font_size", 26)
	finish_score_label.add_theme_color_override("font_color", Color(1, 1, 1))
	box.add_child(finish_score_label)

	var continue_button := Button.new()
	continue_button.text = "Continuar"
	continue_button.custom_minimum_size = Vector2(260, 58)
	continue_button.add_theme_font_size_override("font_size", 22)
	continue_button.pressed.connect(_on_finish_continue_pressed)
	box.add_child(continue_button)

func _connect_score_signal() -> void:
	var callable := Callable(self, "_on_score_changed")
	if not ScoreManager.score_changed.is_connected(callable):
		ScoreManager.score_changed.connect(callable)

func _prepare_challenges() -> void:
	correct_answers_count = 0
	var rules := DifficultyManager.get_rules()
	var challenge_type := str(rules.get("pergunta_tipo", "normal"))
	challenges = DynamicQuestionBank.pick_rounds("maleta_certa", challenge_type, 6)
	if challenges.is_empty():
		challenges = ALL_CHALLENGES.get(challenge_type, ALL_CHALLENGES["normal"]).duplicate(true)
		challenges.shuffle()

	correct_points = DifficultyManager.get_correct_points("maleta_certa")
	wrong_points = DifficultyManager.get_wrong_points("maleta_certa")
	if difficulty_label != null:
		difficulty_label.text = "Dificuldade: %s" % DifficultyManager.get_label()
		DifficultyManager.apply_difficulty_chip(difficulty_label)

func _load_challenge(index: int) -> void:
	if index >= challenges.size():
		_show_finish()
		return

	input_locked = false
	challenge_start_msec = Time.get_ticks_msec()
	current_challenge_index = index
	var current_challenge: Dictionary = challenges[current_challenge_index]
	challenge_counter_label.text = "DESAFIO %s/%s" % [current_challenge_index + 1, challenges.size()]
	problem_label.text = str(current_challenge["problema"])
	_clear_options()

	var options: Array = current_challenge["opcoes"].duplicate(true)
	options.shuffle()
	for i in range(options.size()):
		var option_text := str(options[i])
		var button := Button.new()
		button.name = "Maleta%s" % [i + 1]
		button.text = "MALETA %s\n%s" % [i + 1, option_text]
		button.custom_minimum_size = Vector2(260, 132)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.clip_text = true
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_theme_font_size_override("font_size", 21)
		button.add_theme_stylebox_override("normal", _make_maleta_button_style(Color(0.06, 0.12, 0.28, 0.88), Color(0.15, 0.72, 1.0)))
		button.add_theme_stylebox_override("hover", _make_maleta_button_style(Color(0.12, 0.22, 0.42, 0.95), Color(0.65, 0.92, 1.0), 3))
		button.add_theme_stylebox_override("pressed", _make_maleta_button_style(Color(0.18, 0.30, 0.55, 0.98), Color(1.0, 1.0, 1.0), 3))
		button.add_theme_stylebox_override("disabled", _make_maleta_button_style(Color(0.05, 0.08, 0.15, 0.62), Color(0.25, 0.35, 0.48)))
		button.add_theme_color_override("font_color", Color(1, 1, 1))
		button.add_theme_color_override("font_hover_color", Color(1, 1, 1))
		button.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
		button.icon = load(ICON_PATH)
		button.expand_icon = true
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		button.set_meta("answer_text", option_text)
		button.pressed.connect(_on_option_pressed.bind(option_text, button))
		options_box.add_child(button)
		option_buttons.append(button)

func _clear_options() -> void:
	for child in options_box.get_children():
		child.queue_free()
	option_buttons.clear()

func _on_option_pressed(selected_text: String, selected_button: Button) -> void:
	if input_locked:
		return
	input_locked = true
	for button in option_buttons:
		button.disabled = true

	var current_challenge: Dictionary = challenges[current_challenge_index]
	var correct_text := str(current_challenge["correta"])
	var is_correct := selected_text == correct_text
	var elapsed_seconds: float = float(Time.get_ticks_msec() - challenge_start_msec) / 1000.0
	var awarded_points: int = correct_points
	if is_correct:
		awarded_points = DifficultyManager.get_time_adjusted_points(correct_points, elapsed_seconds)

	_highlight_answer(selected_button, correct_text, is_correct)
	_spawn_mala_burst(selected_button.get_global_rect().get_center(), is_correct)

	if is_correct:
		correct_answers_count += 1
		ScoreManager.add_points(awarded_points)
		if has_node("/root/AudioManager"):
			AudioManager.play_sfx("correto")
	else:
		ScoreManager.subtract_points(abs(wrong_points), true)
		if has_node("/root/AudioManager"):
			AudioManager.play_sfx("errado")
		_start_screen_shake()

	await _show_feedback(is_correct, selected_text, correct_text, elapsed_seconds, awarded_points)
	if not is_inside_tree():
		return
	feedback_layer.visible = false
	_load_challenge(current_challenge_index + 1)

func _highlight_answer(selected_button: Button, correct_text: String, is_correct: bool) -> void:
	for button in option_buttons:
		var answer := str(button.get_meta("answer_text"))
		if answer == correct_text:
			button.add_theme_stylebox_override("disabled", _make_maleta_button_style(Color(0.0, 0.46, 0.16, 0.96), Color(0.62, 1.0, 0.65), 3))
		elif button == selected_button and not is_correct:
			button.add_theme_stylebox_override("disabled", _make_maleta_button_style(Color(0.54, 0.02, 0.02, 0.96), Color(1.0, 0.55, 0.55), 3))

func _show_feedback(is_correct: bool, selected_text: String, correct_text: String, _elapsed_seconds: float, awarded_points: int) -> void:
	var current_challenge: Dictionary = challenges[current_challenge_index]
	var explanation: String = _clean_feedback_explanation(correct_text, str(current_challenge.get("explanation", _get_solution_explanation(correct_text))))
	feedback_title_label.text = "MALETA CERTA!" if is_correct else "MALETA ERRADA!"
	feedback_title_label.add_theme_color_override("font_color", Color(0.42, 1.0, 0.48) if is_correct else Color(1.0, 0.26, 0.22))
	if is_correct:
		feedback_body_label.text = "Resposta correta: %s\n%s\nPontuação adquirida: +%s" % [correct_text, explanation, awarded_points]
	else:
		feedback_body_label.text = "Você escolheu: %s\nEssa opção não resolve bem o cenário apresentado.\n\nSolução correta: %s\n%s\nPontuação perdida: %s" % [selected_text, correct_text, explanation, wrong_points]
	feedback_layer.visible = true
	await _wait_for_feedback_continue()

func _clean_feedback_explanation(answer_text: String, explanation_text: String) -> String:
	var answer := answer_text.strip_edges()
	var explanation := explanation_text.strip_edges()
	if explanation == "" or explanation.to_lower() == answer.to_lower():
		return "%s é a solução que melhor atende ao problema apresentado." % answer
	return explanation

func _get_solution_explanation(correct_text: String) -> String:
	return str(SOLUTION_EXPLANATIONS.get(correct_text, "%s é a solução que melhor atende ao problema apresentado." % correct_text))

func _show_finish() -> void:
	input_locked = true
	if has_node("/root/AchievementManager") and correct_answers_count >= challenges.size():
		AchievementManager.unlock("decisao_risco")
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("correto")
	finish_score_label.text = "Pontuação atual: %s pontos" % ScoreManager.get_score()
	finish_layer.visible = true

func _on_finish_continue_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	GameManager.complete_current_stage(0)


func _press_option_by_index(index: int) -> void:
	if index < 0 or index >= option_buttons.size():
		return
	var button: Button = option_buttons[index]
	if button.disabled:
		return
	_on_option_pressed(str(button.get_meta("answer_text")), button)

func _on_score_changed(new_score: int) -> void:
	if score_label != null:
		score_label.text = "Pontuação: %s" % new_score

func _create_mala_particles() -> void:
	mala_particles.clear()
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0 or viewport_size.y <= 0:
		viewport_size = Vector2(1280, 720)
	var texture = load(ICON_PATH)
	for i in range(MALA_PARTICLE_COUNT):
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(randf_range(26, 44), randf_range(26, 44))
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if texture is Texture2D:
			icon.texture = texture
		icon.modulate = Color(1, 1, 1, randf_range(0.16, 0.34))
		icon.position = Vector2(randf_range(0, viewport_size.x), randf_range(0, viewport_size.y))
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		particles_layer.add_child(icon)
		mala_particles.append({
			"node": icon,
			"speed": randf_range(18.0, 52.0),
			"drift": randf_range(-16.0, 16.0),
			"phase": randf_range(0.0, TAU)
		})

func _update_mala_particles(delta: float) -> void:
	if mala_particles.is_empty():
		return
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0 or viewport_size.y <= 0:
		return
	for particle in mala_particles:
		var icon: TextureRect = particle["node"]
		var pos := icon.position
		pos.y += float(particle["speed"]) * delta
		pos.x += sin(Time.get_ticks_msec() * 0.001 + float(particle["phase"])) * float(particle["drift"]) * delta
		if pos.y > viewport_size.y + 80:
			pos.y = randf_range(-150, -40)
			pos.x = randf_range(0, viewport_size.x)
		icon.position = pos

func _spawn_mala_burst(center: Vector2, is_correct: bool) -> void:
	if not _animations_enabled():
		return
	var color := Color(1.0, 0.80, 0.12) if is_correct else Color(1.0, 0.24, 0.20)
	for i in range(12):
		var label: TextureRect = UiIcons.make_rect("check" if is_correct else "close", float(randi_range(26, 44)), color)
		label.position = center
		add_child(label)
		var target := center + Vector2(randf_range(-120, 120), randf_range(-100, 85))
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(label, "position", target, 0.46).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(label, "modulate:a", 0.0, 0.46)
		tween.finished.connect(label.queue_free)

func _start_screen_shake() -> void:
	if not _animations_enabled():
		return
	var original_position := root_margin.position
	var tween := create_tween()
	for i in range(8):
		var offset := Vector2(randf_range(-9, 9), randf_range(-7, 7))
		tween.tween_property(root_margin, "position", original_position + offset, 0.035)
	tween.tween_property(root_margin, "position", original_position, 0.05)

func _animations_enabled() -> bool:
	return not has_node("/root/SettingsManager") or SettingsManager.animations_enabled()

func _make_panel_style(bg_color: Color, border_color: Color, radius: int = 14, border_width: int = 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
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

func _make_button_style(bg_color: Color, border_color: Color, border_width: int = 2) -> StyleBoxFlat:
	var style := _make_panel_style(bg_color, border_color, 12, border_width)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func _make_maleta_button_style(bg_color: Color, border_color: Color, border_width: int = 2) -> StyleBoxFlat:
	var style := _make_button_style(bg_color, border_color, border_width)
	style.set_corner_radius_all(16)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style
