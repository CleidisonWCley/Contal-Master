extends Control
var pause_menu: MinigamePause

const DynamicQuestionBank := preload("res://scripts/core/question_bank.gd")
const BACKGROUND_PATH := Paths.BG_ROLETA_RISCO
const WARNING_ICON_PATH := Paths.ICON_DANGER
const RESULT_SECONDS_BEFORE_CONTINUE := 0.25
const ORBIT_SPARK_COUNT := 18
const TENSION_SECONDS := 2.85

const COLOR_PINK := Color(1.0, 0.02, 0.46, 1.0)
const COLOR_BLUE := Color(0.02, 0.12, 0.82, 1.0)
const COLOR_DARK_PURPLE := Color(0.16, 0.02, 0.36, 1.0)
const COLOR_GOLD := Color(1.0, 0.78, 0.16, 1.0)
const COLOR_GOOD := Color(0.28, 0.22, 0.96, 1.0)
const COLOR_BAD := Color(1.0, 0.12, 0.38, 1.0)
const PRACTICE_GOOD := "good"
const PRACTICE_BAD := "bad"
const PRACTICE_TARGET_COUNT := 16

var events: Array[Dictionary] = []
var sector_labels: Array[Label] = []
var orbit_angles: Array[float] = []
var orbit_speeds: Array[float] = []
var burst_particles: Array[Dictionary] = []

var wheel_angle: float = 0.0
var wheel_velocity: float = 0.0
var state: String = "ready"
var tension_elapsed: float = 0.0
var result_elapsed: float = 0.0
var points_this_stage: int = 0
var selected_event: Dictionary = {}

var low_penalty: int = -30
var high_penalty: int = -50
var low_bonus: int = 30
var high_bonus: int = 50

var background_rect: TextureRect
var wheel_canvas: Control
var root_margin: MarginContainer
var title_label: Label
var score_label: Label
var difficulty_label: Label
var status_label: Label
var spin_button: Button
var result_layer: Control
var result_title_label: Label
var result_name_label: Label
var result_description_label: Label
var result_impact_label: Label
var continue_button: Button

func _ready() -> void:
	randomize()
	_prepare_events()
	_build_scene()
	pause_menu = MinigamePause.attach(self)
	_connect_score_signal()
	_on_score_changed(ScoreManager.get_score())
	if has_node("/root/AudioManager"):
		AudioManager.play_music("musica_rodada_bonus")
	_set_status("Gire a roleta para revelar um imprevisto de auditoria.")
	_update_sector_label_positions()
	_request_wheel_redraw()
	# V0.10: tutorial do Julios ANTES do giro (o botao fica bloqueado pelo overlay modal).
	await TutorialManager.play(self, "roleta_risco")

func _process(delta: float) -> void:
	if _animations_enabled():
		_update_orbit(delta)
		_update_particles(delta)
	if state == "spinning":
		wheel_angle = fposmod(wheel_angle + wheel_velocity * delta, 360.0)
		wheel_velocity = move_toward(wheel_velocity, 0.0, 250.0 * delta)
		_update_sector_label_positions()
		if wheel_velocity <= 160.0:
			state = "tension"
			tension_elapsed = 0.0
			wheel_velocity = randf_range(64.0, 92.0)
			_set_status("Agora vem a parte tensa... a roleta está parando devagar.")
	elif state == "tension":
		tension_elapsed += delta
		var ratio: float = clampf(tension_elapsed / TENSION_SECONDS, 0.0, 1.0)
		var slow_factor: float = pow(1.0 - ratio, 2.25)
		wheel_angle = fposmod(wheel_angle + wheel_velocity * slow_factor * delta, 360.0)
		_update_sector_label_positions()
		if tension_elapsed >= TENSION_SECONDS:
			wheel_velocity = 0.0
			_resolve_spin()
	elif state == "result":
		result_elapsed += delta
		if continue_button != null:
			continue_button.disabled = result_elapsed < RESULT_SECONDS_BEFORE_CONTINUE
	_request_wheel_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE, KEY_ENTER, KEY_KP_ENTER:
				if state == "ready":
					_on_spin_pressed()
				elif state == "result" and result_elapsed >= RESULT_SECONDS_BEFORE_CONTINUE:
					_on_continue_pressed()

func _draw() -> void:
	pass

func _on_wheel_canvas_draw() -> void:
	_draw_roleta_canvas()

func _draw_roleta_canvas() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var center: Vector2 = _get_wheel_center(viewport_size)
	var radius: float = _get_wheel_radius(viewport_size)
	if _animations_enabled():
		_draw_neon_glow(center, radius)
	_draw_wheel(center, radius)
	if _animations_enabled():
		_draw_orbit_sparks(center, radius)
	_draw_pointer(center, radius)
	if _animations_enabled():
		_draw_burst_particles()

func _prepare_events() -> void:
	var diff: String = DifficultyManager.get_difficulty()
	if diff == "facil":
		low_penalty = -20
		high_penalty = -35
		low_bonus = 40
		high_bonus = 70
	elif diff == "dificil":
		low_penalty = -70
		high_penalty = -115
		low_bonus = 115
		high_bonus = 180
	else:
		low_penalty = -45
		high_penalty = -75
		low_bonus = 75
		high_bonus = 120

	events = _select_practice_events(diff, PRACTICE_TARGET_COUNT)
	if events.is_empty():
		events = _build_default_practice_events()
	events = _reorder_events_for_tension(events)

	orbit_angles.clear()
	orbit_speeds.clear()
	for _i in range(ORBIT_SPARK_COUNT):
		orbit_angles.append(randf_range(0.0, TAU))
		orbit_speeds.append(randf_range(-1.25, 1.25))

func _select_practice_events(diff: String, target_count: int) -> Array[Dictionary]:
	var source: Array[Dictionary] = _build_practice_event_pool(diff)
	var good_events: Array[Dictionary] = []
	var bad_events: Array[Dictionary] = []
	for item in source:
		var prepared: Dictionary = _prepare_practice_event(item)
		if str(prepared.get("practice", PRACTICE_BAD)) == PRACTICE_GOOD:
			good_events.append(prepared)
		else:
			bad_events.append(prepared)
	good_events.shuffle()
	bad_events.shuffle()
	var half_count: int = int(target_count / 2)
	var selected: Array[Dictionary] = []
	for i in range(half_count):
		if i < good_events.size():
			selected.append(good_events[i])
		if i < bad_events.size():
			selected.append(bad_events[i])
	return selected

func _prepare_practice_event(raw: Dictionary) -> Dictionary:
	var practice_type: String = str(raw.get("practice", PRACTICE_BAD))
	var is_good: bool = practice_type == PRACTICE_GOOD
	var strength: String = str(raw.get("strength", "low"))
	var effect: int = low_penalty
	if is_good and strength == "high":
		effect = high_bonus
	elif is_good:
		effect = low_bonus
	elif strength == "high":
		effect = high_penalty
	return {
		"name": str(raw.get("name", "Evento técnico")),
		"effect": effect,
		"practice": practice_type,
		"description": str(raw.get("description", "Uma decisão técnica afetou a jornada.")),
		"learning": str(raw.get("learning", "Boas práticas reduzem riscos; péssimas práticas cobram seu preço.")),
		"color": COLOR_GOOD if is_good else COLOR_BAD
	}

func _build_practice_event_pool(_diff: String) -> Array[Dictionary]:
	var bank_events: Array[Dictionary] = DynamicQuestionBank.get_roleta_events()
	if bank_events.size() >= PRACTICE_TARGET_COUNT:
		return bank_events
	var pool: Array[Dictionary] = [
		{"name": "Backup atualizado", "practice": PRACTICE_GOOD, "strength": "high", "description": "A equipe manteve cópias de segurança antes de uma mudança importante.", "learning": "Backup reduz perdas, acelera recuperação e protege a continuidade do sistema."},
		{"name": "Deploy validado", "practice": PRACTICE_GOOD, "strength": "high", "description": "A publicação passou por conferência antes de chegar ao usuário.", "learning": "Validar deploy evita falhas em produção e melhora a confiabilidade da entrega."},
		{"name": "Código revisado", "practice": PRACTICE_GOOD, "strength": "low", "description": "Uma revisão encontrou problemas antes que eles virassem bugs reais.", "learning": "Code review melhora qualidade, compartilha conhecimento e reduz dívida técnica."},
		{"name": "Testes passando", "practice": PRACTICE_GOOD, "strength": "high", "description": "Os testes confirmaram que a alteração não quebrou funções importantes.", "learning": "Testes automatizados e regressivos protegem o sistema contra efeitos colaterais."},
		{"name": "Equipe alinhada", "practice": PRACTICE_GOOD, "strength": "low", "description": "A equipe combinou prioridades e evitou retrabalho durante a entrega.", "learning": "Comunicação clara fortalece colaboração e reduz conflitos de interpretação."},
		{"name": "Tarefas divididas", "practice": PRACTICE_GOOD, "strength": "low", "description": "As responsabilidades foram distribuídas de forma equilibrada.", "learning": "Boa divisão de tarefas evita sobrecarga e melhora previsibilidade do projeto."},
		{"name": "Documentação clara", "practice": PRACTICE_GOOD, "strength": "low", "description": "A documentação ajudou a equipe a entender o sistema sem adivinhação.", "learning": "Documentação preserva conhecimento e facilita manutenção futura."},
		{"name": "Refatoração segura", "practice": PRACTICE_GOOD, "strength": "high", "description": "O código foi melhorado sem alterar o comportamento esperado.", "learning": "Refatorar com testes reduz dívida técnica sem criar regressões."},
		{"name": "Liderança colaborativa", "practice": PRACTICE_GOOD, "strength": "high", "description": "A liderança ouviu a equipe, removeu bloqueios e organizou decisões.", "learning": "Boa liderança cria clareza, confiança e responsabilidade compartilhada."},
		{"name": "Dados tratados", "practice": PRACTICE_GOOD, "strength": "low", "description": "A base foi limpa antes da análise e do relatório.", "learning": "Tratamento de dados evita conclusões erradas e melhora a qualidade da informação."},
		{"name": "Senha protegida", "practice": PRACTICE_GOOD, "strength": "high", "description": "Credenciais foram protegidas e não entraram no repositório.", "learning": "Segurança começa com boas práticas de acesso, segredo e autenticação."},
		{"name": "Commit descritivo", "practice": PRACTICE_GOOD, "strength": "low", "description": "O histórico do Git explicou claramente o que mudou.", "learning": "Commits claros ajudam revisão, auditoria e manutenção do projeto."},
		{"name": "Monitoramento ativo", "practice": PRACTICE_GOOD, "strength": "high", "description": "Logs e métricas ajudaram a perceber o problema cedo.", "learning": "Observabilidade acelera diagnóstico e reduz tempo de indisponibilidade."},
		{"name": "Arquitetura modular", "practice": PRACTICE_GOOD, "strength": "high", "description": "O sistema foi organizado em partes com responsabilidades claras.", "learning": "Boa estrutura de software facilita evolução, testes e manutenção."},
		{"name": "POO coesa", "practice": PRACTICE_GOOD, "strength": "low", "description": "Classes e métodos ficaram com responsabilidades bem definidas.", "learning": "Coesão em POO reduz acoplamento desnecessário e melhora legibilidade."},
		{"name": "Feedback registrado", "practice": PRACTICE_GOOD, "strength": "low", "description": "A equipe documentou feedbacks antes de alterar o produto.", "learning": "Registrar feedback evita ruído e ajuda a priorizar melhorias reais."},
		{"name": "Deploy sem teste", "practice": PRACTICE_BAD, "strength": "high", "description": "O sistema foi publicado sem validação e um erro chegou ao usuário.", "learning": "Deploy sem teste aumenta risco de regressão, indisponibilidade e retrabalho."},
		{"name": "Backup ausente", "practice": PRACTICE_BAD, "strength": "high", "description": "Uma falha apagou dados importantes sem plano de recuperação.", "learning": "Sem backup, incidentes simples podem virar perda crítica de informação."},
		{"name": "Código duplicado", "practice": PRACTICE_BAD, "strength": "low", "description": "A mesma lógica apareceu em vários pontos do projeto.", "learning": "Duplicação aumenta custo de manutenção e chance de corrigir só uma parte do problema."},
		{"name": "Senha exposta", "practice": PRACTICE_BAD, "strength": "high", "description": "Uma credencial apareceu em local indevido e virou risco de acesso.", "learning": "Credenciais expostas comprometem segurança e podem afetar todo o sistema."},
		{"name": "Conflito ignorado", "practice": PRACTICE_BAD, "strength": "low", "description": "Um conflito de equipe foi empurrado para depois e gerou retrabalho.", "learning": "Conflitos ignorados pioram comunicação e afetam entregas técnicas."},
		{"name": "Documentação vazia", "practice": PRACTICE_BAD, "strength": "low", "description": "A equipe não registrou decisões e ninguém entendeu a regra depois.", "learning": "Falta de documentação transforma manutenção em adivinhação."},
		{"name": "Dados sem limpeza", "practice": PRACTICE_BAD, "strength": "high", "description": "A análise usou dados duplicados, nulos e inconsistentes.", "learning": "Ciência de dados exige limpeza, validação e contexto antes da conclusão."},
		{"name": "Tarefa confusa", "practice": PRACTICE_BAD, "strength": "low", "description": "Ninguém sabia quem era responsável pela entrega.", "learning": "Tarefa mal definida causa atraso, sobrecarga e perda de qualidade."},
		{"name": "Comunicação falhou", "practice": PRACTICE_BAD, "strength": "low", "description": "Uma decisão importante não chegou a todos da equipe.", "learning": "Comunicação falha cria desalinhamento e decisões técnicas contraditórias."},
		{"name": "Bug crítico ignorado", "practice": PRACTICE_BAD, "strength": "high", "description": "Um problema grave foi deixado para depois e voltou maior.", "learning": "Ignorar bug crítico aumenta impacto, custo de correção e perda de confiança."},
		{"name": "Servidor instável", "practice": PRACTICE_BAD, "strength": "high", "description": "O ambiente ficou indisponível por falta de monitoramento e prevenção.", "learning": "Estabilidade exige monitoramento, redundância e plano de contingência."},
		{"name": "Commit confuso", "practice": PRACTICE_BAD, "strength": "low", "description": "O histórico não explicou o motivo da mudança.", "learning": "Commits confusos dificultam revisão, rollback e entendimento do projeto."},
		{"name": "Pressa sem revisão", "practice": PRACTICE_BAD, "strength": "high", "description": "A equipe acelerou a entrega e pulou revisão técnica.", "learning": "Pressa sem revisão pode transformar pequenas falhas em problemas de produção."},
		{"name": "Responsabilidade difusa", "practice": PRACTICE_BAD, "strength": "low", "description": "Todos achavam que outra pessoa resolveria a pendência.", "learning": "Boa liderança define responsáveis e evita tarefas invisíveis."},
		{"name": "Classe gigante", "practice": PRACTICE_BAD, "strength": "low", "description": "Uma classe acumulou regras demais e ficou difícil de manter.", "learning": "Classes gigantes quebram coesão e dificultam testes, leitura e evolução."},
		{"name": "Relatório enviesado", "practice": PRACTICE_BAD, "strength": "high", "description": "A análise ignorou viés e gerou uma conclusão enganosa.", "learning": "Dados precisam de contexto, ética e validação para orientar boas decisões."}
	]
	return pool

func _build_default_practice_events() -> Array[Dictionary]:
	var prepared_events: Array[Dictionary] = []
	for item in _build_practice_event_pool(DifficultyManager.get_difficulty()):
		prepared_events.append(_prepare_practice_event(item))
	var result: Array[Dictionary] = []
	var limit: int = mini(prepared_events.size(), PRACTICE_TARGET_COUNT)
	for i in range(limit):
		result.append(prepared_events[i])
	return result

func _build_scene() -> void:
	_clear_scene_children()

	background_rect = TextureRect.new()
	background_rect.name = "Background"
	background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	var bg_texture: Resource = load(BACKGROUND_PATH)
	if bg_texture is Texture2D:
		background_rect.texture = bg_texture as Texture2D
	add_child(background_rect)

	var dimmer: ColorRect = ColorRect.new()
	dimmer.name = "Dimmer"
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.0, 0.0, 0.0, 0.50)
	add_child(dimmer)

	wheel_canvas = Control.new()
	wheel_canvas.name = "WheelCanvas"
	wheel_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	wheel_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wheel_canvas.z_index = 1
	wheel_canvas.draw.connect(_on_wheel_canvas_draw)
	add_child(wheel_canvas)

	root_margin = MarginContainer.new()
	root_margin.name = "SafeArea"
	root_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_margin.z_index = 10
	root_margin.add_theme_constant_override("margin_left", 36)
	root_margin.add_theme_constant_override("margin_top", 22)
	root_margin.add_theme_constant_override("margin_right", 36)
	root_margin.add_theme_constant_override("margin_bottom", 22)
	add_child(root_margin)

	var main_box: VBoxContainer = VBoxContainer.new()
	main_box.name = "MainLayout"
	main_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_box.alignment = BoxContainer.ALIGNMENT_CENTER
	main_box.add_theme_constant_override("separation", 10)
	root_margin.add_child(main_box)

	var title_row: HBoxContainer = HBoxContainer.new()
	title_row.name = "TitleRow"
	title_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	title_row.add_theme_constant_override("separation", 12)
	main_box.add_child(title_row)

	title_row.add_child(_create_icon(WARNING_ICON_PATH, Vector2(46, 46)))

	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "RODADA BÔNUS  ►  ROLETA DO RISCO"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 38)
	title_label.add_theme_color_override("font_color", COLOR_GOLD)
	title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.88))
	title_label.add_theme_constant_override("shadow_offset_x", 3)
	title_label.add_theme_constant_override("shadow_offset_y", 3)
	title_row.add_child(title_label)

	title_row.add_child(_create_icon(WARNING_ICON_PATH, Vector2(46, 46)))

	var status_row: HBoxContainer = HBoxContainer.new()
	status_row.name = "StatusRow"
	status_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_row.alignment = BoxContainer.ALIGNMENT_CENTER
	status_row.add_theme_constant_override("separation", 12)
	main_box.add_child(status_row)

	score_label = _create_chip_label("Pontuação: 0", 18, Color(0.04, 0.05, 0.12, 0.94), Color(1.0, 1.0, 1.0))
	status_row.add_child(score_label)

	difficulty_label = _create_chip_label("Dificuldade: %s" % DifficultyManager.get_label(), 18, Color(0.04, 0.05, 0.12, 0.94), Color(1.0, 1.0, 1.0))
	DifficultyManager.apply_difficulty_chip(difficulty_label, "", 18)
	status_row.add_child(difficulty_label)

	var spacer_top: Control = Control.new()
	spacer_top.custom_minimum_size = Vector2(0, 318)
	main_box.add_child(spacer_top)

	status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.text = "Gire a roleta para revelar sua rodada bônus."
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.custom_minimum_size = Vector2(0, 32)
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override("font_color", Color(0.94, 0.96, 1.0, 0.96))
	status_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.82))
	status_label.add_theme_constant_override("shadow_offset_x", 2)
	status_label.add_theme_constant_override("shadow_offset_y", 2)
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_box.add_child(status_label)

	var button_row: HBoxContainer = HBoxContainer.new()
	button_row.name = "ButtonRow"
	button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 16)
	main_box.add_child(button_row)

	spin_button = Button.new()
	spin_button.name = "SpinButton"
	spin_button.text = "GIRAR!"
	spin_button.custom_minimum_size = Vector2(280, 56)
	spin_button.add_theme_font_size_override("font_size", 23)
	spin_button.add_theme_stylebox_override("normal", _make_button_style(Color(0.88, 0.02, 0.32, 0.98), Color(1.0, 1.0, 1.0), 3))
	spin_button.add_theme_stylebox_override("hover", _make_button_style(Color(1.0, 0.12, 0.45, 1.0), COLOR_GOLD, 3))
	spin_button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.62, 0.02, 0.24, 1.0), Color(1.0, 1.0, 1.0), 3))
	spin_button.pressed.connect(_on_spin_pressed)
	button_row.add_child(spin_button)


	_create_sector_labels()
	_build_result_layer()

func _clear_scene_children() -> void:
	for child in get_children():
		child.queue_free()

func _create_icon(path: String, min_size: Vector2) -> TextureRect:
	var icon: TextureRect = TextureRect.new()
	icon.custom_minimum_size = min_size
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var texture: Resource = load(path)
	if texture is Texture2D:
		icon.texture = texture as Texture2D
	return icon

func _create_chip_label(text_value: String, font_size: int, bg_color: Color, text_color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(230, 38)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", text_color)
	label.add_theme_stylebox_override("normal", _make_panel_style(bg_color, Color(1.0, 1.0, 1.0, 0.18), 12, 1))
	return label

func _create_sector_labels() -> void:
	sector_labels.clear()
	for i in range(events.size()):
		var label: Label = Label.new()
		label.name = "SectorLabel%s" % [i + 1]
		label.text = _compact_event_name(str(events[i].get("name", "Evento")))
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.custom_minimum_size = Vector2(92, 34)
		label.size = Vector2(92, 34)
		label.add_theme_font_size_override("font_size", 10)
		label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
		label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.94))
		label.add_theme_constant_override("shadow_offset_x", 1)
		label.add_theme_constant_override("shadow_offset_y", 1)
		add_child(label)
		sector_labels.append(label)

func _compact_event_name(value: String) -> String:
	match value:
		"Backup atualizado":
			return "Backup\natualizado"
		"Deploy validado":
			return "Deploy\nvalidado"
		"Código revisado":
			return "Código\nrevisado"
		"Testes passando":
			return "Testes\npassando"
		"Equipe alinhada":
			return "Equipe\nalinhada"
		"Tarefas divididas":
			return "Tarefas\ndivididas"
		"Documentação clara":
			return "Doc.\nclara"
		"Refatoração segura":
			return "Refatoração\nsegura"
		"Liderança colaborativa":
			return "Liderança\ncolaborativa"
		"Dados tratados":
			return "Dados\ntratados"
		"Senha protegida":
			return "Senha\nprotegida"
		"Commit descritivo":
			return "Commit\ndescritivo"
		"Monitoramento ativo":
			return "Monitoramento\nativo"
		"Arquitetura modular":
			return "Arquitetura\nmodular"
		"POO coesa":
			return "POO\ncoesa"
		"Feedback registrado":
			return "Feedback\nregistrado"
		"Deploy sem teste":
			return "Deploy\nsem teste"
		"Backup ausente":
			return "Backup\nausente"
		"Código duplicado":
			return "Código\nduplicado"
		"Senha exposta":
			return "Senha\nexposta"
		"Conflito ignorado":
			return "Conflito\nignorado"
		"Documentação vazia":
			return "Doc.\nvazia"
		"Dados sem limpeza":
			return "Dados\nsem limpeza"
		"Tarefa confusa":
			return "Tarefa\nconfusa"
		"Comunicação falhou":
			return "Comunicação\nfalhou"
		"Bug crítico ignorado":
			return "Bug crítico\nignorado"
		"Servidor instável":
			return "Servidor\ninstável"
		"Commit confuso":
			return "Commit\nconfuso"
		"Pressa sem revisão":
			return "Pressa\nsem revisão"
		"Responsabilidade difusa":
			return "Respons.\ndifusa"
		"Classe gigante":
			return "Classe\ngigante"
		"Relatório enviesado":
			return "Relatório\nenviesado"
	return value

func _reorder_events_for_tension(source_events: Array[Dictionary]) -> Array[Dictionary]:
	var good_events: Array[Dictionary] = []
	var bad_events: Array[Dictionary] = []
	for event in source_events:
		if int(event.get("effect", 0)) >= 0:
			good_events.append(event)
		else:
			bad_events.append(event)
	good_events.shuffle()
	bad_events.shuffle()
	var result: Array[Dictionary] = []
	var max_count: int = maxi(good_events.size(), bad_events.size())
	for i in range(max_count):
		if i < good_events.size():
			result.append(good_events[i])
		if i < bad_events.size():
			result.append(bad_events[i])
	return result

func _build_result_layer() -> void:
	result_layer = Control.new()
	result_layer.name = "ResultLayer"
	result_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	result_layer.z_index = 200
	result_layer.visible = false
	result_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(result_layer)

	var overlay: ColorRect = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.0, 0.0, 0.0, 0.94)
	result_layer.add_child(overlay)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	result_layer.add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 360)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.02, 0.12, 0.98), COLOR_GOLD, 20, 3))
	center.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_bottom", 28)
	panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 13)
	margin.add_child(box)

	result_title_label = Label.new()
	result_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_title_label.add_theme_font_size_override("font_size", 39)
	box.add_child(result_title_label)

	result_name_label = Label.new()
	result_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_name_label.add_theme_font_size_override("font_size", 29)
	result_name_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	box.add_child(result_name_label)

	result_description_label = Label.new()
	result_description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_description_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_description_label.add_theme_font_size_override("font_size", 22)
	result_description_label.add_theme_color_override("font_color", Color(0.94, 0.96, 1.0))
	box.add_child(result_description_label)

	result_impact_label = Label.new()
	result_impact_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_impact_label.add_theme_font_size_override("font_size", 26)
	box.add_child(result_impact_label)

	continue_button = Button.new()
	continue_button.text = "Continuar"
	continue_button.custom_minimum_size = Vector2(260, 58)
	continue_button.add_theme_font_size_override("font_size", 22)
	continue_button.pressed.connect(_on_continue_pressed)
	box.add_child(continue_button)

func _connect_score_signal() -> void:
	var callable: Callable = Callable(self, "_on_score_changed")
	if not ScoreManager.score_changed.is_connected(callable):
		ScoreManager.score_changed.connect(callable)

func _on_spin_pressed() -> void:
	if state != "ready":
		return
	state = "spinning"
	points_this_stage = 0
	selected_event = {}
	burst_particles.clear()
	_set_sector_labels_visible(true)
	if result_layer != null:
		result_layer.visible = false
	wheel_velocity = randf_range(1520.0, 1980.0)
	spin_button.disabled = true
	_set_status("Roleta girando... prepare-se para o impacto!")
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("roleta")

func _resolve_spin() -> void:
	state = "result"
	result_elapsed = 0.0
	var angle_per_sector: float = 360.0 / float(events.size())
	var result_index: int = int(floor(fposmod(270.0 - wheel_angle, 360.0) / angle_per_sector))
	result_index = clampi(result_index, 0, events.size() - 1)
	selected_event = events[result_index]
	if has_node("/root/AchievementManager"):
		AchievementManager.unlock("boas_praticas")
	points_this_stage = int(selected_event.get("effect", 0))
	if points_this_stage >= 0:
		ScoreManager.add_points(points_this_stage)
	else:
		ScoreManager.subtract_points(abs(points_this_stage), true)
	_spawn_result_particles(result_index, points_this_stage >= 0)
	_show_result_overlay()
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("correto" if points_this_stage >= 0 else "errado")

func _show_result_overlay() -> void:
	var event_name: String = str(selected_event.get("name", "Evento"))
	var description: String = str(selected_event.get("description", ""))
	var impact_prefix: String = "+" if points_this_stage > 0 else ""
	var good_result: bool = points_this_stage >= 0
	result_title_label.text = "BOA PRÁTICA DETECTADA!" if good_result else "PÉSSIMA PRÁTICA IDENTIFICADA!"
	result_title_label.add_theme_color_override("font_color", COLOR_GOOD if good_result else COLOR_BAD)
	result_name_label.text = event_name
	result_description_label.text = "%s\n\nAprendizado: %s" % [description, _get_result_learning(good_result)]
	result_impact_label.text = "Resultado: %s%s pontos" % [impact_prefix, points_this_stage]
	result_impact_label.add_theme_color_override("font_color", COLOR_GOOD if good_result else COLOR_BAD)
	_set_sector_labels_visible(false)
	result_layer.visible = true
	_set_status("Resultado definido. Toque em continuar para seguir.")

func _get_result_learning(good_result: bool) -> String:
	var dynamic_learning: String = str(selected_event.get("learning", ""))
	if dynamic_learning != "":
		return dynamic_learning
	if good_result:
		return "boas práticas técnicas, liderança e comunicação reduzem riscos na jornada do projeto."
	return "péssimas práticas técnicas e falhas de processo cobram pontos, tempo e qualidade."

func _spawn_result_particles(result_index: int, good_result: bool) -> void:
	if not _animations_enabled():
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	var center: Vector2 = _get_wheel_center(viewport_size)
	var radius: float = _get_wheel_radius(viewport_size)
	var angle_per_sector: float = 360.0 / float(events.size())
	var event_angle: float = deg_to_rad(float(result_index) * angle_per_sector + wheel_angle + angle_per_sector * 0.5)
	var origin: Vector2 = center + Vector2(cos(event_angle), sin(event_angle)) * (radius * 0.68)
	var amount: int = 28 if good_result else 36
	var particle_color: Color = Color(1.0, 0.84, 0.25, 1.0) if good_result else Color(1.0, 0.16, 0.14, 1.0)
	for _i in range(amount):
		var angle: float = randf_range(0.0, TAU)
		var speed: float = randf_range(100.0, 260.0) if good_result else randf_range(140.0, 330.0)
		burst_particles.append({
			"position": origin,
			"velocity": Vector2(cos(angle), sin(angle)) * speed,
			"life": randf_range(0.42, 0.78),
			"max_life": 0.78,
			"radius": randf_range(3.0, 7.0),
			"color": particle_color
		})

func _on_continue_pressed() -> void:
	if state != "result" or result_elapsed < RESULT_SECONDS_BEFORE_CONTINUE:
		return
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	GameManager.complete_current_stage(0)


func _on_score_changed(new_score: int) -> void:
	if score_label != null:
		score_label.text = "Pontuação: %s" % new_score

func _set_status(value: String) -> void:
	if status_label != null:
		status_label.text = value

func _get_wheel_center(viewport_size: Vector2) -> Vector2:
	return Vector2(viewport_size.x * 0.5, viewport_size.y * 0.515)

func _get_wheel_radius(viewport_size: Vector2) -> float:
	return minf(viewport_size.x, viewport_size.y) * 0.235

func _draw_neon_glow(center: Vector2, radius: float) -> void:
	var ticks: float = float(Time.get_ticks_msec()) * 0.001
	var pulse: float = (sin(ticks * 4.2) + 1.0) * 0.5
	var glow_color: Color = COLOR_PINK if int(ticks * 2.0) % 2 == 0 else COLOR_BLUE
	for i in range(6):
		var layer_radius: float = radius * (1.22 + float(i) * 0.075)
		var alpha: float = (0.10 - float(i) * 0.012) + pulse * 0.045
		var color: Color = Color(glow_color.r, glow_color.g, glow_color.b, clampf(alpha, 0.0, 0.16))
		wheel_canvas.draw_circle(center, layer_radius, color)

func _draw_wheel(center: Vector2, radius: float) -> void:
	if events.is_empty():
		return
	wheel_canvas.draw_circle(center + Vector2(0.0, 12.0), radius * 1.10, Color(0.0, 0.0, 0.0, 0.50))
	wheel_canvas.draw_circle(center, radius * 1.08, Color(0.46, 0.04, 0.10, 1.0))
	wheel_canvas.draw_circle(center, radius * 1.045, COLOR_GOLD)
	wheel_canvas.draw_circle(center, radius * 0.995, COLOR_DARK_PURPLE)
	var angle_per_sector: float = 360.0 / float(events.size())
	for i in range(events.size()):
		var start_angle: float = deg_to_rad(float(i) * angle_per_sector + wheel_angle)
		var end_angle: float = deg_to_rad(float(i + 1) * angle_per_sector + wheel_angle)
		var points: PackedVector2Array = PackedVector2Array()
		points.append(center)
		var steps: int = 16
		for step in range(steps + 1):
			var ratio: float = float(step) / float(steps)
			var angle: float = lerpf(start_angle, end_angle, ratio)
			points.append(center + Vector2(cos(angle), sin(angle)) * radius)
		var color_value: Variant = events[i].get("color", COLOR_BAD)
		var event_color: Color = COLOR_BAD
		if color_value is Color:
			event_color = color_value
		wheel_canvas.draw_colored_polygon(points, event_color)
		wheel_canvas.draw_polyline(points, Color(1.0, 0.90, 0.18, 0.92), 2.2)

	for i in range(events.size()):
		var divider_angle: float = deg_to_rad(float(i) * angle_per_sector + wheel_angle)
		var outer_point: Vector2 = center + Vector2(cos(divider_angle), sin(divider_angle)) * radius
		wheel_canvas.draw_line(center, outer_point, Color(1.0, 0.86, 0.18, 0.78), 2.4)

	var dot_total: int = maxi(events.size() * 2, 12)
	for i in range(dot_total):
		var dot_angle: float = deg_to_rad(float(i) * 360.0 / float(dot_total) + wheel_angle * 0.25)
		var dot_position: Vector2 = center + Vector2(cos(dot_angle), sin(dot_angle)) * (radius * 1.005)
		wheel_canvas.draw_circle(dot_position, radius * 0.025, Color(1.0, 0.94, 0.12, 1.0))
	wheel_canvas.draw_arc(center, radius * 1.025, 0.0, TAU, 160, COLOR_GOLD, 7.0)
	wheel_canvas.draw_arc(center, radius * 0.92, 0.0, TAU, 160, Color(1.0, 1.0, 1.0, 0.18), 2.0)
	wheel_canvas.draw_circle(center, radius * 0.17, Color(0.56, 0.04, 0.16, 1.0))
	wheel_canvas.draw_circle(center, radius * 0.145, COLOR_GOLD)
	wheel_canvas.draw_circle(center, radius * 0.075, Color(1.0, 0.92, 0.28, 1.0))
	wheel_canvas.draw_circle(center, radius * 0.17, Color(0.18, 0.04, 0.10, 0.92), false, 3.0)

func _draw_pointer(center: Vector2, radius: float) -> void:
	var top: Vector2 = center + Vector2(0.0, -radius - 6.0)
	var points: PackedVector2Array = PackedVector2Array([
		top + Vector2(0.0, 34.0),
		top + Vector2(-22.0, -4.0),
		top + Vector2(22.0, -4.0)
	])
	wheel_canvas.draw_colored_polygon(points, COLOR_GOLD)
	wheel_canvas.draw_polyline(points, Color(0.0, 0.0, 0.0, 0.90), 3.0)

func _draw_orbit_sparks(center: Vector2, radius: float) -> void:
	for i in range(orbit_angles.size()):
		var angle: float = orbit_angles[i]
		var sparkle_radius: float = radius * 1.12 + sin(angle * 2.0) * 8.0
		var spot: Vector2 = center + Vector2(cos(angle), sin(angle)) * sparkle_radius
		var alpha: float = 0.48 + 0.35 * absf(sin(angle * 1.7))
		wheel_canvas.draw_circle(spot, 3.0, Color(1.0, 1.0, 0.62, alpha))

func _draw_burst_particles() -> void:
	for particle in burst_particles:
		var spot: Vector2 = particle["position"]
		var life: float = float(particle.get("life", 0.0))
		var max_life: float = float(particle.get("max_life", 0.78))
		var radius: float = float(particle.get("radius", 4.0))
		var color: Color = COLOR_GOLD
		var color_value: Variant = particle.get("color", COLOR_GOLD)
		if color_value is Color:
			color = color_value
		var alpha: float = clampf(life / max_life, 0.0, 1.0)
		wheel_canvas.draw_circle(spot, radius, Color(color.r, color.g, color.b, alpha))

func _update_orbit(delta: float) -> void:
	for i in range(orbit_angles.size()):
		orbit_angles[i] = fposmod(orbit_angles[i] + orbit_speeds[i] * delta, TAU)

func _update_particles(delta: float) -> void:
	for i in range(burst_particles.size() - 1, -1, -1):
		var particle: Dictionary = burst_particles[i]
		var spot: Vector2 = particle["position"]
		var velocity: Vector2 = particle["velocity"]
		var life: float = float(particle.get("life", 0.0))
		spot += velocity * delta
		velocity *= 0.90
		life -= delta
		if life <= 0.0:
			burst_particles.remove_at(i)
		else:
			particle["position"] = spot
			particle["velocity"] = velocity
			particle["life"] = life
			burst_particles[i] = particle

func _update_sector_label_positions() -> void:
	if sector_labels.is_empty() or events.is_empty():
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	var center: Vector2 = _get_wheel_center(viewport_size)
	var radius: float = _get_wheel_radius(viewport_size)
	var angle_per_sector: float = 360.0 / float(events.size())
	for i in range(sector_labels.size()):
		var label: Label = sector_labels[i]
		var angle: float = deg_to_rad(float(i) * angle_per_sector + wheel_angle + angle_per_sector * 0.5)
		var label_center: Vector2 = center + Vector2(cos(angle), sin(angle)) * (radius * 0.64)
		label.size = Vector2(92, 34)
		label.position = label_center - label.size * 0.5
		label.rotation = 0.0
		label.z_index = 15

func _request_wheel_redraw() -> void:
	if wheel_canvas != null:
		wheel_canvas.queue_redraw()
	else:
		queue_redraw()

func _set_sector_labels_visible(visible_state: bool) -> void:
	for label in sector_labels:
		if label != null:
			label.visible = visible_state

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
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
	style.shadow_size = 8
	return style

func _make_button_style(bg_color: Color, border_color: Color, border_width: int = 2) -> StyleBoxFlat:
	var style: StyleBoxFlat = _make_panel_style(bg_color, border_color, 14, border_width)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style
