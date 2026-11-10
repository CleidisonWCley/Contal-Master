extends Control
var pause_menu: MinigamePause

const DynamicQuestionBank := preload("res://scripts/core/question_bank.gd")

const BACKGROUND_PATH := Paths.BG_PERSEGUICAO
const LOCK_ICON_PATH := Paths.ICON_LOCK
const THREAT_ICON_PATH := Paths.ICON_DANGER
const FEEDBACK_SECONDS := 0.72
const ROAD_LINE_COUNT := 25

const ACTION_EXPLANATIONS := {
	"Verificar backup/autosave": "Backup e autosave podem recuperar versões recentes antes de refazer o trabalho.",
	"Revisar filtros e dados": "Filtros incorretos ou dados ausentes são causas comuns de consultas sem retorno.",
	"Melhorar navegação": "Uma navegação clara ajuda o usuário a entender como voltar e seguir fluxos.",
	"Revisar condição do laço": "Laços infinitos costumam ocorrer quando a condição de parada está errada.",
	"Organizar backlog e responsáveis": "Backlog e responsáveis deixam o trabalho visível e reduzem atrasos.",
	"Reportar phishing": "Phishing deve ser reportado para bloquear a ameaça e orientar usuários.",
	"Analisar gargalo e escalar": "Análise de gargalo identifica o recurso saturado antes de escalar a solução.",
	"Aplicar testes de regressão": "Testes de regressão verificam se mudanças quebraram funções existentes.",
	"Revisar consentimento e privacidade": "Dados pessoais exigem finalidade clara, consentimento e proteção adequada.",
	"Revisar modelo e constraints": "Modelo correto e constraints reduzem duplicidade e inconsistência no banco.",
	"Exigir autenticação e autorização": "APIs sensíveis precisam identificar usuários e limitar permissões.",
	"Validar prioridade com stakeholders": "Stakeholders ajudam a confirmar valor, urgência e impacto dos requisitos.",
	"Acionar plano de contingência": "Contingência define como manter ou recuperar o serviço em crise.",
	"Analisar complexidade e estrutura": "Complexidade e estrutura de dados influenciam diretamente uso de memória.",
	"Bloquear conta e investigar": "Bloquear a conta reduz dano imediato e a investigação identifica a origem.",
	"Revisar escalabilidade": "Escalabilidade prepara a arquitetura para crescer com mais usuários.",
	"Aplicar critérios de acessibilidade": "Critérios de acessibilidade reduzem barreiras para diferentes perfis de usuário.",
	"Avaliar ética, viés e impacto": "IA deve considerar riscos de viés, transparência e efeitos sociais."
}

const ALL_INCIDENTS := {
	"facil": [
		{"descricao": "Um aluno esqueceu de salvar o trabalho antes de fechar o editor.", "opcoes": ["Verificar backup/autosave", "Começar do zero sem procurar"], "correta": "Verificar backup/autosave"},
		{"descricao": "A consulta SQL não retorna nenhum aluno cadastrado.", "opcoes": ["Revisar filtros e dados", "Apagar a tabela"], "correta": "Revisar filtros e dados"},
		{"descricao": "Um usuário não entende como voltar no aplicativo.", "opcoes": ["Melhorar navegação", "Culpar o usuário"], "correta": "Melhorar navegação"},
		{"descricao": "Um algoritmo entrou em repetição sem parar.", "opcoes": ["Revisar condição do laço", "Aumentar o volume"], "correta": "Revisar condição do laço"},
		{"descricao": "A equipe perdeu o prazo por falta de divisão de tarefas.", "opcoes": ["Organizar backlog e responsáveis", "Trabalhar no escuro"], "correta": "Organizar backlog e responsáveis"},
		{"descricao": "Um e-mail suspeito pede senha institucional.", "opcoes": ["Reportar phishing", "Enviar a senha"], "correta": "Reportar phishing"}
	],
	"normal": [
		{"descricao": "O sistema ficou lento após muitos acessos simultâneos.", "opcoes": ["Analisar gargalo e escalar", "Reiniciar sem investigar"], "correta": "Analisar gargalo e escalar"},
		{"descricao": "Uma alteração quebrou uma função que antes funcionava.", "opcoes": ["Aplicar testes de regressão", "Ignorar usuários afetados"], "correta": "Aplicar testes de regressão"},
		{"descricao": "Dados pessoais foram coletados sem explicar finalidade.", "opcoes": ["Revisar consentimento e privacidade", "Publicar tudo"], "correta": "Revisar consentimento e privacidade"},
		{"descricao": "O banco apresenta registros duplicados e relatórios inconsistentes.", "opcoes": ["Revisar modelo e constraints", "Duplicar a planilha"], "correta": "Revisar modelo e constraints"},
		{"descricao": "A API está aceitando requisições sem autenticação.", "opcoes": ["Exigir autenticação e autorização", "Deixar aberto"], "correta": "Exigir autenticação e autorização"},
		{"descricao": "A equipe não sabe qual requisito tem prioridade.", "opcoes": ["Validar prioridade com stakeholders", "Escolher no chute"], "correta": "Validar prioridade com stakeholders"}
	],
	"dificil": [
		{"descricao": "Um serviço crítico caiu durante a apresentação final.", "opcoes": ["Acionar plano de contingência", "Apagar evidências"], "correta": "Acionar plano de contingência"},
		{"descricao": "Um algoritmo consome memória demais com entradas grandes.", "opcoes": ["Analisar complexidade e estrutura", "Adicionar mais botões"], "correta": "Analisar complexidade e estrutura"},
		{"descricao": "Logs indicam tentativa de acesso indevido em conta administrativa.", "opcoes": ["Bloquear conta e investigar", "Compartilhar senha nova"], "correta": "Bloquear conta e investigar"},
		{"descricao": "A arquitetura atual não suporta crescimento de usuários.", "opcoes": ["Revisar escalabilidade", "Ignorar até travar"], "correta": "Revisar escalabilidade"},
		{"descricao": "Uma decisão técnica pode excluir usuários com deficiência.", "opcoes": ["Aplicar critérios de acessibilidade", "Manter barreiras"], "correta": "Aplicar critérios de acessibilidade"},
		{"descricao": "A organização quer adotar IA sem avaliar riscos sociais.", "opcoes": ["Avaliar ética, viés e impacto", "Automatizar sem análise"], "correta": "Avaliar ética, viés e impacto"}
	]
}

var incidents: Array = []
var option_buttons: Array[Button] = []
var road_lines: Array = []
var current_incident_index := 0
var correct_points := 10
var wrong_points := -12
var time_limit := 2.5
var question_elapsed := 0.0
var input_locked := false
var finish_visible := false
var damage_count: int = 0

var root_margin: MarginContainer
var road_layer: Control
var top_siren: ColorRect
var bottom_siren: ColorRect
var title_label: Label
var incident_counter_label: Label
var score_label: Label
var difficulty_label: Label
var incident_label: Label
var timer_progress: ProgressBar
var timer_label: Label
var options_box: HBoxContainer
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
	_prepare_incidents()
	_on_score_changed(ScoreManager.get_score())
	if has_node("/root/AudioManager"):
		AudioManager.play_music("musica_perseguicao")
	_load_incident(0)
	# V0.10: tutorial do Ariel ANTES da rodada; a barra de tempo so comeca a correr depois dele.
	input_locked = true
	await TutorialManager.play(self, "perseguicao")
	if not is_inside_tree():
		return
	question_elapsed = 0.0
	input_locked = false

func _process(delta: float) -> void:
	if _animations_enabled():
		if road_layer != null:
			road_layer.visible = true
		_update_road_lines(delta)
		_update_sirens()
	else:
		if road_layer != null:
			road_layer.visible = false
		if top_siren != null:
			top_siren.color.a = 0.0
		if bottom_siren != null:
			bottom_siren.color.a = 0.0
	if input_locked or finish_visible:
		return
	question_elapsed += delta
	_update_timer()
	if question_elapsed >= time_limit:
		_register_answer("", null, true)

func _unhandled_input(event: InputEvent) -> void:
	if finish_visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1, KEY_KP_1, KEY_A, KEY_LEFT:
				_press_option_by_index(0)
			KEY_2, KEY_KP_2, KEY_B, KEY_RIGHT:
				_press_option_by_index(1)

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
	dimmer.color = Color(0, 0, 0, 0.52)
	add_child(dimmer)

	road_layer = Control.new()
	road_layer.name = "RoadLines"
	road_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	road_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(road_layer)
	_create_road_lines()

	top_siren = ColorRect.new()
	top_siren.name = "TopSiren"
	top_siren.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_siren.custom_minimum_size = Vector2(0, 34)
	# V0.13.4: a altura vem dos OFFSETS (faixa de 34 px colada no topo). Antes se atribuia .size a um Control de
	# ancoras opostas diferentes, o que o Godot avisa e sobrescreve (control.cpp _set_size); a faixa de baixo
	# provavelmente ficava fora da tela. Agora as duas ficam coladas nas bordas.
	top_siren.offset_top = 0.0
	top_siren.offset_bottom = 34.0
	top_siren.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top_siren)

	bottom_siren = ColorRect.new()
	bottom_siren.name = "BottomSiren"
	bottom_siren.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_siren.custom_minimum_size = Vector2(0, 34)
	bottom_siren.offset_top = -34.0
	bottom_siren.offset_bottom = 0.0
	bottom_siren.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bottom_siren)

	root_margin = MarginContainer.new()
	root_margin.name = "SafeArea"
	root_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 46)
	root_margin.add_theme_constant_override("margin_top", 30)
	root_margin.add_theme_constant_override("margin_right", 46)
	root_margin.add_theme_constant_override("margin_bottom", 30)
	add_child(root_margin)

	var main_box := VBoxContainer.new()
	main_box.name = "MainLayout"
	main_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_box.alignment = BoxContainer.ALIGNMENT_CENTER
	main_box.add_theme_constant_override("separation", 14)
	root_margin.add_child(main_box)

	var top_row := HBoxContainer.new()
	top_row.name = "TopRow"
	top_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.alignment = BoxContainer.ALIGNMENT_CENTER
	top_row.add_theme_constant_override("separation", 16)
	main_box.add_child(top_row)

	top_row.add_child(_create_icon(LOCK_ICON_PATH, Vector2(62, 62)))

	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "ALERTA DE SEGURANÇA"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 50)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.05))
	title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.86))
	title_label.add_theme_constant_override("shadow_offset_x", 3)
	title_label.add_theme_constant_override("shadow_offset_y", 3)
	top_row.add_child(title_label)

	top_row.add_child(_create_icon(LOCK_ICON_PATH, Vector2(62, 62)))

	var status_row := HBoxContainer.new()
	status_row.name = "StatusRow"
	status_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_row.alignment = BoxContainer.ALIGNMENT_CENTER
	status_row.add_theme_constant_override("separation", 14)
	main_box.add_child(status_row)

	incident_counter_label = _create_chip_label("INCIDENTE 1/6", 18, Color(0.72, 0.02, 0.02, 0.96), Color(1, 1, 1))
	status_row.add_child(incident_counter_label)

	score_label = _create_chip_label("Pontuação: 0", 18, Color(0.03, 0.06, 0.12, 0.94), Color(1, 1, 1))
	status_row.add_child(score_label)

	difficulty_label = _create_chip_label("Dificuldade: Normal", 18, Color(0.03, 0.06, 0.12, 0.94), Color(1, 1, 1))
	status_row.add_child(difficulty_label)

	var incident_panel := PanelContainer.new()
	incident_panel.name = "IncidentPanel"
	incident_panel.custom_minimum_size = Vector2(840, 174)
	incident_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	incident_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.0, 0.08, 0.04, 0.86), Color(0.0, 1.0, 0.2), 14, 2))
	main_box.add_child(incident_panel)

	var incident_margin := MarginContainer.new()
	incident_margin.add_theme_constant_override("margin_left", 30)
	incident_margin.add_theme_constant_override("margin_top", 20)
	incident_margin.add_theme_constant_override("margin_right", 30)
	incident_margin.add_theme_constant_override("margin_bottom", 20)
	incident_panel.add_child(incident_margin)

	var incident_box := VBoxContainer.new()
	incident_box.alignment = BoxContainer.ALIGNMENT_CENTER
	incident_box.add_theme_constant_override("separation", 10)
	incident_margin.add_child(incident_box)

	var warning_label := Label.new()
	warning_label.text = "> INCIDENTE DETECTADO <"
	warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning_label.add_theme_font_size_override("font_size", 23)
	warning_label.add_theme_color_override("font_color", Color(1.0, 0.1, 0.1))
	incident_box.add_child(warning_label)

	incident_label = Label.new()
	incident_label.name = "IncidentText"
	incident_label.text = ""
	incident_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	incident_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	incident_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	incident_label.add_theme_font_size_override("font_size", 29)
	incident_label.add_theme_color_override("font_color", Color(0.78, 1.0, 0.78))
	incident_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	incident_box.add_child(incident_label)

	options_box = HBoxContainer.new()
	options_box.name = "OptionsBox"
	options_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	options_box.alignment = BoxContainer.ALIGNMENT_CENTER
	options_box.add_theme_constant_override("separation", 34)
	main_box.add_child(options_box)

	var timer_box := VBoxContainer.new()
	timer_box.name = "TimerBox"
	timer_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	timer_box.alignment = BoxContainer.ALIGNMENT_CENTER
	timer_box.add_theme_constant_override("separation", 6)
	main_box.add_child(timer_box)

	timer_label = Label.new()
	timer_label.text = "Tempo: 0.0s"
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.add_theme_font_size_override("font_size", 20)
	timer_label.add_theme_color_override("font_color", Color(1, 1, 1))
	timer_box.add_child(timer_label)

	timer_progress = ProgressBar.new()
	timer_progress.name = "TimerProgress"
	timer_progress.min_value = 0.0
	timer_progress.max_value = 1.0
	timer_progress.value = 1.0
	timer_progress.show_percentage = false
	timer_progress.custom_minimum_size = Vector2(900, 22)
	timer_progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	timer_progress.add_theme_stylebox_override("background", _make_panel_style(Color(0.04, 0.04, 0.06, 0.95), Color(0.20, 0.20, 0.26), 10, 1))
	timer_progress.add_theme_stylebox_override("fill", _make_panel_style(Color(0.0, 0.86, 0.22), Color(0.0, 1.0, 0.52), 10, 0))
	timer_box.add_child(timer_progress)

	var hint_label := Label.new()
	hint_label.text = "Decida rápido antes do tempo acabar. Atalhos: 1/A/← para a primeira opção, 2/B/→ para a segunda."
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label.add_theme_font_size_override("font_size", 17)
	hint_label.add_theme_color_override("font_color", Color(0.90, 0.94, 1.0, 0.92))
	main_box.add_child(hint_label)


	_build_feedback_layer()
	_build_finish_layer()

func _clear_scene_children() -> void:
	for child in get_children():
		child.queue_free()

func _create_icon(path: String, min_size: Vector2) -> TextureRect:
	var icon := TextureRect.new()
	icon.custom_minimum_size = min_size
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var texture = load(path)
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
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.72)
	feedback_layer.add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	feedback_layer.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(760, 330)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.06, 0.10, 0.98), Color(1.0, 0.1, 0.1), 20, 3))
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
	feedback_title_label.add_theme_font_size_override("font_size", 43)
	box.add_child(feedback_title_label)

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

	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.80)
	finish_layer.add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	finish_layer.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 330)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.06, 0.10, 0.98), Color(1.0, 0.84, 0.05), 22, 3))
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
	title.text = "Relatório da Perseguição"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.05))
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

func _prepare_incidents() -> void:
	damage_count = 0
	var rules := DifficultyManager.get_rules()
	var incident_type := str(rules.get("pergunta_tipo", "normal"))
	incidents = DynamicQuestionBank.pick_rounds("perseguicao", incident_type, 6)
	if incidents.is_empty():
		incidents = ALL_INCIDENTS.get(incident_type, ALL_INCIDENTS["normal"]).duplicate(true)
		incidents.shuffle()

	time_limit = float(rules.get("perseguicao_tempo", 2.5))
	correct_points = DifficultyManager.get_correct_points("perseguicao")
	wrong_points = DifficultyManager.get_wrong_points("perseguicao")
	if difficulty_label != null:
		difficulty_label.text = "Dificuldade: %s" % DifficultyManager.get_label()
		DifficultyManager.apply_difficulty_chip(difficulty_label)

func _load_incident(index: int) -> void:
	if index >= incidents.size():
		_show_finish()
		return

	input_locked = false
	current_incident_index = index
	question_elapsed = 0.0
	var current_incident: Dictionary = incidents[current_incident_index]
	incident_counter_label.text = "INCIDENTE %s/%s" % [current_incident_index + 1, incidents.size()]
	incident_label.text = str(current_incident["descricao"])
	_clear_options()

	var options: Array = _get_two_safe_options(current_incident)
	for i in range(options.size()):
		var option_text: String = str(options[i])
		var button := Button.new()
		button.name = "Option%s" % [i + 1]
		var action_label: String = "AÇÃO A" if i == 0 else "AÇÃO B"
		button.text = "%s\n%s" % [action_label, option_text]
		button.custom_minimum_size = Vector2(500, 118)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.clip_text = true
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_theme_font_size_override("font_size", 22)
		button.add_theme_stylebox_override("normal", _make_option_button_style(Color(0.04, 0.11, 0.25, 0.92), Color(0.15, 0.70, 1.0)))
		button.add_theme_stylebox_override("hover", _make_option_button_style(Color(0.10, 0.22, 0.42, 0.98), Color(0.90, 0.95, 1.0), 3))
		button.add_theme_stylebox_override("pressed", _make_option_button_style(Color(0.18, 0.30, 0.55, 1.0), Color(1, 1, 1), 3))
		button.add_theme_stylebox_override("disabled", _make_option_button_style(Color(0.04, 0.07, 0.14, 0.65), Color(0.25, 0.35, 0.48)))
		button.add_theme_color_override("font_color", Color(1, 1, 1))
		button.add_theme_color_override("font_hover_color", Color(1, 1, 1))
		button.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
		button.icon = load(THREAT_ICON_PATH)
		button.expand_icon = true
		button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		button.set_meta("answer_text", option_text)
		button.pressed.connect(_on_option_pressed.bind(option_text, button))
		options_box.add_child(button)
		option_buttons.append(button)
	_update_timer()

func _get_two_safe_options(current_incident: Dictionary) -> Array:
	var raw_options: Array = []
	var raw_value: Variant = current_incident.get("opcoes", [])
	if raw_value is Array:
		raw_options = (raw_value as Array).duplicate(true)
	var correct_text: String = str(current_incident.get("correta", "")).strip_edges()
	var wrong_options: Array[String] = []
	for option in raw_options:
		var option_text: String = str(option).strip_edges()
		if option_text == "":
			continue
		if option_text == correct_text:
			continue
		if not wrong_options.has(option_text):
			wrong_options.append(option_text)
	wrong_options.shuffle()
	var result: Array = []
	if correct_text != "":
		result.append(correct_text)
	if not wrong_options.is_empty():
		result.append(wrong_options[0])
	elif raw_options.size() > 0:
		for option in raw_options:
			var fallback_text: String = str(option).strip_edges()
			if fallback_text != "" and not result.has(fallback_text):
				result.append(fallback_text)
				break
	if result.size() < 2:
		result.append("Ignorar o incidente")
	result.shuffle()
	return result.slice(0, 2)

func _clear_options() -> void:
	for child in options_box.get_children():
		child.queue_free()
	option_buttons.clear()

func _on_option_pressed(selected_text: String, selected_button: Button) -> void:
	_register_answer(selected_text, selected_button, false)

func _register_answer(selected_text: String, selected_button, timed_out: bool) -> void:
	if input_locked or finish_visible:
		return
	input_locked = true
	for button in option_buttons:
		button.disabled = true

	var current_incident: Dictionary = incidents[current_incident_index]
	var correct_text := str(current_incident["correta"])
	var is_correct := selected_text == correct_text and not timed_out
	var remaining_ratio: float = _get_remaining_time_ratio()
	var awarded_points: int = correct_points
	if is_correct:
		awarded_points = DifficultyManager.get_chase_time_adjusted_points(correct_points, remaining_ratio)

	_highlight_answer(selected_button, correct_text, is_correct, timed_out)

	if is_correct:
		ScoreManager.add_points(awarded_points)
		if has_node("/root/AudioManager"):
			AudioManager.play_sfx("correto")
	else:
		damage_count += 1
		ScoreManager.subtract_points(abs(wrong_points), true)
		if has_node("/root/AudioManager"):
			AudioManager.play_sfx("errado")
		_start_screen_shake()

	await _show_feedback(is_correct, selected_text, correct_text, timed_out, remaining_ratio, awarded_points)
	if not is_inside_tree():
		return
	feedback_layer.visible = false
	_load_incident(current_incident_index + 1)

func _highlight_answer(selected_button, correct_text: String, is_correct: bool, timed_out: bool) -> void:
	for button in option_buttons:
		var answer := str(button.get_meta("answer_text"))
		if answer == correct_text:
			button.add_theme_stylebox_override("disabled", _make_option_button_style(Color(0.0, 0.44, 0.14, 0.98), Color(0.56, 1.0, 0.62), 3))
		elif button == selected_button and not is_correct and not timed_out:
			button.add_theme_stylebox_override("disabled", _make_option_button_style(Color(0.54, 0.02, 0.02, 0.98), Color(1.0, 0.52, 0.52), 3))

func _show_feedback(is_correct: bool, selected_text: String, correct_text: String, timed_out: bool, _remaining_ratio: float, awarded_points: int) -> void:
	var current_incident: Dictionary = incidents[current_incident_index]
	var explanation: String = _clean_feedback_explanation(correct_text, str(current_incident.get("explanation", _get_action_explanation(correct_text))))
	if is_correct:
		feedback_title_label.text = "AMEAÇA BLOQUEADA"
		feedback_title_label.add_theme_color_override("font_color", Color(0.42, 1.0, 0.48))
		feedback_body_label.text = "Ação correta: %s\n%s\nPontuação adquirida: +%s" % [correct_text, explanation, awarded_points]
	else:
		feedback_title_label.text = "TEMPO ESGOTADO" if timed_out else "ERRO CRÍTICO"
		feedback_title_label.add_theme_color_override("font_color", Color(1.0, 0.24, 0.20))
		if timed_out:
			feedback_body_label.text = "Você demorou demais.\n\nAção segura: %s\n%s\n%s pontos" % [correct_text, explanation, wrong_points]
		else:
			feedback_body_label.text = "Você escolheu: %s\nEssa decisão aumenta o risco do incidente.\n\nAção segura: %s\n%s\n%s pontos" % [selected_text, correct_text, explanation, wrong_points]
	feedback_layer.visible = true
	await _wait_for_feedback_continue()

func _clean_feedback_explanation(answer_text: String, explanation_text: String) -> String:
	var answer := answer_text.strip_edges()
	var explanation := explanation_text.strip_edges()
	if explanation == "" or explanation.to_lower() == answer.to_lower():
		return "%s reduz melhor o risco do incidente apresentado." % answer
	return explanation

func _get_action_explanation(correct_text: String) -> String:
	return str(ACTION_EXPLANATIONS.get(correct_text, "%s é a ação mais segura para reduzir o risco apresentado." % correct_text))

func _show_finish() -> void:
	input_locked = true
	finish_visible = true
	if has_node("/root/AchievementManager") and damage_count <= 0:
		AchievementManager.unlock("perigo_iminente")
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
	_on_option_pressed(str(button.get_meta("answer_text")), button)

func _on_score_changed(new_score: int) -> void:
	if score_label != null:
		score_label.text = "Pontuação: %s" % new_score

func _get_remaining_time_ratio() -> float:
	if time_limit <= 0.0:
		return 0.0
	var remaining: float = maxf(0.0, time_limit - question_elapsed)
	return clampf(remaining / time_limit, 0.0, 1.0)

func _update_timer() -> void:
	if timer_progress == null or timer_label == null:
		return
	var remaining: float = maxf(0.0, time_limit - question_elapsed)
	var ratio: float = 0.0
	if time_limit > 0.0:
		ratio = clampf(remaining / time_limit, 0.0, 1.0)
	timer_progress.value = ratio
	timer_label.text = "Tempo: %.1fs" % remaining
	var fill_color := Color(0.0, 0.86, 0.22)
	if ratio < 0.60:
		fill_color = Color(1.0, 0.84, 0.05)
	if ratio < 0.25:
		fill_color = Color(1.0, 0.10, 0.08)
	timer_progress.add_theme_stylebox_override("fill", _make_panel_style(fill_color, Color(1, 1, 1, 0.10), 10, 0))

func _create_road_lines() -> void:
	road_lines.clear()
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0 or viewport_size.y <= 0:
		viewport_size = Vector2(1280, 720)
	for i in range(ROAD_LINE_COUNT):
		var line := ColorRect.new()
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.color = Color(0.16, 0.16, 0.25, randf_range(0.28, 0.55))
		road_layer.add_child(line)
		road_lines.append({"node": line, "speed": randf_range(210.0, 420.0), "width": randi_range(2, 4), "length": randf_range(30.0, 78.0)})
		_reset_road_line(road_lines[road_lines.size() - 1], true)

func _reset_road_line(data: Dictionary, random_y: bool = false) -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0 or viewport_size.y <= 0:
		viewport_size = Vector2(1280, 720)
	var line: ColorRect = data["node"]
	line.size = Vector2(float(data["width"]), float(data["length"]))
	line.position = Vector2(randf_range(0, viewport_size.x), randf_range(-viewport_size.y, viewport_size.y) if random_y else -float(data["length"]))

func _update_road_lines(delta: float) -> void:
	if road_lines.is_empty():
		return
	var viewport_size := get_viewport_rect().size
	for data in road_lines:
		var line: ColorRect = data["node"]
		var pos := line.position
		pos.y += float(data["speed"]) * delta
		if pos.y > viewport_size.y + 90:
			_reset_road_line(data)
		else:
			line.position = pos

func _update_sirens() -> void:
	if top_siren == null or bottom_siren == null:
		return
	var t: float = float(Time.get_ticks_msec()) * 0.001
	var alpha: float = absf(sin(t * 5.0)) * 0.42
	var color: Color = Color(1.0, 0.0, 0.0, alpha) if int(t * 2.0) % 2 == 0 else Color(0.0, 0.15, 1.0, alpha)
	top_siren.color = color
	bottom_siren.color = color

func _start_screen_shake() -> void:
	if not _animations_enabled():
		return
	var original_position := root_margin.position
	var tween := create_tween()
	for i in range(10):
		var offset := Vector2(randf_range(-12, 12), randf_range(-8, 8))
		tween.tween_property(root_margin, "position", original_position + offset, 0.028)
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

func _make_option_button_style(bg_color: Color, border_color: Color, border_width: int = 2) -> StyleBoxFlat:
	var style := _make_button_style(bg_color, border_color, border_width)
	style.set_corner_radius_all(16)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style
