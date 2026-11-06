extends Node

signal achievements_changed()
signal achievement_unlocked(achievement_id: String)

const SAVE_PATH := Paths.SAVE_ACHIEVEMENTS
const PLATINUM_SCORE_HARD := 4350
const FREE_MODE_REQUIRED_KEYS := [
	"show_do_bilhao",
	"batalha_naval",
	"maleta_certa",
	"perseguicao",
	"forca_tecnica",
	"stop",
	"desvio_logico"
]
const DIFFICULTY_KEYS := ["facil", "normal", "dificil"]

# Rank (insignia) por quantidade de conquistas. Platina = todas. Usado pelo rank e pela meta do painel.
const RANK_SILVER_AT := 5
const RANK_GOLD_AT := 9

const ACHIEVEMENTS := [
	{
		"id": "primeiro_passo",
		"title": "Primeiro Passo",
		"description": "Complete seu primeiro minigame.",
		"icon": "medal",
		"icon_path": Paths.ACH_PRIMEIRO_PASSO
	},
	{
		"id": "inicio_jornada",
		"title": "O Início da Jornada",
		"description": "Inicie o modo campanha pela primeira vez.",
		"icon": "compass",
		"icon_path": Paths.ACH_INICIO_JORNADA
	},
	{
		"id": "jornada_completa",
		"title": "Jornada Completa",
		"description": "Complete o modo campanha pela primeira vez.",
		"icon": "sparkles",
		"icon_path": Paths.ACH_JORNADA_COMPLETA
	},
	{
		"id": "superacao_tecnica",
		"title": "Superação Técnica",
		"description": "Supere um recorde anterior.",
		"icon": "chart",
		"icon_path": Paths.ACH_SUPERACAO_TECNICA
	},
	{
		"id": "jornada_dificil",
		"title": "Uma Jornada Difícil",
		"description": "Complete o modo campanha na dificuldade Difícil.",
		"icon": "flame",
		"icon_path": Paths.ACH_JORNADA_DIFICIL
	},
	{
		"id": "mente_milionaria",
		"title": "Mente Milionária",
		"description": "Acerte todas as perguntas no Show do Bilhão.",
		"icon": "dollar",
		"icon_path": Paths.ACH_MENTE_MILIONARIA
	},
	{
		"id": "estrategia_naval",
		"title": "Estratégia Naval",
		"description": "Complete Batalha Naval com no máximo 3 erros marítimos.",
		"icon": "anchor",
		"icon_path": Paths.ACH_ESTRATEGIA_NAVAL
	},
	{
		"id": "decisao_risco",
		"title": "Decisão de Risco",
		"description": "Acerte todas as rodadas no minigame Maleta Certa.",
		"icon": "briefcase",
		"icon_path": Paths.ACH_DECISAO_RISCO
	},
	{
		"id": "piloto_imbativel",
		"title": "Piloto Imbatível",
		"description": "Complete Desvio Lógico no modo Difícil sem sofrer colisão.",
		"icon": "car",
		"icon_path": Paths.ACH_PILOTO_IMBATIVEL
	},
	{
		"id": "boas_praticas",
		"title": "Boas Práticas São Essenciais!",
		"description": "Passe pela primeira vez por uma Roleta de Risco.",
		"secret": true,
		"icon": "roulette",
		"icon_path": Paths.ACH_BOAS_PRATICAS
	},
	{
		"id": "perigo_iminente",
		"title": "Perigo Iminente",
		"description": "Conclua o modo Perseguição sem danos.",
		"icon": "danger",
		"icon_path": Paths.ACH_PERIGO_IMINENTE
	},
	{
		"id": "sistema_intacto",
		"title": "Sistema Intacto!",
		"description": "Complete Forca Tecnica com integridade 100% no sistema.",
		"icon": "puzzle",
		"icon_path": Paths.ACH_SISTEMA_INTACTO
	},
	{
		"id": "profissional_dedicado",
		"title": "Profissional Dedicado!",
		"description": "Complete todos os minigames do modo livre em todas as dificuldades.",
		"icon": "laptop",
		"icon_path": Paths.ACH_PROFISSIONAL_DEDICADO
	},
	{
		"id": "ultrapassando_sistema",
		"title": "Ultrapassando o Sistema!",
		"description": "Alcance 4.350 pontos no modo campanha Difícil.",
		"icon": "trophy",
		"icon_path": Paths.ACH_ULTRAPASSANDO_SISTEMA
	},
	{
		"id": "mestre_stop",
		"title": "Mestre do STOP!",
		"description": "Complete o minigame STOP acertando todas as rodadas.",
		"icon": "stop",
		"icon_path": Paths.ACH_MESTRE_STOP
	}
]

var _data: Dictionary = {}
var _notification_layer: CanvasLayer
var _notification_active: bool = false
var _notification_queue: Array[Dictionary] = []

func _ready() -> void:
	_load_data()
	_prepare_notification_layer()

func unlock(achievement_id: String) -> bool:
	var safe_id: String = achievement_id.strip_edges()
	if safe_id == "":
		return false
	if is_unlocked(safe_id):
		return false
	var achievement: Dictionary = get_achievement(safe_id)
	if achievement.is_empty():
		push_warning("Conquista desconhecida: %s" % safe_id)
		return false
	_ensure_data_shape()
	var unlocked: Dictionary = _data.get("unlocked", {})
	unlocked[safe_id] = {
		"unlocked": true,
		"unlocked_at": Time.get_datetime_string_from_system(false, true)
	}
	_data["unlocked"] = unlocked
	_save_data()
	achievements_changed.emit()
	achievement_unlocked.emit(safe_id)
	_queue_notification(achievement)
	return true

func is_unlocked(achievement_id: String) -> bool:
	_ensure_data_shape()
	var unlocked: Dictionary = _data.get("unlocked", {})
	return unlocked.has(achievement_id)

func get_unlocked_count() -> int:
	_ensure_data_shape()
	var unlocked: Dictionary = _data.get("unlocked", {})
	var count: int = 0
	for achievement in ACHIEVEMENTS:
		if not achievement is Dictionary:
			continue
		var achievement_data: Dictionary = achievement as Dictionary
		if unlocked.has(str(achievement_data.get("id", ""))):
			count += 1
	return count

func get_total_count() -> int:
	return ACHIEVEMENTS.size()


func get_insignia_name() -> String:
	return get_insignia_name_for_count(get_unlocked_count())

## Insignia para uma contagem qualquer de conquistas (usada na animacao de progresso).
func get_insignia_name_for_count(count: int) -> String:
	var total: int = get_total_count()
	if count <= 0:
		return "Sem insígnia"
	if count >= total:
		return "Platina"
	if count >= RANK_GOLD_AT:
		return "Ouro"
	if count >= RANK_SILVER_AT:
		return "Prata"
	return "Bronze"

func is_platinum_complete() -> bool:
	return get_unlocked_count() >= get_total_count()

func get_rank() -> String:
	var count: int = get_unlocked_count()
	if count <= 0:
		return "Sem rank"
	if count >= get_total_count():
		return "Platina"
	if count >= RANK_GOLD_AT:
		return "Ouro"
	if count >= RANK_SILVER_AT:
		return "Prata"
	return "Bronze"

## Nome do icone (UiIcons) da insignia atual. Cor: use get_rank_color().
func get_rank_icon() -> String:
	match get_rank():
		"Platina":
			return "gem"
		"Ouro", "Prata", "Bronze":
			return "medal"
		_:
			return "lock"

## Pontos de rank mostrados na barra do painel: [{"name": "Prata", "count": 5}, ...].
func get_rank_thresholds() -> Array:
	return [
		{"name": "Prata", "count": RANK_SILVER_AT},
		{"name": "Ouro", "count": RANK_GOLD_AT},
		{"name": "Platina", "count": get_total_count()}
	]

## Proximo rank para uma contagem de conquistas: {"name", "count", "remaining"}. Vazio se ja e Platina.
func get_next_rank(count: int = -1) -> Dictionary:
	var current: int = get_unlocked_count() if count < 0 else count
	var steps: Array = [{"name": "Bronze", "count": 1}]
	steps.append_array(get_rank_thresholds())
	for step in steps:
		var step_data: Dictionary = step as Dictionary
		var needed: int = int(step_data.get("count", 0))
		if current < needed:
			return {"name": str(step_data.get("name", "")), "count": needed, "remaining": needed - current}
	return {}

## Conquista secreta: o cartao bloqueado mostra "???" em vez do titulo.
func is_secret(achievement_id: String) -> bool:
	return bool(get_achievement(achievement_id).get("secret", false))

## Data/hora de desbloqueio salva no unlock() ("2026-11-05 14:30:00"). Vazio se nao desbloqueada.
func get_unlocked_at(achievement_id: String) -> String:
	_ensure_data_shape()
	var unlocked: Dictionary = _data.get("unlocked", {})
	var entry: Variant = unlocked.get(achievement_id, null)
	if entry is Dictionary:
		return str((entry as Dictionary).get("unlocked_at", ""))
	return ""

## Andamento de conquistas que tem uma medida natural (calculado dos recordes; nao precisa de contadores novos).
## Retorna {"current": int, "target": int, "text": String} ou {} quando a conquista e de evento unico.
func get_progress(achievement_id: String) -> Dictionary:
	if not has_node("/root/ScoreManager"):
		return {}
	match achievement_id:
		"profissional_dedicado":
			var done: int = 0
			var total: int = FREE_MODE_REQUIRED_KEYS.size() * DIFFICULTY_KEYS.size()
			for minigame_key in FREE_MODE_REQUIRED_KEYS:
				for difficulty_key in DIFFICULTY_KEYS:
					if ScoreManager.has_free_mode_record(str(minigame_key), str(difficulty_key)):
						done += 1
			return {"current": done, "target": total, "text": "%d/%d" % [done, total]}
		"ultrapassando_sistema":
			var best: int = mini(ScoreManager.get_campaign_total_score("dificil"), PLATINUM_SCORE_HARD)
			var best_text: String = UiKit.format_points(best).replace(" pts", "")
			return {"current": best, "target": PLATINUM_SCORE_HARD, "text": "%s / %s" % [best_text, UiKit.format_points(PLATINUM_SCORE_HARD)]}
	return {}

# ---- "Vistas" (v4.2): o que o jogador ja viu na tela de Conquistas -------------------------------
## Quantas conquistas desbloqueadas ja foram vistas na tela de Conquistas.
func get_seen_count() -> int:
	_ensure_data_shape()
	var seen: Array = _data.get("seen", [])
	var unlocked: Dictionary = _data.get("unlocked", {})
	var count: int = 0
	for id in seen:
		if unlocked.has(str(id)):
			count += 1
	return count

## Desbloqueada desde a ultima visita a tela de Conquistas (selo "NOVA").
func is_new(achievement_id: String) -> bool:
	_ensure_data_shape()
	var unlocked: Dictionary = _data.get("unlocked", {})
	var seen: Array = _data.get("seen", [])
	return unlocked.has(achievement_id) and not seen.has(achievement_id)

## Chamado ao sair da tela de Conquistas: tudo o que esta desbloqueado passa a contar como visto.
func mark_all_seen() -> void:
	_ensure_data_shape()
	var unlocked: Dictionary = _data.get("unlocked", {})
	var seen: Array = _data.get("seen", [])
	var changed: bool = false
	for id in unlocked.keys():
		if not seen.has(str(id)):
			seen.append(str(id))
			changed = true
	if changed:
		_data["seen"] = seen
		_save_data()

func get_all_achievements() -> Array:
	return ACHIEVEMENTS.duplicate(true)

func get_achievement(achievement_id: String) -> Dictionary:
	for achievement in ACHIEVEMENTS:
		if not achievement is Dictionary:
			continue
		var achievement_data: Dictionary = achievement as Dictionary
		if str(achievement_data.get("id", "")) == achievement_id:
			return achievement_data.duplicate(true)
	return {}

func record_campaign_started() -> void:
	unlock("inicio_jornada")

func record_campaign_completed(difficulty: String, total_score: int) -> void:
	unlock("jornada_completa")
	if difficulty == "dificil":
		unlock("jornada_dificil")
		if total_score >= PLATINUM_SCORE_HARD:
			unlock("ultrapassando_sistema")

func record_minigame_completed(_minigame_key: String, _difficulty: String) -> void:
	unlock("primeiro_passo")

func record_free_mode_completion(minigame_key: String, difficulty: String, save_result: Dictionary) -> void:
	record_minigame_completed(minigame_key, difficulty)
	if bool(save_result.get("saved", false)) and int(save_result.get("previous_score", 0)) > 0:
		var current_score: int = int(save_result.get("score", 0))
		var previous_score: int = int(save_result.get("previous_score", 0))
		if current_score > previous_score:
			unlock("superacao_tecnica")
	_check_professional_dedication()

func record_campaign_score_result(result: Dictionary) -> void:
	if bool(result.get("saved", false)) and int(result.get("previous_score", 0)) > 0:
		var total_score: int = int(result.get("total_score", 0))
		var previous_score: int = int(result.get("previous_score", 0))
		if total_score > previous_score:
			unlock("superacao_tecnica")

func _check_professional_dedication() -> void:
	if not has_node("/root/ScoreManager"):
		return
	for minigame_key in FREE_MODE_REQUIRED_KEYS:
		for difficulty_key in DIFFICULTY_KEYS:
			if not ScoreManager.has_free_mode_record(minigame_key, difficulty_key):
				return
	unlock("profissional_dedicado")

func _load_data() -> void:
	Paths.migrate_legacy_saves()
	_data = _default_data()
	if FileAccess.file_exists(SAVE_PATH):
		var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file != null:
			var parsed: Variant = JSON.parse_string(file.get_as_text())
			if parsed is Dictionary:
				_data = parsed as Dictionary
				# v4.2: saves antigos nao tem "seen". O que ja estava desbloqueado conta como visto,
				# assim ninguem recebe selo "NOVA" nem animacao de rank por conquistas antigas.
				if not _data.has("seen"):
					var old_seen: Array = []
					var old_unlocked: Variant = _data.get("unlocked", {})
					if old_unlocked is Dictionary:
						old_seen = (old_unlocked as Dictionary).keys()
					_data["seen"] = old_seen
	_ensure_data_shape()
	_save_data()

func _save_data() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Não foi possível salvar conquistas em %s" % SAVE_PATH)
		return
	file.store_string(JSON.stringify(_data, "\t"))

func _ensure_data_shape() -> void:
	if not (_data is Dictionary) or _data.is_empty():
		_data = _default_data()
	if not _data.has("unlocked") or not (_data["unlocked"] is Dictionary):
		_data["unlocked"] = {}
	if not _data.has("seen") or not (_data["seen"] is Array):
		_data["seen"] = []

func _default_data() -> Dictionary:
	return {
		"unlocked": {},
		"seen": []
	}

func _prepare_notification_layer() -> void:
	if _notification_layer != null:
		return
	_notification_layer = CanvasLayer.new()
	_notification_layer.name = "AchievementNotificationLayer"
	_notification_layer.layer = 900
	add_child(_notification_layer)

func _queue_notification(achievement: Dictionary) -> void:
	_notification_queue.append(achievement.duplicate(true))
	if not _notification_active:
		_show_next_notification()

func _show_next_notification() -> void:
	if _notification_queue.is_empty():
		_notification_active = false
		return
	_notification_active = true
	var achievement: Dictionary = _notification_queue.pop_front()
	_show_notification_card(achievement)

func _show_notification_card(achievement: Dictionary) -> void:
	_prepare_notification_layer()
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("conquista")
	var panel: PanelContainer = PanelContainer.new()
	panel.name = "AchievementToast"
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.anchor_top = 0.0
	panel.anchor_bottom = 0.0
	panel.offset_left = -430.0
	panel.offset_right = -28.0
	panel.offset_top = 28.0
	panel.offset_bottom = 140.0
	panel.modulate.a = 0.0
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.11, 0.07, 0.22, 0.96), Color(1.0, 0.80, 0.18, 1.0), 18, 3))
	_notification_layer.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	margin.add_child(row)

	var icon_texture: Texture2D = null
	var icon_path: String = str(achievement.get("icon_path", ""))
	if icon_path != "":
		var loaded_icon: Resource = load(icon_path)
		if loaded_icon is Texture2D:
			icon_texture = loaded_icon as Texture2D
	if icon_texture != null:
		var icon_rect: TextureRect = TextureRect.new()
		icon_rect.custom_minimum_size = Vector2(54, 54)
		icon_rect.expand_mode = 1
		icon_rect.stretch_mode = 5
		icon_rect.texture = icon_texture
		row.add_child(icon_rect)
	else:
		row.add_child(UiIcons.make_rect(str(achievement.get("icon", "medal")), 46.0, UiPalette.ACCENT_ACHIEVEMENTS))

	var text_box: VBoxContainer = VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 2)
	row.add_child(text_box)

	var header: Label = Label.new()
	header.text = "Conquista desbloqueada!"
	header.add_theme_font_size_override("font_size", 16)
	header.add_theme_color_override("font_color", Color(1.0, 0.86, 0.24, 1.0))
	text_box.add_child(header)

	var title: Label = Label.new()
	title.text = str(achievement.get("title", "Conquista"))
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 21)
	title.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	text_box.add_child(title)

	var description: Label = Label.new()
	description.text = str(achievement.get("description", ""))
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_font_size_override("font_size", 13)
	description.add_theme_color_override("font_color", Color(0.88, 0.91, 1.0, 0.92))
	text_box.add_child(description)

	var tween: Tween = create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.22)
	tween.tween_interval(2.65)
	tween.tween_property(panel, "modulate:a", 0.0, 0.32)
	await tween.finished
	if is_instance_valid(panel):
		panel.queue_free()
	_show_next_notification()

func _make_panel_style(bg_color: Color, border_color: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.set_corner_radius_all(radius)
	style.content_margin_left = 0
	style.content_margin_right = 0
	style.content_margin_top = 0
	style.content_margin_bottom = 0
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.42)
	style.shadow_size = 12
	return style
