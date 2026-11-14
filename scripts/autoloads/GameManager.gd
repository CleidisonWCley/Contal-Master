extends Node

enum GameMode { NONE, CAMPAIGN, FREE }

const BrandText := preload("res://scripts/ui/BrandText.gd")

const APP_NAME := BrandText.BRAND_NAME  # "ContalMaster" (sempre junto)
const APP_VERSION := BrandText.DEFAULT_VERSION  # versao real: project.godot > BrandText.app_version()

const MAIN_MENU_SCENE := Paths.SCENE_MAIN_MENU
const MODE_SELECT_SCENE := Paths.SCENE_MODE_SELECT
const SETTINGS_SCENE := Paths.SCENE_SETTINGS
const SCORE_SCENE := Paths.SCENE_SCORE
const ACHIEVEMENTS_SCENE := Paths.SCENE_ACHIEVEMENTS
const FREE_MENU_SCENE := Paths.SCENE_FREE_MENU
const INTRO_SCENE := Paths.SCENE_CUTSCENE_INTRO
const STAGE_TRANSITION_SCENE := Paths.SCENE_STAGE_TRANSITION
const FINAL_SCENE := Paths.SCENE_CUTSCENE_FINAL

const PHASES := [
	{
		"key": "show_do_bilhao",
		"name": "Show do Bilhão",
		"scene": Paths.SCENE_SHOW_DO_BILHAO,
		"music": "musica_show_do_bilhao"
	},
	{
		"key": "batalha_naval",
		"name": "Batalha Naval",
		"scene": Paths.SCENE_BATALHA_NAVAL,
		"music": "musica_batalha_naval"
	},
	{
		"key": "maleta_certa",
		"name": "Maleta Certa",
		"scene": Paths.SCENE_MALETA_CERTA,
		"music": "musica_maleta_certa"
	},
	{
		"key": "roleta_risco",
		"name": "Roleta de Risco",
		"scene": Paths.SCENE_ROLETA_RISCO,
		"music": "musica_rodada_bonus"
	},
	{
		"key": "perseguicao",
		"name": "Perseguição",
		"scene": Paths.SCENE_PERSEGUICAO,
		"music": "musica_perseguicao"
	},
	{
		"key": "forca_tecnica",
		"name": "Forca Tecnica",
		"scene": Paths.SCENE_FORCA_TECNICA,
		"music": "musica_forca_tecnica"
	},
	{
		"key": "stop",
		"name": "STOP",
		"scene": Paths.SCENE_STOP,
		"music": "musica_stop"
	},
	{
		"key": "desvio_logico",
		"name": "Desvio Lógico",
		"scene": Paths.SCENE_DESVIO_LOGICO,
		"music": "desvio_logico"
	}
]

const FREE_PHASE_KEYS := [
	"show_do_bilhao",
	"batalha_naval",
	"maleta_certa",
	"perseguicao",
	"forca_tecnica",
	"stop",
	"desvio_logico"
]

## V0.11: a campanha acontece em 2 dias. O dia 1 vai do Show do Bilhao ate o STOP; o dia 2 comeca
## de manha, com o Desvio Logico (carro saindo da garagem). Mude APENAS esta chave para mover a virada.
const DAY_TWO_FIRST_PHASE_KEY := "desvio_logico"
const DAY_LABELS := {1: "DIA 1 · MANHÃ", 2: "DIA 2 · MANHÃ"}

var current_mode: int = GameMode.NONE
var campaign_index: int = 0
var current_phase_key: String = ""
var phase_start_score: int = 0
## Resultado da ultima campanha concluida ({"saved", "previous_score", "total_score"...}); a cutscene final usa para o recorde.
var last_campaign_result: Dictionary = {}

## V0.14.3: true enquanto a fase atual ainda NAO foi concluida. complete_current_stage() so vale uma vez por fase:
## em aparelho lento o jogador toca em "Continuar" de novo enquanto a tela congela e antes isso avancava a campanha
## DUAS fases (campaign_index += 2) e gravava a pontuacao em dobro. Volta a true em _load_phase().
var _stage_open: bool = true
## Cortina (CanvasLayer) que cobre a tela entre o clique em "Continuar" e a LoadingScreen.
var _exit_shield: CanvasLayer = null

## V0.14.3: imagem principal de cada minigame, carregada pela LoadingScreen ANTES da cena (ver SceneLoader).
const PHASE_WARM := {
	"show_do_bilhao": [Paths.BG_SHOW_DO_BILHAO],
	"batalha_naval": [Paths.BG_BATALHA_NAVAL],
	"maleta_certa": [Paths.BG_MALETA_CERTA],
	"roleta_risco": [Paths.BG_ROLETA_RISCO],
	"perseguicao": [Paths.BG_PERSEGUICAO],
	"forca_tecnica": [Paths.BG_FORCA],
	"stop": [Paths.BG_STOP],
	"desvio_logico": [Paths.BG_DL_AMANHECER]
}

func get_app_version_label() -> String:
	return BrandText.version_plain()

func get_app_version_bbcode() -> String:
	return BrandText.version_bbcode()

func go_to_main_menu() -> void:
	current_mode = GameMode.NONE
	current_phase_key = ""
	if has_node("/root/AudioManager"):
		AudioManager.play_music("menu")
	_change_scene(MAIN_MENU_SCENE)

func open_mode_select() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	_change_scene(MODE_SELECT_SCENE)

func open_settings() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	_change_scene(SETTINGS_SCENE)

func open_scores() -> void:
	current_mode = GameMode.NONE
	current_phase_key = ""
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	_change_scene(SCORE_SCENE)

func open_achievements() -> void:
	current_mode = GameMode.NONE
	current_phase_key = ""
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	_change_scene(ACHIEVEMENTS_SCENE)

func open_free_menu() -> void:
	current_mode = GameMode.FREE
	current_phase_key = ""
	if has_node("/root/AudioManager"):
		AudioManager.play_music("menu")
	_change_scene(FREE_MENU_SCENE)

func start_campaign() -> void:
	current_mode = GameMode.CAMPAIGN
	campaign_index = 0
	current_phase_key = ""
	ScoreManager.reset_score()
	ScoreManager.begin_campaign_run(DifficultyManager.get_difficulty())
	if has_node("/root/AchievementManager"):
		AchievementManager.record_campaign_started()
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	_change_scene(INTRO_SCENE)

func start_campaign_after_intro() -> void:
	current_mode = GameMode.CAMPAIGN
	_open_stage_transition()

func start_current_campaign_stage() -> void:
	if current_mode != GameMode.CAMPAIGN:
		go_to_main_menu()
		return
	_load_current_campaign_stage()

func start_free_minigame(index: int) -> void:
	var free_phases: Array = get_free_phases()
	if index < 0 or index >= free_phases.size():
		push_error("Índice de minigame livre inválido: %s" % index)
		return
	current_mode = GameMode.FREE
	# Modo livre sempre inicia em zero e salva somente o recorde solo do minigame.
	ScoreManager.reset_score()
	_load_phase(free_phases[index])

func complete_current_stage(points: int) -> void:
	# Ver _stage_open: so a PRIMEIRA chamada por fase conta.
	if not _stage_open:
		return
	_stage_open = false
	# V0.14.3: cobre a tela e para a fase ANTES do trabalho pesado (salvar, trocar de cena, carregar). O navegador
	# ganha 2 quadros para mostrar o clique, em vez de congelar com o botao "pressionado" na tela.
	await _begin_stage_exit()
	_finish_stage(points)

func _finish_stage(points: int) -> void:
	var completed_phase_key: String = current_phase_key
	if points != 0:
		ScoreManager.add_points(points)
	var score_after_stage: int = ScoreManager.get_score()
	var stage_points: int = score_after_stage - phase_start_score
	var difficulty: String = DifficultyManager.get_difficulty()
	if current_mode == GameMode.CAMPAIGN:
		ScoreManager.save_campaign_stage_score(completed_phase_key, difficulty, stage_points)
		if has_node("/root/AchievementManager"):
			AchievementManager.record_minigame_completed(completed_phase_key, difficulty)
		campaign_index += 1
		if campaign_index < PHASES.size():
			_open_stage_transition()
		else:
			var campaign_result: Dictionary = ScoreManager.finish_campaign_run(difficulty, score_after_stage)
			last_campaign_result = campaign_result
			if has_node("/root/AchievementManager"):
				AchievementManager.record_campaign_completed(difficulty, score_after_stage)
				AchievementManager.record_campaign_score_result(campaign_result)
			current_phase_key = "final"
			if has_node("/root/AudioManager"):
				AudioManager.play_music("musica_final")
			_change_scene(FINAL_SCENE, _warm_for_final())
	else:
		var free_result: Dictionary = ScoreManager.save_free_mode_score(completed_phase_key, difficulty, stage_points)
		if has_node("/root/AchievementManager"):
			AchievementManager.record_free_mode_completion(completed_phase_key, difficulty, free_result)
		ScoreManager.reset_score()
		open_free_menu()
	_release_exit_shield_later()

func is_campaign_mode() -> bool:
	return current_mode == GameMode.CAMPAIGN

func is_free_mode() -> bool:
	return current_mode == GameMode.FREE

func get_current_phase_name() -> String:
	var phase: Dictionary = get_current_phase_info()
	return str(phase.get("name", ""))

func get_current_phase_info() -> Dictionary:
	if campaign_index >= 0 and campaign_index < PHASES.size():
		return PHASES[campaign_index]
	for phase in PHASES:
		if str(phase.get("key", "")) == current_phase_key:
			return phase
	return {}

func get_current_stage_number() -> int:
	return campaign_index + 1

## Dia da campanha (1 ou 2) de um minigame, pela posicao dele em PHASES.
func get_day_for_phase(phase_key: String) -> int:
	if phase_key == "final":
		return 2
	var day_two_index: int = _phase_index(DAY_TWO_FIRST_PHASE_KEY)
	var index: int = _phase_index(phase_key)
	if day_two_index >= 0 and index >= day_two_index:
		return 2
	return 1

## Dia da fase atual da campanha.
func get_current_day() -> int:
	return get_day_for_phase(current_phase_key)

## true se este minigame abre um dia novo (Show do Bilhao abre o dia 1; Desvio Logico abre o dia 2).
func is_first_phase_of_day(phase_key: String) -> bool:
	var index: int = _phase_index(phase_key)
	if index < 0:
		return false
	return index == 0 or get_day_for_phase(phase_key) != get_day_for_phase(str(PHASES[index - 1].get("key", "")))

func _phase_index(phase_key: String) -> int:
	for i in range(PHASES.size()):
		if str(PHASES[i].get("key", "")) == phase_key:
			return i
	return -1

func get_total_stages() -> int:
	return PHASES.size()

func get_free_phases() -> Array:
	var result: Array = []
	for free_key in FREE_PHASE_KEYS:
		for phase in PHASES:
			if str(phase.get("key", "")) == free_key:
				result.append(phase)
				break
	return result

func _open_stage_transition() -> void:
	if campaign_index < PHASES.size():
		current_phase_key = str(PHASES[campaign_index].get("key", ""))
		# V0.14.3 (web): nao carrega a musica "loop_start" aqui. Ela era trocada logo em seguida pela musica da fase
		# (StageTransition) e custava um load() + decodificacao de ~2,8 MB no quadro do clique. Na web a musica
		# anterior segue ate a transicao assumir; fora da web o comportamento e o de sempre.
		if not WebLite.is_web() and has_node("/root/AudioManager"):
			AudioManager.play_music("loop_start")
		_change_scene(STAGE_TRANSITION_SCENE, _warm_for_transition(current_phase_key))
	else:
		current_phase_key = "final"
		_change_scene(FINAL_SCENE, _warm_for_final())

func _load_current_campaign_stage() -> void:
	if campaign_index < PHASES.size():
		_load_phase(PHASES[campaign_index])
	else:
		current_phase_key = "final"
		if has_node("/root/AudioManager"):
			AudioManager.play_music("musica_final")
		_change_scene(FINAL_SCENE, _warm_for_final())

func _load_phase(phase: Dictionary) -> void:
	_stage_open = true
	current_phase_key = str(phase.get("key", ""))
	phase_start_score = ScoreManager.get_score()
	if has_node("/root/AudioManager"):
		AudioManager.play_music(str(phase.get("music", "menu")))
	_change_scene(str(phase.get("scene", MAIN_MENU_SCENE)), _warm_for_minigame(current_phase_key))

func _change_scene(scene_path: String, warm_paths: Array = []) -> void:
	# V0.13: minigames e cutscenes passam pela tela de Loading (SceneLoader decide); menus trocam direto.
	# V0.14.3: warm_paths = recursos pesados que a LoadingScreen carrega antes (ver SceneLoader).
	var result: Error = SceneLoader.change_scene(get_tree(), scene_path, warm_paths)
	if result != OK:
		push_error("Falha ao carregar cena %s. Código: %s" % [scene_path, result])
		_restore_after_failed_change()

# ---------------------------------------------------------------- V0.14.3: saida de fase e pre-carregamento
## Cobre a tela, para a fase atual e espera 2 quadros (o navegador desenha a cortina antes do trabalho pesado).
func _begin_stage_exit() -> void:
	_raise_exit_shield()
	var scene: Node = get_tree().current_scene
	if scene != null:
		scene.process_mode = Node.PROCESS_MODE_DISABLED  # sem _process/_input/timers: nada roda enquanto sai
		if scene is CanvasItem:
			(scene as CanvasItem).visible = false  # e nao desenha mais (CanvasLayers ficam sob a cortina)
	await get_tree().process_frame
	await get_tree().process_frame

func _raise_exit_shield() -> void:
	if _exit_shield != null and is_instance_valid(_exit_shield):
		return
	_exit_shield = CanvasLayer.new()
	_exit_shield.name = "ExitShield"
	_exit_shield.layer = 128
	_exit_shield.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_exit_shield)
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.color = UiPalette.BG
	rect.mouse_filter = Control.MOUSE_FILTER_STOP  # toques extras durante a troca nao chegam em lugar nenhum
	_exit_shield.add_child(rect)

## Solta a cortina so depois de a cena nova ter desenhado (3 quadros).
func _release_exit_shield_later() -> void:
	for _i in range(3):
		await get_tree().process_frame
	_drop_exit_shield()

func _drop_exit_shield() -> void:
	if _exit_shield != null and is_instance_valid(_exit_shield):
		_exit_shield.queue_free()
	_exit_shield = null

## Se a troca de cena falhar, devolve o jogo ao estado anterior em vez de deixar tela preta/travada.
func _restore_after_failed_change() -> void:
	_stage_open = true
	var scene: Node = get_tree().current_scene
	if scene != null:
		scene.process_mode = Node.PROCESS_MODE_INHERIT
		if scene is CanvasItem:
			(scene as CanvasItem).visible = true
	_drop_exit_shield()

## Recursos pesados da transicao: cenario da novel, sprites (Jales + anfitriao) e a musica da fase.
func _warm_for_transition(phase_key: String) -> Array:
	var list: Array = []
	var bg_path: String = str(Paths.CUTSCENE_BG_BY_PHASE.get(phase_key, ""))
	if bg_path != "":
		list.append(bg_path)
	for character_id in _novel_character_ids(phase_key):
		var sprite_path: String = TutorialManager.resolve_sprite_path(str(character_id), "v1")
		if sprite_path != "":
			list.append(sprite_path)
	if has_node("/root/AudioManager"):
		var music_key: String = AudioManager.music_key_for_phase(phase_key)
		var music_path: String = str(AudioManager.MUSIC.get(music_key, ""))
		if music_path != "":
			list.append(music_path)
	return list

## Mesmos personagens que StageTransition._build_novel_frames() usa: Jales + anfitriao do minigame.
func _novel_character_ids(phase_key: String) -> Array:
	var ids: Array = ["jales"]
	var path: String = str(Paths.DIALOGUE_MINIGAMES.get(phase_key, ""))
	if path == "" or not FileAccess.file_exists(path):
		return ids
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary:
		var character: Dictionary = (parsed as Dictionary).get("character", {}) as Dictionary
		var host: String = str(character.get("name", "")).to_lower()
		if host != "" and not ids.has(host):
			ids.append(host)
	return ids

func _warm_for_minigame(phase_key: String) -> Array:
	return (PHASE_WARM.get(phase_key, []) as Array).duplicate()

## A cena final abre no escritorio a noite (final.json > backgrounds > farewell).
func _warm_for_final() -> Array:
	return [Paths.BG_CUT_09_ESCRITORIO]
