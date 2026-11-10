extends Control
var pause_menu: MinigamePause

const DynamicQuestionBank := preload("res://scripts/core/question_bank.gd")

const BACKGROUND_PATH := Paths.BG_SHOW_DO_BILHAO
const ICON_PATH := Paths.ICON_MONEY
const FEEDBACK_SECONDS := 2.5
const MONEY_PARTICLE_COUNT := 26

const ALL_QUESTIONS := {
	"facil": [
		{
			"pergunta": "Qual estrutura de dados segue o princípio LIFO, em que o último elemento a entrar é o primeiro a sair?",
			"opcoes": {"A": "Fila", "B": "Pilha", "C": "Tabela", "D": "Grafo"},
			"resposta": "B",
			"motivos": {"B": "Pilha usa o princípio Last In, First Out: o último item inserido é o primeiro removido."}
		},
		{
			"pergunta": "Qual comando SQL é usado para consultar dados em uma tabela?",
			"opcoes": {"A": "SELECT", "B": "DELETE", "C": "DROP", "D": "CREATE"},
			"resposta": "A",
			"motivos": {"A": "SELECT recupera registros de uma ou mais tabelas em um banco de dados."}
		},
		{
			"pergunta": "Em engenharia de software, qual artefato ajuda a representar atores e funcionalidades esperadas pelo usuário?",
			"opcoes": {"A": "Diagrama de Casos de Uso", "B": "Planilha de custos", "C": "Mapa de calor", "D": "Ata de reunião"},
			"resposta": "A",
			"motivos": {"A": "Casos de uso representam interações entre atores e funcionalidades do sistema."}
		},
		{
			"pergunta": "Qual protocolo é usado para acessar páginas web de forma segura?",
			"opcoes": {"A": "FTP", "B": "HTTP", "C": "HTTPS", "D": "SMTP"},
			"resposta": "C",
			"motivos": {"C": "HTTPS usa criptografia para proteger a comunicação entre navegador e servidor."}
		},
		{
			"pergunta": "Qual prática ajuda a proteger contas contra roubo de senha?",
			"opcoes": {"A": "Autenticação multifator", "B": "Senha compartilhada", "C": "Desativar logs", "D": "Usar a mesma senha"},
			"resposta": "A",
			"motivos": {"A": "A autenticação multifator exige mais de uma evidência de identidade, aumentando a segurança."}
		},
		{
			"pergunta": "Na IHC, o que significa usabilidade?",
			"opcoes": {"A": "Facilidade de uso e eficiência da interação", "B": "Quantidade de código", "C": "Preço do software", "D": "Velocidade da internet"},
			"resposta": "A",
			"motivos": {"A": "Usabilidade mede o quanto um sistema é fácil, eficiente e satisfatório para o usuário."}
		}
	],
	"normal": [
		{
			"pergunta": "Qual técnica divide um problema em partes menores para facilitar sua solução em algoritmos?",
			"opcoes": {"A": "Normalização", "B": "Decomposição", "C": "Criptografia", "D": "Virtualização"},
			"resposta": "B",
			"motivos": {"B": "Decompor um problema permite resolver partes menores e combinar as soluções."}
		},
		{
			"pergunta": "Em banco de dados relacional, qual chave identifica de forma única cada registro de uma tabela?",
			"opcoes": {"A": "Chave estrangeira", "B": "Chave primária", "C": "Chave pública", "D": "Chave de rede"},
			"resposta": "B",
			"motivos": {"B": "A chave primária identifica unicamente cada linha de uma tabela."}
		},
		{
			"pergunta": "Qual prática reduz o risco de entregar software com defeitos recorrentes?",
			"opcoes": {"A": "Testes e validação contínua", "B": "Ignorar requisitos", "C": "Testar só em produção", "D": "Remover documentação"},
			"resposta": "A",
			"motivos": {"A": "Testes ajudam a encontrar falhas cedo e aumentam a confiabilidade do software."}
		},
		{
			"pergunta": "Qual componente do computador executa instruções e realiza operações lógicas e aritméticas?",
			"opcoes": {"A": "CPU", "B": "Monitor", "C": "Switch", "D": "HD externo"},
			"resposta": "A",
			"motivos": {"A": "A CPU é o processador responsável por executar instruções e operações do sistema."}
		},
		{
			"pergunta": "O que a governança de TI busca alinhar?",
			"opcoes": {"A": "Tecnologia e objetivos organizacionais", "B": "Cores do layout", "C": "Somente hardware", "D": "Apenas redes sociais"},
			"resposta": "A",
			"motivos": {"A": "Governança orienta tecnologia, processos e decisões para gerar valor ao negócio e à sociedade."}
		},
		{
			"pergunta": "Qual preocupação se relaciona ao impacto social da tecnologia?",
			"opcoes": {"A": "Privacidade e inclusão digital", "B": "Somente lucro", "C": "Tamanho do cabo", "D": "Cor do gabinete"},
			"resposta": "A",
			"motivos": {"A": "Sistemas impactam pessoas; privacidade, acessibilidade e inclusão precisam ser consideradas."}
		}
	],
	"dificil": [
		{
			"pergunta": "Qual estrutura é mais adequada para representar relações hierárquicas, como diretórios ou árvores de decisão?",
			"opcoes": {"A": "Pilha", "B": "Fila", "C": "Árvore", "D": "Vetor simples"},
			"resposta": "C",
			"motivos": {"C": "Árvores representam relações hierárquicas entre nós, como pastas, menus e decisões."}
		},
		{
			"pergunta": "Em SQL, qual cláusula normalmente filtra registros em uma consulta?",
			"opcoes": {"A": "WHERE", "B": "TABLE", "C": "DATABASE", "D": "INDEX"},
			"resposta": "A",
			"motivos": {"A": "WHERE define condições para selecionar apenas os registros desejados."}
		},
		{
			"pergunta": "Qual princípio de projeto orientado a objetos favorece esconder detalhes internos e expor apenas o necessário?",
			"opcoes": {"A": "Encapsulamento", "B": "Fragmentação", "C": "Redundância", "D": "Latência"},
			"resposta": "A",
			"motivos": {"A": "Encapsulamento protege o estado interno e oferece uma interface controlada de acesso."}
		},
		{
			"pergunta": "Em redes, qual equipamento costuma encaminhar pacotes entre redes diferentes?",
			"opcoes": {"A": "Roteador", "B": "Teclado", "C": "Hub USB", "D": "Impressora"},
			"resposta": "A",
			"motivos": {"A": "Roteadores conectam redes distintas e encaminham pacotes até seus destinos."}
		},
		{
			"pergunta": "Qual conceito representa a capacidade de um sistema continuar funcionando mesmo diante de falhas?",
			"opcoes": {"A": "Tolerância a falhas", "B": "Obsolescência", "C": "Polimorfismo visual", "D": "Fragmentação de tela"},
			"resposta": "A",
			"motivos": {"A": "Tolerância a falhas usa redundância e recuperação para manter serviços disponíveis."}
		},
		{
			"pergunta": "Qual abordagem ajuda a avaliar se uma interface atende pessoas com diferentes limitações e contextos?",
			"opcoes": {"A": "Acessibilidade", "B": "Overclock", "C": "Desnormalização total", "D": "Ping"},
			"resposta": "A",
			"motivos": {"A": "Acessibilidade busca tornar sistemas utilizáveis por pessoas com diferentes necessidades."}
		}
	]
}

var questions: Array = []
var current_question_index: int = 0
var correct_points: int = 10
var wrong_points: int = -12
var input_locked: bool = false
var question_start_msec: int = 0
var correct_answers_count: int = 0
var option_buttons: Array = []
var money_particles: Array = []

var background_rect: TextureRect
var dimmer: ColorRect
var particles_layer: Control
var root_margin: MarginContainer
var question_counter_label: Label
var title_label: Label
var score_label: Label
var difficulty_label: Label
var question_panel: PanelContainer
var question_text_label: Label
var options_box: VBoxContainer
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
	ScoreManager.score_changed.emit(ScoreManager.get_score())
	if has_node("/root/AudioManager"):
		AudioManager.play_music("musica_show_do_bilhao")
	_load_question(0)
	# V0.10: tutorial da Priscila ANTES da rodada valer; o relogio de resposta so comeca depois dele.
	input_locked = true
	await TutorialManager.play(self, "show_do_bilhao")
	if not is_inside_tree():
		return
	question_start_msec = Time.get_ticks_msec()
	input_locked = false

func _process(delta: float) -> void:
	if not _animations_enabled():
		if particles_layer != null:
			particles_layer.visible = false
		return
	if particles_layer != null:
		particles_layer.visible = true
	_update_money_particles(delta)

func _unhandled_input(event: InputEvent) -> void:
	if input_locked:
		return
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		match key_event.keycode:
			KEY_A:
				_press_option_by_index(0)
			KEY_B:
				_press_option_by_index(1)
			KEY_C:
				_press_option_by_index(2)
			KEY_D:
				_press_option_by_index(3)

func _build_scene() -> void:
	background_rect = TextureRect.new()
	background_rect.name = "Background"
	background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_rect.expand_mode = 1
	background_rect.stretch_mode = 6
	var bg_texture = load(BACKGROUND_PATH)
	if bg_texture is Texture2D:
		background_rect.texture = bg_texture
	add_child(background_rect)

	dimmer = ColorRect.new()
	dimmer.name = "Dimmer"
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0, 0, 0, 0.48)
	add_child(dimmer)

	particles_layer = Control.new()
	particles_layer.name = "MoneyParticles"
	particles_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	particles_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(particles_layer)
	_create_money_particles()

	root_margin = MarginContainer.new()
	root_margin.name = "SafeArea"
	root_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 46)
	root_margin.add_theme_constant_override("margin_top", 34)
	root_margin.add_theme_constant_override("margin_right", 46)
	root_margin.add_theme_constant_override("margin_bottom", 34)
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
	top_row.add_theme_constant_override("separation", 18)
	main_box.add_child(top_row)

	var left_icon := _create_money_icon()
	top_row.add_child(left_icon)

	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "SHOW DO BILHÃO"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 54)
	title_label.add_theme_color_override("font_color", Color(1, 1, 1))
	title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	title_label.add_theme_constant_override("shadow_offset_x", 3)
	title_label.add_theme_constant_override("shadow_offset_y", 3)
	top_row.add_child(title_label)

	var right_icon := _create_money_icon()
	top_row.add_child(right_icon)

	var status_row := HBoxContainer.new()
	status_row.name = "StatusRow"
	status_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_row.alignment = BoxContainer.ALIGNMENT_CENTER
	status_row.add_theme_constant_override("separation", 14)
	main_box.add_child(status_row)

	question_counter_label = _create_chip_label("PERGUNTA 1/6", 18, Color(1.0, 0.82, 0.0), Color(0.05, 0.05, 0.05))
	status_row.add_child(question_counter_label)

	score_label = _create_chip_label("Pontuação: 0", 18, Color(0.05, 0.1, 0.18, 0.92), Color(1, 1, 1))
	status_row.add_child(score_label)

	difficulty_label = _create_chip_label("Dificuldade: Normal", 18, Color(0.05, 0.1, 0.18, 0.92), Color(1, 1, 1))
	status_row.add_child(difficulty_label)

	question_panel = PanelContainer.new()
	question_panel.name = "QuestionPanel"
	question_panel.custom_minimum_size = Vector2(780, 150)
	question_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	question_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.04, 0.06, 0.12, 0.84), Color(1.0, 0.82, 0.0), 18, 2))
	main_box.add_child(question_panel)

	var question_margin := MarginContainer.new()
	question_margin.name = "QuestionMargin"
	question_margin.add_theme_constant_override("margin_left", 28)
	question_margin.add_theme_constant_override("margin_top", 24)
	question_margin.add_theme_constant_override("margin_right", 28)
	question_margin.add_theme_constant_override("margin_bottom", 24)
	question_panel.add_child(question_margin)

	question_text_label = Label.new()
	question_text_label.name = "QuestionText"
	question_text_label.text = ""
	question_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	question_text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	question_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	question_text_label.add_theme_font_size_override("font_size", 28)
	question_text_label.add_theme_color_override("font_color", Color(1, 1, 1))
	question_margin.add_child(question_text_label)

	options_box = VBoxContainer.new()
	options_box.name = "OptionsBox"
	options_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	options_box.add_theme_constant_override("separation", 12)
	main_box.add_child(options_box)


	_build_feedback_layer()
	_build_finish_layer()

func _create_money_icon() -> TextureRect:
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(70, 70)
	icon.expand_mode = 1
	icon.stretch_mode = 5
	var texture = load(ICON_PATH)
	if texture is Texture2D:
		icon.texture = texture
	return icon

func _create_chip_label(text_value: String, font_size: int, bg_color: Color, text_color: Color) -> Label:
	var label := Label.new()
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(210, 38)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", text_color)
	label.add_theme_stylebox_override("normal", _make_panel_style(bg_color, Color(1, 1, 1, 0.16), 12, 1))
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
	overlay.color = Color(0, 0, 0, 0.74)
	feedback_layer.add_child(overlay)

	var center := CenterContainer.new()
	center.name = "FeedbackCenter"
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	feedback_layer.add_child(center)

	var panel := PanelContainer.new()
	panel.name = "FeedbackPanel"
	panel.custom_minimum_size = Vector2(760, 330)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.06, 0.07, 0.12, 0.97), Color(1.0, 0.82, 0.0), 22, 3))
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
	feedback_title_label.add_theme_font_size_override("font_size", 46)
	box.add_child(feedback_title_label)

	feedback_body_label = Label.new()
	feedback_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	feedback_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_body_label.add_theme_font_size_override("font_size", 22)
	feedback_body_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
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
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.08, 0.14, 0.97), Color(1.0, 0.82, 0.0), 22, 3))
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
	title.text = "Fim do Show!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
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

func _prepare_questions() -> void:
	var rules := DifficultyManager.get_rules()
	var question_type := str(rules.get("pergunta_tipo", "normal"))
	var raw_questions: Array = DynamicQuestionBank.pick_rounds("show_do_bilhao", question_type, 6)
	if raw_questions.is_empty():
		raw_questions = ALL_QUESTIONS.get(question_type, ALL_QUESTIONS["normal"]).duplicate(true)
		raw_questions.shuffle()

	questions.clear()
	correct_answers_count = 0
	for raw_question in raw_questions:
		var option_values: Array = raw_question["opcoes"].values()
		option_values.shuffle()
		var correct_key := str(raw_question["resposta"])
		var correct_text := str(raw_question["opcoes"][correct_key])
		var correct_reason := str(raw_question["motivos"].get(correct_key, raw_question.get("explanation", "Resposta correta.")))
		questions.append({
			"pergunta": str(raw_question["pergunta"]),
			"opcoes_embaralhadas": option_values,
			"texto_correto": correct_text,
			"motivo_correto": correct_reason,
			"topic": str(raw_question.get("topic", "Geral"))
		})

	correct_points = DifficultyManager.get_correct_points("show_do_bilhao")
	wrong_points = DifficultyManager.get_wrong_points("show_do_bilhao")
	if difficulty_label != null:
		difficulty_label.text = "Dificuldade: %s" % DifficultyManager.get_label()
		DifficultyManager.apply_difficulty_chip(difficulty_label)

func _load_question(index: int) -> void:
	if index >= questions.size():
		_show_finish()
		return

	input_locked = false
	question_start_msec = Time.get_ticks_msec()
	current_question_index = index
	var current_question: Dictionary = questions[current_question_index]

	question_counter_label.text = "PERGUNTA %s/%s" % [current_question_index + 1, questions.size()]
	question_text_label.text = str(current_question["pergunta"])
	_clear_options()

	var letters := ["A", "B", "C", "D"]
	var options: Array = current_question["opcoes_embaralhadas"]
	for i in range(options.size()):
		var option_text := str(options[i])
		var button := Button.new()
		button.name = "Option%s" % letters[i]
		button.text = "%s. %s" % [letters[i], option_text]
		button.custom_minimum_size = Vector2(720, 62)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.clip_text = true
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_theme_font_size_override("font_size", 22)
		button.add_theme_stylebox_override("normal", _make_button_style(Color(0.08, 0.1, 0.22, 0.86), Color(0.45, 0.45, 0.65)))
		button.add_theme_stylebox_override("hover", _make_button_style(Color(1.0, 0.82, 0.0, 0.24), Color(1.0, 0.9, 0.25), 3))
		button.add_theme_stylebox_override("pressed", _make_button_style(Color(1.0, 0.82, 0.0, 0.33), Color(1.0, 1.0, 1.0), 3))
		button.add_theme_stylebox_override("disabled", _make_button_style(Color(0.08, 0.1, 0.22, 0.56), Color(0.25, 0.25, 0.38)))
		button.add_theme_color_override("font_color", Color(1, 1, 1))
		button.add_theme_color_override("font_hover_color", Color(1, 1, 1))
		button.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
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

	var current_question: Dictionary = questions[current_question_index]
	var correct_text := str(current_question["texto_correto"])
	var correct_reason := str(current_question["motivo_correto"])
	var is_correct := selected_text == correct_text
	var elapsed_seconds: float = float(Time.get_ticks_msec() - question_start_msec) / 1000.0
	var awarded_points: int = correct_points
	if is_correct:
		awarded_points = DifficultyManager.get_time_adjusted_points(correct_points, elapsed_seconds)

	_highlight_answer(selected_button, correct_text, is_correct)
	_spawn_coin_burst(selected_button.get_global_rect().get_center())

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

	await _show_feedback(is_correct, selected_text, correct_text, correct_reason, elapsed_seconds, awarded_points)
	if not is_inside_tree():
		return
	feedback_layer.visible = false
	_load_question(current_question_index + 1)

func _highlight_answer(selected_button: Button, correct_text: String, is_correct: bool) -> void:
	for button in option_buttons:
		var answer := str(button.get_meta("answer_text"))
		if answer == correct_text:
			button.add_theme_stylebox_override("disabled", _make_button_style(Color(0.0, 0.48, 0.16, 0.94), Color(0.6, 1.0, 0.62), 3))
		elif button == selected_button and not is_correct:
			button.add_theme_stylebox_override("disabled", _make_button_style(Color(0.55, 0.0, 0.0, 0.94), Color(1.0, 0.55, 0.55), 3))

func _show_feedback(is_correct: bool, selected_text: String, correct_text: String, correct_reason: String, elapsed_seconds: float, awarded_points: int) -> void:
	feedback_title_label.text = "RESPOSTA CORRETA!" if is_correct else "RESPOSTA INCORRETA"
	feedback_title_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.45) if is_correct else Color(1.0, 0.25, 0.25))
	var explanation: String = _clean_feedback_explanation(correct_text, correct_reason)
	if is_correct:
		feedback_body_label.text = "Você marcou: %s\n\n%s\nPontuação adquirida: +%s" % [correct_text, explanation, awarded_points]
	else:
		feedback_body_label.text = "Você escolheu: %s\nEssa opção não responde corretamente ao conceito pedido.\n\nResposta correta: %s\n%s\nPontuação perdida: %s" % [selected_text, correct_text, explanation, wrong_points]
	feedback_layer.visible = true
	await _wait_for_feedback_continue()

func _clean_feedback_explanation(answer_text: String, explanation_text: String) -> String:
	var answer := answer_text.strip_edges()
	var explanation := explanation_text.strip_edges()
	if explanation == "" or explanation.to_lower() == answer.to_lower():
		return "%s é o conceito correto para a situação apresentada." % answer
	return explanation

func _show_finish() -> void:
	input_locked = true
	if has_node("/root/AchievementManager") and correct_answers_count >= questions.size():
		AchievementManager.unlock("mente_milionaria")
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("correto")
	finish_score_label.text = "Saldo Final: %s pontos" % ScoreManager.get_score()
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

func _create_money_particles() -> void:
	money_particles.clear()
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0 or viewport_size.y <= 0:
		viewport_size = Vector2(1280, 720)
	for i in range(MONEY_PARTICLE_COUNT):
		var label := Label.new()
		label.text = "$"
		label.add_theme_font_size_override("font_size", randi_range(24, 54))
		label.add_theme_color_override("font_color", [Color(1.0, 0.84, 0.0, 0.42), Color(0.0, 1.0, 0.35, 0.32), Color(0.6, 0.9, 1.0, 0.28)].pick_random())
		label.position = Vector2(randf_range(0, viewport_size.x), randf_range(0, viewport_size.y))
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		particles_layer.add_child(label)
		money_particles.append({
			"node": label,
			"speed": randf_range(18.0, 70.0),
			"drift": randf_range(-18.0, 18.0),
			"phase": randf_range(0.0, TAU)
		})

func _update_money_particles(delta: float) -> void:
	if money_particles.is_empty():
		return
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0 or viewport_size.y <= 0:
		return
	for particle in money_particles:
		var label: Label = particle["node"]
		var pos := label.position
		pos.y -= float(particle["speed"]) * delta
		pos.x += sin(Time.get_ticks_msec() * 0.001 + float(particle["phase"])) * float(particle["drift"]) * delta
		if pos.y < -70:
			pos.y = viewport_size.y + randf_range(20, 140)
			pos.x = randf_range(0, viewport_size.x)
		label.position = pos

func _spawn_coin_burst(center: Vector2) -> void:
	if not _animations_enabled():
		return
	for i in range(16):
		var label := Label.new()
		label.text = "$"
		label.position = center
		label.add_theme_font_size_override("font_size", randi_range(22, 38))
		label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(label)
		var target := center + Vector2(randf_range(-120, 120), randf_range(-120, 80))
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(label, "position", target, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(label, "modulate:a", 0.0, 0.45)
		tween.finished.connect(label.queue_free)

func _start_screen_shake() -> void:
	if not _animations_enabled():
		return
	var original_position := root_margin.position
	var tween := create_tween()
	for i in range(8):
		var offset := Vector2(randf_range(-10, 10), randf_range(-8, 8))
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
