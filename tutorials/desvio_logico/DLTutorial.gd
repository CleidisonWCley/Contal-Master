extends RefCounted
class_name DLTutorial
## Tutorial do Desvio Logico (V0.10) — migrado de DesvioLogico.gd para a pasta de tutoriais.
##
## Mantem o tutorial MECANICO de antes (praticar o desvio para a esquerda e para a direita, com os
## carros da cena) e coloca a NATALIA por cima, usando o mesmo TutorialOverlay dos outros minigames:
##   fase "intro"    -> overlay MODAL: explica o que a mecanica nao mostra (o carro acelera sozinho,
##                      o jogador so escolhe o lado, a bifurcacao e a pergunta);
##   fases "left" / "right" -> overlay COACH (nao bloqueia): Natalia + seta apontando o lado
##                      enquanto o jogador pratica;
##   fase "go"       -> overlay MODAL ANTES da largada: a Natalia anuncia o inicio e o carro so acelera
##                      quando o jogador aperta "Continuar" (pular tambem inicia o jogo);
##   fase "decision" -> COACH na 1a bifurcacao da partida.
## Textos: res://tutorials/data/desvio_logico.json. Pular em qualquer ponto vai direto para a corrida real.
## So roda na rodada 0 (como antes) e respeita Configuracoes > Tutoriais.

const KEY := "desvio_logico"

var g: DesvioLogicoGame
var coach: TutorialOverlay
var skipped: bool = false
var arrow_textures: Dictionary = {}

func _init(game: DesvioLogicoGame) -> void:
	g = game

# ---------------------------------------------------------------- ciclo

func load_textures() -> void:
	arrow_textures.clear()
	arrow_textures["left"] = g._load_texture(str(DLConfig.TUTORIAL_ARROW_SPRITES["left"]))
	arrow_textures["right"] = g._load_texture(str(DLConfig.TUTORIAL_ARROW_SPRITES["right"]))

func is_active_state() -> bool:
	return g.state == DLConfig.STATE_TUTORIAL_INTRO or g.state == DLConfig.STATE_TUTORIAL_LEFT or g.state == DLConfig.STATE_TUTORIAL_RIGHT

func is_car_state() -> bool:
	return g.state == DLConfig.STATE_TUTORIAL_LEFT or g.state == DLConfig.STATE_TUTORIAL_RIGHT

func is_point_over_ui(point: Vector2) -> bool:
	return coach != null and is_instance_valid(coach) and coach.is_point_over_ui(point)

func start_sequence() -> void:
	skipped = false
	g.state = DLConfig.STATE_TUTORIAL_INTRO
	g.input_locked = true
	g.traffic._reset_traffic_wave_distribution()
	g.drive_elapsed = 0.0
	g.traffic.next_spawn_time = g.traffic._first_spawn_delay()
	if g.pause_button != null:
		g.pause_button.visible = false
	g.status_label.text = "Tutorial rápido: use esquerda e direita para desviar dos carros."
	if not TutorialManager.is_enabled(g):
		finish_sequence()
		return
	# 1) Natalia explica por cima (modal). Pular aqui pula o tutorial inteiro.
	var completed: bool = await TutorialManager.play(g, KEY, {"phase": "intro", "arrow_textures": arrow_textures})
	if not g.is_inside_tree():
		return
	if not completed and _intro_was_skipped():
		finish_sequence()
		return
	# 2) Tutorial mecanico com a Natalia como coach.
	_create_coach()
	start_left()

func _intro_was_skipped() -> bool:
	# play() devolve false tanto para "pulou" quanto para "arquivo ausente"; so pulamos o mecanico no 1o caso.
	return TutorialManager.steps_for(g, KEY, "intro").size() > 0

func start_left() -> void:
	if skipped:
		return
	g.state = DLConfig.STATE_TUTORIAL_LEFT
	g.input_locked = false
	g.current_lane = DLConfig.LANE_RIGHT
	g._set_car_sprite("reto")
	g._reset_car_lane_tilt()
	g._layout_car(false)
	g._clear_obstacles()
	spawn_car(DLConfig.LANE_RIGHT)
	g.status_label.text = "Tutorial: clique à esquerda para escapar do carro à direita."
	_show_coach_phase("left")

func start_right() -> void:
	if skipped:
		return
	g.state = DLConfig.STATE_TUTORIAL_RIGHT
	g.input_locked = false
	g.current_lane = DLConfig.LANE_LEFT
	g._set_car_sprite("reto")
	g._reset_car_lane_tilt()
	g._layout_car(false)
	g._clear_obstacles()
	spawn_car(DLConfig.LANE_LEFT)
	g.status_label.text = "Tutorial: clique à direita para escapar do carro à esquerda."
	_show_coach_phase("right")

func handle_input(lane: int) -> void:
	if g.input_locked:
		return
	if g.state == DLConfig.STATE_TUTORIAL_LEFT:
		if lane != DLConfig.LANE_LEFT:
			g.status_label.text = "Clique no lado esquerdo para desviar desse carro."
			return
		g._move_to_lane(DLConfig.LANE_LEFT)
		g.input_locked = true
		g._clear_obstacles()
		await g.get_tree().create_timer(0.35).timeout
		if g.state == DLConfig.STATE_TUTORIAL_LEFT:
			start_right()
	elif g.state == DLConfig.STATE_TUTORIAL_RIGHT:
		if lane != DLConfig.LANE_RIGHT:
			g.status_label.text = "Clique no lado direito para desviar desse carro."
			return
		g._move_to_lane(DLConfig.LANE_RIGHT)
		g.input_locked = true
		g._clear_obstacles()
		await g.get_tree().create_timer(0.35).timeout
		if g.state == DLConfig.STATE_TUTORIAL_RIGHT:
			finish_sequence()

func finish_sequence() -> void:
	g._clear_obstacles()
	g._reset_car_lane_tilt()
	g._set_car_sprite("reto")
	g.input_locked = true
	close_coach()
	# V0.10.2: a Natalia fecha o tutorial ANTES de o carro acelerar. O jogo so inicia quando o jogador
	# aperta "Continuar" (ou "Pular", quando permitido). Se pulou ou os tutoriais estao desligados,
	# o jogo inicia direto.
	if not skipped and TutorialManager.is_enabled(g):
		await TutorialManager.play(g, KEY, {"phase": "go", "arrow_textures": arrow_textures})
		if not g.is_inside_tree():
			return
	g._begin_real_drive_after_tutorial()

## Chamado por DesvioLogico._enter_decision_phase(): dica na 1a bifurcacao.
func on_decision_phase() -> void:
	if g.current_round != 0 or skipped or not TutorialManager.is_enabled(g):
		return
	_show_coach_phase("decision")

## Chamado por DesvioLogico._resolve_choice(): a dica some quando o jogador escolhe a rota.
func on_choice_made() -> void:
	close_coach()

func close_coach() -> void:
	if coach != null and is_instance_valid(coach):
		coach.close(true)
	coach = null

func spawn_car(lane: int) -> void:
	var viewport_height: float = maxf(g.get_viewport_rect().size.y, 720.0)
	var y: float = viewport_height * 0.370
	g.traffic._spawn_npc_at(lane, y, true, 0.34)
	if g.obstacle_data.size() > 0:
		var data: Dictionary = g.obstacle_data[g.obstacle_data.size() - 1]
		data["tutorial"] = true
		data["grace"] = 9999.0
		data["collision_y"] = viewport_height * 9.0
		data["speed"] = g._obstacle_speed() * 0.34
		g.obstacle_data[g.obstacle_data.size() - 1] = data

# ---------------------------------------------------------------- coach (Natalia)

func _create_coach() -> void:
	if coach != null and is_instance_valid(coach):
		return
	if not TutorialManager.is_enabled(g):
		return
	coach = TutorialManager.create_overlay(g, KEY, {"arrow_textures": arrow_textures}, TutorialOverlay.Mode.COACH)
	if coach != null:
		coach.skip_requested.connect(_on_coach_skip)

func _show_coach_phase(phase: String) -> void:
	if not TutorialManager.is_enabled(g):
		return
	_create_coach()
	if coach == null:
		return
	var steps: Array = TutorialManager.steps_for(g, KEY, phase)
	if not steps.is_empty():
		coach.show_coach(steps[0])

func _on_coach_skip() -> void:
	if is_active_state():
		skipped = true
		close_coach()
		finish_sequence()
	else:
		skipped = true
		close_coach()
