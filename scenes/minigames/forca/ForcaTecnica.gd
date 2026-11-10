extends Control
var pause_menu: MinigamePause

const DynamicQuestionBank := preload("res://scripts/core/question_bank.gd")

const BACKGROUND_PATH := Paths.BG_FORCA
const TOTAL_ROUNDS := 6
const ERRORS_BY_DIFFICULTY := {"facil": 14, "normal": 10, "dificil": 6}
const SOLVE_BASE_POINTS := 100
const INTEGRITY_BONUS_CAP := 60
const FEEDBACK_SECONDS := 1.45
const SYMBOL_PARTICLE_COUNT := 42
const TECH_SYMBOLS := ["</>", "{}", "[]", "#", "@", "SQL", "API", "DB", "UX", "QA", "CI", "01", "λ", "git"]
const KEY_TO_LETTER := {
	KEY_A: "a",
	KEY_B: "b",
	KEY_C: "c",
	KEY_D: "d",
	KEY_E: "e",
	KEY_F: "f",
	KEY_G: "g",
	KEY_H: "h",
	KEY_I: "i",
	KEY_J: "j",
	KEY_K: "k",
	KEY_L: "l",
	KEY_M: "m",
	KEY_N: "n",
	KEY_O: "o",
	KEY_P: "p",
	KEY_Q: "q",
	KEY_R: "r",
	KEY_S: "s",
	KEY_T: "t",
	KEY_U: "u",
	KEY_V: "v",
	KEY_W: "w",
	KEY_X: "x",
	KEY_Y: "y",
	KEY_Z: "z"
}

const WORD_BANK := [
	{"word": "algoritmo", "area": "Engenharia de Software", "hint": "Sequência lógica de passos para resolver um problema."},
	{"word": "abstração", "area": "Engenharia de Software", "hint": "Representa apenas os aspectos essenciais de uma solução."},
	{"word": "encapsulamento", "area": "Engenharia de Software", "hint": "Oculta detalhes internos e expõe apenas o necessário."},
	{"word": "polimorfismo", "area": "Engenharia de Software", "hint": "Permite que diferentes objetos respondam à mesma operação."},
	{"word": "herança", "area": "Engenharia de Software", "hint": "Reutiliza características de uma classe em outra."},
	{"word": "refatoração", "area": "Engenharia de Software", "hint": "Melhora o código sem alterar seu comportamento externo."},
	{"word": "requisito", "area": "Engenharia de Software", "hint": "Necessidade ou condição que o sistema deve atender."},
	{"word": "prototipação", "area": "Engenharia de Software", "hint": "Criação de versão inicial para validar ideias e fluxos."},
	{"word": "arquitetura", "area": "Engenharia de Software", "hint": "Organização estrutural dos componentes de um sistema."},
	{"word": "modularidade", "area": "Engenharia de Software", "hint": "Divisão do sistema em partes menores e independentes."},
	{"word": "manutenibilidade", "area": "Qualidade de Software", "hint": "Facilidade de corrigir, adaptar e evoluir um software."},
	{"word": "escalabilidade", "area": "Qualidade de Software", "hint": "Capacidade de crescer sem perder desempenho de forma crítica."},
	{"word": "fila", "area": "Estruturas de Dados", "hint": "Estrutura em que o primeiro a entrar é o primeiro a sair."},
	{"word": "pilha", "area": "Estruturas de Dados", "hint": "Estrutura em que o último a entrar é o primeiro a sair."},
	{"word": "lista", "area": "Estruturas de Dados", "hint": "Coleção sequencial de elementos."},
	{"word": "árvore", "area": "Estruturas de Dados", "hint": "Estrutura hierárquica com raiz, ramos e nós."},
	{"word": "grafo", "area": "Estruturas de Dados", "hint": "Estrutura formada por vértices e conexões."},
	{"word": "hash", "area": "Estruturas de Dados", "hint": "Valor calculado para indexar, comparar ou proteger dados."},
	{"word": "vetor", "area": "Estruturas de Dados", "hint": "Estrutura indexada de tamanho geralmente fixo."},
	{"word": "matriz", "area": "Estruturas de Dados", "hint": "Organização de dados em linhas e colunas."},
	{"word": "ponteiro", "area": "Estruturas de Dados", "hint": "Referência para uma posição de memória."},
	{"word": "recursão", "area": "Estruturas de Dados", "hint": "Técnica em que uma função chama a si mesma."},
	{"word": "responsividade", "area": "Front-end", "hint": "Capacidade da interface se adaptar a diferentes telas."},
	{"word": "componente", "area": "Front-end", "hint": "Bloco reutilizável de uma interface."},
	{"word": "interface", "area": "Front-end", "hint": "Camada visual pela qual o usuário interage com o sistema."},
	{"word": "renderização", "area": "Front-end", "hint": "Processo de desenhar elementos visuais na tela."},
	{"word": "semântica", "area": "Front-end", "hint": "Uso de elementos com significado adequado na estrutura da página."},
	{"word": "estilização", "area": "Front-end", "hint": "Definição da aparência visual de uma interface."},
	{"word": "layout", "area": "Front-end", "hint": "Organização espacial dos elementos na tela."},
	{"word": "dom", "area": "Front-end", "hint": "Representação em árvore dos elementos de uma página web."},
	{"word": "estado", "area": "Front-end", "hint": "Conjunto de dados que define o comportamento atual da interface."},
	{"word": "evento", "area": "Front-end", "hint": "Ação capturada pela interface, como clique ou tecla."},
	{"word": "endpoint", "area": "Back-end", "hint": "Ponto de acesso de uma API para executar uma operação."},
	{"word": "middleware", "area": "Back-end", "hint": "Camada intermediária que processa requisições antes da resposta final."},
	{"word": "autenticação", "area": "Back-end", "hint": "Processo de verificar a identidade de um usuário."},
	{"word": "autorização", "area": "Back-end", "hint": "Define o que um usuário autenticado pode acessar."},
	{"word": "sessão", "area": "Back-end", "hint": "Estado mantido para identificar interações de um usuário."},
	{"word": "servidor", "area": "Back-end", "hint": "Sistema que processa requisições e fornece respostas."},
	{"word": "requisição", "area": "Back-end", "hint": "Pedido enviado por um cliente para um serviço."},
	{"word": "validação", "area": "Back-end", "hint": "Verificação se dados seguem regras esperadas."},
	{"word": "websocket", "area": "Back-end", "hint": "Comunicação bidirecional em tempo real entre cliente e servidor."},
	{"word": "cache", "area": "Back-end", "hint": "Armazenamento temporário para acelerar respostas futuras."},
	{"word": "consulta", "area": "Banco de Dados", "hint": "Operação usada para buscar dados armazenados."},
	{"word": "índice", "area": "Banco de Dados", "hint": "Estrutura que acelera buscas em tabelas."},
	{"word": "transação", "area": "Banco de Dados", "hint": "Conjunto de operações que deve ser concluído com consistência."},
	{"word": "rollback", "area": "Banco de Dados", "hint": "Desfaz alterações de uma transação."},
	{"word": "commit", "area": "Banco de Dados", "hint": "Confirma alterações de uma transação."},
	{"word": "chave primária", "area": "Banco de Dados", "hint": "Identifica de forma única um registro."},
	{"word": "chave estrangeira", "area": "Banco de Dados", "hint": "Liga uma tabela a outra por referência."},
	{"word": "relacionamento", "area": "Banco de Dados", "hint": "Associação entre entidades ou tabelas."},
	{"word": "entidade", "area": "Banco de Dados", "hint": "Objeto ou conceito representado no modelo de dados."},
	{"word": "normalização", "area": "Banco de Dados", "hint": "Organiza tabelas para reduzir redundâncias e inconsistências."},
	{"word": "protocolo", "area": "Redes", "hint": "Conjunto de regras para comunicação entre sistemas."},
	{"word": "roteamento", "area": "Redes", "hint": "Escolha do caminho que os pacotes percorrem na rede."},
	{"word": "latência", "area": "Redes", "hint": "Tempo de atraso entre envio e resposta de dados."},
	{"word": "pacote", "area": "Redes", "hint": "Unidade de dados transmitida em uma rede."},
	{"word": "dns", "area": "Redes", "hint": "Serviço que traduz nomes de domínio em endereços IP."},
	{"word": "tcp", "area": "Redes", "hint": "Protocolo orientado à conexão e entrega confiável."},
	{"word": "ip", "area": "Redes", "hint": "Endereço usado para identificar dispositivos em uma rede."},
	{"word": "gateway", "area": "Redes", "hint": "Ponto de saída entre redes diferentes."},
	{"word": "largura de banda", "area": "Redes", "hint": "Capacidade de transmissão de dados em um canal."},
	{"word": "sub-rede", "area": "Redes", "hint": "Divisão lógica de uma rede maior."},
	{"word": "criptografia", "area": "Segurança", "hint": "Protege dados tornando-os ilegíveis sem uma chave."},
	{"word": "firewall", "area": "Segurança", "hint": "Filtra tráfego de rede conforme regras de segurança."},
	{"word": "vulnerabilidade", "area": "Segurança", "hint": "Fraqueza que pode ser explorada por uma ameaça."},
	{"word": "token", "area": "Segurança", "hint": "Credencial usada para representar autorização ou sessão."},
	{"word": "permissão", "area": "Segurança", "hint": "Regra que define acesso a recursos."},
	{"word": "ameaça", "area": "Segurança", "hint": "Possível causa de dano a um sistema."},
	{"word": "phishing", "area": "Segurança", "hint": "Golpe que tenta enganar usuários para roubar informações."},
	{"word": "sanitização", "area": "Segurança", "hint": "Tratamento de entradas para reduzir risco de ataques."},
	{"word": "assinatura digital", "area": "Segurança", "hint": "Recurso usado para verificar autoria e integridade."},
	{"word": "backup", "area": "Segurança", "hint": "Cópia de segurança para recuperação de dados."},
	{"word": "usabilidade", "area": "IHC", "hint": "Facilidade com que pessoas conseguem usar um sistema."},
	{"word": "heurística", "area": "IHC", "hint": "Princípio usado para avaliar a qualidade de uma interface."},
	{"word": "acessibilidade", "area": "IHC", "hint": "Permite uso por pessoas com diferentes necessidades."},
	{"word": "experiência", "area": "IHC", "hint": "Percepção geral do usuário ao interagir com um produto."},
	{"word": "feedback", "area": "IHC", "hint": "Resposta do sistema às ações do usuário."},
	{"word": "affordance", "area": "IHC", "hint": "Pista visual que sugere como um elemento pode ser usado."},
	{"word": "navegação", "area": "IHC", "hint": "Forma como o usuário se desloca entre telas e conteúdos."},
	{"word": "interação", "area": "IHC", "hint": "Troca de ações e respostas entre usuário e sistema."},
	{"word": "persona", "area": "IHC", "hint": "Perfil fictício usado para representar usuários."},
	{"word": "wireframe", "area": "IHC", "hint": "Esboço estrutural de uma interface."},
	{"word": "deploy", "area": "DevOps", "hint": "Publicação de uma aplicação em ambiente de uso."},
	{"word": "pipeline", "area": "DevOps", "hint": "Fluxo automatizado de etapas de build, teste e entrega."},
	{"word": "container", "area": "DevOps", "hint": "Ambiente isolado para executar aplicações e dependências."},
	{"word": "build", "area": "DevOps", "hint": "Processo de preparar o software para execução ou distribuição."},
	{"word": "integração contínua", "area": "DevOps", "hint": "Prática de integrar e testar mudanças frequentemente."},
	{"word": "entrega contínua", "area": "DevOps", "hint": "Prática de manter versões prontas para publicação."},
	{"word": "versionamento", "area": "DevOps", "hint": "Controle do histórico de alterações de arquivos e código."},
	{"word": "ambiente", "area": "DevOps", "hint": "Contexto onde a aplicação é executada, como teste ou produção."},
	{"word": "observabilidade", "area": "DevOps", "hint": "Capacidade de entender o estado interno do sistema por sinais externos."},
	{"word": "monitoramento", "area": "DevOps", "hint": "Acompanhamento de métricas, logs e eventos do sistema."},
	{"word": "teste unitário", "area": "Qualidade de Software", "hint": "Verifica uma pequena unidade de código de forma isolada."},
	{"word": "teste regressivo", "area": "Qualidade de Software", "hint": "Confirma que mudanças não quebraram funcionalidades existentes."},
	{"word": "teste funcional", "area": "Qualidade de Software", "hint": "Valida se o sistema cumpre funções esperadas."},
	{"word": "defeito", "area": "Qualidade de Software", "hint": "Falha ou comportamento incorreto no software."},
	{"word": "cobertura", "area": "Qualidade de Software", "hint": "Mede quanto do código ou requisito foi exercitado por testes."},
	{"word": "confiabilidade", "area": "Qualidade de Software", "hint": "Capacidade de funcionar corretamente por determinado tempo."},
	{"word": "desempenho", "area": "Qualidade de Software", "hint": "Qualidade relacionada a tempo de resposta e uso de recursos."},
	{"word": "compatibilidade", "area": "Qualidade de Software", "hint": "Capacidade de funcionar em diferentes ambientes ou plataformas."},
	{"word": "portabilidade", "area": "Qualidade de Software", "hint": "Facilidade de transferir o software para outro ambiente."},
	{"word": "validação", "area": "Qualidade de Software", "hint": "Confirma se o produto atende às necessidades reais."}
]

var questions: Array = []
var current_question: Dictionary = {}
var current_round_index: int = 0
var guessed_letters: Dictionary = {}
var letter_buttons: Dictionary = {}
var errors_this_word: int = 0
var max_errors: int = 10
var success_count: int = 0
var failure_count: int = 0
var total_errors_count: int = 0
var earned_points: int = 0
var input_locked: bool = true
var finish_visible: bool = false
var elapsed: float = 0.0
var shake_strength: float = 0.0
var base_root_position: Vector2 = Vector2.ZERO
var symbol_particles: Array[Dictionary] = []

var root_margin: MarginContainer
var main_box: VBoxContainer
var effects_canvas: Control
var particle_layer: Control
var title_label: Label
var round_label: Label
var score_label: Label
var difficulty_label: Label
var area_label: Label
var hint_label: Label
var terminal_label: Label
var word_label: Label
var integrity_bar: ProgressBar
var integrity_label: Label
var error_label: Label
var keyboard_grid: GridContainer
var feedback_layer: Control
var feedback_title_label: Label
var feedback_body_label: Label
var feedback_continue_button: Button
var finish_layer: Control
var finish_title_label: Label
var finish_body_label: Label

func _ready() -> void:
	randomize()
	_build_scene()
	pause_menu = MinigamePause.attach(self)
	_connect_score_signal()
	_prepare_questions()
	_on_score_changed(ScoreManager.get_score())
	if has_node("/root/AudioManager"):
		AudioManager.play_music("musica_forca_tecnica")
	await _start_round(0)
	# V0.10: tutorial da Aline ANTES da primeira palavra (letras bloqueadas durante o tutorial).
	input_locked = true
	await TutorialManager.play(self, "forca_tecnica", {"placeholders": {"errors": max_errors, "base": SOLVE_BASE_POINTS, "bonus": INTEGRITY_BONUS_CAP}})
	if not is_inside_tree():
		return
	input_locked = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_responsive_layout()
		if _animations_enabled():
			_reset_symbol_particles()

func _process(delta: float) -> void:
	elapsed += delta
	if not _animations_enabled():
		if particle_layer != null:
			particle_layer.visible = false
		if effects_canvas != null:
			effects_canvas.visible = false
		if root_margin != null:
			root_margin.position = base_root_position
		return
	if particle_layer != null:
		particle_layer.visible = true
	if effects_canvas != null:
		effects_canvas.visible = true
		_update_effects_canvas()
	_update_symbol_particles(delta)
	_update_screen_shake(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event: InputEventKey = event as InputEventKey
		if finish_visible:
			match key_event.keycode:
				KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
					_on_finish_continue_pressed()
			return
		match key_event.keycode:
			_:
				if KEY_TO_LETTER.has(key_event.keycode):
					_guess_letter(str(KEY_TO_LETTER[key_event.keycode]))

func _build_scene() -> void:
	_clear_scene_children()

	var background_rect: TextureRect = TextureRect.new()
	background_rect.name = "Background"
	background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_rect.expand_mode = 1
	background_rect.stretch_mode = 6
	var bg_texture: Resource = load(BACKGROUND_PATH)
	if bg_texture is Texture2D:
		background_rect.texture = bg_texture as Texture2D
	add_child(background_rect)

	var dimmer: ColorRect = ColorRect.new()
	dimmer.name = "Dimmer"
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.01, 0.03, 0.07, 0.34)
	add_child(dimmer)

	effects_canvas = Control.new()
	effects_canvas.name = "SystemEffectsCanvas"
	effects_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	effects_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effects_canvas.draw.connect(_on_effects_canvas_draw)
	add_child(effects_canvas)

	particle_layer = Control.new()
	particle_layer.name = "TechnicalSymbolLayer"
	particle_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	particle_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(particle_layer)
	_create_symbol_particles()

	root_margin = MarginContainer.new()
	root_margin.name = "SafeArea"
	root_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root_margin)
	base_root_position = root_margin.position

	main_box = VBoxContainer.new()
	main_box.name = "MainLayout"
	main_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_box.alignment = BoxContainer.ALIGNMENT_CENTER
	root_margin.add_child(main_box)

	var top_panel: PanelContainer = PanelContainer.new()
	top_panel.name = "TopPanel"
	top_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.015, 0.06, 0.10, 0.58), Color(0.18, 1.0, 0.78, 0.72), 20, 2))
	main_box.add_child(top_panel)

	var top_margin: MarginContainer = MarginContainer.new()
	top_margin.add_theme_constant_override("margin_left", 22)
	top_margin.add_theme_constant_override("margin_top", 14)
	top_margin.add_theme_constant_override("margin_right", 22)
	top_margin.add_theme_constant_override("margin_bottom", 14)
	top_panel.add_child(top_margin)

	var top_box: VBoxContainer = VBoxContainer.new()
	top_box.alignment = BoxContainer.ALIGNMENT_CENTER
	top_box.add_theme_constant_override("separation", 9)
	top_margin.add_child(top_box)

	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "FORCA TÉCNICA"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color", Color(0.48, 1.0, 0.82))
	title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.92))
	title_label.add_theme_constant_override("shadow_offset_x", 3)
	title_label.add_theme_constant_override("shadow_offset_y", 3)
	top_box.add_child(title_label)

	var status_row: HBoxContainer = HBoxContainer.new()
	status_row.name = "StatusRow"
	status_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_row.alignment = BoxContainer.ALIGNMENT_CENTER
	status_row.add_theme_constant_override("separation", 10)
	top_box.add_child(status_row)

	round_label = _create_chip_label("RODADA 1/6", Color(0.02, 0.16, 0.18, 0.94), Color(0.72, 1.0, 0.92))
	status_row.add_child(round_label)
	score_label = _create_chip_label("Pontuação: 0", Color(0.03, 0.08, 0.16, 0.94), Color(1, 1, 1))
	status_row.add_child(score_label)
	difficulty_label = _create_chip_label("Dificuldade: Normal", Color(0.03, 0.08, 0.16, 0.94), Color(1, 1, 1))
	status_row.add_child(difficulty_label)

	var content_row: HBoxContainer = HBoxContainer.new()
	content_row.name = "ContentRow"
	content_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_row.add_theme_constant_override("separation", 16)
	main_box.add_child(content_row)

	var question_panel: PanelContainer = PanelContainer.new()
	question_panel.name = "QuestionPanel"
	question_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	question_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	question_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.02, 0.04, 0.09, 0.66), Color(0.30, 0.82, 1.0, 0.72), 22, 2))
	content_row.add_child(question_panel)

	var question_margin: MarginContainer = MarginContainer.new()
	question_margin.add_theme_constant_override("margin_left", 26)
	question_margin.add_theme_constant_override("margin_top", 22)
	question_margin.add_theme_constant_override("margin_right", 26)
	question_margin.add_theme_constant_override("margin_bottom", 22)
	question_panel.add_child(question_margin)

	var question_box: VBoxContainer = VBoxContainer.new()
	question_box.alignment = BoxContainer.ALIGNMENT_CENTER
	question_box.add_theme_constant_override("separation", 14)
	question_margin.add_child(question_box)

	area_label = Label.new()
	area_label.name = "AreaLabel"
	area_label.text = "ÁREA:"
	area_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	area_label.add_theme_color_override("font_color", Color(0.80, 0.96, 1.0))
	question_box.add_child(area_label)

	hint_label = Label.new()
	hint_label.name = "HintLabel"
	hint_label.text = "DICA:"
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint_label.add_theme_color_override("font_color", Color(0.94, 0.98, 1.0))
	question_box.add_child(hint_label)

	word_label = Label.new()
	word_label.name = "WordLabel"
	word_label.text = "_ _ _"
	word_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	word_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	word_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	word_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	word_label.add_theme_color_override("font_color", Color(1.0, 0.94, 0.42))
	word_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.96))
	word_label.add_theme_constant_override("shadow_offset_x", 3)
	word_label.add_theme_constant_override("shadow_offset_y", 3)
	question_box.add_child(word_label)

	keyboard_grid = GridContainer.new()
	keyboard_grid.name = "KeyboardGrid"
	keyboard_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	keyboard_grid.add_theme_constant_override("h_separation", 7)
	keyboard_grid.add_theme_constant_override("v_separation", 7)
	question_box.add_child(keyboard_grid)
	_build_keyboard()


	var system_panel: PanelContainer = PanelContainer.new()
	system_panel.name = "SystemPanel"
	system_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.00, 0.07, 0.08, 0.68), Color(0.18, 1.0, 0.54, 0.66), 22, 2))
	content_row.add_child(system_panel)

	var system_margin: MarginContainer = MarginContainer.new()
	system_margin.add_theme_constant_override("margin_left", 22)
	system_margin.add_theme_constant_override("margin_top", 22)
	system_margin.add_theme_constant_override("margin_right", 22)
	system_margin.add_theme_constant_override("margin_bottom", 22)
	system_panel.add_child(system_margin)

	var system_box: VBoxContainer = VBoxContainer.new()
	system_box.alignment = BoxContainer.ALIGNMENT_CENTER
	system_box.add_theme_constant_override("separation", 14)
	system_margin.add_child(system_box)

	var system_title: Label = Label.new()
	system_title.text = "INTEGRIDADE DO SISTEMA"
	system_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	system_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	system_title.add_theme_color_override("font_color", Color(0.60, 1.0, 0.78))
	system_box.add_child(system_title)

	integrity_bar = ProgressBar.new()
	integrity_bar.name = "IntegrityBar"
	integrity_bar.min_value = 0
	integrity_bar.max_value = 100
	integrity_bar.value = 100
	integrity_bar.show_percentage = false
	system_box.add_child(integrity_bar)

	integrity_label = Label.new()
	integrity_label.name = "IntegrityLabel"
	integrity_label.text = "100%"
	integrity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	integrity_label.add_theme_color_override("font_color", Color(0.84, 1.0, 0.90))
	system_box.add_child(integrity_label)

	error_label = Label.new()
	error_label.name = "ErrorLabel"
	error_label.text = "Erros: 0/6"
	error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	error_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.68))
	system_box.add_child(error_label)

	terminal_label = Label.new()
	terminal_label.name = "TerminalLabel"
	terminal_label.text = "> sistema íntegro"
	terminal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	terminal_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	terminal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	terminal_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	terminal_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	terminal_label.add_theme_color_override("font_color", Color(0.54, 1.0, 0.70))
	terminal_label.add_theme_stylebox_override("normal", _make_panel_style(Color(0.0, 0.015, 0.02, 0.72), Color(0.20, 1.0, 0.48, 0.34), 12, 1))
	system_box.add_child(terminal_label)

	_build_feedback_layer()
	_build_finish_layer()
	_apply_responsive_layout()

func _clear_scene_children() -> void:
	for child in get_children():
		child.queue_free()

func _apply_responsive_layout() -> void:
	var compact: bool = ScreenTools.is_compact(self)
	ScreenTools.apply_safe_margins(root_margin, self, 34, 14)
	if main_box != null:
		main_box.add_theme_constant_override("separation", 10 if compact else 16)
	if title_label != null:
		title_label.add_theme_font_size_override("font_size", ScreenTools.responsive_font(self, 42, 30))
	for label in [round_label, score_label, difficulty_label]:
		if label is Label:
			(label as Label).add_theme_font_size_override("font_size", ScreenTools.responsive_font(self, 15, 12))
			(label as Label).custom_minimum_size = ScreenTools.responsive_size(self, Vector2(210, 34), Vector2(118, 30))
	if area_label != null:
		area_label.add_theme_font_size_override("font_size", ScreenTools.responsive_font(self, 22, 16))
	if hint_label != null:
		hint_label.add_theme_font_size_override("font_size", ScreenTools.responsive_font(self, 19, 14))
		hint_label.custom_minimum_size = ScreenTools.responsive_size(self, Vector2(720, 58), Vector2(330, 52))
	if word_label != null:
		word_label.add_theme_font_size_override("font_size", ScreenTools.responsive_font(self, 43, 27))
		word_label.custom_minimum_size = ScreenTools.responsive_size(self, Vector2(720, 86), Vector2(330, 70))
	if keyboard_grid != null:
		keyboard_grid.columns = 9 if ScreenTools.is_narrow(self) else 13
	for button in letter_buttons.values():
		if button is Button:
			ScreenTools.apply_button(button as Button, self, "secondary", Vector2(48, 42), Vector2(35, 33), 17, 13)
	if integrity_bar != null:
		integrity_bar.custom_minimum_size = ScreenTools.responsive_size(self, Vector2(300, 34), Vector2(180, 28))
	if integrity_label != null:
		integrity_label.add_theme_font_size_override("font_size", ScreenTools.responsive_font(self, 28, 20))
	if error_label != null:
		error_label.add_theme_font_size_override("font_size", ScreenTools.responsive_font(self, 18, 14))
	if terminal_label != null:
		terminal_label.add_theme_font_size_override("font_size", ScreenTools.responsive_font(self, 17, 13))
		terminal_label.custom_minimum_size = ScreenTools.responsive_size(self, Vector2(310, 166), Vector2(180, 110))
	var system_title_node: Label = get_node_or_null("SafeArea/MainLayout/ContentRow/SystemPanel/MarginContainer/VBoxContainer/Label")
	if system_title_node != null:
		system_title_node.add_theme_font_size_override("font_size", ScreenTools.responsive_font(self, 19, 14))
	var system_panel: PanelContainer = get_node_or_null("SafeArea/MainLayout/ContentRow/SystemPanel")
	if system_panel != null:
		system_panel.custom_minimum_size = ScreenTools.responsive_size(self, Vector2(350, 430), Vector2(210, 300))
	var question_panel: PanelContainer = get_node_or_null("SafeArea/MainLayout/ContentRow/QuestionPanel")
	if question_panel != null:
		question_panel.custom_minimum_size = ScreenTools.responsive_size(self, Vector2(760, 430), Vector2(390, 300))

func _create_chip_label(text_value: String, bg_color: Color, text_color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(210, 34)
	label.add_theme_color_override("font_color", text_color)
	label.add_theme_stylebox_override("normal", _make_panel_style(bg_color, Color(1, 1, 1, 0.20), 12, 1))
	return label

func _build_keyboard() -> void:
	if keyboard_grid == null:
		return
	for child in keyboard_grid.get_children():
		child.queue_free()
	letter_buttons.clear()
	var letters: Array[String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
	for display_letter in letters:
		var normalized: String = display_letter.to_lower()
		var button: Button = Button.new()
		button.name = "Letter%s" % display_letter
		button.text = display_letter
		button.set_meta("letter", normalized)
		button.pressed.connect(_on_letter_button_pressed.bind(normalized))
		keyboard_grid.add_child(button)
		letter_buttons[normalized] = button

func _on_letter_button_pressed(letter: String) -> void:
	_guess_letter(letter)

func _connect_score_signal() -> void:
	var callable: Callable = Callable(self, "_on_score_changed")
	if not ScoreManager.score_changed.is_connected(callable):
		ScoreManager.score_changed.connect(callable)

func _prepare_questions() -> void:
	total_errors_count = 0
	_configure_difficulty()
	questions.clear()
	var question_type: String = str(DifficultyManager.get_rules().get("pergunta_tipo", "normal"))
	questions = DynamicQuestionBank.pick_rounds("forca_tecnica", question_type, TOTAL_ROUNDS)
	if questions.is_empty():
		var all_words: Array = WORD_BANK.duplicate(true)
		all_words.shuffle()
		var used_areas: Array[String] = []
		for item in all_words:
			if questions.size() >= TOTAL_ROUNDS:
				break
			if not item is Dictionary:
				continue
			var data: Dictionary = item as Dictionary
			var area: String = str(data.get("area", ""))
			if not used_areas.has(area):
				questions.append(data)
				used_areas.append(area)
		if questions.size() < TOTAL_ROUNDS:
			for item in all_words:
				if questions.size() >= TOTAL_ROUNDS:
					break
				if item is Dictionary and not questions.has(item):
					questions.append(item as Dictionary)
	_configure_difficulty()

func _configure_difficulty() -> void:
	var diff: String = DifficultyManager.get_difficulty()
	max_errors = int(ERRORS_BY_DIFFICULTY.get(diff, 10))
	if difficulty_label != null:
		difficulty_label.text = "Dificuldade: %s • Erros: %s" % [DifficultyManager.get_label(), max_errors]
		DifficultyManager.apply_difficulty_chip(difficulty_label)

func _start_round(index: int) -> void:
	if index >= TOTAL_ROUNDS or index >= questions.size():
		_show_finish()
		return
	input_locked = true
	finish_visible = false
	current_round_index = index
	current_question = questions[current_round_index]
	guessed_letters.clear()
	errors_this_word = 0
	_reset_keyboard_buttons()
	_update_round_ui()
	_update_integrity_ui()
	_update_word_display()
	await get_tree().create_timer(0.25, false).timeout
	if is_inside_tree():
		input_locked = false

func _reset_keyboard_buttons() -> void:
	for key in letter_buttons.keys():
		var button: Button = letter_buttons[key] as Button
		if button == null:
			continue
		button.disabled = false
		ScreenTools.apply_button(button, self, "secondary", Vector2(48, 42), Vector2(35, 33), 17, 13)

func _update_round_ui() -> void:
	round_label.text = "RODADA %s/%s" % [current_round_index + 1, TOTAL_ROUNDS]
	area_label.text = "ÁREA: %s" % str(current_question.get("area", "Sistemas de Informação"))
	hint_label.text = "DICA: %s" % str(current_question.get("hint", "Identifique o termo técnico."))
	terminal_label.text = "> boot: forca_tecnica.v0.11.2\n> área carregada: %s\n> aguardando entrada do jogador" % str(current_question.get("area", "SI"))

func _guess_letter(letter: String) -> void:
	if input_locked or finish_visible:
		return
	letter = _normalize_text(letter)
	if letter.length() != 1 or not _is_letter_char(letter):
		return
	if guessed_letters.has(letter):
		return
	guessed_letters[letter] = true
	var is_correct: bool = _word_contains_letter(letter)
	_update_letter_button(letter, is_correct)
	if is_correct:
		if has_node("/root/AudioManager"):
			AudioManager.play_sfx("correto")
		terminal_label.text = "> letra aceita: %s\n> módulo recuperado\n> verificando integridade semântica" % letter.to_upper()
		_update_word_display()
		if _is_word_solved():
			await _complete_round(true)
	else:
		errors_this_word += 1
		total_errors_count += 1
		if has_node("/root/AudioManager"):
			AudioManager.play_sfx("errado")
		if _animations_enabled():
			shake_strength = 10.0 + float(errors_this_word) * 2.0
		_update_integrity_ui()
		if errors_this_word >= max_errors:
			_update_word_display(true)
			await _complete_round(false)

func _update_letter_button(letter: String, is_correct: bool) -> void:
	if not letter_buttons.has(letter):
		return
	var button: Button = letter_buttons[letter] as Button
	if button == null:
		return
	button.disabled = true
	if is_correct:
		button.add_theme_stylebox_override("disabled", _make_button_style(Color(0.0, 0.38, 0.18, 0.95), Color(0.50, 1.0, 0.62), 2))
		button.add_theme_color_override("font_disabled_color", Color(0.88, 1.0, 0.90))
	else:
		button.add_theme_stylebox_override("disabled", _make_button_style(Color(0.52, 0.04, 0.05, 0.95), Color(1.0, 0.36, 0.32), 2))
		button.add_theme_color_override("font_disabled_color", Color(1.0, 0.84, 0.82))

func _complete_round(solved: bool) -> void:
	input_locked = true
	for button in letter_buttons.values():
		if button is Button:
			(button as Button).disabled = true
	var word: String = str(current_question.get("word", ""))
	var explanation: String = _get_current_term_explanation()
	if solved:
		success_count += 1
		var round_points: int = SOLVE_BASE_POINTS + int(round(float(_get_integrity_percent()) / 100.0 * float(INTEGRITY_BONUS_CAP)))
		earned_points += round_points
		ScoreManager.add_points(round_points)
		await _show_feedback(true, "Termo identificado!", "Resposta correta: %s\n%s\nIntegridade preservada: %s%%\n+%s pontos" % [word.to_upper(), explanation, _get_integrity_percent(), round_points])
	else:
		failure_count += 1
		await _show_feedback(false, "Sistema em falha!", "O termo correto era: %s\n%s\nIntegridade comprometida nesta rodada." % [word.to_upper(), explanation])
	if not is_inside_tree():
		return
	feedback_layer.visible = false
	_start_round(current_round_index + 1)

func _show_feedback(success: bool, title: String, body: String) -> void:
	feedback_title_label.text = title
	feedback_body_label.text = body
	feedback_title_label.add_theme_color_override("font_color", Color(0.46, 1.0, 0.62) if success else Color(1.0, 0.25, 0.22))
	feedback_layer.visible = true
	await _wait_for_feedback_continue()

func _show_finish() -> void:
	input_locked = true
	finish_visible = true
	if has_node("/root/AchievementManager") and success_count >= TOTAL_ROUNDS and total_errors_count <= 0:
		AchievementManager.unlock("sistema_intacto")
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("correto")
	var classification: String = _get_final_classification()
	finish_title_label.text = "Forca Tecnica concluída!"
	finish_body_label.text = "Termos identificados: %s/%s\nFalhas de sistema: %s\nPontos obtidos no minigame: %s\nResultado: %s\nPontuação total: %s" % [success_count, TOTAL_ROUNDS, failure_count, earned_points, classification, ScoreManager.get_score()]
	finish_layer.visible = true

func _get_final_classification() -> String:
	if success_count >= 6:
		return "Sistema totalmente estabilizado"
	if success_count >= 4:
		return "Sistema recuperado com sucesso"
	if success_count >= 2:
		return "Sistema parcialmente comprometido"
	return "Sistema em falha crítica"

func _on_finish_continue_pressed() -> void:
	if not finish_visible:
		return
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	GameManager.complete_current_stage(0)


func _update_word_display(reveal_all: bool = false) -> void:
	word_label.text = _get_display_word(reveal_all)

func _get_display_word(reveal_all: bool = false) -> String:
	var word: String = str(current_question.get("word", ""))
	var parts: Array[String] = []
	for i in range(word.length()):
		var original_char: String = word.substr(i, 1)
		var normalized_char: String = _normalize_text(original_char)
		if _is_letter_char(normalized_char):
			if reveal_all or guessed_letters.has(normalized_char):
				parts.append(original_char.to_upper())
			else:
				parts.append("_")
		elif original_char == " ":
			parts.append("   ")
		else:
			parts.append(original_char)
	return " ".join(PackedStringArray(parts))

func _word_contains_letter(letter: String) -> bool:
	var normalized_word: String = _normalize_text(str(current_question.get("word", "")))
	return normalized_word.find(letter) >= 0

func _is_word_solved() -> bool:
	var word: String = str(current_question.get("word", ""))
	for i in range(word.length()):
		var normalized_char: String = _normalize_text(word.substr(i, 1))
		if _is_letter_char(normalized_char) and not guessed_letters.has(normalized_char):
			return false
	return true

func _is_letter_char(value: String) -> bool:
	return value.length() == 1 and "abcdefghijklmnopqrstuvwxyz".find(value) >= 0

func _normalize_text(value: String) -> String:
	var result: String = value.to_lower()
	var pairs := {
		"á": "a", "à": "a", "ã": "a", "â": "a", "ä": "a",
		"é": "e", "è": "e", "ê": "e", "ë": "e",
		"í": "i", "ì": "i", "î": "i", "ï": "i",
		"ó": "o", "ò": "o", "õ": "o", "ô": "o", "ö": "o",
		"ú": "u", "ù": "u", "û": "u", "ü": "u",
		"ç": "c"
	}
	for key in pairs.keys():
		result = result.replace(str(key), str(pairs[key]))
	return result

func _get_current_term_explanation() -> String:
	var word: String = str(current_question.get("word", "termo técnico"))
	var dynamic_explanation: String = str(current_question.get("explanation", "")).strip_edges()
	if dynamic_explanation != "" and dynamic_explanation.to_lower() != word.to_lower():
		return dynamic_explanation
	var hint: String = str(current_question.get("hint", "Representa um conceito importante de Sistemas de Informação."))
	var area: String = str(current_question.get("area", "Sistemas de Informação"))
	return "%s é um termo de %s: %s" % [word.capitalize(), area, hint]

func _update_integrity_ui() -> void:
	var integrity: int = _get_integrity_percent()
	integrity_bar.value = integrity
	integrity_label.text = "%s%%" % integrity
	error_label.text = "Erros: %s/%s" % [errors_this_word, max_errors]
	var state: String = _get_system_state()
	terminal_label.text = "> status: %s\n> integridade: %s%%\n> erros detectados: %s/%s\n> %s" % [state, integrity, errors_this_word, max_errors, _get_system_message()]
	var color: Color = _get_integrity_color()
	integrity_label.add_theme_color_override("font_color", color)
	integrity_bar.add_theme_stylebox_override("fill", _make_progress_style(color))

func _get_integrity_percent() -> int:
	if max_errors <= 0:
		return 0
	return maxi(0, int(round(100.0 - (float(errors_this_word) / float(max_errors)) * 100.0)))

func _get_system_state() -> String:
	var integrity: int = _get_integrity_percent()
	if integrity >= 100:
		return "Sistema íntegro"
	if integrity >= 75:
		return "Pequena instabilidade"
	if integrity >= 50:
		return "Sistema instável"
	if integrity >= 25:
		return "Sistema crítico"
	if integrity > 0:
		return "Falha iminente"
	return "Sistema em falha"

func _get_system_message() -> String:
	var integrity: int = _get_integrity_percent()
	if integrity >= 100:
		return "nenhuma anomalia ativa"
	if integrity >= 75:
		return "anomalia leve detectada"
	if integrity >= 50:
		return "pacotes corrompidos encontrados"
	if integrity >= 25:
		return "integridade crítica no módulo técnico"
	if integrity > 0:
		return "falha iminente no subsistema"
	return "sistema comprometido"

func _get_integrity_color() -> Color:
	var integrity: int = _get_integrity_percent()
	if integrity >= 75:
		return Color(0.42, 1.0, 0.58)
	if integrity >= 50:
		return Color(1.0, 0.84, 0.20)
	if integrity > 0:
		return Color(1.0, 0.38, 0.22)
	return Color(1.0, 0.12, 0.16)

func _build_feedback_layer() -> void:
	feedback_layer = Control.new()
	feedback_layer.name = "FeedbackLayer"
	feedback_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	feedback_layer.visible = false
	feedback_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	feedback_layer.z_index = 50
	add_child(feedback_layer)

	var overlay: ColorRect = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.74)
	feedback_layer.add_child(overlay)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	feedback_layer.add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 340)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.02, 0.04, 0.09, 0.98), Color(0.48, 1.0, 0.82), 22, 3))
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
	feedback_title_label.add_theme_font_size_override("font_size", 40)
	box.add_child(feedback_title_label)

	feedback_body_label = Label.new()
	feedback_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	feedback_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_body_label.add_theme_font_size_override("font_size", 22)
	feedback_body_label.add_theme_color_override("font_color", Color(0.94, 0.98, 1.0))
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
	finish_layer.z_index = 60
	add_child(finish_layer)

	var overlay: ColorRect = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.82)
	finish_layer.add_child(overlay)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	finish_layer.add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(760, 380)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.02, 0.04, 0.09, 0.98), Color(0.48, 1.0, 0.82), 24, 3))
	center.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 38)
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_right", 38)
	margin.add_theme_constant_override("margin_bottom", 32)
	panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 18)
	margin.add_child(box)

	finish_title_label = Label.new()
	finish_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	finish_title_label.add_theme_font_size_override("font_size", 40)
	finish_title_label.add_theme_color_override("font_color", Color(0.48, 1.0, 0.82))
	box.add_child(finish_title_label)

	finish_body_label = Label.new()
	finish_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	finish_body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	finish_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	finish_body_label.add_theme_font_size_override("font_size", 22)
	finish_body_label.add_theme_color_override("font_color", Color(0.94, 0.98, 1.0))
	box.add_child(finish_body_label)

	var continue_button: Button = Button.new()
	continue_button.text = "Continuar"
	continue_button.pressed.connect(_on_finish_continue_pressed)
	box.add_child(continue_button)
	ScreenTools.apply_button(continue_button, self, "success", Vector2(260, 58), Vector2(210, 46), 22, 17)

func _create_symbol_particles() -> void:
	symbol_particles.clear()
	if particle_layer == null:
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(1280, 720)
	for i in range(SYMBOL_PARTICLE_COUNT):
		var label: Label = Label.new()
		label.text = str(TECH_SYMBOLS[i % TECH_SYMBOLS.size()])
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_font_size_override("font_size", randi_range(17, 34))
		label.add_theme_color_override("font_color", Color(0.45, 1.0, 0.86, randf_range(0.14, 0.34)))
		particle_layer.add_child(label)
		var data: Dictionary = {
			"node": label,
			"speed": randf_range(12.0, 42.0),
			"drift": randf_range(-20.0, 20.0),
			"phase": randf_range(0.0, TAU),
			"rotation_speed": randf_range(-0.35, 0.35)
		}
		symbol_particles.append(data)
		_reset_symbol_particle(data, true)

func _reset_symbol_particles() -> void:
	for data in symbol_particles:
		_reset_symbol_particle(data, true)

func _reset_symbol_particle(data: Dictionary, random_y: bool = false) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(1280, 720)
	var label: Label = data["node"] as Label
	if label == null:
		return
	var next_y: float = randf_range(0.0, viewport_size.y) if random_y else viewport_size.y + randf_range(20.0, 120.0)
	label.position = Vector2(randf_range(12.0, viewport_size.x - 40.0), next_y)
	label.rotation = randf_range(-0.20, 0.20)

func _update_symbol_particles(delta: float) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	for data in symbol_particles:
		var label: Label = data["node"] as Label
		if label == null:
			continue
		var pos: Vector2 = label.position
		pos.y -= float(data.get("speed", 22.0)) * delta
		pos.x += sin(elapsed * 1.2 + float(data.get("phase", 0.0))) * float(data.get("drift", 0.0)) * delta
		label.position = pos
		label.rotation += float(data.get("rotation_speed", 0.0)) * delta
		var pulse: float = 0.60 + absf(sin(elapsed * 2.0 + float(data.get("phase", 0.0)))) * 0.40
		label.modulate = Color(1.0, 1.0, 1.0, pulse)
		if pos.y < -80.0 or pos.x < -110.0 or pos.x > viewport_size.x + 110.0:
			_reset_symbol_particle(data)

func _update_effects_canvas() -> void:
	if effects_canvas != null:
		effects_canvas.queue_redraw()

func _on_effects_canvas_draw() -> void:
	if not _animations_enabled():
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	var pulse: float = (sin(elapsed * 2.6) + 1.0) * 0.5
	var integrity_color: Color = _get_integrity_color()
	effects_canvas.draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.0, 0.18, 0.15, 0.035 + pulse * 0.020), true)
	for i in range(7):
		var y: float = viewport_size.y * (0.14 + float(i) * 0.12)
		effects_canvas.draw_line(Vector2(0, y), Vector2(viewport_size.x, y + sin(elapsed + i) * 18.0), Color(integrity_color.r, integrity_color.g, integrity_color.b, 0.065), 2.0)
	for i in range(9):
		var x: float = viewport_size.x * (0.10 + float(i) * 0.10)
		effects_canvas.draw_line(Vector2(x, 0), Vector2(x + sin(elapsed + i) * 18.0, viewport_size.y), Color(0.18, 0.92, 1.0, 0.035), 1.0)
	if errors_this_word >= 4:
		var glitch_alpha: float = 0.05 + pulse * 0.10
		effects_canvas.draw_rect(Rect2(Vector2(0, viewport_size.y * 0.18), Vector2(viewport_size.x, 12.0)), Color(1.0, 0.06, 0.04, glitch_alpha), true)
		effects_canvas.draw_rect(Rect2(Vector2(0, viewport_size.y * 0.72), Vector2(viewport_size.x, 10.0)), Color(1.0, 0.06, 0.04, glitch_alpha), true)

func _update_screen_shake(delta: float) -> void:
	if root_margin == null:
		return
	if shake_strength <= 0.0:
		root_margin.position = base_root_position
		return
	shake_strength = maxf(0.0, shake_strength - 34.0 * delta)
	var offset: Vector2 = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength * 0.65, shake_strength * 0.65))
	root_margin.position = base_root_position + offset

func _on_score_changed(new_score: int) -> void:
	if score_label != null:
		score_label.text = "Pontuação: %s" % new_score

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
	style.shadow_color = Color(0, 0, 0, 0.38)
	style.shadow_size = 10
	return style

func _make_button_style(bg_color: Color, border_color: Color, border_width: int = 2) -> StyleBoxFlat:
	var style: StyleBoxFlat = _make_panel_style(bg_color, border_color, 12, border_width)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 7
	style.content_margin_bottom = 7
	return style

func _make_progress_style(fill_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill_color
	style.set_corner_radius_all(8)
	return style
