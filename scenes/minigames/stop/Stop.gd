extends Control
var pause_menu: MinigamePause

const DynamicQuestionBank := preload("res://scripts/core/question_bank.gd")

const BACKGROUND_PATH := Paths.BG_STOP
const STOP_ICON_PATH := Paths.ICON_STOP
const FEEDBACK_SECONDS := 1.20
const ROULETTE_STEPS := 18
const LETTER_PARTICLE_COUNT := 28

const STOP_EXPLANATIONS := {
	"Pilha": "Pilha segue LIFO: o último item a entrar é o primeiro a sair.",
	"SELECT": "SELECT consulta e recupera dados armazenados em tabelas SQL.",
	"HTTPS": "HTTPS protege a comunicação web com criptografia.",
	"UML": "UML é uma linguagem visual usada para modelar sistemas.",
	"MFA": "MFA adiciona camadas extras de verificação na autenticação.",
	"Usabilidade": "Usabilidade mede facilidade, eficiência e clareza no uso da interface.",
	"Normalização": "Normalização reduz redundância e inconsistência em bancos relacionais.",
	"Roteador": "Roteador encaminha pacotes entre redes diferentes.",
	"Processo": "Processo é um programa em execução no sistema operacional.",
	"Backlog": "Backlog prioriza itens de trabalho que devem ser planejados e entregues.",
	"Cache": "Cache guarda cópias temporárias para acelerar acessos futuros.",
	"Privacidade": "Privacidade protege dados pessoais e escolhas do usuário.",
	"Complexidade": "Complexidade avalia o custo de tempo ou espaço de um algoritmo.",
	"Índice": "Índice acelera buscas em tabelas, como um atalho para localizar registros.",
	"Criptografia": "Criptografia transforma dados para impedir leitura indevida sem chave.",
	"Encapsulamento": "Encapsulamento esconde detalhes internos e expõe apenas o necessário.",
	"Escalabilidade": "Escalabilidade permite crescer sem perda crítica de desempenho.",
	"Acessibilidade": "Acessibilidade permite uso por pessoas com diferentes necessidades."
}

const ALL_QUESTIONS := {
	"facil": [
		{"categoria": "Estrutura de dados", "letra": "P", "dica": "Segue o princípio LIFO.", "opcoes": ["Pilha", "Ponte", "Pixel", "Proxy", "Pacote"], "correta": "Pilha"},
		{"categoria": "Comando SQL", "letra": "S", "dica": "Consulta dados em uma tabela.", "opcoes": ["SELECT", "SET", "SEND", "START", "SAVE"], "correta": "SELECT"},
		{"categoria": "Protocolo de rede", "letra": "H", "dica": "Versão segura usada na web.", "opcoes": ["HTTPS", "HTML", "HOST", "HUB", "HASH"], "correta": "HTTPS"},
		{"categoria": "Engenharia de software", "letra": "U", "dica": "Linguagem visual de modelagem.", "opcoes": ["UML", "URL", "USB", "UDP", "UX"], "correta": "UML"},
		{"categoria": "Segurança", "letra": "M", "dica": "Camada extra de autenticação.", "opcoes": ["MFA", "MVC", "MVP", "MP3", "MAC"], "correta": "MFA"},
		{"categoria": "IHC", "letra": "U", "dica": "Facilidade de uso de uma interface.", "opcoes": ["Usabilidade", "Upload", "Unidade", "Usuário", "Utilitário"], "correta": "Usabilidade"}
	],
	"normal": [
		{"categoria": "Banco de dados", "letra": "N", "dica": "Processo para reduzir redundância em tabelas.", "opcoes": ["Normalização", "Navegação", "Notificação", "Namespace", "Nuvem"], "correta": "Normalização"},
		{"categoria": "Redes", "letra": "R", "dica": "Encaminha pacotes entre redes diferentes.", "opcoes": ["Roteador", "Registro", "Requisito", "Render", "Runtime"], "correta": "Roteador"},
		{"categoria": "Sistemas operacionais", "letra": "P", "dica": "Programa em execução.", "opcoes": ["Processo", "Pixel", "Pilha", "Porta", "Protótipo"], "correta": "Processo"},
		{"categoria": "Gestão de projetos", "letra": "B", "dica": "Lista priorizada de itens de trabalho no Scrum.", "opcoes": ["Backlog", "Backup", "Branch", "Buffer", "Board"], "correta": "Backlog"},
		{"categoria": "Arquitetura", "letra": "C", "dica": "Sistema que armazena cópias para acesso mais rápido.", "opcoes": ["Cache", "Classe", "Cliente", "Controle", "Comando"], "correta": "Cache"},
		{"categoria": "Impacto social", "letra": "P", "dica": "Proteção de dados pessoais e escolhas do usuário.", "opcoes": ["Privacidade", "Protocolo", "Processador", "Pseudocódigo", "Pacote"], "correta": "Privacidade"}
	],
	"dificil": [
		{"categoria": "Algoritmos", "letra": "C", "dica": "Mede custo de tempo ou espaço de um algoritmo.", "opcoes": ["Complexidade", "Compilação", "Conexão", "Consulta", "Componente"], "correta": "Complexidade"},
		{"categoria": "Banco de dados", "letra": "I", "dica": "Estrutura que acelera buscas em tabelas.", "opcoes": ["Índice", "Interface", "Instância", "Integridade", "Iteração"], "correta": "Índice"},
		{"categoria": "Segurança", "letra": "C", "dica": "Transforma dados para protegê-los contra leitura indevida.", "opcoes": ["Criptografia", "Cache", "Cookie", "Classe", "Consulta"], "correta": "Criptografia"},
		{"categoria": "Engenharia de software", "letra": "E", "dica": "Protege detalhes internos de um objeto.", "opcoes": ["Encapsulamento", "Escalonamento", "Empilhamento", "Execução", "Endereço"], "correta": "Encapsulamento"},
		{"categoria": "Infraestrutura", "letra": "E", "dica": "Capacidade de crescer sem perder desempenho.", "opcoes": ["Escalabilidade", "Estética", "Entrada", "Entidade", "Exportação"], "correta": "Escalabilidade"},
		{"categoria": "IHC e sociedade", "letra": "A", "dica": "Permite uso por pessoas com diferentes necessidades.", "opcoes": ["Acessibilidade", "Algoritmo", "Atributo", "Arquivo", "Assinatura"], "correta": "Acessibilidade"}
	]
}


const STOP_TECH_TERMS_BY_INITIAL := {
	"A": ["API", "Algoritmo", "Acessibilidade", "Autenticação", "Autorização", "Acoplamento", "Amostragem", "Arquivo", "Arquitetura", "Angular"],
	"B": ["Backup", "Backlog", "Banco de Dados", "Branch", "Buffer", "Bug", "Build", "Bootstrap", "Big Data", "Business Intelligence"],
	"C": ["CSS", "Cache", "Cliente", "Classe", "Commit", "Cookie", "Container", "Criptografia", "Complexidade", "Coesão", "CI/CD", "Chave Estrangeira", "Correlação"],
	"D": ["DNS", "Dashboard", "DataFrame", "Deploy", "DevOps", "Diagrama ER", "Data Warehouse", "Data Mart", "Dados", "Documentação", "Docker", "Design Responsivo"],
	"E": ["ETL", "Escalabilidade", "Encapsulamento", "Endpoint", "Entidade", "Escopo", "Estatística", "Engenharia de Software", "Estrutura de Dados", "Exception"],
	"F": ["Fila", "Função", "Firewall", "Feature Engineering", "Framework", "Front-end", "Fork", "Feature", "Figma", "Fluxograma"],
	"G": ["Git", "Get", "Gestão", "Gateway", "GraphQL", "Granularidade", "GroupBy", "Governança", "GitHub", "Go"],
	"H": ["HTML", "HTTPS", "Hash", "Header", "Handshake", "Hospedagem", "Hardware", "Heurística", "Host", "Hook", "HMAC"],
	"I": ["Índice", "Interface", "Instância", "Integridade", "Iteração", "IoT", "IDE", "Input", "Inspeção", "Injeção SQL"],
	"J": ["JavaScript", "JSON", "JOIN", "Jira", "JWT", "Jupyter", "Java", "Job", "Jenkins"],
	"K": ["KPI", "KDD", "Kanban", "Kernel", "Kubernetes", "Key", "Knowledge Base"],
	"L": ["LGPD", "Lógica", "Loop", "Layout", "Link", "Linux", "Log", "Load Balancer", "Lambda", "Limpeza de Dados"],
	"M": ["MFA", "MVC", "MVP", "Método", "Modelagem", "Metadados", "Mineração de Dados", "Middleware", "Mock", "Machine Learning"],
	"N": ["Normalização", "Namespace", "Nuvem", "Nó", "Navegação", "Notificação", "Node.js", "Null", "NAT", "NoSQL"],
	"O": ["OLAP", "OLTP", "Objeto", "Outlier", "Open Source", "Operação", "Orquestração", "Observabilidade", "ORM", "OAuth"],
	"P": ["Pilha", "Processo", "Privacidade", "POO", "Pipeline", "Persona", "Padronização de Dados", "Polimorfismo", "Protocolo", "Proxy", "Porta", "Pseudocódigo"],
	"Q": ["Query", "Qualidade de Software", "Queue", "QA", "QRCode", "Quick Sort", "Quorum"],
	"R": ["Roteador", "Rede", "Requisito", "Runtime", "Render", "Refatoração", "Roteamento", "Repositório", "REST", "Rollback", "Regressão"],
	"S": ["SELECT", "Servidor", "Scrum", "SOLID", "Senha", "Sistema Operacional", "Star Schema", "SQL Injection", "Series", "Sprint", "Stack", "Switch"],
	"T": ["Teste", "Transação", "Tabela", "Token", "Thread", "Timeout", "Tarefa", "Template", "Trigger", "Tratamento de Dados"],
	"U": ["UML", "URL", "UX", "Usabilidade", "Upload", "Usuário", "UDP", "Unicode", "Unidade", "UI"],
	"V": ["VPN", "Variável", "Versionamento", "Validação", "View", "Virtualização", "Vetor", "Vulnerabilidade", "Visão Computacional"],
	"W": ["Web", "WebSocket", "Wireframe", "Workflow", "Widget", "Wrapper", "WAN"],
	"X": ["XSS", "XML", "XOR", "XAML", "XPath", "XQuery", "XUnit", "Xen"],
	"Z": ["Zero Trust", "Zip", "Z-Score", "Zabbix", "Zendesk", "Zombie Process", "Zona Desmilitarizada", "Zettabyte"]
}

var questions: Array = []
var option_buttons: Array[Button] = []
var letter_particles: Array = []
var current_question: Dictionary = {}
var current_question_index: int = 0
var correct_points: int = 10
var correct_answers_count: int = 0
var wrong_points: int = -12
var input_locked: bool = true
var finish_visible: bool = false
var round_start_msec: int = 0
var shake_strength: float = 0.0
var base_root_position: Vector2 = Vector2.ZERO

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
	# V0.10: tutorial do Cleiton depois da 1a letra sorteada; o relogio da rodada so comeca depois dele.
	input_locked = true
	await TutorialManager.play(self, "stop")
	if not is_inside_tree():
		return
	round_start_msec = Time.get_ticks_msec()
	input_locked = false

func _process(delta: float) -> void:
	if not _animations_enabled():
		if particle_layer != null:
			particle_layer.visible = false
		if root_margin != null:
			root_margin.position = base_root_position
		return
	if particle_layer != null:
		particle_layer.visible = true
	_update_letter_particles(delta)
	_update_screen_shake(delta)

func _unhandled_input(event: InputEvent) -> void:
	if finish_visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event: InputEventKey = event as InputEventKey
		match key_event.keycode:
			KEY_1, KEY_KP_1, KEY_A:
				_press_option_by_index(0)
			KEY_2, KEY_KP_2, KEY_B:
				_press_option_by_index(1)
			KEY_3, KEY_KP_3, KEY_C:
				_press_option_by_index(2)
			KEY_4, KEY_KP_4, KEY_D:
				_press_option_by_index(3)
			KEY_5, KEY_KP_5, KEY_E:
				_press_option_by_index(4)
			KEY_6, KEY_KP_6, KEY_F:
				_press_option_by_index(5)

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
	dimmer.color = Color(0.02, 0.02, 0.08, 0.58)
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

	var top_row: HBoxContainer = HBoxContainer.new()
	top_row.name = "TopRow"
	top_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.alignment = BoxContainer.ALIGNMENT_CENTER
	top_row.add_theme_constant_override("separation", 12)
	main_box.add_child(top_row)

	top_row.add_child(_create_stop_icon(Vector2(52, 52)))

	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "STOP - GOVERNANÇA DE TI"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 42)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.05))
	title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	title_label.add_theme_constant_override("shadow_offset_x", 3)
	title_label.add_theme_constant_override("shadow_offset_y", 3)
	top_row.add_child(title_label)

	top_row.add_child(_create_stop_icon(Vector2(52, 52)))

	var status_row: HBoxContainer = HBoxContainer.new()
	status_row.name = "StatusRow"
	status_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_row.alignment = BoxContainer.ALIGNMENT_CENTER
	status_row.add_theme_constant_override("separation", 12)
	main_box.add_child(status_row)

	question_counter_label = _create_chip_label("RODADA 1/6", 17, Color(0.78, 0.05, 0.08, 0.96), Color(1, 1, 1))
	status_row.add_child(question_counter_label)

	score_label = _create_chip_label("Pontuação: 0", 17, Color(0.04, 0.07, 0.16, 0.95), Color(1, 1, 1))
	status_row.add_child(score_label)

	difficulty_label = _create_chip_label("Dificuldade: Normal", 17, Color(0.04, 0.07, 0.16, 0.95), Color(1, 1, 1))
	status_row.add_child(difficulty_label)

	roulette_label = Label.new()
	roulette_label.name = "RouletteLetter"
	roulette_label.text = "?"
	roulette_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	roulette_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	roulette_label.custom_minimum_size = Vector2(190, 150)
	roulette_label.add_theme_font_size_override("font_size", 118)
	roulette_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.05))
	roulette_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.92))
	roulette_label.add_theme_constant_override("shadow_offset_x", 4)
	roulette_label.add_theme_constant_override("shadow_offset_y", 4)
	roulette_label.add_theme_stylebox_override("normal", _make_panel_style(Color(0.04, 0.04, 0.12, 0.74), Color(1.0, 0.84, 0.05), 26, 3))
	main_box.add_child(roulette_label)

	var question_panel: PanelContainer = PanelContainer.new()
	question_panel.name = "QuestionPanel"
	question_panel.custom_minimum_size = Vector2(880, 128)
	question_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	question_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.08, 0.18, 0.88), Color(0.34, 0.90, 1.0), 18, 2))
	main_box.add_child(question_panel)

	var question_margin: MarginContainer = MarginContainer.new()
	question_margin.name = "QuestionMargin"
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

	options_grid = GridContainer.new()
	options_grid.name = "OptionsGrid"
	options_grid.columns = 3
	options_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	options_grid.add_theme_constant_override("h_separation", 18)
	options_grid.add_theme_constant_override("v_separation", 10)
	main_box.add_child(options_grid)



	_build_feedback_layer()
	_build_finish_layer()

func _clear_scene_children() -> void:
	for child in get_children():
		child.queue_free()

func _create_stop_icon(min_size: Vector2) -> TextureRect:
	var icon: TextureRect = TextureRect.new()
	icon.custom_minimum_size = min_size
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var texture: Resource = load(STOP_ICON_PATH)
	if texture is Texture2D:
		icon.texture = texture
	return icon

func _create_chip_label(text_value: String, font_size: int, bg_color: Color, text_color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(220, 36)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", text_color)
	label.add_theme_stylebox_override("normal", _make_panel_style(bg_color, Color(1, 1, 1, 0.20), 12, 1))
	return label

func _build_feedback_layer() -> void:
	feedback_layer = Control.new()
	feedback_layer.name = "FeedbackLayer"
	feedback_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	feedback_layer.visible = false
	feedback_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(feedback_layer)

	var overlay: ColorRect = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.74)
	feedback_layer.add_child(overlay)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	feedback_layer.add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(760, 330)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.06, 0.12, 0.98), Color(1.0, 0.84, 0.05), 20, 3))
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

	var overlay: ColorRect = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.82)
	finish_layer.add_child(overlay)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	finish_layer.add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 330)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.06, 0.12, 0.98), Color(1.0, 0.84, 0.05), 22, 3))
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
	title.text = "Fim do Desafio STOP!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.05))
	box.add_child(title)

	finish_score_label = Label.new()
	finish_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	finish_score_label.add_theme_font_size_override("font_size", 26)
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

func _prepare_questions() -> void:
	correct_answers_count = 0
	var rules: Dictionary = DifficultyManager.get_rules()
	var question_type: String = str(rules.get("pergunta_tipo", "normal"))
	questions = DynamicQuestionBank.pick_rounds("stop", question_type, 6)
	if questions.is_empty():
		if not ALL_QUESTIONS.has(question_type):
			question_type = "normal"
		questions = ALL_QUESTIONS[question_type].duplicate(true)
		questions.shuffle()

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
	current_question = _normalize_stop_question(questions[current_question_index])
	question_counter_label.text = "RODADA %s/%s" % [current_question_index + 1, questions.size()]
	category_label.text = "Categoria: %s" % str(current_question.get("categoria", ""))
	tip_label.text = "Dica: %s" % str(current_question.get("dica", ""))
	_clear_options()

	await _play_roulette(str(current_question.get("letra", "?")))
	if not is_inside_tree():
		return
	_build_options()
	round_start_msec = Time.get_ticks_msec()
	input_locked = false

func _play_roulette(target_letter: String) -> void:
	var letters := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	for i in range(ROULETTE_STEPS):
		if i == ROULETTE_STEPS - 1:
			roulette_label.text = target_letter
			roulette_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.05))
		else:
			var random_index: int = randi_range(0, letters.length() - 1)
			roulette_label.text = letters.substr(random_index, 1)
			roulette_label.add_theme_color_override("font_color", Color(0.78, 0.82, 0.90))
		var duration: float = 0.035 + float(i) * 0.006
		await get_tree().create_timer(duration, false).timeout
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("explosion")
	_flash_letter()

func _flash_letter() -> void:
	if not _animations_enabled():
		roulette_label.scale = Vector2.ONE
		return
	var tween: Tween = create_tween()
	roulette_label.scale = Vector2.ONE
	tween.tween_property(roulette_label, "scale", Vector2(1.12, 1.12), 0.07)
	tween.tween_property(roulette_label, "scale", Vector2.ONE, 0.10)

func _build_options() -> void:
	_clear_options()
	var options: Array = _get_stop_options(current_question)
	var icon_resource: Resource = load(STOP_ICON_PATH)

	for i in range(options.size()):
		var option_text: String = str(options[i])
		var button: Button = Button.new()
		button.name = "Option%s" % [i + 1]
		button.text = option_text
		button.custom_minimum_size = Vector2(240, 58)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.clip_text = true
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.expand_icon = true
		button.add_theme_font_size_override("font_size", 20)
		button.add_theme_constant_override("h_separation", 14)
		button.add_theme_constant_override("icon_max_width", 42)
		button.add_theme_stylebox_override("normal", _make_option_button_style(Color(0.06, 0.10, 0.24, 0.94), Color(0.38, 0.72, 1.0)))
		button.add_theme_stylebox_override("hover", _make_option_button_style(Color(0.14, 0.22, 0.46, 1.0), Color(1.0, 1.0, 1.0), 3))
		button.add_theme_stylebox_override("pressed", _make_option_button_style(Color(0.22, 0.30, 0.56, 1.0), Color(1, 1, 1), 3))
		button.add_theme_stylebox_override("disabled", _make_option_button_style(Color(0.04, 0.07, 0.14, 0.68), Color(0.25, 0.35, 0.48)))
		button.add_theme_color_override("font_color", Color(1, 1, 1))
		button.add_theme_color_override("font_hover_color", Color(1, 1, 1))
		button.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
		if icon_resource is Texture2D:
			button.icon = icon_resource as Texture2D
		button.set_meta("answer_text", option_text)
		button.pressed.connect(_on_option_pressed.bind(option_text, button))
		options_grid.add_child(button)
		option_buttons.append(button)

func _normalize_stop_question(question_data: Dictionary) -> Dictionary:
	var normalized: Dictionary = question_data.duplicate(true)
	var correct_text: String = str(normalized.get("correta", "")).strip_edges()
	if correct_text == "":
		return normalized
	var official_letter: String = _get_initial_key(correct_text)
	if official_letter != "":
		normalized["letra"] = official_letter
	normalized["opcoes"] = _build_stop_options_for_letter(correct_text, official_letter)
	return normalized

func _get_stop_options(question_data: Dictionary) -> Array:
	var options_value: Variant = question_data.get("opcoes", [])
	if options_value is Array:
		return (options_value as Array).duplicate(true)
	return []

func _build_stop_options_for_letter(correct_text: String, letter_key: String) -> Array:
	var options: Array = [correct_text]
	var pool: Array = _get_stop_distractor_pool(letter_key, correct_text)
	pool = _sort_stop_pool_for_difficulty(pool)
	for term_value in pool:
		var term_text: String = str(term_value).strip_edges()
		if term_text == "" or term_text == correct_text:
			continue
		if _get_initial_key(term_text) != letter_key:
			continue
		if not options.has(term_text):
			options.append(term_text)
		if options.size() >= 6:
			break
	if options.size() < 6:
		for fallback_value in _get_stop_fallback_terms(letter_key):
			var fallback_text: String = str(fallback_value).strip_edges()
			if fallback_text == "" or fallback_text == correct_text:
				continue
			if _get_initial_key(fallback_text) != letter_key:
				continue
			if not options.has(fallback_text):
				options.append(fallback_text)
			if options.size() >= 6:
				break
	options.shuffle()
	return options

func _get_stop_fallback_terms(letter_key: String) -> Array:
	if _stop_terms_by_initial().has(letter_key):
		return (_stop_terms_by_initial()[letter_key] as Array).duplicate(true)
	return []

func _get_stop_distractor_pool(letter_key: String, correct_text: String) -> Array:
	var pool: Array = []
	if _stop_terms_by_initial().has(letter_key):
		pool = (_stop_terms_by_initial()[letter_key] as Array).duplicate(true)
	var source_options: Array = []
	if current_question.has("opcoes") and current_question["opcoes"] is Array:
		source_options = (current_question["opcoes"] as Array).duplicate(true)
	for option_value in source_options:
		var option_text: String = str(option_value).strip_edges()
		if option_text != "" and _get_initial_key(option_text) == letter_key and not pool.has(option_text):
			pool.append(option_text)
	if not pool.has(correct_text):
		pool.append(correct_text)
	pool.shuffle()
	return pool

func _sort_stop_pool_for_difficulty(pool: Array) -> Array:
	var sorted_pool: Array = pool.duplicate(true)
	var difficulty_key: String = DifficultyManager.get_difficulty()
	if difficulty_key == "dificil":
		sorted_pool.sort_custom(Callable(self, "_compare_stop_terms_hard"))
	elif difficulty_key == "facil":
		sorted_pool.sort_custom(Callable(self, "_compare_stop_terms_easy"))
	return sorted_pool

func _compare_stop_terms_hard(a: Variant, b: Variant) -> bool:
	return _stop_term_complexity(str(a)) > _stop_term_complexity(str(b))

func _compare_stop_terms_easy(a: Variant, b: Variant) -> bool:
	return _stop_term_complexity(str(a)) < _stop_term_complexity(str(b))

func _stop_term_complexity(term_text: String) -> int:
	var score: int = term_text.length()
	if term_text.find(" ") >= 0:
		score += 5
	if term_text.find("/") >= 0 or term_text.find("-") >= 0:
		score += 4
	if term_text == term_text.to_upper() and term_text.length() >= 3:
		score += 3
	return score

func _get_initial_key(term_text: String) -> String:
	var normalized_text: String = _normalize_initial_text(term_text.strip_edges())
	if normalized_text.length() == 0:
		return ""
	return normalized_text.substr(0, 1).to_upper()

func _normalize_initial_text(value: String) -> String:
	var result: String = value.to_upper()
	var replacements: Dictionary = {
		"Á": "A", "À": "A", "Â": "A", "Ã": "A", "Ä": "A",
		"É": "E", "È": "E", "Ê": "E", "Ë": "E",
		"Í": "I", "Ì": "I", "Î": "I", "Ï": "I",
		"Ó": "O", "Ò": "O", "Ô": "O", "Õ": "O", "Ö": "O",
		"Ú": "U", "Ù": "U", "Û": "U", "Ü": "U",
		"Ç": "C"
	}
	for key_value in replacements.keys():
		result = result.replace(str(key_value), str(replacements[key_value]))
	return result

func _clear_options() -> void:
	if options_grid == null:
		return
	for child in options_grid.get_children():
		child.queue_free()
	option_buttons.clear()

func _on_option_pressed(selected_text: String, selected_button: Button) -> void:
	_register_answer(selected_text, selected_button)

func _register_answer(selected_text: String, selected_button: Button) -> void:
	if input_locked or finish_visible:
		return
	input_locked = true
	for button in option_buttons:
		button.disabled = true

	var correct_text: String = str(current_question.get("correta", ""))
	var is_correct: bool = selected_text == correct_text
	var elapsed_seconds: float = float(Time.get_ticks_msec() - round_start_msec) / 1000.0
	var awarded_points: int = correct_points
	if is_correct:
		awarded_points = DifficultyManager.get_time_adjusted_points(correct_points, elapsed_seconds)
	_highlight_answer(selected_button, correct_text, is_correct)

	if is_correct:
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

	await _show_feedback(is_correct, selected_text, correct_text, elapsed_seconds, awarded_points)
	if not is_inside_tree():
		return
	feedback_layer.visible = false
	_start_question(current_question_index + 1)

func _highlight_answer(selected_button: Button, correct_text: String, is_correct: bool) -> void:
	for button in option_buttons:
		var answer: String = str(button.get_meta("answer_text"))
		if answer == correct_text:
			button.add_theme_stylebox_override("disabled", _make_option_button_style(Color(0.0, 0.43, 0.14, 0.98), Color(0.56, 1.0, 0.62), 3))
		elif button == selected_button and not is_correct:
			button.add_theme_stylebox_override("disabled", _make_option_button_style(Color(0.56, 0.02, 0.02, 0.98), Color(1.0, 0.52, 0.52), 3))

func _show_feedback(is_correct: bool, selected_text: String, correct_text: String, _elapsed_seconds: float, awarded_points: int) -> void:
	var explanation: String = _clean_feedback_explanation(correct_text, _get_stop_explanation(correct_text))
	if is_correct:
		feedback_title_label.text = "CORRETO"
		feedback_title_label.add_theme_color_override("font_color", Color(0.42, 1.0, 0.48))
		feedback_body_label.text = "Resposta correta: %s\n%s\nPontuação adquirida: +%s" % [correct_text, explanation, awarded_points]
	else:
		feedback_title_label.text = "INCORRETO"
		feedback_title_label.add_theme_color_override("font_color", Color(1.0, 0.24, 0.20))
		feedback_body_label.text = "Você escolheu: %s\nEssa opção não combina com a categoria e a dica da rodada.\n\nResposta correta: %s\n%s\nPontuação perdida: %s" % [selected_text, correct_text, explanation, wrong_points]
	feedback_layer.visible = true
	await _wait_for_feedback_continue()

func _clean_feedback_explanation(answer_text: String, explanation_text: String) -> String:
	var answer := answer_text.strip_edges()
	var explanation := explanation_text.strip_edges()
	if explanation == "" or explanation.to_lower() == answer.to_lower():
		return "%s atende à categoria e à dica apresentadas nesta rodada." % answer
	return explanation

func _get_stop_explanation(correct_text: String) -> String:
	var dynamic_explanation: String = str(current_question.get("explanation", ""))
	if dynamic_explanation != "":
		return dynamic_explanation
	return str(STOP_EXPLANATIONS.get(correct_text, "%s atende à categoria e à dica apresentadas nesta rodada." % correct_text))

func _show_finish() -> void:
	input_locked = true
	finish_visible = true
	if has_node("/root/AchievementManager") and correct_answers_count >= questions.size():
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
	if input_locked or index < 0 or index >= option_buttons.size():
		return
	var button: Button = option_buttons[index]
	if button.disabled:
		return
	var answer_text: String = str(button.get_meta("answer_text"))
	_on_option_pressed(answer_text, button)

func _on_score_changed(new_score: int) -> void:
	if score_label != null:
		score_label.text = "Pontuação: %s" % new_score

func _create_letter_particles() -> void:
	letter_particles.clear()
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(1280, 720)
	var chars: Array[String] = ["S", "T", "O", "P", "?", "!", "$", "#"]
	for i in range(WebLite.scaled_count(LETTER_PARTICLE_COUNT)):
		var label: Label = Label.new()
		label.text = chars[randi_range(0, chars.size() - 1)]
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_font_size_override("font_size", randi_range(28, 58))
		label.add_theme_color_override("font_color", _random_particle_color())
		particle_layer.add_child(label)
		var data: Dictionary = {
			"node": label,
			"speed": randf_range(22.0, 74.0),
			"drift": randf_range(-18.0, 18.0),
			"phase": randf_range(0.0, 6.28)
		}
		letter_particles.append(data)
		_reset_letter_particle(data, true)

func _random_particle_color() -> Color:
	var palette: Array[Color] = [
		Color(1.0, 0.22, 0.22, 0.32),
		Color(0.22, 0.94, 1.0, 0.30),
		Color(1.0, 0.84, 0.10, 0.30),
		Color(0.72, 0.30, 1.0, 0.28)
	]
	return palette[randi_range(0, palette.size() - 1)]

func _reset_letter_particle(data: Dictionary, random_y: bool = false) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(1280, 720)
	var label: Label = data["node"] as Label
	var next_y: float = randf_range(0.0, viewport_size.y) if random_y else viewport_size.y + randf_range(20.0, 100.0)
	label.position = Vector2(randf_range(20.0, viewport_size.x - 40.0), next_y)
	label.rotation = randf_range(-0.35, 0.35)

func _update_letter_particles(delta: float) -> void:
	if letter_particles.is_empty():
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	for data in letter_particles:
		var label: Label = data["node"] as Label
		var pos: Vector2 = label.position
		var speed: float = float(data["speed"])
		var drift: float = float(data["drift"])
		var phase: float = float(data["phase"])
		pos.y -= speed * delta
		pos.x += sin(float(Time.get_ticks_msec()) * 0.001 + phase) * drift * delta
		label.position = pos
		label.rotation += delta * 0.45
		if pos.y < -80.0 or pos.x < -90.0 or pos.x > viewport_size.x + 90.0:
			_reset_letter_particle(data)

func _update_screen_shake(delta: float) -> void:
	if root_margin == null:
		return
	if shake_strength <= 0.0:
		root_margin.position = base_root_position
		return
	shake_strength = maxf(0.0, shake_strength - 36.0 * delta)
	var offset: Vector2 = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength * 0.65, shake_strength * 0.65))
	root_margin.position = base_root_position + offset

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


func _stop_terms_by_initial() -> Dictionary:
	# Termos do dicionario.json agrupados pela inicial (substitui a lista antiga de TI).
	return DynamicQuestionBank.get_stop_terms_by_initial()
