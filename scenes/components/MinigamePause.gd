extends CanvasLayer
class_name MinigamePause
## Botao de pause + menu de pausa PADRONIZADOS de todos os minigames (campanha e modo livre).
## Substitui o antigo botao "Voltar" de cada minigame. Visual e efeitos vieram do Desvio Logico.
##
## Uso (no _ready do minigame, depois de montar a interface):
##     pause_menu = MinigamePause.attach(self)
## Esc abre/fecha o pause (pause_menu.toggle()).
##
## Opcoes (dicionario):
##   "tree_pause": bool      -> pausa a SceneTree inteira (padrao true). O Desvio Logico usa false
##                              porque congela a simulacao por conta propria (gameplay_paused).
##   "can_pause": Callable   -> retorna bool; se false o botao nao abre o pause.
##   "on_finish": Callable   -> substitui "Finalizar minigame".
##   "on_menu": Callable     -> substitui "Voltar ao menu principal".

signal paused
signal resumed

var tree_pause: bool = true
var can_pause: Callable = Callable()
var on_finish: Callable = Callable()
var on_menu: Callable = Callable()

var pause_button: Button
var overlay: Control
var continue_button: Button
var finish_button: Button
var menu_button: Button
var is_open: bool = false

static func attach(host: Node, options: Dictionary = {}) -> MinigamePause:
	var instance := MinigamePause.new()
	instance.name = "MinigamePause"
	instance.tree_pause = bool(options.get("tree_pause", true))
	instance.can_pause = options.get("can_pause", Callable())
	instance.on_finish = options.get("on_finish", Callable())
	instance.on_menu = options.get("on_menu", Callable())
	host.add_child(instance)
	return instance

func _ready() -> void:
	layer = 90
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_button()
	_build_overlay()

func _exit_tree() -> void:
	# Nunca deixar a arvore pausada ao sair da cena.
	if is_open and tree_pause and get_tree() != null:
		get_tree().paused = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		toggle()

# ---------------------------------------------------------------- API
func toggle() -> void:
	if is_open:
		close()
	else:
		open()

func open() -> void:
	if is_open:
		return
	if can_pause.is_valid() and not bool(can_pause.call()):
		return
	_click()
	is_open = true
	if tree_pause:
		get_tree().paused = true
	overlay.visible = true
	pause_button.visible = false
	continue_button.grab_focus()
	paused.emit()

func close() -> void:
	if not is_open:
		return
	_click()
	is_open = false
	if tree_pause:
		get_tree().paused = false
	overlay.visible = false
	pause_button.visible = true
	resumed.emit()

func set_button_visible(value: bool) -> void:
	if pause_button != null and not is_open:
		pause_button.visible = value

# ---------------------------------------------------------------- construcao
func _build_button() -> void:
	pause_button = Button.new()
	pause_button.name = "PauseButton"
	pause_button.text = "Pausar"
	pause_button.icon = UiIcons.texture("pause")
	pause_button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	pause_button.focus_mode = Control.FOCUS_ALL
	pause_button.tooltip_text = "Pausar (Esc)"
	pause_button.anchor_left = 1.0
	pause_button.anchor_right = 1.0
	pause_button.offset_left = -144.0
	pause_button.offset_right = -18.0
	pause_button.offset_top = 14.0
	pause_button.offset_bottom = 60.0
	pause_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	pause_button.add_theme_font_size_override("font_size", 18)
	pause_button.add_theme_constant_override("icon_max_width", 20)
	pause_button.add_theme_constant_override("h_separation", 8)
	# Mesmos efeitos do pause original do Desvio Logico: translucido, realca no hover, destaca ao pressionar.
	pause_button.add_theme_stylebox_override("normal", UiKit.panel_style(UiPalette.with_alpha(UiPalette.BG, 0.74), UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.85), 14, 2, 4))
	pause_button.add_theme_stylebox_override("hover", UiKit.panel_style(UiPalette.with_alpha(UiPalette.CARD, 0.92), UiPalette.TEXT_ON_DARK, 14, 2, 4))
	pause_button.add_theme_stylebox_override("pressed", UiKit.panel_style(UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.97), UiPalette.TEXT_ON_DARK, 14, 2, 4))
	pause_button.add_theme_stylebox_override("focus", ButtonStyles.make_focus_ring(14))
	for state in ["font_color", "font_hover_color", "font_focus_color", "icon_normal_color", "icon_hover_color", "icon_focus_color"]:
		pause_button.add_theme_color_override(state, UiPalette.TEXT_ON_DARK)
	for state in ["font_pressed_color", "icon_pressed_color"]:
		pause_button.add_theme_color_override(state, UiPalette.TEXT_ON_BRIGHT)
	pause_button.pressed.connect(open)
	add_child(pause_button)

func _build_overlay() -> void:
	overlay = Control.new()
	overlay.name = "PauseOverlay"
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.visible = false
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var shade := ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = UiPalette.with_alpha(UiPalette.BG, 0.62)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(460, 0)
	panel.add_theme_stylebox_override("panel", UiKit.card_style(24))
	center.add_child(panel)
	var pad := UiKit.margin(30, 30, 26, 22)
	panel.add_child(pad)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	pad.add_child(box)

	var title_row := HBoxContainer.new()
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	title_row.add_theme_constant_override("separation", 12)
	title_row.add_child(UiIcons.make_rect("pause", 30, UiPalette.HIGHLIGHT))
	title_row.add_child(UiKit.label("JOGO PAUSADO", 30, UiPalette.TEXT_ON_DARK))
	box.add_child(title_row)

	continue_button = _make_menu_button("Continuar jogo", "play", "ui_primary")
	continue_button.pressed.connect(close)
	box.add_child(continue_button)

	finish_button = _make_menu_button("Finalizar minigame", "flag", "ui_ghost")
	finish_button.pressed.connect(_on_finish_pressed)
	box.add_child(finish_button)

	menu_button = _make_menu_button("Voltar ao menu principal", "home", "ui_ghost")
	menu_button.pressed.connect(_on_menu_pressed)
	box.add_child(menu_button)

	box.add_child(UiKit.label("Esc para continuar", 16, UiPalette.TEXT_MUTED, HORIZONTAL_ALIGNMENT_CENTER))

func _make_menu_button(text_value: String, icon_name: String, variant: String) -> Button:
	var button := Button.new()
	button.text = text_value
	button.icon = UiIcons.texture(icon_name)
	button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.expand_icon = false
	ButtonStyles.apply(button, variant, Vector2(380, 54), 20)
	return button

# ---------------------------------------------------------------- acoes
func _release_pause() -> void:
	is_open = false
	if tree_pause:
		get_tree().paused = false
	overlay.visible = false

func _on_finish_pressed() -> void:
	_click()
	_release_pause()
	if on_finish.is_valid():
		on_finish.call()
	else:
		# Pontos ja ganhos continuam somados; no modo livre salva o recorde.
		GameManager.complete_current_stage(0)

func _on_menu_pressed() -> void:
	_click()
	_release_pause()
	if on_menu.is_valid():
		on_menu.call()
	else:
		GameManager.go_to_main_menu()

func _click() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
