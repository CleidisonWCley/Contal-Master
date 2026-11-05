extends Control
class_name DesvioLogicoGame
const DynamicQuestionBank := preload("res://scripts/core/question_bank.gd")
var traffic: DLTraffic = DLTraffic.new(self)
var sideprops: DLSideProps = DLSideProps.new(self)
var engineaudio: DLEngineAudio = DLEngineAudio.new(self)
var waterfx: DLWaterFX = DLWaterFX.new(self)
var difficulty: String = "normal"
var questions: Array = []
var current_round: int = 0
var current_lane: int = DLConfig.LANE_RIGHT
var state: String = DLConfig.STATE_DRIVE
var drive_elapsed: float = 0.0
var integrity: float = 100.0
var collisions: int = 0
var correct_count: int = 0
var local_points: int = 0
var input_locked: bool = false
var obstacle_data: Array = []
var tutorial_arrow_textures: Dictionary = {}
var tutorial_alpha: float = 0.0
var tutorial_direction: int = DLConfig.LANE_CENTER
var tutorial_message: String = ""
var tutorial_submessage: String = ""
var acceleration_elapsed: float = 0.0
var acceleration_duration: float = 2.30
var acceleration_ratio: float = 1.0
var road_time: float = 0.0
var route_result_applied: bool = false
var wrong_route_damage_applied_this_question: bool = false
var last_route_damage_loss: float = 0.0
var gameplay_paused: bool = false
var car_y_ratio: float = 0.78
var car_visual_bob: float = 0.0
var feedback_continue_requested: bool = false
var finish_was_failure: bool = false
var lane_change_active: bool = false
var lane_change_tween: Tween
var car_tilt_tween: Tween
var last_turn_choice: String = ""
var background_rect: TextureRect
var dimmer: ColorRect
var water_layer: Control
var road_layer: Control
var side_props_layer: Control
var obstacles_layer: Control
var lane_click_layer: Control
var car_rect: TextureRect
var hud_layer: Control
var route_progress_hud: Control
var route_car_texture: Texture2D
var question_panel: PanelContainer
var status_panel: PanelContainer
var title_label: Label
var round_label: Label
var score_label: Label
var timer_label: Label
var question_label: Label
var status_label: Label
var decision_layer: Control
var option_a_button: Button
var option_b_button: Button
var feedback_layer: Control
var feedback_title_label: Label
var feedback_body_label: Label
var feedback_continue_button: Button
var finish_layer: Control
var finish_title_label: Label
var finish_body_label: Label
var finish_continue_button: Button
var damage_hud: Control
var damage_car_texture: Texture2D
var score_hud: Control
var pause_button: Button
var pause_layer: Control
var pause_menu: MinigamePause
var tutorial_layer: Control
var fade_rect: ColorRect
func _ready() -> void:
	randomize()
	difficulty = DifficultyManager.get_difficulty() if has_node("/root/DifficultyManager") else "normal"
	_build_scene()
	_prepare_questions()
	if has_node("/root/AudioManager"):
		AudioManager.play_music("desvio_logico")
		engineaudio._configure_desvio_music_audio_profile()
	_start_round(0)

func _process(delta: float) -> void:
	if gameplay_paused:
		return
	waterfx.water_time += delta
	var was_accelerating: bool = state == DLConfig.STATE_ACCELERATION
	if was_accelerating:
		_update_acceleration_start(delta)
	engineaudio._ensure_engine_audio_state()
	var motion_delta: float = _motion_delta(delta)
	var is_motion_state: bool = state == DLConfig.STATE_ACCELERATION or state == DLConfig.STATE_DRIVE or _is_tutorial_state()
	if is_motion_state:
		road_time += motion_delta
		_update_background_motion_fx(motion_delta)
		_update_car_motion_fx(motion_delta)
		if state == DLConfig.STATE_ACCELERATION or state == DLConfig.STATE_DRIVE:
			sideprops.side_prop_time += motion_delta
			sideprops._update_side_motion_props(motion_delta)
	if _is_tutorial_car_state():
		_update_obstacles(delta)
	if water_layer != null and DLConfig.WATER_EFFECT_QUALITY > 0:
		waterfx.water_redraw_accumulator += delta
		if waterfx.water_redraw_accumulator >= DLConfig.WATER_REDRAW_INTERVAL:
			waterfx.water_redraw_accumulator = 0.0
			water_layer.queue_redraw()
	if road_layer != null:
		road_layer.queue_redraw()
	if side_props_layer != null:
		side_props_layer.queue_redraw()
	if tutorial_layer != null:
		tutorial_layer.queue_redraw()
	if route_progress_hud != null:
		route_progress_hud.queue_redraw()
	if score_hud != null:
		score_hud.queue_redraw()
	if damage_hud != null:
		damage_hud.queue_redraw()
	if state == DLConfig.STATE_DRIVE and not input_locked and not was_accelerating:
		_update_drive(delta)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_background_motion_fx(0.0)
		_layout_car(false)
	elif what == NOTIFICATION_EXIT_TREE:
		engineaudio._stop_engine_audio()
		engineaudio._clear_desvio_music_audio_profile()

func _input(event: InputEvent) -> void:
	if gameplay_paused:
		# Esc com o pause aberto e tratado pelo proprio componente (fecha o menu).
		return
	if input_locked or state == DLConfig.STATE_FEEDBACK or state == DLConfig.STATE_FINISH or state == DLConfig.STATE_FAILURE or state == DLConfig.STATE_TURN_EXIT:
		return
	if event.is_action_pressed("ui_cancel"):
		pause_menu.open()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event: InputEventKey = event as InputEventKey
		match key_event.keycode:
			KEY_A, KEY_LEFT:
				_handle_lane_or_choice(DLConfig.LANE_LEFT)
				get_viewport().set_input_as_handled()
			KEY_D, KEY_RIGHT:
				_handle_lane_or_choice(DLConfig.LANE_RIGHT)
				get_viewport().set_input_as_handled()
			KEY_S, KEY_DOWN, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER:
				_show_center_hint()
				get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if _is_gameplay_pointer(mouse_event.position):
			_handle_pointer(mouse_event.position)
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch and event.pressed:
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		if _is_gameplay_pointer(touch_event.position):
			_handle_pointer(touch_event.position)
			get_viewport().set_input_as_handled()

func _build_scene() -> void:
	background_rect = TextureRect.new()
	background_rect.name = "Background"
	background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(background_rect)

	dimmer = ColorRect.new()
	dimmer.name = "Dimmer"
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.0, 0.0, 0.0, 0.018)
	dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dimmer)

	# V1.0.2.5.1: shader/máscara d'água removido após teste visual.
	# Mantemos apenas os brilhos horizontais desenhados pela camada WaterSurfaceOverlay.

	# V0.13.12.2: camada própria de mar vivo.
	# Ela fica acima do background/dimmer para aparecer, mas abaixo de pista/postes/carros/HUD.
	# Assim os postes dinâmicos continuam limpos e o efeito não vira filtro global.
	water_layer = Control.new()
	water_layer.name = "WaterSurfaceOverlay"
	water_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	water_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	water_layer.draw.connect(waterfx._on_water_layer_draw)
	add_child(water_layer)

	road_layer = Control.new()
	road_layer.name = "LaneOverlay"
	road_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	road_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	road_layer.draw.connect(_on_road_layer_draw)
	add_child(road_layer)

	side_props_layer = Control.new()
	side_props_layer.name = "SideMotionProps"
	side_props_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	side_props_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	side_props_layer.draw.connect(sideprops._on_side_props_layer_draw)
	add_child(side_props_layer)

	sideprops._load_side_prop_textures()
	_load_tutorial_arrow_textures()

	obstacles_layer = Control.new()
	obstacles_layer.name = "Obstacles"
	obstacles_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	obstacles_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(obstacles_layer)

	car_rect = TextureRect.new()
	car_rect.name = "Velox01"
	car_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	car_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	car_rect.custom_minimum_size = Vector2(116, 86)
	car_rect.z_index = 20
	car_rect.texture = _load_texture(DLConfig.CAR_SPRITES["reto"])
	add_child(car_rect)

	_build_lane_click_layer()
	_build_hud()
	_build_decision_layer()
	_build_feedback_layer()
	_build_finish_layer()
	_build_fade_layer()
	engineaudio._build_engine_audio()

func _build_hud() -> void:
	hud_layer = Control.new()
	hud_layer.name = "HUD"
	hud_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_layer.z_index = 30
	add_child(hud_layer)

	_build_route_progress_hud()
	_build_score_hud()
	_build_question_panel()
	_build_status_panel()
	_build_damage_hud()
	_build_tutorial_layer()
	_build_pause_button()

func _build_route_progress_hud() -> void:
	route_car_texture = _load_texture(str(DLConfig.CAR_SPRITES["lateral_direita"]))
	route_progress_hud = Control.new()
	route_progress_hud.name = "RouteProgressHUD"
	route_progress_hud.anchor_left = 0.20
	route_progress_hud.anchor_top = 0.025
	route_progress_hud.anchor_right = 0.80
	route_progress_hud.anchor_bottom = 0.135
	route_progress_hud.z_index = 36
	route_progress_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	route_progress_hud.draw.connect(_on_route_progress_hud_draw)
	hud_layer.add_child(route_progress_hud)

func _build_score_hud() -> void:
	score_hud = Control.new()
	score_hud.name = "ScoreHUD"
	score_hud.anchor_left = 0.018
	score_hud.anchor_top = 0.024
	score_hud.anchor_right = 0.018
	score_hud.anchor_bottom = 0.024
	score_hud.offset_left = 0.0
	score_hud.offset_top = 0.0
	score_hud.offset_right = 205.0
	score_hud.offset_bottom = 42.0
	score_hud.z_index = 38
	score_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	score_hud.draw.connect(_on_score_hud_draw)
	hud_layer.add_child(score_hud)

func _on_score_hud_draw() -> void:
	if score_hud == null:
		return
	var hud_size: Vector2 = score_hud.size
	if hud_size.x <= 0.0 or hud_size.y <= 0.0:
		return
	var panel_rect := Rect2(Vector2.ZERO, hud_size)
	score_hud.draw_rect(panel_rect, Color(0.01, 0.025, 0.060, 0.18), true)
	score_hud.draw_rect(panel_rect, Color(0.0, 0.92, 1.0, 0.48), false, 1.0)
	var font: Font = get_theme_default_font()
	var score_value: int = ScoreManager.get_score() if has_node("/root/ScoreManager") else local_points
	var text := "Score: %s pts" % score_value
	score_hud.draw_string(font, Vector2(12.0, 27.0) + Vector2(1.5, 1.5), text, HORIZONTAL_ALIGNMENT_LEFT, hud_size.x - 22.0, 15, Color(0.0, 0.0, 0.0, 0.58))
	score_hud.draw_string(font, Vector2(12.0, 27.0), text, HORIZONTAL_ALIGNMENT_LEFT, hud_size.x - 22.0, 15, Color(0.78, 1.0, 0.88, 0.96))

func _build_question_panel() -> void:
	question_panel = PanelContainer.new()
	question_panel.name = "QuestionPanel"
	question_panel.anchor_left = 0.11
	question_panel.anchor_top = 0.025
	question_panel.anchor_right = 0.89
	question_panel.anchor_bottom = 0.155
	question_panel.z_index = 37
	question_panel.visible = false
	question_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.015, 0.025, 0.075, 0.72), Color(0.0, 0.9, 1.0, 0.74), 18, 2))
	hud_layer.add_child(question_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 10)
	question_panel.add_child(margin)

	question_label = _make_label("", 19, Color(1.0, 1.0, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	question_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	question_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	margin.add_child(question_label)

func _build_status_panel() -> void:
	status_panel = PanelContainer.new()
	status_panel.name = "StatusPanel"
	# V0.13.4.15: card compacto com safe area inferior maior; evita colar no rodapé.
	status_panel.anchor_left = 0.025
	status_panel.anchor_top = 1.0
	status_panel.anchor_right = 0.025
	status_panel.anchor_bottom = 1.0
	status_panel.offset_left = 0.0
	status_panel.offset_top = -220.0
	status_panel.offset_right = 320.0
	status_panel.offset_bottom = -64.0
	status_panel.z_index = 34
	status_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_panel.add_theme_stylebox_override("panel", _make_hud_card_style(Color(0.01, 0.025, 0.060, 0.12), Color(0.0, 0.92, 1.0, 0.64), 16, 1))
	hud_layer.add_child(status_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 9)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 9)
	status_panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	margin.add_child(box)

	title_label = _make_label("DESVIO LÓGICO", 16, Color(0.0, 0.95, 1.0), HORIZONTAL_ALIGNMENT_LEFT)
	box.add_child(title_label)

	round_label = _make_label("Desafio 1/6", 17, Color(1.0, 0.93, 0.55), HORIZONTAL_ALIGNMENT_LEFT)
	box.add_child(round_label)

	score_label = _make_label("Dificuldade: Normal", 15, Color(0.93, 0.98, 1.0), HORIZONTAL_ALIGNMENT_LEFT)
	DifficultyManager.apply_difficulty_chip(score_label, difficulty, 15)
	box.add_child(score_label)

	timer_label = _make_label("", 14, Color(0.74, 0.95, 1.0), HORIZONTAL_ALIGNMENT_LEFT)
	timer_label.visible = false
	box.add_child(timer_label)

	status_label = _make_label("Dirija até a decisão.", 13, Color(0.84, 0.90, 1.0, 0.88), HORIZONTAL_ALIGNMENT_LEFT)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(status_label)

func _build_lane_click_layer() -> void:
	lane_click_layer = Control.new()
	lane_click_layer.name = "LaneClickLayer"
	lane_click_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	lane_click_layer.z_index = 28
	add_child(lane_click_layer)

	var left_button: Button = _make_lane_button(DLConfig.LANE_LEFT)
	left_button.anchor_left = 0.0
	left_button.anchor_top = 0.26
	left_button.anchor_right = 0.50
	left_button.anchor_bottom = 1.0
	lane_click_layer.add_child(left_button)

	var right_button: Button = _make_lane_button(DLConfig.LANE_RIGHT)
	right_button.anchor_left = 0.50
	right_button.anchor_top = 0.26
	right_button.anchor_right = 1.0
	right_button.anchor_bottom = 1.0
	lane_click_layer.add_child(right_button)

func _make_lane_button(lane: int) -> Button:
	var button: Button = Button.new()
	button.text = ""
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	# V0.13.4.14: o botão de clique cobre grande parte da tela para captar as faixas.
	# Ele precisa ser 100% invisível: StyleBoxFlat herdava sombra de _make_panel_style()
	# e criava o bloco escuro fantasma sobre o cenário.
	button.flat = true
	var clear_style: StyleBoxEmpty = StyleBoxEmpty.new()
	button.add_theme_stylebox_override("normal", clear_style)
	button.add_theme_stylebox_override("hover", clear_style)
	button.add_theme_stylebox_override("pressed", clear_style)
	button.add_theme_stylebox_override("focus", clear_style)
	button.add_theme_stylebox_override("disabled", clear_style)
	button.add_theme_stylebox_override("hover_pressed", clear_style)
	button.add_theme_color_override("font_color", Color(1, 1, 1, 0))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1, 0))
	button.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 0))
	button.add_theme_color_override("font_focus_color", Color(1, 1, 1, 0))
	button.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0))
	button.pressed.connect(_on_lane_click_pressed.bind(lane))
	return button

func _on_lane_click_pressed(lane: int) -> void:
	if input_locked or state == DLConfig.STATE_FEEDBACK or state == DLConfig.STATE_FINISH or state == DLConfig.STATE_FAILURE or state == DLConfig.STATE_TURN_EXIT:
		return
	_handle_lane_or_choice(lane)

func _build_damage_hud() -> void:
	# V0.13.10.8: painel mantém largura compacta, mas ganha altura útil.
	# O velocímetro usa zona própria para separar ponteiro, número e unidade.
	damage_car_texture = null
	damage_hud = Control.new()
	damage_hud.name = "DamageHUD"
	damage_hud.anchor_left = 1.0
	damage_hud.anchor_top = 1.0
	damage_hud.anchor_right = 1.0
	damage_hud.anchor_bottom = 1.0
	# Card um pouco mais alto para dar folga entre ponteiro, número e integridade.
	damage_hud.offset_left = -304.0
	damage_hud.offset_top = -226.0
	damage_hud.offset_right = -40.0
	damage_hud.offset_bottom = -44.0
	damage_hud.z_index = 34
	damage_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	damage_hud.draw.connect(_on_damage_hud_draw)
	hud_layer.add_child(damage_hud)

func _build_tutorial_layer() -> void:
	tutorial_layer = Control.new()
	tutorial_layer.name = "TutorialLayer"
	tutorial_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	tutorial_layer.z_index = 58
	tutorial_layer.visible = false
	tutorial_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_layer.draw.connect(_on_tutorial_layer_draw)
	hud_layer.add_child(tutorial_layer)

func _build_pause_button() -> void:
	# Botao + overlay de pause PADRONIZADOS (mesmo componente de todos os minigames).
	# O Desvio Logico congela a simulacao por conta propria (gameplay_paused), sem pausar a arvore.
	pause_menu = MinigamePause.attach(self, {
		"tree_pause": false,
		"can_pause": _can_pause_game,
		"on_finish": _on_pause_finish_pressed,
		"on_menu": _on_pause_main_menu_pressed
	})
	pause_menu.paused.connect(_on_pause_opened)
	pause_menu.resumed.connect(_on_pause_closed)
	pause_button = pause_menu.pause_button
	pause_layer = pause_menu.overlay

func _build_decision_layer() -> void:
	decision_layer = Control.new()
	decision_layer.name = "DecisionLayer"
	decision_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	decision_layer.z_index = 35
	decision_layer.visible = false
	add_child(decision_layer)

	option_a_button = _make_choice_button("A")
	option_a_button.anchor_left = 0.11
	option_a_button.anchor_top = 0.17
	option_a_button.anchor_right = 0.46
	option_a_button.anchor_bottom = 0.31
	option_a_button.pressed.connect(_on_choice_pressed.bind("A"))
	decision_layer.add_child(option_a_button)

	option_b_button = _make_choice_button("B")
	option_b_button.anchor_left = 0.54
	option_b_button.anchor_top = 0.17
	option_b_button.anchor_right = 0.89
	option_b_button.anchor_bottom = 0.31
	option_b_button.pressed.connect(_on_choice_pressed.bind("B"))
	decision_layer.add_child(option_b_button)

func _build_feedback_layer() -> void:
	feedback_layer = Control.new()
	feedback_layer.name = "FeedbackLayer"
	feedback_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	feedback_layer.z_index = 60
	feedback_layer.visible = false
	feedback_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(feedback_layer)

	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.0, 0.0, 0.0, 0.24)
	feedback_layer.add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	# V0.13.4.13: feedback redesenhado, menor e com borda no conteúdo real.
	center.offset_top = -10.0
	center.offset_bottom = -10.0
	feedback_layer.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(650, 286)
	panel.add_theme_stylebox_override("panel", _make_hud_card_style(Color(0.02, 0.025, 0.055, 0.62), Color(0.0, 0.88, 1.0, 0.86), 20, 2))
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	feedback_title_label = _make_label("", 28, Color(1.0, 1.0, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(feedback_title_label)

	feedback_body_label = _make_label("", 18, Color(0.95, 0.96, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	feedback_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_body_label.custom_minimum_size = Vector2(580, 108)
	box.add_child(feedback_body_label)

	feedback_continue_button = Button.new()
	feedback_continue_button.text = "Continuar"
	feedback_continue_button.custom_minimum_size = Vector2(250, 40)
	feedback_continue_button.add_theme_font_size_override("font_size", 19)
	feedback_continue_button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.0, 0.30, 0.48, 0.95), Color(0.45, 0.95, 1.0), 13, 2))
	feedback_continue_button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.0, 0.45, 0.66, 1.0), Color(1.0, 1.0, 1.0), 13, 2))
	feedback_continue_button.pressed.connect(_on_feedback_continue_pressed)
	box.add_child(feedback_continue_button)

func _build_finish_layer() -> void:
	finish_layer = Control.new()
	finish_layer.name = "FinishLayer"
	finish_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	finish_layer.z_index = 70
	finish_layer.visible = false
	finish_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(finish_layer)

	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.0, 0.0, 0.0, 0.42)
	finish_layer.add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	finish_layer.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(820, 420)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.015, 0.020, 0.055, 0.88), Color(1.0, 0.80, 0.10, 0.92), 26, 2))
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_top", 34)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_bottom", 34)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 22)
	margin.add_child(box)

	finish_title_label = _make_label("ROTA FINAL CONCLUÍDA!", 34, Color(1.0, 0.88, 0.20), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(finish_title_label)

	finish_body_label = _make_label("", 22, Color(0.96, 0.98, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	finish_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	finish_body_label.custom_minimum_size = Vector2(720, 170)
	box.add_child(finish_body_label)

	finish_continue_button = Button.new()
	finish_continue_button.text = "Continuar"
	finish_continue_button.custom_minimum_size = Vector2(320, 54)
	finish_continue_button.add_theme_font_size_override("font_size", 22)
	finish_continue_button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.44, 0.18, 0.00, 0.96), Color(1.0, 0.86, 0.20), 14, 2))
	finish_continue_button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.62, 0.28, 0.00, 1.0), Color(1.0, 1.0, 1.0), 14, 2))
	finish_continue_button.pressed.connect(_on_finish_continue_pressed)
	box.add_child(finish_continue_button)

func _build_fade_layer() -> void:
	fade_rect = ColorRect.new()
	fade_rect.name = "Fade"
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.color = Color(0.0, 0.0, 0.0, 0.0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.z_index = 90
	add_child(fade_rect)

func _load_tutorial_arrow_textures() -> void:
	tutorial_arrow_textures.clear()
	tutorial_arrow_textures["left"] = _load_texture(str(DLConfig.TUTORIAL_ARROW_SPRITES["left"]))
	tutorial_arrow_textures["right"] = _load_texture(str(DLConfig.TUTORIAL_ARROW_SPRITES["right"]))

func _prepare_questions() -> void:
	questions = DynamicQuestionBank.pick_rounds("desvio_logico", difficulty, DLConfig.TOTAL_ROUNDS)
	if questions.is_empty():
		questions = DynamicQuestionBank.pick_rounds("show_do_bilhao", difficulty, DLConfig.TOTAL_ROUNDS)

func _start_round(index: int) -> void:
	if index >= DLConfig.TOTAL_ROUNDS or index >= questions.size():
		_show_finish()
		return
	current_round = index
	state = DLConfig.STATE_ACCELERATION
	input_locked = true
	finish_was_failure = false
	drive_elapsed = 0.0
	traffic.next_spawn_time = traffic._first_spawn_delay()
	acceleration_elapsed = 0.0
	acceleration_duration = _acceleration_duration()
	acceleration_ratio = 0.0
	road_time = 0.0
	car_y_ratio = DLConfig.CAR_DRIVE_START_Y_RATIO
	car_visual_bob = 0.0
	current_lane = DLConfig.LANE_RIGHT
	traffic.last_spawn_lane = DLConfig.LANE_LEFT
	traffic.last_combo_lane = DLConfig.LANE_RIGHT
	traffic.traffic_safe_opening_done = false
	traffic.traffic_opening_step = 0
	traffic.traffic_wave_count_bag.clear()
	traffic.traffic_wave_lane_bags.clear()
	route_result_applied = false
	wrong_route_damage_applied_this_question = false
	last_route_damage_loss = 0.0
	traffic.last_npc_sprite_path = ""
	gameplay_paused = false
	if pause_layer != null:
		pause_layer.visible = false
	_clear_obstacles()
	sideprops._reset_side_props()
	decision_layer.visible = false
	feedback_layer.visible = false
	gameplay_paused = false
	if pause_layer != null:
		pause_layer.visible = false
	if question_panel != null:
		question_panel.visible = false
	if route_progress_hud != null:
		route_progress_hud.visible = true
	if pause_button != null:
		pause_button.visible = true
	if question_label != null:
		question_label.text = ""
	_set_background(index)
	_set_car_sprite("reto")
	car_rect.scale = Vector2.ONE
	car_rect.rotation_degrees = 0.0
	car_rect.modulate = Color.WHITE
	_layout_car(false)
	_update_hud()
	status_label.text = "Cenário: %s. Alterne entre esquerda/direita até a decisão." % _stage_name(index)
	_fade_from_black()
	if current_round == 0:
		_start_tutorial_sequence()
	else:
		_begin_real_drive_after_tutorial()

func _begin_real_drive_after_tutorial() -> void:
	_clear_obstacles()
	state = DLConfig.STATE_ACCELERATION
	input_locked = true
	traffic._reset_traffic_wave_distribution()
	drive_elapsed = 0.0
	traffic.next_spawn_time = traffic._first_spawn_delay()
	acceleration_elapsed = 0.0
	acceleration_duration = _acceleration_duration()
	acceleration_ratio = 0.0
	road_time = 0.0
	car_visual_bob = 0.0
	_reset_car_lane_tilt()
	_set_car_sprite("reto")
	if tutorial_layer != null:
		tutorial_layer.visible = false
	if pause_button != null:
		pause_button.visible = true
	_update_drive_timer_label()
	status_label.text = "Bionix parado. Aceleração gradual iniciada no cenário %s." % _stage_name(current_round)
	engineaudio._start_engine_acceleration_audio()

func _update_acceleration_start(delta: float) -> void:
	if state != DLConfig.STATE_ACCELERATION:
		return
	acceleration_elapsed += delta
	var raw_ratio: float = clampf(acceleration_elapsed / maxf(acceleration_duration, 0.01), 0.0, 1.0)
	# Curva mais orgânica: início realmente lento, meio progressivo e pico apenas no fim do tempo definido.
	acceleration_ratio = pow(raw_ratio, 1.75)
	_update_drive_timer_label()
	if raw_ratio >= 1.0:
		_complete_acceleration_start()

func _complete_acceleration_start() -> void:
	if state != DLConfig.STATE_ACCELERATION:
		return
	_clear_obstacles()
	state = DLConfig.STATE_DRIVE
	input_locked = false
	acceleration_ratio = 1.0
	drive_elapsed = 0.0
	car_y_ratio = DLConfig.CAR_DRIVE_START_Y_RATIO
	_reset_car_lane_tilt()
	_set_car_sprite("reto")
	_layout_car(false)
	traffic.next_spawn_time = traffic._first_spawn_delay()
	traffic._reset_traffic_wave_distribution()
	_update_drive_timer_label()
	status_label.text = "Bionix em velocidade de rota. Desvie até a decisão técnica."
	engineaudio._start_engine_loop_audio()

func _start_tutorial_sequence() -> void:
	state = DLConfig.STATE_TUTORIAL_INTRO
	input_locked = true
	traffic._reset_traffic_wave_distribution()
	drive_elapsed = 0.0
	traffic.next_spawn_time = traffic._first_spawn_delay()
	if pause_button != null:
		pause_button.visible = false
	_show_tutorial_intro()
	await get_tree().create_timer(2.0).timeout
	if state != DLConfig.STATE_TUTORIAL_INTRO:
		return
	if _animations_enabled():
		var tween := create_tween()
		tween.tween_property(self, "tutorial_alpha", 0.0, 0.42)
		await tween.finished
	else:
		tutorial_alpha = 0.0
	_start_tutorial_left()

func _show_tutorial_intro() -> void:
	tutorial_direction = DLConfig.LANE_CENTER
	tutorial_message = "MINIGAME DESVIO LÓGICO"
	tutorial_submessage = "Clique na metade esquerda para desviar à esquerda. Clique na metade direita para desviar à direita."
	tutorial_alpha = 1.0
	if tutorial_layer != null:
		tutorial_layer.visible = true
		tutorial_layer.queue_redraw()
	status_label.text = "Tutorial rápido: use esquerda e direita para desviar dos carros."

func _start_tutorial_left() -> void:
	state = DLConfig.STATE_TUTORIAL_LEFT
	input_locked = false
	current_lane = DLConfig.LANE_RIGHT
	_set_car_sprite("reto")
	_reset_car_lane_tilt()
	_layout_car(false)
	_clear_obstacles()
	tutorial_direction = DLConfig.LANE_LEFT
	tutorial_message = "DESVIE PARA A ESQUERDA"
	tutorial_submessage = "Carro vindo pela direita. Clique no lado esquerdo da tela."
	tutorial_alpha = 1.0
	_spawn_tutorial_car(DLConfig.LANE_RIGHT)
	status_label.text = "Tutorial: clique à esquerda para escapar do carro à direita."
	if tutorial_layer != null:
		tutorial_layer.visible = true
		tutorial_layer.queue_redraw()

func _start_tutorial_right() -> void:
	state = DLConfig.STATE_TUTORIAL_RIGHT
	input_locked = false
	current_lane = DLConfig.LANE_LEFT
	_set_car_sprite("reto")
	_reset_car_lane_tilt()
	_layout_car(false)
	_clear_obstacles()
	tutorial_direction = DLConfig.LANE_RIGHT
	tutorial_message = "DESVIE PARA A DIREITA"
	tutorial_submessage = "Carro vindo pela esquerda. Clique no lado direito da tela."
	tutorial_alpha = 1.0
	_spawn_tutorial_car(DLConfig.LANE_LEFT)
	status_label.text = "Tutorial: clique à direita para escapar do carro à esquerda."
	if tutorial_layer != null:
		tutorial_layer.visible = true
		tutorial_layer.queue_redraw()

func _handle_tutorial_input(lane: int) -> void:
	if state == DLConfig.STATE_TUTORIAL_LEFT:
		if lane != DLConfig.LANE_LEFT:
			status_label.text = "Clique no lado esquerdo para desviar desse carro."
			return
		_move_to_lane(DLConfig.LANE_LEFT)
		input_locked = true
		_clear_obstacles()
		await get_tree().create_timer(0.35).timeout
		if state == DLConfig.STATE_TUTORIAL_LEFT:
			_start_tutorial_right()
	elif state == DLConfig.STATE_TUTORIAL_RIGHT:
		if lane != DLConfig.LANE_RIGHT:
			status_label.text = "Clique no lado direito para desviar desse carro."
			return
		_move_to_lane(DLConfig.LANE_RIGHT)
		input_locked = true
		_clear_obstacles()
		await get_tree().create_timer(0.35).timeout
		if state == DLConfig.STATE_TUTORIAL_RIGHT:
			_finish_tutorial_sequence()

func _finish_tutorial_sequence() -> void:
	_clear_obstacles()
	tutorial_alpha = 0.0
	if tutorial_layer != null:
		tutorial_layer.visible = false
	_reset_car_lane_tilt()
	_set_car_sprite("reto")
	_begin_real_drive_after_tutorial()

func _spawn_tutorial_car(lane: int) -> void:
	var viewport_height: float = maxf(get_viewport_rect().size.y, 720.0)
	var y: float = viewport_height * 0.370
	traffic._spawn_npc_at(lane, y, true, 0.34)
	if obstacle_data.size() > 0:
		var data: Dictionary = obstacle_data[obstacle_data.size() - 1]
		data["tutorial"] = true
		data["grace"] = 9999.0
		data["collision_y"] = viewport_height * 9.0
		data["speed"] = _obstacle_speed() * 0.34
		obstacle_data[obstacle_data.size() - 1] = data

func _is_tutorial_state() -> bool:
	return state == DLConfig.STATE_TUTORIAL_INTRO or state == DLConfig.STATE_TUTORIAL_LEFT or state == DLConfig.STATE_TUTORIAL_RIGHT

func _is_tutorial_car_state() -> bool:
	return state == DLConfig.STATE_TUTORIAL_LEFT or state == DLConfig.STATE_TUTORIAL_RIGHT

func _set_background(index: int) -> void:
	var path: String = DLConfig.BACKGROUNDS[clampi(index, 0, DLConfig.BACKGROUNDS.size() - 1)]
	background_rect.texture = _load_texture(path)

func _update_drive(delta: float) -> void:
	drive_elapsed += delta
	_update_player_car_route_progress()
	_update_drive_timer_label()
	_update_obstacles(delta * _current_motion_ratio())
	traffic._update_pending_combo_spawns()
	if traffic.traffic_combo_queue.is_empty() and drive_elapsed >= traffic.next_spawn_time:
		var was_in_safe_opening: bool = not traffic.traffic_safe_opening_done
		var spawned: bool = false
		if traffic._can_spawn_new_traffic():
			spawned = traffic._spawn_obstacle()
		var interval: float = traffic._traffic_spawn_retry_delay()
		if spawned:
			if was_in_safe_opening and not traffic.traffic_safe_opening_done:
				interval = traffic._safe_opening_followup_delay()
			elif was_in_safe_opening and traffic.traffic_safe_opening_done:
				interval = traffic._post_safe_opening_delay()
			else:
				interval = traffic._spawn_interval()
		traffic.next_spawn_time = drive_elapsed + interval
	if drive_elapsed >= _drive_duration():
		_enter_decision_phase()

func _update_player_car_route_progress() -> void:
	if state != DLConfig.STATE_DRIVE:
		return
	car_y_ratio = _player_car_y_ratio_for_progress(_route_progress_ratio())

func _player_car_y_ratio_for_progress(progress: float) -> float:
	# V0.13.8.7: curva em três partes.
	# 1) sobe até uma zona alta, mas ainda segura;
	# 2) segura com pequeno avanço para manter tensão;
	# 3) avança só no final, quando novos NPCs já estão sendo bloqueados.
	# V0.13.8.8: o destino final agora é a própria zona de decisão, evitando
	# o "boom"/salto visual entre o fim da rota e a placa da bifurcação.
	progress = clampf(progress, 0.0, 1.0)
	var hold_start: float = _route_hold_start_progress()
	var final_start: float = maxf(_route_final_advance_progress(), hold_start + 0.04)
	var safe_y: float = DLConfig.CAR_ROUTE_SAFE_HOLD_Y_RATIO
	var pre_final_y: float = maxf(DLConfig.CAR_DRIVE_END_Y_RATIO, safe_y - DLConfig.CAR_ROUTE_SAFE_HOLD_DRIFT)
	if progress <= hold_start:
		var t_to_hold: float = clampf(progress / maxf(hold_start, 0.01), 0.0, 1.0)
		var eased_to_hold: float = t_to_hold * t_to_hold * (3.0 - 2.0 * t_to_hold)
		return lerpf(DLConfig.CAR_DRIVE_START_Y_RATIO, safe_y, eased_to_hold)
	if progress < final_start:
		var t_hold: float = clampf((progress - hold_start) / maxf(final_start - hold_start, 0.01), 0.0, 1.0)
		var eased_hold: float = t_hold * t_hold * (3.0 - 2.0 * t_hold)
		return lerpf(safe_y, pre_final_y, eased_hold)
	var t_final: float = clampf((progress - final_start) / maxf(1.0 - final_start, 0.01), 0.0, 1.0)
	var eased_final: float = t_final * t_final * (3.0 - 2.0 * t_final)
	return lerpf(pre_final_y, _car_decision_stop_y_ratio(), eased_final)

func _car_decision_stop_y_ratio() -> float:
	return clampf(DLConfig.CAR_APPROACH_Y_RATIO + DLConfig.CAR_DECISION_STOP_Y_OFFSET_RATIO, 0.365, DLConfig.CAR_APPROACH_Y_RATIO)

func _route_hold_start_progress() -> float:
	return float(DLConfig.CAR_ROUTE_HOLD_START_BY_DIFFICULTY.get(difficulty, 0.70))

func _route_final_advance_progress() -> float:
	return float(DLConfig.CAR_ROUTE_FINAL_ADVANCE_BY_DIFFICULTY.get(difficulty, 0.90))

func _decision_center_blend_start_progress() -> float:
	return float(DLConfig.CAR_DECISION_CENTER_BLEND_START_BY_DIFFICULTY.get(difficulty, traffic._final_spawn_cutoff_progress()))

func _decision_center_blend_ratio(progress: float) -> float:
	if state != DLConfig.STATE_DRIVE:
		return 0.0
	var blend_start: float = clampf(_decision_center_blend_start_progress(), 0.0, 0.98)
	var t: float = clampf((progress - blend_start) / maxf(1.0 - blend_start, 0.01), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)

func _final_deceleration_start_progress() -> float:
	# V0.13.10.2: a desaceleração visual começa quando os spawns finais
	# deixam de nascer. Assim o Bionix chega à bifurcação com o cenário
	# parando naturalmente antes da pergunta aparecer.
	var progress_cutoff: float = clampf(traffic._final_spawn_cutoff_progress(), 0.0, 0.98)
	var seconds_cutoff: float = clampf(1.0 - (traffic._final_spawn_cutoff_seconds() / maxf(_drive_duration(), 1.0)), 0.0, 0.98)
	return minf(progress_cutoff, seconds_cutoff)

func _final_deceleration_ratio(progress: float = -1.0) -> float:
	if state != DLConfig.STATE_DRIVE:
		return 0.0 if state == DLConfig.STATE_DECISION else 1.0
	if progress < 0.0:
		progress = _route_progress_ratio()
	var start: float = _final_deceleration_start_progress()
	var t: float = clampf((progress - start) / maxf(1.0 - start, 0.01), 0.0, 1.0)
	var eased: float = t * t * (3.0 - 2.0 * t)
	return clampf(1.0 - eased, 0.0, 1.0)

func _player_car_depth_progress() -> float:
	var distance: float = maxf(DLConfig.CAR_DRIVE_START_Y_RATIO - DLConfig.CAR_DRIVE_END_Y_RATIO, 0.001)
	return clampf((DLConfig.CAR_DRIVE_START_Y_RATIO - car_y_ratio) / distance, 0.0, 1.0)

func _enter_decision_phase() -> void:
	if state != DLConfig.STATE_DRIVE:
		return
	# V0.13.13: fluxo direto de decisão. Não existe mais etapa/tween de chegada
	# depois que o velocímetro zera; o Bionix é fixado no ponto correto e a pergunta
	# abre no mesmo ciclo, sem depender de animação antiga da bifurcação.
	drive_elapsed = _drive_duration()
	car_y_ratio = _car_decision_stop_y_ratio()
	current_lane = DLConfig.LANE_CENTER
	_cancel_lane_change_motion()
	_reset_car_lane_tilt()
	_snap_bionix_to_decision_point()
	state = DLConfig.STATE_DECISION
	input_locked = false
	_apply_route_reached_bonus_once()
	_clear_obstacles()
	engineaudio._stop_engine_audio()
	_update_drive_timer_label()
	if route_progress_hud != null:
		route_progress_hud.visible = false
	if question_panel != null:
		question_panel.visible = true
	decision_layer.visible = true
	var q: Dictionary = _current_question()
	var opts: Dictionary = q.get("opcoes", {})
	option_a_button.text = "ROTA A ←\n%s" % str(opts.get("A", "Alternativa A"))
	option_b_button.text = "ROTA B →\n%s" % str(opts.get("B", "Alternativa B"))
	status_label.text = "Escolha a rota: clique à esquerda para A ou à direita para B."
	question_label.text = str(q.get("pergunta", "Escolha o melhor caminho técnico."))
	_set_car_sprite("reto")
	_layout_car(false)

func _on_choice_pressed(choice: String) -> void:
	if state != DLConfig.STATE_DECISION or input_locked:
		return
	_resolve_choice(choice)

func _resolve_choice(choice: String) -> void:
	input_locked = true
	state = DLConfig.STATE_TURN_EXIT
	last_turn_choice = choice
	last_route_damage_loss = 0.0
	decision_layer.visible = false
	if pause_button != null:
		pause_button.visible = false
	if question_panel != null:
		question_panel.visible = false
	var q: Dictionary = _current_question()
	var correct: String = str(q.get("resposta", "A"))
	var is_correct: bool = choice == correct
	if is_correct:
		correct_count += 1
		_apply_score_delta(_choice_score_delta(true))
		if has_node("/root/AudioManager"):
			AudioManager.play_sfx("correto")
	else:
		_apply_score_delta(_choice_score_delta(false))
		last_route_damage_loss = _apply_wrong_route_damage_once()
		if has_node("/root/AudioManager"):
			AudioManager.play_sfx("errado")
	_update_hud()
	await _animate_turn_exit(choice)
	if integrity <= 0.0:
		_show_finish(true)
		return
	state = DLConfig.STATE_FEEDBACK
	_show_feedback(is_correct, choice, q, last_route_damage_loss)

func _show_feedback(is_correct: bool, choice: String, q: Dictionary, route_damage_loss: float = 0.0) -> void:
	if fade_rect != null:
		fade_rect.color = Color(0, 0, 0, 0.0)
	var opts: Dictionary = q.get("opcoes", {})
	var correct_letter: String = str(q.get("resposta", "A"))
	var chosen_text: String = str(opts.get(choice, ""))
	var correct_text: String = str(opts.get(correct_letter, ""))
	var explanation: String = _clean_feedback(correct_text, _get_reason(q, correct_letter))
	feedback_title_label.text = "ROTA CORRETA!" if is_correct else "ROTA INCORRETA"
	feedback_title_label.add_theme_color_override("font_color", Color(0.38, 1.0, 0.48) if is_correct else Color(1.0, 0.28, 0.25))
	if is_correct:
		feedback_body_label.text = "Você escolheu: %s\n\n%s" % [correct_text, explanation]
	else:
		var wrong_reason: String = _get_reason(q, choice)
		if wrong_reason == "" or wrong_reason == explanation:
			wrong_reason = "Essa rota não resolve melhor a situação apresentada."
		var damage_line: String = ""
		if route_damage_loss > 0.0:
			damage_line = "\n\nPenalidade da rota: -%s%% de integridade." % int(round(route_damage_loss))
		feedback_body_label.text = "Você escolheu: %s\n%s%s\n\nResposta correta: %s\n%s" % [chosen_text, wrong_reason, damage_line, correct_text, explanation]
	feedback_continue_requested = false
	if pause_button != null:
		pause_button.visible = false
	feedback_layer.visible = true

func _on_feedback_continue_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	feedback_continue_requested = true
	feedback_layer.visible = false
	if current_round + 1 >= DLConfig.TOTAL_ROUNDS or current_round + 1 >= questions.size():
		await _fade_to_black()
		_show_finish()
	else:
		await _fade_to_black()
		_start_round(current_round + 1)

func _show_finish(is_failure: bool = false) -> void:
	if fade_rect != null:
		fade_rect.color = Color(0, 0, 0, 0.0)
	state = DLConfig.STATE_FAILURE if is_failure else DLConfig.STATE_FINISH
	finish_was_failure = is_failure
	engineaudio._stop_engine_audio()
	gameplay_paused = false
	if pause_layer != null:
		pause_layer.visible = false
	input_locked = true
	decision_layer.visible = false
	feedback_layer.visible = false
	if question_panel != null:
		question_panel.visible = false
	if route_progress_hud != null:
		route_progress_hud.visible = false
	if pause_button != null:
		pause_button.visible = false
	_clear_obstacles()
	var rating: String = "Rota concluída com estabilidade."
	if correct_count >= 6 and integrity >= 80.0:
		rating = "Rota perfeita! Você dominou a estrada e as decisões técnicas."
	elif correct_count >= 4:
		rating = "Boa jornada! Algumas colisões não impediram a conclusão da rota."
	elif correct_count >= 2:
		rating = "Rota concluída com falhas. Revise os conceitos e tente novamente."
	else:
		rating = "Rota crítica. O treino ajudará a reconhecer os melhores caminhos técnicos."
	finish_body_label.text = "Acertos: %s/%s\nColisões: %s\nIntegridade final: %s%%\nPontos do minigame: %s\n\n%s" % [correct_count, DLConfig.TOTAL_ROUNDS, collisions, int(round(integrity)), local_points, rating]
	if has_node("/root/AchievementManager") and not is_failure and difficulty == "dificil" and collisions <= 0:
		AchievementManager.unlock("piloto_imbativel")
	finish_layer.visible = true
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("correto")

func _on_finish_continue_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	engineaudio._stop_engine_audio()
	engineaudio._clear_desvio_music_audio_profile()
	_save_desvio_free_mode_record_if_needed()
	GameManager.complete_current_stage(0)

func _save_desvio_free_mode_record_if_needed() -> void:
	if not GameManager.is_free_mode():
		return
	if not has_node("/root/ScoreManager"):
		return
	ScoreManager.save_free_mode_score("desvio_logico", DifficultyManager.get_difficulty(), max(local_points, 0))

func _on_pause_opened() -> void:
	gameplay_paused = true
	engineaudio._set_engine_audio_paused(true)
	input_locked = true

func _on_pause_closed() -> void:
	gameplay_paused = false
	engineaudio._set_engine_audio_paused(false)
	engineaudio._ensure_engine_audio_state()
	input_locked = state == DLConfig.STATE_ACCELERATION

func _on_pause_finish_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	gameplay_paused = false
	engineaudio._stop_engine_audio()
	input_locked = true
	if pause_layer != null:
		pause_layer.visible = false
	engineaudio._clear_desvio_music_audio_profile()
	if GameManager.is_free_mode():
		GameManager.open_free_menu()
	else:
		# Desvio Lógico é o último minigame da campanha. Pontos já ganhos foram somados ao ScoreManager.
		# complete_current_stage(0) preserva o acumulado e segue para a cutscene final.
		GameManager.complete_current_stage(0)

func _on_pause_main_menu_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	gameplay_paused = false
	engineaudio._stop_engine_audio()
	engineaudio._clear_desvio_music_audio_profile()
	GameManager.go_to_main_menu()

func _resume_game() -> void:
	if pause_menu != null:
		pause_menu.close()

func _can_pause_game() -> bool:
	return state == DLConfig.STATE_ACCELERATION or state == DLConfig.STATE_DRIVE or state == DLConfig.STATE_DECISION

func _handle_pointer(pointer_position: Vector2) -> void:
	var lane: int = _lane_from_x(pointer_position.x)
	_handle_lane_or_choice(lane)

func _is_gameplay_pointer(pointer_position: Vector2) -> bool:
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(1280, 720)
	if state == DLConfig.STATE_DRIVE:
		return pointer_position.y >= viewport_size.y * 0.26
	if state == DLConfig.STATE_TUTORIAL_LEFT or state == DLConfig.STATE_TUTORIAL_RIGHT:
		return pointer_position.y >= viewport_size.y * 0.18
	if state == DLConfig.STATE_DECISION:
		return pointer_position.y >= viewport_size.y * 0.15
	return false

func _handle_lane_or_choice(lane: int) -> void:
	if lane != DLConfig.LANE_LEFT and lane != DLConfig.LANE_RIGHT:
		_show_center_hint()
		return
	if state == DLConfig.STATE_TUTORIAL_LEFT or state == DLConfig.STATE_TUTORIAL_RIGHT:
		_handle_tutorial_input(lane)
	elif state == DLConfig.STATE_DRIVE:
		_move_to_lane(lane)
	elif state == DLConfig.STATE_DECISION:
		if lane == DLConfig.LANE_LEFT:
			_resolve_choice("A")
		elif lane == DLConfig.LANE_RIGHT:
			_resolve_choice("B")

func _show_center_hint() -> void:
	status_label.text = "Use apenas esquerda ou direita: esquerda = faixa/rota A, direita = faixa/rota B."

func _move_to_lane(lane: int) -> void:
	lane = DLConfig.LANE_LEFT if lane == DLConfig.LANE_LEFT else DLConfig.LANE_RIGHT
	if lane_change_active:
		return
	if lane == current_lane:
		_layout_car(false)
		return
	var previous_lane: int = current_lane
	current_lane = lane
	var turn_direction: int = -1 if current_lane < previous_lane else 1
	# V0.13.9.7: a troca de faixa usa o sprite reto com inclinação leve.
	# Isso evita a sensação de "capô virando" e deixa a curva mais orgânica.
	_set_car_sprite("reto")
	_layout_car(true)
	_animate_car_lane_tilt(turn_direction)

func _cancel_lane_change_motion() -> void:
	# V0.13.10.7: elimina qualquer tween de faixa pendente antes da decisão.
	# Isso impede a animação residual de chegada quando o velocímetro já zerou.
	if lane_change_tween != null and lane_change_tween.is_valid():
		lane_change_tween.kill()
	lane_change_tween = null
	lane_change_active = false

func _layout_car(animated: bool = true) -> void:
	if car_rect == null:
		return
	var car_size: Vector2 = _car_size()
	car_rect.size = car_size
	car_rect.custom_minimum_size = car_size
	car_rect.pivot_offset = car_size * 0.5
	if state == DLConfig.STATE_ACCELERATION or state == DLConfig.STATE_DRIVE:
		var route_scale: float = _player_car_route_scale()
		car_rect.scale = Vector2(route_scale, route_scale)
	var target: Vector2 = _car_position_for_lane(current_lane, car_y_ratio, car_size)
	if animated and _animations_enabled():
		_cancel_lane_change_motion()
		lane_change_active = true
		lane_change_tween = create_tween()
		lane_change_tween.tween_property(car_rect, "position", target, 0.46).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		lane_change_tween.tween_callback(Callable(self, "_finish_lane_change"))
	else:
		_cancel_lane_change_motion()
		car_rect.position = target

func _finish_lane_change() -> void:
	lane_change_active = false
	lane_change_tween = null
	if state == DLConfig.STATE_DRIVE:
		_set_car_sprite("reto")

func _reset_car_lane_tilt() -> void:
	if car_tilt_tween != null and car_tilt_tween.is_valid():
		car_tilt_tween.kill()
	car_tilt_tween = null
	if car_rect != null:
		car_rect.rotation_degrees = 0.0

func _animate_car_lane_tilt(direction: int) -> void:
	if car_rect == null:
		return
	if car_tilt_tween != null and car_tilt_tween.is_valid():
		car_tilt_tween.kill()
	car_tilt_tween = null
	car_rect.pivot_offset = car_rect.size * 0.5
	if not _animations_enabled():
		car_rect.rotation_degrees = 0.0
		return
	var tilt_degrees: float = float(direction) * DLConfig.CAR_LANE_TILT_DEGREES
	car_tilt_tween = create_tween()
	car_tilt_tween.tween_property(car_rect, "rotation_degrees", tilt_degrees, DLConfig.CAR_LANE_TILT_IN_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	car_tilt_tween.tween_property(car_rect, "rotation_degrees", 0.0, DLConfig.CAR_LANE_TILT_RETURN_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _snap_bionix_to_decision_point() -> void:
	if car_rect == null:
		return
	_cancel_lane_change_motion()
	_reset_car_lane_tilt()
	_set_car_sprite("reto")
	var car_size: Vector2 = _car_size()
	car_rect.size = car_size
	car_rect.custom_minimum_size = car_size
	car_rect.pivot_offset = car_size * 0.5
	car_rect.rotation_degrees = 0.0
	car_rect.scale = Vector2(DLConfig.PLAYER_CAR_DECISION_SCALE, DLConfig.PLAYER_CAR_DECISION_SCALE)
	car_rect.position = _car_position_for_lane(DLConfig.LANE_CENTER, _car_decision_stop_y_ratio(), car_size)

func _animate_turn_exit(choice: String) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(1280, 720)
	var target_lane: int = DLConfig.LANE_LEFT if choice == "A" else DLConfig.LANE_RIGHT
	var turn_key: String = "esquerda" if choice == "A" else "direita"
	_set_car_sprite(turn_key)
	var car_size: Vector2 = _car_size()
	car_rect.size = car_size
	car_y_ratio = _car_decision_stop_y_ratio() - 0.010
	var route_target: Vector2 = _car_position_for_lane(target_lane, car_y_ratio, car_size)
	if _animations_enabled():
		var lane_tween: Tween = create_tween()
		lane_tween.set_parallel(true)
		car_rect.pivot_offset = car_size * 0.5
		lane_tween.tween_property(car_rect, "position", route_target, 0.38).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		lane_tween.tween_property(car_rect, "scale", Vector2(0.70, 0.70), 0.38).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		lane_tween.tween_property(car_rect, "rotation_degrees", -5.0 if choice == "A" else 5.0, 0.24).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		await lane_tween.finished
	else:
		car_rect.position = route_target
		car_rect.scale = Vector2(0.70, 0.70)
		car_rect.rotation_degrees = -5.0 if choice == "A" else 5.0

	# As rotas A/B são apenas uma inclinação curta dentro da própria pista.
	# O carro não deve alcançar a água nem abrir uma curva longa.
	_set_car_sprite("reto")
	car_rect.size = _car_size()
	var exit_x_ratio: float = 0.455 if choice == "A" else 0.545
	var exit_end: Vector2 = Vector2(viewport_size.x * exit_x_ratio - car_rect.size.x * 0.5, viewport_size.y * 0.255)
	car_rect.modulate = Color.WHITE
	if fade_rect != null:
		fade_rect.color = Color(0, 0, 0, 0.0)
	if _animations_enabled():
		var exit_tween: Tween = create_tween()
		exit_tween.set_parallel(true)
		exit_tween.tween_property(car_rect, "position", exit_end, 1.08).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		exit_tween.tween_property(car_rect, "scale", Vector2(0.34, 0.34), 1.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		exit_tween.tween_property(car_rect, "rotation_degrees", 0.0, 0.40).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		exit_tween.tween_property(car_rect, "modulate", Color(1.0, 1.0, 1.0, 0.28), 1.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		if fade_rect != null:
			exit_tween.tween_property(fade_rect, "color", Color(0, 0, 0, 0.82), 1.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await exit_tween.finished
	else:
		car_rect.position = exit_end
		car_rect.scale = Vector2(0.34, 0.34)
		car_rect.rotation_degrees = 0.0
		car_rect.modulate = Color(1.0, 1.0, 1.0, 0.28)
		if fade_rect != null:
			fade_rect.color = Color(0, 0, 0, 0.82)

func _update_background_motion_fx(_delta: float) -> void:
	if background_rect == null:
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(1280, 720)
	background_rect.pivot_offset = viewport_size * 0.5
	if state == DLConfig.STATE_ACCELERATION or state == DLConfig.STATE_DRIVE or _is_tutorial_state():
		# Micro zoom + ondulação vertical: simula subida/descida da pista sem deformar o background.
		# Na V0.13.8, a força desse movimento acompanha a aceleração do Bionix.
		var motion_ratio: float = _current_motion_ratio()
		var slope_wave: float = sin(road_time * 0.42)
		var fast_wave: float = sin(road_time * 1.05)
		var zoom: float = lerpf(1.0, 1.024, motion_ratio) + slope_wave * 0.006 * motion_ratio + fast_wave * 0.002 * motion_ratio
		background_rect.scale = Vector2(zoom, zoom)
		background_rect.position = Vector2(0.0, (slope_wave * 3.8 + fast_wave * 1.2) * motion_ratio)
	else:
		background_rect.scale = Vector2.ONE
		background_rect.position = Vector2.ZERO

func _update_car_motion_fx(delta: float) -> void:
	if car_rect == null or state == DLConfig.STATE_DECISION or state == DLConfig.STATE_FEEDBACK or state == DLConfig.STATE_FINISH or state == DLConfig.STATE_FAILURE:
		return
	var motion_ratio: float = _current_motion_ratio()
	car_visual_bob += delta * lerpf(2.4, 8.0, motion_ratio)
	if (state == DLConfig.STATE_ACCELERATION or state == DLConfig.STATE_DRIVE) and not lane_change_active:
		var base_size: Vector2 = _car_size()
		car_rect.size = base_size
		car_rect.custom_minimum_size = base_size
		car_rect.pivot_offset = base_size * 0.5
		var desired_scale: float = _player_car_route_scale()
		var scale_lerp: float = minf(1.0, delta * lerpf(4.5, 9.0, motion_ratio))
		car_rect.scale = car_rect.scale.lerp(Vector2(desired_scale, desired_scale), scale_lerp)
		var target: Vector2 = _car_position_for_lane(current_lane, car_y_ratio, base_size)
		target.y += (sin(car_visual_bob) * 2.8 + sin(road_time * 0.42) * 1.6) * motion_ratio
		var final_settle: float = 0.0
		if state == DLConfig.STATE_DRIVE:
			final_settle = 1.0 - _final_deceleration_ratio(_route_progress_ratio())
		var follow_rate: float = lerpf(5.0, 10.0, motion_ratio) + final_settle * 26.0
		car_rect.position = car_rect.position.lerp(target, minf(1.0, delta * follow_rate))

func _car_position_for_lane(lane: int, y_ratio: float, car_size: Vector2) -> Vector2:
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(1280, 720)
	var center_y: float = viewport_size.y * y_ratio
	var lane_x: float = _lane_x_at_y(lane, center_y)
	# V0.13.8.8: nos últimos segundos, quando novos NPCs já não nascem,
	# o Bionix centraliza gradualmente. Assim ele chega ao meio da placa
	# sem teleporte quando a decisão A/B aparece.
	if state == DLConfig.STATE_DRIVE:
		var center_blend: float = _decision_center_blend_ratio(_route_progress_ratio())
		lane_x = lerpf(lane_x, viewport_size.x * 0.50, center_blend)
	return Vector2(lane_x - car_size.x * 0.5, center_y - car_size.y * 0.5)

func _obstacle_spawn_y() -> float:
	var viewport_height: float = maxf(get_viewport_rect().size.y, 720.0)
	# NPC nasce já dentro da área da estrada, não colado na cidade/água.
	return viewport_height * 0.355 + randf_range(-4.0, 5.0)

func _obstacle_position(lane: int, y: float, obstacle_size: Vector2) -> Vector2:
	return Vector2(_lane_x_at_y(lane, y) - obstacle_size.x * 0.5, y - obstacle_size.y * 0.5)

func _depth_t(y: float) -> float:
	var viewport_height: float = maxf(get_viewport_rect().size.y, 720.0)
	return clampf((y - viewport_height * 0.355) / (viewport_height * 0.565), 0.0, 1.0)

func _perspective_scale(y: float) -> float:
	return lerpf(0.26, 1.16, _depth_t(y))

func _lane_x_at_y(lane: int, y: float) -> float:
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(1280, 720)
	var t: float = _depth_t(y)
	# Duas faixas jogáveis alinhadas à estrada atual: esquerda e direita ao redor da faixa central branca.
	var lane_offset: float = lerpf(0.045, 0.165, t)
	match lane:
		DLConfig.LANE_LEFT:
			return viewport_size.x * (0.50 - lane_offset)
		DLConfig.LANE_RIGHT:
			return viewport_size.x * (0.50 + lane_offset)
		_:
			return viewport_size.x * 0.50

func _update_obstacles(delta: float) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	for i in range(obstacle_data.size() - 1, -1, -1):
		var data: Dictionary = obstacle_data[i]
		var node: Control = data.get("node", null)
		if node == null or not is_instance_valid(node):
			obstacle_data.remove_at(i)
			continue
		var previous_y: float = float(data.get("y", _obstacle_spawn_y()))
		var previous_t: float = _depth_t(previous_y)
		var y: float = previous_y + float(data.get("speed", 120.0)) * lerpf(0.28, 0.82, previous_t) * delta
		var base_size: Vector2 = data.get("base_size", Vector2(84, 52))
		var scale_factor: float = _perspective_scale(y)
		var obstacle_size: Vector2 = base_size * scale_factor
		node.size = obstacle_size
		node.custom_minimum_size = obstacle_size
		node.position = _obstacle_position(int(data.get("lane", DLConfig.LANE_RIGHT)), y, obstacle_size)
		node.modulate = Color(1.0, 1.0, 1.0, clampf(0.48 + scale_factor * 0.52, 0.45, 1.0))
		data["y"] = y
		if float(data.get("grace", 0.0)) > 0.0:
			data["grace"] = maxf(0.0, float(data.get("grace", 0.0)) - delta)
		# V0.13.8.6: usa colisão visual com varredura vertical entre o frame anterior
		# e o atual. Isso evita que NPCs rápidos atravessem o Bionix quando ele
		# está subindo em direção à bifurcação.
		if _npc_can_damage(data, node, previous_y, y):
			data["hit"] = true
			obstacle_data[i] = data
			_on_collision(node)
			if state == DLConfig.STATE_FAILURE:
				return
		if y > viewport_size.y + 185.0:
			node.queue_free()
			obstacle_data.remove_at(i)
		else:
			obstacle_data[i] = data

func _wrong_route_damage_loss() -> float:
	return float(_rules().get("wrong_route_loss", _rules().get("wrong_loss", 8.0)))

func _apply_wrong_route_damage_once() -> float:
	# V0.13.13: dano de rota é mecânica própria, separada da colisão.
	# Aplica uma única vez por pergunta para eliminar dano invisível/duplicado.
	if wrong_route_damage_applied_this_question:
		return 0.0
	wrong_route_damage_applied_this_question = true
	var loss: float = _wrong_route_damage_loss()
	integrity = maxf(0.0, integrity - loss)
	_update_hud()
	if damage_hud != null:
		damage_hud.queue_redraw()
	status_label.text = "Rota incorreta! Integridade -%s%%." % int(round(loss))
	return loss

func _apply_collision_damage() -> float:
	var loss: float = float(_rules().get("collision_loss", 8.0))
	integrity = maxf(0.0, integrity - loss)
	_update_hud()
	return loss

func _on_collision(node: Control) -> void:
	collisions += 1
	_apply_collision_damage()
	if damage_hud != null:
		damage_hud.queue_redraw()
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("errado")
	if _animations_enabled():
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(node, "modulate", Color(1.0, 0.28, 0.20, 0.15), 0.18)
		tween.tween_property(car_rect, "modulate", Color(1.0, 0.5, 0.5, 1.0), 0.08)
		tween.chain().tween_property(car_rect, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.12)
	status_label.text = "Colisão detectada! Integridade reduzida."
	if integrity <= 0.0:
		if state == DLConfig.STATE_DRIVE:
			_apply_route_failed_penalty_once()
		_show_finish(true)

func _npc_can_damage(data: Dictionary, node: Control, previous_y: float = -1.0, current_y: float = -1.0) -> bool:
	if state != DLConfig.STATE_DRIVE:
		return false
	if bool(data.get("tutorial", false)) or bool(data.get("preview_only", false)) or bool(data.get("hit", false)):
		return false
	if node == null or not is_instance_valid(node):
		return false
	# V0.13.8.6: grace curto serve só como proteção contra spawn instantâneo.
	# Se o retângulo visual já cruza o Velox depois do grace, o dano precisa entrar
	# em qualquer altura da rota, não apenas na parte inferior antiga.
	if float(data.get("grace", 0.0)) > 0.0:
		return false
	return _collides_with_car(data, node, previous_y, current_y)

func _control_visual_rect(control: Control) -> Rect2:
	# Usa o transform real do Control para respeitar posição, pivot e escala visual.
	# Isso é essencial depois que o Bionix passou a subir e reduzir de tamanho.
	var transform: Transform2D = control.get_global_transform()
	var corners := [
		Vector2.ZERO,
		Vector2(control.size.x, 0.0),
		control.size,
		Vector2(0.0, control.size.y)
	]
	var first_point: Vector2 = transform * corners[0]
	var min_point: Vector2 = first_point
	var max_point: Vector2 = first_point
	for corner in corners:
		var point: Vector2 = transform * corner
		min_point.x = minf(min_point.x, point.x)
		min_point.y = minf(min_point.y, point.y)
		max_point.x = maxf(max_point.x, point.x)
		max_point.y = maxf(max_point.y, point.y)
	return Rect2(min_point, max_point - min_point)

func _shrink_hitbox(visual_rect: Rect2, margin_x: float, margin_top: float, margin_bottom: float) -> Rect2:
	var hit_position: Vector2 = visual_rect.position + Vector2(visual_rect.size.x * margin_x, visual_rect.size.y * margin_top)
	var hit_size: Vector2 = Vector2(
		visual_rect.size.x * maxf(0.05, 1.0 - margin_x * 2.0),
		visual_rect.size.y * maxf(0.05, 1.0 - margin_top - margin_bottom)
	)
	return Rect2(hit_position, hit_size)

func _control_hitbox(control: Control, margin_x: float, margin_top: float, margin_bottom: float) -> Rect2:
	return _shrink_hitbox(_control_visual_rect(control), margin_x, margin_top, margin_bottom)

func _rect_union(a: Rect2, b: Rect2) -> Rect2:
	var min_point := Vector2(minf(a.position.x, b.position.x), minf(a.position.y, b.position.y))
	var max_point := Vector2(
		maxf(a.position.x + a.size.x, b.position.x + b.size.x),
		maxf(a.position.y + a.size.y, b.position.y + b.size.y)
	)
	return Rect2(min_point, max_point - min_point)

func _obstacle_visual_rect_at(data: Dictionary, y: float) -> Rect2:
	var lane: int = int(data.get("lane", DLConfig.LANE_RIGHT))
	var base_size: Vector2 = data.get("base_size", Vector2(180, 130))
	var scale_factor: float = _perspective_scale(y)
	var obstacle_size: Vector2 = base_size * scale_factor
	var local_position: Vector2 = _obstacle_position(lane, y, obstacle_size)
	var global_offset: Vector2 = obstacles_layer.global_position if obstacles_layer != null else Vector2.ZERO
	return Rect2(local_position + global_offset, obstacle_size)

func _obstacle_swept_hitbox(data: Dictionary, node: Control, previous_y: float, current_y: float) -> Rect2:
	var current_rect: Rect2 = _control_hitbox(node, 0.17, 0.17, 0.17)
	if previous_y < 0.0 or current_y < 0.0:
		return current_rect
	var previous_rect: Rect2 = _shrink_hitbox(_obstacle_visual_rect_at(data, previous_y), 0.17, 0.17, 0.17)
	var swept_rect: Rect2 = _rect_union(previous_rect, current_rect)
	swept_rect.position.y -= DLConfig.NPC_SWEPT_COLLISION_PADDING_Y
	swept_rect.size.y += DLConfig.NPC_SWEPT_COLLISION_PADDING_Y * 2.0
	return swept_rect

func _collides_with_car(data: Dictionary, obstacle: Control, previous_y: float = -1.0, current_y: float = -1.0) -> bool:
	# V0.13.8.6: colisão real por área visual + varredura vertical.
	# O Bionix sobe enquanto diminui; os NPCs descem enquanto crescem. A interseção
	# precisa considerar esse cruzamento, senão a colisão só funciona quando o player
	# ainda está embaixo da tela.
	if car_rect == null or obstacle == null or not is_instance_valid(obstacle):
		return false
	var car_rect_global := _control_hitbox(car_rect, 0.14, 0.15, 0.14)
	var obstacle_global := _obstacle_swept_hitbox(data, obstacle, previous_y, current_y)
	return car_rect_global.intersects(obstacle_global)

func _clear_obstacles() -> void:
	for data in obstacle_data:
		var node: Control = data.get("node", null)
		if node != null and is_instance_valid(node):
			node.queue_free()
	obstacle_data.clear()

func _stage_name(index: int) -> String:
	return str(DLConfig.STAGE_NAMES[clampi(index, 0, DLConfig.STAGE_NAMES.size() - 1)])

func _update_hud() -> void:
	var difficulty_label := DifficultyManager.get_label(difficulty) if has_node("/root/DifficultyManager") else "Normal"
	if round_label != null:
		round_label.text = "Desafio %s/%s • %s" % [current_round + 1, DLConfig.TOTAL_ROUNDS, _stage_name(current_round)]
	if score_label != null:
		score_label.text = "Dificuldade: %s" % difficulty_label
		DifficultyManager.apply_difficulty_chip(score_label, difficulty, 15)
	_update_drive_timer_label()
	if damage_hud != null:
		damage_hud.queue_redraw()
	if question_panel != null and question_panel.visible and state == DLConfig.STATE_DECISION:
		var q: Dictionary = _current_question()
		question_label.text = str(q.get("pergunta", "Escolha o caminho técnico correto."))

func _current_question() -> Dictionary:
	if current_round >= 0 and current_round < questions.size() and questions[current_round] is Dictionary:
		return questions[current_round]
	return {}

func _get_reason(q: Dictionary, letter: String) -> String:
	var motivos: Dictionary = q.get("motivos", {})
	return str(motivos.get(letter, ""))

func _clean_feedback(answer_text: String, explanation_text: String) -> String:
	var answer := answer_text.strip_edges()
	var explanation := explanation_text.strip_edges()
	if explanation == "" or explanation.to_lower() == answer.to_lower():
		return "%s é a decisão técnica mais adequada para a situação." % answer
	return explanation

func _choice_score_delta(is_correct: bool) -> int:
	var data: Dictionary = DLConfig.SCORE_CHOICE_POINTS.get(difficulty, DLConfig.SCORE_CHOICE_POINTS["normal"])
	return int(data.get("correct" if is_correct else "wrong", 0))

func _route_reached_score_delta() -> int:
	var data: Dictionary = DLConfig.SCORE_ROUTE_POINTS.get(difficulty, DLConfig.SCORE_ROUTE_POINTS["normal"])
	return int(data.get("reached", 0))

func _route_failed_score_delta() -> int:
	var data: Dictionary = DLConfig.SCORE_ROUTE_POINTS.get(difficulty, DLConfig.SCORE_ROUTE_POINTS["normal"])
	return int(data.get("failed", 0))

func _apply_route_reached_bonus_once() -> void:
	if route_result_applied:
		return
	route_result_applied = true
	_apply_score_delta(_route_reached_score_delta())

func _apply_route_failed_penalty_once() -> void:
	if route_result_applied:
		return
	route_result_applied = true
	_apply_score_delta(_route_failed_score_delta())

func _apply_score_delta(delta_points: int) -> void:
	if delta_points == 0:
		return
	local_points += delta_points
	if has_node("/root/ScoreManager"):
		ScoreManager.add_points(delta_points)
	_spawn_score_delta_popup(delta_points)
	if score_hud != null:
		score_hud.queue_redraw()

func _spawn_score_delta_popup(delta_points: int) -> void:
	if hud_layer == null:
		return
	var label := Label.new()
	label.name = "ScoreDeltaPopup"
	label.text = "+%d" % delta_points if delta_points > 0 else "%d" % delta_points
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 85
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.88))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	var positive := delta_points > 0
	label.add_theme_color_override("font_color", Color(0.45, 1.0, 0.58, 1.0) if positive else Color(1.0, 0.30, 0.24, 1.0))
	label.size = Vector2(90, 30)
	var start_pos := Vector2(226.0, 32.0)
	if score_hud != null:
		start_pos = score_hud.global_position + Vector2(score_hud.size.x + 8.0, 6.0)
	hud_layer.add_child(label)
	label.global_position = start_pos
	if _animations_enabled():
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(label, "global_position", start_pos + Vector2(0.0, -28.0), 1.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(label, "modulate", Color(1, 1, 1, 0), 1.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.chain().tween_callback(label.queue_free)
	else:
		label.queue_free()

func _acceleration_duration() -> float:
	return float(DLConfig.ENGINE_ACCELERATION_DURATION_BY_DIFFICULTY.get(difficulty, DLConfig.ENGINE_ACCELERATION_DURATION_BY_DIFFICULTY["normal"]))

func _current_motion_ratio() -> float:
	if state == DLConfig.STATE_ACCELERATION:
		return clampf(acceleration_ratio, 0.0, 1.0)
	if state == DLConfig.STATE_DRIVE:
		return _final_deceleration_ratio(_route_progress_ratio())
	if state == DLConfig.STATE_DECISION:
		return 0.0
	if _is_tutorial_state():
		return 0.0
	return 0.0

func _motion_delta(delta: float) -> float:
	if state == DLConfig.STATE_ACCELERATION:
		return delta * _current_motion_ratio()
	if state == DLConfig.STATE_DRIVE:
		return delta * _current_motion_ratio()
	if _is_tutorial_state():
		# Mantém a animação das setas do tutorial sem mover o mundo.
		return delta
	return 0.0

func _rules() -> Dictionary:
	return DLConfig.DIFFICULTY_RULES.get(difficulty, DLConfig.DIFFICULTY_RULES["normal"])

func _drive_duration() -> float:
	return DLConfig.DRIVE_DURATION_SECONDS

func _difficulty_motion_factor() -> float:
	match difficulty:
		"facil":
			return 1.56
		"normal":
			return 1.72
		"dificil":
			return 2.35
		_:
			return 1.25

func _obstacle_speed() -> float:
	var round_bonus: float = float(current_round) * (2.8 if difficulty == "facil" else 4.2)
	return float(_rules().get("npc_speed", 58.0)) + round_bonus + randf_range(-3.0, 4.0)

func _world_speed() -> float:
	return float(_rules().get("world_speed", 270.0)) + float(current_round) * 10.0

func _lane_x(lane: int) -> float:
	var viewport_height: float = maxf(get_viewport_rect().size.y, 720.0)
	return _lane_x_at_y(lane, viewport_height * car_y_ratio)

func _lane_from_x(x: float) -> int:
	var viewport_width: float = maxf(get_viewport_rect().size.x, 1.0)
	return DLConfig.LANE_LEFT if x < viewport_width * 0.5 else DLConfig.LANE_RIGHT

func _player_car_route_scale() -> float:
	if state == DLConfig.STATE_ACCELERATION:
		return DLConfig.PLAYER_CAR_NEAR_ROUTE_SCALE
	if state == DLConfig.STATE_DRIVE:
		# V0.13.8.7: a escala segue a profundidade visual real do Velox,
		# não apenas o tempo. Assim a zona segura não deixa o carro pequeno demais
		# antes de ele avançar para a bifurcação.
		# V0.13.8.8: na reta final, a escala também chega gradualmente à escala
		# da decisão, eliminando o salto visual antes das opções A/B.
		var depth_progress: float = _player_car_depth_progress()
		var depth_scale: float = lerpf(DLConfig.PLAYER_CAR_NEAR_ROUTE_SCALE, DLConfig.PLAYER_CAR_FAR_ROUTE_SCALE, depth_progress)
		var center_blend: float = _decision_center_blend_ratio(_route_progress_ratio())
		return lerpf(depth_scale, DLConfig.PLAYER_CAR_DECISION_SCALE, center_blend)
	return car_rect.scale.x if car_rect != null else DLConfig.PLAYER_CAR_NEAR_ROUTE_SCALE

func _car_size() -> Vector2:
	var viewport_size: Vector2 = get_viewport_rect().size
	var scale_factor: float = clampf(minf(viewport_size.x / 1280.0, viewport_size.y / 720.0), 0.76, 1.15)
	return Vector2(158, 118) * scale_factor

func _set_car_sprite(key: String) -> void:
	car_rect.texture = _load_texture(str(DLConfig.CAR_SPRITES.get(key, DLConfig.CAR_SPRITES["reto"])))

func _load_texture(path: String) -> Texture2D:
	var resource: Resource = load(path)
	if resource is Texture2D:
		return resource as Texture2D
	return null

func _fade_from_black() -> void:
	if fade_rect == null:
		return
	fade_rect.color = Color(0, 0, 0, 0.85)
	if _animations_enabled():
		var tween := create_tween()
		tween.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 0.35)
	else:
		fade_rect.color = Color(0, 0, 0, 0)

func _fade_to_black() -> void:
	if fade_rect == null:
		return
	if _animations_enabled():
		var tween := create_tween()
		tween.tween_property(fade_rect, "color", Color(0, 0, 0, 0.88), 0.22)
		await tween.finished
	else:
		fade_rect.color = Color(0, 0, 0, 0.88)

func _canvas_item_global_position(node: Node) -> Vector2:
	if node == null or not is_instance_valid(node):
		return Vector2.ZERO

	var raw_pos := Vector2.ZERO
	if node is Node2D:
		raw_pos = (node as Node2D).global_position
	elif node is Control:
		raw_pos = (node as Control).global_position
	else:
		return Vector2.ZERO

	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return raw_pos

	# Resolução base de referência do editor (1280x720)
	const BASE_WIDTH := 1280.0
	const BASE_HEIGHT := 720.0

	# Fator de escala vertical da tela atual
	var scale_y: float = viewport_size.y / BASE_HEIGHT

	# Centro X real da tela do dispositivo vs Centro X da resolução de projeto (640px)
	var current_center_x: float = viewport_size.x * 0.5
	var base_center_x: float = BASE_WIDTH * 0.5

	# Recalcula a posição X proporcionalmente ao centro da estrada e a altura Y com a escala
	var adjusted_x: float = current_center_x + (raw_pos.x - base_center_x) * scale_y
	var adjusted_y: float = raw_pos.y * scale_y

	return Vector2(adjusted_x, adjusted_y)

func _on_tutorial_layer_draw() -> void:
	if tutorial_layer == null or not tutorial_layer.visible or tutorial_alpha <= 0.01:
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var font: Font = get_theme_default_font()
	var pulse: float = 0.5 + 0.5 * sin(road_time * 8.0)
	var card_w: float = minf(viewport_size.x * 0.86, 920.0)
	var card_h: float = 168.0 if state == DLConfig.STATE_TUTORIAL_INTRO else 142.0
	var card_pos: Vector2 = Vector2((viewport_size.x - card_w) * 0.5, viewport_size.y * 0.135)
	var card_rect: Rect2 = Rect2(card_pos, Vector2(card_w, card_h))
	tutorial_layer.draw_rect(card_rect, Color(0.01, 0.025, 0.060, 0.46 * tutorial_alpha), true)
	tutorial_layer.draw_rect(card_rect, Color(0.0, 0.92, 1.0, 0.72 * tutorial_alpha), false, 2.0)
	if state == DLConfig.STATE_TUTORIAL_INTRO:
		tutorial_layer.draw_string(font, card_pos + Vector2(0.0, 38.0), tutorial_message, HORIZONTAL_ALIGNMENT_CENTER, card_w, 28, Color(0.74, 0.98, 1.0, tutorial_alpha))
		var arrow_y: float = card_pos.y + 86.0
		_draw_tutorial_arrow(Vector2(card_pos.x + card_w * 0.24 - pulse * 8.0, arrow_y), DLConfig.LANE_LEFT, 1.0, tutorial_alpha)
		_draw_tutorial_arrow(Vector2(card_pos.x + card_w * 0.76 + pulse * 8.0, arrow_y), DLConfig.LANE_RIGHT, 1.0, tutorial_alpha)
		tutorial_layer.draw_string(font, card_pos + Vector2(card_w * 0.36, 95.0), "faixa centro", HORIZONTAL_ALIGNMENT_CENTER, card_w * 0.28, 18, Color(1.0, 0.92, 0.45, tutorial_alpha))
		tutorial_layer.draw_string(font, card_pos + Vector2(28.0, 136.0), "clique para seguir para esquerda", HORIZONTAL_ALIGNMENT_LEFT, card_w * 0.43, 17, Color(0.96, 0.98, 1.0, tutorial_alpha))
		tutorial_layer.draw_string(font, card_pos + Vector2(card_w * 0.54, 136.0), "clique para seguir para direita", HORIZONTAL_ALIGNMENT_RIGHT, card_w * 0.43, 17, Color(0.96, 0.98, 1.0, tutorial_alpha))
	else:
		var arrow_offset: float = (-pulse * 10.0) if tutorial_direction == DLConfig.LANE_LEFT else (pulse * 10.0)
		_draw_tutorial_arrow(Vector2(card_pos.x + card_w * 0.50 + arrow_offset, card_pos.y + 50.0), tutorial_direction, 1.28, tutorial_alpha)
		tutorial_layer.draw_string(font, card_pos + Vector2(0.0, 88.0), tutorial_message, HORIZONTAL_ALIGNMENT_CENTER, card_w, 25, Color(1.0, 0.92, 0.45, tutorial_alpha))
		tutorial_layer.draw_string(font, card_pos + Vector2(20.0, 121.0), tutorial_submessage, HORIZONTAL_ALIGNMENT_CENTER, card_w - 40.0, 17, Color(0.95, 0.98, 1.0, tutorial_alpha))

func _draw_tutorial_arrow(center: Vector2, direction: int, scale_value: float, alpha: float) -> void:
	var key: String = "left" if direction == DLConfig.LANE_LEFT else "right"
	var texture: Texture2D = tutorial_arrow_textures.get(key, null)
	var size_value: Vector2 = Vector2(180.0, 54.0) * scale_value
	if texture != null:
		tutorial_layer.draw_texture_rect(texture, Rect2(center - size_value * 0.5, size_value), false, Color(1.0, 1.0, 1.0, alpha))
		return
	var direction_sign: float = -1.0 if direction == DLConfig.LANE_LEFT else 1.0
	var start: Vector2 = center - Vector2(direction_sign * -68.0, 0.0) * scale_value
	var finish: Vector2 = center + Vector2(direction_sign * 68.0, 0.0) * scale_value
	tutorial_layer.draw_line(start, finish, Color(0.0, 0.92, 1.0, alpha), 7.0 * scale_value)
	var tip: Vector2 = finish
	tutorial_layer.draw_line(tip, tip - Vector2(direction_sign * 26.0, 18.0) * scale_value, Color(0.0, 0.92, 1.0, alpha), 7.0 * scale_value)
	tutorial_layer.draw_line(tip, tip - Vector2(direction_sign * 26.0, -18.0) * scale_value, Color(0.0, 0.92, 1.0, alpha), 7.0 * scale_value)

func _on_road_layer_draw() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	if state == DLConfig.STATE_ACCELERATION or state == DLConfig.STATE_DRIVE:
		_draw_road_motion(viewport_size)
	if state == DLConfig.STATE_DECISION:
		var left_color: Color = Color(0.0, 0.95, 1.0, 0.12)
		var right_color: Color = Color(1.0, 0.55, 0.0, 0.12)
		road_layer.draw_rect(Rect2(0, viewport_size.y * 0.25, viewport_size.x * 0.50, viewport_size.y * 0.75), left_color, true)
		road_layer.draw_rect(Rect2(viewport_size.x * 0.50, viewport_size.y * 0.25, viewport_size.x * 0.50, viewport_size.y * 0.75), right_color, true)

func _draw_road_motion(viewport_size: Vector2) -> void:
	var road_top: float = viewport_size.y * 0.345
	var player_zone_y: float = viewport_size.y * clampf(car_y_ratio + 0.11, 0.82, 0.97)
	var road_bottom: float = minf(viewport_size.y * 0.99, player_zone_y)
	var road_span: float = maxf(road_bottom - road_top, 1.0)
	var speed_factor: float = _world_speed()
	var offset: float = fmod(road_time * speed_factor * 0.95, 104.0)
	var motion_ratio: float = _current_motion_ratio()
	var effect_alpha: float = lerpf(0.12, 1.0, motion_ratio)

	# Linha central animada: nasce na zona de spawn dos NPCs e segue até a área do Bionix.
	for c in range(11):
		var cy: float = road_top + fmod(float(c) * 84.0 + offset * 1.15, road_span)
		var ct: float = clampf((cy - road_top) / road_span, 0.0, 1.0)
		var dash_len: float = lerpf(9.0, 46.0, ct)
		var dash_w: float = lerpf(1.4, 5.2, ct)
		road_layer.draw_line(Vector2(viewport_size.x * 0.5, cy), Vector2(viewport_size.x * 0.5, minf(road_bottom, cy + dash_len)), Color(0.90, 0.94, 1.0, lerpf(0.050, 0.245, ct) * effect_alpha), dash_w)

	# V0.13.7.2: placas prateadas curtas sobre a pista para deixar a animação de velocidade mais perceptível.
	for lane in DLConfig.PLAYABLE_LANES:
		for s_i in range(7):
			var sy: float = road_top + fmod(float(s_i) * 132.0 + offset * 1.58 + float(lane) * 54.0, road_span)
			var st: float = clampf((sy - road_top) / road_span, 0.0, 1.0)
			var sx: float = _lane_x_at_y(lane, sy)
			var half_len: float = lerpf(12.0, 46.0, st)
			var down_shift: float = lerpf(3.0, 17.0, st)
			var silver_alpha: float = lerpf(0.045, 0.205, st)
			road_layer.draw_line(Vector2(sx - half_len, sy), Vector2(sx + half_len, sy + down_shift), Color(0.86, 0.89, 0.93, silver_alpha * effect_alpha), lerpf(1.7, 4.4, st))

	# Rastros internos por faixa: deixam claro o fluxo entre o nascimento dos NPCs e o carro do jogador.
	for lane in DLConfig.PLAYABLE_LANES:
		for r in range(8):
			var y: float = road_top + fmod(float(r) * 112.0 + offset * 1.36 + float(lane) * 34.0, road_span)
			var t: float = clampf((y - road_top) / road_span, 0.0, 1.0)
			var lane_x: float = _lane_x_at_y(lane, y)
			var lane_dir: float = -1.0 if lane == DLConfig.LANE_LEFT else 1.0
			var side_offset: float = lerpf(7.0, 34.0, t)
			var streak_len: float = lerpf(12.0, 42.0, t)
			var alpha: float = lerpf(0.040, 0.155, t)
			road_layer.draw_line(Vector2(lane_x - lane_dir * side_offset, y), Vector2(lane_x - lane_dir * (side_offset + streak_len), y + lerpf(3.0, 19.0, t)), Color(0.82, 0.90, 0.98, alpha * effect_alpha), lerpf(1.0, 2.0, t))

	# Listras laterais na pista, nos dois lados da estrada, reforçando velocidade sem poluir o centro.
	for side in [-1, 1]:
		for k in range(10):
			var y: float = road_top + float(k) * 86.0 + offset * 1.06 + float(side) * 17.0
			while y > road_bottom:
				y -= road_span
			var t: float = clampf((y - road_top) / road_span, 0.0, 1.0)
			var left_edge: float = viewport_size.x * lerpf(0.455, 0.115, t)
			var right_edge: float = viewport_size.x * lerpf(0.545, 0.885, t)
			var edge_x: float = left_edge if side < 0 else right_edge
			var inner_offset: float = lerpf(9.0, 34.0, t)
			var x: float = edge_x - float(side) * inner_offset
			var streak_len: float = lerpf(10.0, 35.0, t)
			var streak_down: float = lerpf(4.0, 16.0, t)
			var streak_alpha: float = lerpf(0.044, 0.170, t)
			road_layer.draw_line(Vector2(x, y), Vector2(x + float(side) * streak_len, y + streak_down), Color(0.78, 0.86, 0.96, streak_alpha * effect_alpha), lerpf(1.0, 2.0, t))

	# Linhas discretas no gramado, usando trilhas editáveis no Godot.
	for side in [-1, 1]:
		var prop_type: String = DLConfig.PROP_POST_LEFT if side < 0 else DLConfig.PROP_POST
		for k in range(12):
			var y: float = road_top + float(k) * 74.0 + offset
			while y > road_bottom:
				y -= road_span
			var t: float = clampf((y - road_top) / road_span, 0.0, 1.0)
			var grass_x: float = sideprops._side_prop_path_x_at_y(prop_type, side, y)
			if grass_x < 0.0:
				grass_x = sideprops._side_grass_x_at_y(side, y, viewport_size)
			var marker_alpha: float = lerpf(0.035, 0.14, t)
			var marker_length: float = lerpf(10.0, 38.0, t)
			var marker_width: float = lerpf(1.0, 2.2, t)
			road_layer.draw_line(Vector2(grass_x, y), Vector2(grass_x + float(side) * marker_length, y + lerpf(4.0, 18.0, t)), Color(0.78, 1.0, 0.36, marker_alpha * effect_alpha), marker_width)

	var center_shadow: Rect2 = Rect2(viewport_size.x * 0.39, road_top, viewport_size.x * 0.22, road_span)
	road_layer.draw_rect(center_shadow, Color(0.0, 0.0, 0.0, 0.022 * effect_alpha), true)

func _update_drive_timer_label() -> void:
	# V0.13.10: o avanço/tempo fica apenas no HUD superior.
	# O painel inferior esquerdo passa a exibir só contexto e mensagens curtas.
	if timer_label != null:
		timer_label.visible = false
		timer_label.text = ""
	if route_progress_hud != null:
		route_progress_hud.queue_redraw()

func _route_progress_ratio() -> float:
	if state == DLConfig.STATE_DRIVE:
		return clampf(drive_elapsed / maxf(_drive_duration(), 1.0), 0.0, 1.0)
	if state == DLConfig.STATE_DECISION or state == DLConfig.STATE_TURN_EXIT:
		return 1.0
	return 0.0

func _on_route_progress_hud_draw() -> void:
	if route_progress_hud == null or not route_progress_hud.visible:
		return
	var hud_size: Vector2 = route_progress_hud.size
	if hud_size.x <= 0.0 or hud_size.y <= 0.0:
		return
	var font: Font = get_theme_default_font()
	var progress: float = _route_progress_ratio()
	var line_y: float = hud_size.y * 0.58
	var line_start: Vector2 = Vector2(hud_size.x * 0.17, line_y)
	var line_end: Vector2 = Vector2(hud_size.x * 0.83, line_y)
	var fill_end: Vector2 = line_start.lerp(line_end, progress)
	# V0.13.4.10: HUD superior sem retângulo preenchido; apenas texto/barra com sombra.
	var label_pos: Vector2 = Vector2(hud_size.x * 0.04, hud_size.y * 0.31)
	var percent_pos: Vector2 = Vector2(hud_size.x * 0.69, hud_size.y * 0.31)
	route_progress_hud.draw_string(font, label_pos + Vector2(1.5, 1.5), "ROTA ATÉ A DECISÃO", HORIZONTAL_ALIGNMENT_LEFT, hud_size.x * 0.34, 13, Color(0.0, 0.0, 0.0, 0.45))
	route_progress_hud.draw_string(font, percent_pos + Vector2(1.5, 1.5), "%s%%" % int(round(progress * 100.0)), HORIZONTAL_ALIGNMENT_RIGHT, hud_size.x * 0.27, 13, Color(0.0, 0.0, 0.0, 0.45))
	route_progress_hud.draw_string(font, label_pos, "ROTA ATÉ A DECISÃO", HORIZONTAL_ALIGNMENT_LEFT, hud_size.x * 0.34, 13, Color(0.74, 0.96, 1.0, 0.95))
	route_progress_hud.draw_string(font, percent_pos, "%s%%" % int(round(progress * 100.0)), HORIZONTAL_ALIGNMENT_RIGHT, hud_size.x * 0.27, 13, Color(1.0, 0.92, 0.45, 0.98))
	route_progress_hud.draw_line(line_start + Vector2(0.0, 2.0), line_end + Vector2(0.0, 2.0), Color(0.0, 0.0, 0.0, 0.24), 6.0)
	route_progress_hud.draw_line(line_start, line_end, Color(0.08, 0.27, 0.36, 0.60), 5.0)
	route_progress_hud.draw_line(line_start, fill_end, Color(0.0, 0.92, 1.0, 0.95), 5.0)
	route_progress_hud.draw_circle(line_start, 5.0, Color(0.72, 0.96, 1.0, 0.88))
	route_progress_hud.draw_circle(line_end, 6.0, Color(1.0, 0.68, 0.18, 0.92))
	var car_size := Vector2(54, 34)
	var car_pos := fill_end - Vector2(car_size.x * 0.50, car_size.y + 6.0 + sin(waterfx.water_time * 6.0) * 1.4)
	if route_car_texture != null:
		route_progress_hud.draw_texture_rect(route_car_texture, Rect2(car_pos, car_size), false, Color(1.0, 1.0, 1.0, 0.96))
	else:
		route_progress_hud.draw_rect(Rect2(car_pos, car_size), Color(0.0, 0.75, 1.0, 0.92), true)

func _on_damage_hud_draw() -> void:
	if damage_hud == null:
		return
	var hud_size: Vector2 = damage_hud.size
	if hud_size.x <= 0.0 or hud_size.y <= 0.0:
		return
	var panel_rect: Rect2 = Rect2(Vector2.ZERO, hud_size)
	# V0.13.10.8: painel compacto com separação vertical interna.
	# A safe area mantém arco/agulha/textos totalmente dentro das bordas.
	damage_hud.draw_rect(panel_rect, Color(0.005, 0.020, 0.055, 0.22), true)
	damage_hud.draw_rect(panel_rect, Color(0.0, 0.92, 1.0, 0.66), false, 1.0)
	var font: Font = get_theme_default_font()

	var safe_margin: float = 16.0
	var gauge_area: Rect2 = Rect2(
		Vector2(safe_margin, 8.0),
		Vector2(maxf(1.0, hud_size.x - safe_margin * 2.0), 92.0)
	)
	var gauge_center_x: float = gauge_area.position.x + gauge_area.size.x * 0.5
	var speed: float = _bionix_current_speed_kmh()
	var max_speed: float = _bionix_max_speed_kmh()
	var speed_ratio: float = clampf(speed / maxf(max_speed, 1.0), 0.0, 1.0)
	var center: Vector2 = Vector2(gauge_center_x, gauge_area.position.y + 42.0)
	var radius_limit_x: float = maxf(20.0, gauge_area.size.x * 0.5 - 14.0)
	var radius_limit_y: float = maxf(20.0, center.y - gauge_area.position.y - 8.0)
	var radius: float = minf(34.0, minf(radius_limit_x, radius_limit_y))
	var start_angle: float = deg_to_rad(205.0)
	var end_angle: float = deg_to_rad(335.0)
	var needle_angle: float = lerpf(start_angle, end_angle, speed_ratio)
	damage_hud.draw_arc(center + Vector2(0.0, 2.0), radius, start_angle, end_angle, 36, Color(0.0, 0.0, 0.0, 0.34), 5.0, true)
	damage_hud.draw_arc(center, radius, start_angle, end_angle, 36, Color(0.05, 0.20, 0.28, 0.72), 4.5, true)
	damage_hud.draw_arc(center, radius, start_angle, needle_angle, 28, Color(0.0, 0.92, 1.0, 0.92), 4.5, true)
	var warning_start: float = lerpf(start_angle, end_angle, 0.78)
	damage_hud.draw_arc(center, radius + 2.0, warning_start, end_angle, 14, Color(1.0, 0.66, 0.12, 0.70), 2.0, true)
	for i in range(0, 6):
		var t: float = float(i) / 5.0
		var angle: float = lerpf(start_angle, end_angle, t)
		var p1: Vector2 = center + Vector2(cos(angle), sin(angle)) * (radius - 7.0)
		var p2: Vector2 = center + Vector2(cos(angle), sin(angle)) * (radius + 1.5)
		var tick_color: Color = Color(0.78, 1.0, 1.0, 0.74) if t < 0.78 else Color(1.0, 0.72, 0.18, 0.82)
		damage_hud.draw_line(p1, p2, tick_color, 1.8)
	var needle_end: Vector2 = center + Vector2(cos(needle_angle), sin(needle_angle)) * (radius - 10.0)
	damage_hud.draw_line(center, needle_end, Color(1.0, 0.80, 0.18, 0.96), 2.6)
	damage_hud.draw_circle(center, 4.4, Color(0.0, 0.92, 1.0, 0.95))

	var speed_text: String = "%03d" % int(round(speed))
	var speed_text_width: float = minf(98.0, gauge_area.size.x - 10.0)
	# A leitura fica abaixo da base do ponteiro, com folga visual constante.
	var speed_text_pos: Vector2 = Vector2(gauge_center_x - speed_text_width * 0.5, center.y + radius + 13.0)
	damage_hud.draw_string(font, speed_text_pos + Vector2(1.3, 1.3), speed_text, HORIZONTAL_ALIGNMENT_CENTER, speed_text_width, 27, Color(0.0, 0.0, 0.0, 0.52))
	damage_hud.draw_string(font, speed_text_pos, speed_text, HORIZONTAL_ALIGNMENT_CENTER, speed_text_width, 27, Color(1.0, 0.88, 0.34, 0.98))
	var unit_width: float = minf(58.0, gauge_area.size.x - 10.0)
	var unit_pos: Vector2 = Vector2(gauge_center_x - unit_width * 0.5, speed_text_pos.y + 20.0)
	damage_hud.draw_string(font, unit_pos + Vector2(1.0, 1.0), "km/h", HORIZONTAL_ALIGNMENT_CENTER, unit_width, 12, Color(0.0, 0.0, 0.0, 0.48))
	damage_hud.draw_string(font, unit_pos, "km/h", HORIZONTAL_ALIGNMENT_CENTER, unit_width, 12, Color(0.82, 0.96, 1.0, 0.86))

	var integrity_label: String = "Integridade: %s%%" % int(round(integrity))
	var label_width: float = maxf(1.0, hud_size.x - safe_margin * 2.0)
	var is_integrity_critical: bool = integrity <= 25.0
	var label_y: float = hud_size.y - 56.0 if is_integrity_critical else hud_size.y - 43.0
	var label_pos: Vector2 = Vector2(safe_margin, label_y)
	damage_hud.draw_string(font, label_pos + Vector2(1.1, 1.1), integrity_label, HORIZONTAL_ALIGNMENT_CENTER, label_width, 13, Color(0.0, 0.0, 0.0, 0.54))
	damage_hud.draw_string(font, label_pos, integrity_label, HORIZONTAL_ALIGNMENT_CENTER, label_width, 13, _integrity_color())
	if is_integrity_critical:
		var pulse: float = 0.50 + 0.36 * sin(waterfx.water_time * 8.0)
		damage_hud.draw_rect(panel_rect, Color(1.0, 0.05, 0.02, pulse * 0.10), true)
		var alert_pos: Vector2 = Vector2(safe_margin, hud_size.y - 39.0)
		damage_hud.draw_string(font, alert_pos + Vector2(1.0, 1.0), "ALERTA CRÍTICO", HORIZONTAL_ALIGNMENT_CENTER, label_width, 11, Color(0.0, 0.0, 0.0, 0.52))
		damage_hud.draw_string(font, alert_pos, "ALERTA CRÍTICO", HORIZONTAL_ALIGNMENT_CENTER, label_width, 11, Color(1.0, 0.25, 0.18, 0.95))
	# Barra horizontal mantida: mais legível e sem competir com o velocímetro.
	var bar_w: float = minf(198.0, hud_size.x - safe_margin * 2.0)
	var bar_x: float = (hud_size.x - bar_w) * 0.5
	var bar_rect: Rect2 = Rect2(Vector2(bar_x, hud_size.y - 18.0), Vector2(bar_w, 8.0))
	damage_hud.draw_rect(bar_rect, Color(0.0, 0.0, 0.0, 0.36), true)
	damage_hud.draw_rect(bar_rect, Color(0.0, 0.92, 1.0, 0.34), false, 1.0)
	var fill_rect: Rect2 = Rect2(bar_rect.position, Vector2(bar_rect.size.x * clampf(integrity / 100.0, 0.0, 1.0), bar_rect.size.y))
	damage_hud.draw_rect(fill_rect, _integrity_color(), true)

func _bionix_max_speed_kmh() -> float:
	return float(DLConfig.BIONIX_MAX_SPEED_KMH.get(difficulty, 200.0))

func _bionix_current_speed_kmh() -> float:
	var max_speed: float = _bionix_max_speed_kmh()
	if state == DLConfig.STATE_ACCELERATION:
		return max_speed * clampf(acceleration_ratio, 0.0, 1.0)
	if state == DLConfig.STATE_DRIVE:
		var progress: float = _route_progress_ratio()
		var pulse: float = 0.018 * sin(road_time * 5.5) + 0.010 * sin(road_time * 13.0)
		var decel_ratio: float = _final_deceleration_ratio(progress)
		var base_speed: float = max_speed * (0.965 + pulse)
		return clampf(base_speed * decel_ratio, 0.0, max_speed)
	if state == DLConfig.STATE_DECISION:
		return 0.0
	return 0.0

func _fit_rect_into(container_rect: Rect2, content_size: Vector2) -> Rect2:
	if content_size.x <= 0.0 or content_size.y <= 0.0:
		return container_rect
	var scale_factor: float = minf(container_rect.size.x / content_size.x, container_rect.size.y / content_size.y)
	var fitted_size: Vector2 = content_size * scale_factor
	var fitted_position: Vector2 = container_rect.position + (container_rect.size - fitted_size) * 0.5
	return Rect2(fitted_position, fitted_size)

func _integrity_color() -> Color:
	if integrity >= 70.0:
		return Color(0.42, 1.0, 0.60)
	if integrity >= 35.0:
		return Color(1.0, 0.82, 0.22)
	return Color(1.0, 0.30, 0.24)

func _make_choice_button(label: String) -> Button:
	var button := Button.new()
	button.text = label
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_color_override("font_color", Color(1, 1, 1))
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.02, 0.04, 0.10, 0.82), Color(0.0, 0.95, 1.0, 0.78), 18, 2))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.03, 0.16, 0.26, 0.95), Color(1.0, 1.0, 1.0, 0.88), 18, 2))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.08, 0.32, 0.42, 0.98), Color(1.0, 0.82, 0.18, 0.92), 18, 2))
	return button

func _make_label(text: String, font_size: int, color: Color, align: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.88))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	return label

func _make_hud_card_style(bg_color: Color, border_color: Color, radius: int = 14, border_width: int = 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0, 0, 0, 0.16)
	style.shadow_size = 3
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func _make_panel_style(bg_color: Color, border_color: Color, radius: int = 14, border_width: int = 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0, 0, 0, 0.38)
	style.shadow_size = 8
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

func _animations_enabled() -> bool:
	return not has_node("/root/SettingsManager") or SettingsManager.animations_enabled()

