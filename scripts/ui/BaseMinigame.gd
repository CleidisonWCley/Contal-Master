extends Control

var phase_name: String = "Minigame"
var music_key: String = "menu"
var background_path: String = ""
var simulated_points: int = 100

@onready var background_rect: TextureRect = get_node_or_null("Background")
@onready var title_label: Label = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel")
@onready var description_label: Label = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/DescriptionLabel")
@onready var score_label: Label = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScoreLabel")
@onready var difficulty_label: Label = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/DifficultyLabel")
@onready var complete_button: Button = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonRow/CompleteButton")
@onready var back_button: Button = get_node_or_null("SafeArea/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonRow/BackButton")

func _ready() -> void:
	_apply_background()
	_update_texts()
	_update_score(ScoreManager.get_score())
	var score_callable := Callable(self, "_update_score")
	if not ScoreManager.score_changed.is_connected(score_callable):
		ScoreManager.score_changed.connect(score_callable)
	var complete_callable := Callable(self, "_on_complete_pressed")
	if complete_button != null and not complete_button.pressed.is_connected(complete_callable):
		complete_button.pressed.connect(complete_callable)
	var back_callable := Callable(self, "_on_back_pressed")
	if back_button != null and not back_button.pressed.is_connected(back_callable):
		back_button.pressed.connect(back_callable)
	if has_node("/root/AudioManager"):
		AudioManager.play_music(music_key)

func _apply_background() -> void:
	if background_rect == null or background_path == "":
		return
	var texture = load(background_path)
	if texture is Texture2D:
		background_rect.texture = texture

func _update_texts() -> void:
	if title_label != null:
		title_label.text = phase_name
	if description_label != null:
		description_label.text = "Placeholder funcional da V0.1.0. A mecânica fiel do Pygame será portada nas próximas versões."
	if difficulty_label != null:
		difficulty_label.text = "Dificuldade: %s" % DifficultyManager.get_label()
	if complete_button != null:
		complete_button.text = "Concluir fase teste (+%s)" % simulated_points
	if back_button != null:
		back_button.text = "Voltar"

func _update_score(new_score: int) -> void:
	if score_label != null:
		score_label.text = "Pontuação atual: %s" % new_score

func _on_complete_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("correto")
	GameManager.complete_current_stage(simulated_points)

func _on_back_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	if GameManager.is_free_mode():
		GameManager.open_free_menu()
	else:
		GameManager.go_to_main_menu()
