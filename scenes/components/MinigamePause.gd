extends CanvasLayer
class_name MinigamePause
## Botao de pause + menu de pausa PADRONIZADOS de todos os minigames (campanha e modo livre).
## Substitui o antigo botao "Voltar" de cada minigame. Visual e efeitos vieram do Desvio Logico.
## V0.14: o antigo "Finalizar minigame" (atalho de desenvolvedor que pulava para os creditos) FOI REMOVIDO.
## No lugar dele ha "Configuracoes": volume (musica/efeitos), animacoes, tutoriais e modo da novel (Auto/Clique).
## A DIFICULDADE nao pode ser mudada durante a partida (so e exibida, bloqueada).
##
## Uso (no _ready do minigame, depois de montar a interface):
##     pause_menu = MinigamePause.attach(self)
## Esc abre/fecha o pause (pause_menu.toggle()).
##
## Opcoes (dicionario):
##   "tree_pause": bool      -> pausa a SceneTree inteira (padrao true). O Desvio Logico usa false
##                              porque congela a simulacao por conta propria (gameplay_paused).
##   "can_pause": Callable   -> retorna bool; se false o botao nao abre o pause.
##   "on_menu": Callable     -> substitui "Voltar ao menu principal".

signal paused
signal resumed

var tree_pause: bool = true
var can_pause: Callable = Callable()
var on_menu: Callable = Callable()

var pause_button: Button
var overlay: Control
var continue_button: Button
var settings_button: Button
var menu_button: Button
var is_open: bool = false

var host_node: Node
var _main_box: VBoxContainer
var _settings_scroll: ScrollContainer
var _settings_box: VBoxContainer
var _settings_left: VBoxContainer    # V0.16.11.1d: configuracoes em 2 colunas (menos rolagem, botoes mais largos)
var _settings_right: VBoxContainer
var _in_settings: bool = false
var _music_slider: HSlider
var _sfx_slider: HSlider
var _music_value: Label
var _sfx_value: Label
var _animations_button: Button
var _tutorials_button: Button
var _novel_auto_button: Button
var _novel_click_button: Button
var _settings_back_button: Button
var _font_selector: FontSizeSelector   # V0.16.3: acessibilidade - tamanho da fonte
var _grabber: Texture2D
var _pause_alpha_tween: Tween   # V0.16.4

## V0.16.4: mesmo tratamento do botao "Tela cheia": apagado no canto (ainda visivel) e acende quando o jogador vai pausar.
const PAUSE_IDLE_ALPHA: float = 0.42
const PAUSE_ACTIVE_ALPHA: float = 1.0

static func attach(host: Node, options: Dictionary = {}) -> MinigamePause:
	var instance := MinigamePause.new()
	instance.name = "MinigamePause"
	instance.tree_pause = bool(options.get("tree_pause", true))
	instance.can_pause = options.get("can_pause", Callable())
	instance.on_menu = options.get("on_menu", Callable())
	instance.host_node = host
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
		if is_open and _in_settings:
			_show_settings(false)
			return
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
	_show_settings(false)
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
	pause_button.release_focus()
	pause_button.self_modulate.a = PAUSE_ACTIVE_ALPHA if pause_button.is_hovered() else PAUSE_IDLE_ALPHA
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
	pause_button.offset_left = -176.0
	pause_button.offset_right = -18.0
	pause_button.offset_top = 14.0
	pause_button.offset_bottom = 68.0
	pause_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	FontScale.set_size(pause_button, 18)
	FontScale.set_icon_ratio(pause_button, 20.0 / 18.0)
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
	# Acende com mouse, toque (button_down) ou foco de teclado; volta a ficar apagado ao sair.
	pause_button.self_modulate = Color(1.0, 1.0, 1.0, PAUSE_IDLE_ALPHA)
	pause_button.mouse_entered.connect(_set_pause_alpha.bind(PAUSE_ACTIVE_ALPHA))
	pause_button.mouse_exited.connect(_on_pause_pointer_left)
	pause_button.button_down.connect(_set_pause_alpha.bind(PAUSE_ACTIVE_ALPHA))
	pause_button.focus_entered.connect(_set_pause_alpha.bind(PAUSE_ACTIVE_ALPHA))
	pause_button.focus_exited.connect(_set_pause_alpha.bind(PAUSE_IDLE_ALPHA))
	add_child(pause_button)

func _on_pause_pointer_left() -> void:
	# Com foco de teclado o botao continua aceso; sem foco, apaga.
	if pause_button != null and pause_button.has_focus():
		return
	_set_pause_alpha(PAUSE_IDLE_ALPHA)

func _set_pause_alpha(alpha: float) -> void:
	if pause_button == null:
		return
	if _pause_alpha_tween != null and _pause_alpha_tween.is_valid():
		_pause_alpha_tween.kill()
	# process_always: o pause da arvore nao pode congelar a animacao de brilho.
	_pause_alpha_tween = pause_button.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_pause_alpha_tween.tween_property(pause_button, "self_modulate:a", alpha, 0.12)

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
	panel.custom_minimum_size = Vector2(1080, 0)   # V0.16.11.1e: o container cresce para os lados (menos rolagem vertical)
	panel.add_theme_stylebox_override("panel", UiKit.card_style(24))
	center.add_child(panel)
	var pad := UiKit.margin(38, 38, 30, 26)
	panel.add_child(pad)
	var stack := VBoxContainer.new()
	pad.add_child(stack)

	# ---- Visao principal: Continuar / Configuracoes / Menu principal
	_main_box = VBoxContainer.new()
	_main_box.name = "MainView"
	_main_box.add_theme_constant_override("separation", 18)
	stack.add_child(_main_box)

	var title_row := HBoxContainer.new()
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	title_row.add_theme_constant_override("separation", 12)
	title_row.add_child(UiIcons.make_rect("pause", 30, UiPalette.HIGHLIGHT))
	title_row.add_child(UiKit.label("JOGO PAUSADO", 30, UiPalette.TEXT_ON_DARK))
	_main_box.add_child(title_row)

	continue_button = _make_menu_button("Continuar jogo", "play", "ui_primary")
	continue_button.pressed.connect(close)
	_main_box.add_child(continue_button)

	settings_button = _make_menu_button("Configurações", "settings", "ui_ghost")
	settings_button.name = "SettingsButton"
	settings_button.pressed.connect(_on_settings_pressed)
	_main_box.add_child(settings_button)

	menu_button = _make_menu_button("Voltar ao menu principal", "home", "ui_ghost")
	menu_button.pressed.connect(_on_menu_pressed)
	_main_box.add_child(menu_button)

	_main_box.add_child(UiKit.label("Esc para continuar", 16, UiPalette.TEXT_MUTED, HORIZONTAL_ALIGNMENT_CENTER))

	_build_settings_view(stack)

## Visao "Configuracoes" dentro do proprio pause (sem trocar de cena, funciona com a arvore pausada).
## Opcoes: volume, animacoes, tutoriais, novel Auto/Clique. A dificuldade NAO e editavel aqui.
func _build_settings_view(stack: VBoxContainer) -> void:
	_grabber = UiKit.circle_texture(28, UiPalette.TEXT_ON_DARK)
	_settings_scroll = ScrollContainer.new()
	_settings_scroll.name = "SettingsView"
	_settings_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_settings_scroll.visible = false
	stack.add_child(_settings_scroll)

	_settings_box = VBoxContainer.new()
	_settings_box.add_theme_constant_override("separation", 14)
	_settings_box.custom_minimum_size = Vector2(1000, 0)
	_settings_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_settings_scroll.add_child(_settings_box)

	var title_row := HBoxContainer.new()
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	title_row.add_theme_constant_override("separation", 12)
	title_row.add_child(UiIcons.make_rect("settings", 30, UiPalette.HIGHLIGHT))
	title_row.add_child(UiKit.label("CONFIGURAÇÕES", 28, UiPalette.TEXT_ON_DARK))
	_settings_box.add_child(title_row)
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 56)
	_settings_box.add_child(cols)
	_settings_left = VBoxContainer.new()
	_settings_left.add_theme_constant_override("separation", 14)
	_settings_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cols.add_child(_settings_left)
	_settings_right = VBoxContainer.new()
	_settings_right.add_theme_constant_override("separation", 14)
	_settings_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cols.add_child(_settings_right)

	# ---- Volume
	_settings_left.add_child(_section_header("ÁUDIO"))
	var music_row: Array = _make_slider_row("music", "Música")
	_music_slider = music_row[0] as HSlider
	_music_value = music_row[1] as Label
	var sfx_row: Array = _make_slider_row("speaker", "Efeitos")
	_sfx_slider = sfx_row[0] as HSlider
	_sfx_value = sfx_row[1] as Label
	_music_slider.value_changed.connect(_on_music_changed)
	_sfx_slider.value_changed.connect(_on_sfx_changed)

	# ---- Jogo
	_settings_left.add_child(_section_header("JOGO"))
	_animations_button = Button.new()
	_animations_button.name = "AnimationsToggle"
	_animations_button.pressed.connect(_on_animations_pressed)
	_settings_left.add_child(_animations_button)
	_tutorials_button = Button.new()
	_tutorials_button.name = "TutorialsToggle"
	_tutorials_button.pressed.connect(_on_tutorials_pressed)
	_settings_left.add_child(_tutorials_button)

	_settings_right.add_child(_section_header("NOVEL"))
	var novel_row := HBoxContainer.new()
	novel_row.add_theme_constant_override("separation", 10)
	_settings_right.add_child(novel_row)
	var novel_label_box := HBoxContainer.new()
	novel_label_box.custom_minimum_size = Vector2(120, 0)
	novel_label_box.add_theme_constant_override("separation", 10)
	var novel_icon := UiIcons.make_rect("compass", 24, UiPalette.TEXT_ON_DARK)
	novel_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	novel_label_box.add_child(novel_icon)
	var novel_label: Label = UiKit.label("Novel", 19, UiPalette.TEXT_ON_DARK)
	novel_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	novel_label_box.add_child(novel_label)
	novel_row.add_child(novel_label_box)
	_novel_auto_button = Button.new()
	_novel_auto_button.name = "NovelAutoButton"
	_novel_auto_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_novel_auto_button.tooltip_text = "A conversa passa sozinha"
	_novel_auto_button.pressed.connect(_on_novel_mode_pressed.bind(true))
	novel_row.add_child(_novel_auto_button)
	_novel_click_button = Button.new()
	_novel_click_button.name = "NovelClickButton"
	_novel_click_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_novel_click_button.tooltip_text = "Você clica para avançar a conversa"
	_novel_click_button.pressed.connect(_on_novel_mode_pressed.bind(false))
	novel_row.add_child(_novel_click_button)

	# ---- Acessibilidade (V0.16.3): tamanho da fonte, na hora, tambem durante a partida.
	_settings_right.add_child(_section_header("ACESSIBILIDADE"))
	var font_title := HBoxContainer.new()
	font_title.name = "FontTitleRow"
	font_title.add_theme_constant_override("separation", 10)
	var font_icon := UiIcons.make_rect("font", 24, UiPalette.TEXT_ON_DARK)
	font_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	font_title.add_child(font_icon)
	var font_label: Label = UiKit.label("Fonte", 19, UiPalette.TEXT_ON_DARK)
	font_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	font_title.add_child(font_label)
	_settings_right.add_child(font_title)
	_font_selector = FontSizeSelector.create(2, 58.0, 18)
	_settings_right.add_child(_font_selector)
	FontScale.scale_changed.connect(_on_font_scale_changed)

	# ---- Dificuldade: so informativa (bloqueada durante a partida)
	var difficulty_label := UiKit.label("Dificuldade: %s (não pode ser alterada durante a partida)" % DifficultyManager.get_label(), 15, UiPalette.TEXT_MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	difficulty_label.name = "DifficultyLockedLabel"
	difficulty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	difficulty_label.custom_minimum_size = Vector2(0, 0)
	_settings_right.add_child(difficulty_label)

	_settings_back_button = _make_menu_button("Voltar", "back", "ui_ghost")
	_settings_back_button.name = "SettingsBackButton"
	_settings_back_button.pressed.connect(_on_settings_back_pressed)
	# V0.16.3: "Voltar" fica FORA da rolagem (sempre visivel, mesmo com fonte Grande/Extra grande).
	_settings_back_button.visible = false
	stack.add_child(_settings_back_button)

func _section_header(text_value: String) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	box.add_child(UiKit.label(text_value, 15, UiPalette.HIGHLIGHT))
	var line := Panel.new()
	line.custom_minimum_size = Vector2(0, 2)
	var style := StyleBoxFlat.new()
	style.bg_color = UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.38)
	line.add_theme_stylebox_override("panel", style)
	box.add_child(line)
	return box

## Linha [icone] Rotulo ----slider---- 50%. Retorna [slider, rotulo_do_valor].
func _make_slider_row(icon_name: String, text_value: String) -> Array:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	_settings_left.add_child(row)

	var label_box := HBoxContainer.new()
	label_box.custom_minimum_size = Vector2(150, 0)
	label_box.add_theme_constant_override("separation", 10)
	var icon := UiIcons.make_rect(icon_name, 24, UiPalette.TEXT_ON_DARK)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	label_box.add_child(icon)
	var label: Label = UiKit.label(text_value, 19, UiPalette.TEXT_ON_DARK)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label_box.add_child(label)
	row.add_child(label_box)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.custom_minimum_size = Vector2(180, 36)
	var rail := StyleBoxFlat.new()
	rail.bg_color = UiPalette.with_alpha(UiPalette.BG, 0.85)
	rail.border_color = UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.30)
	rail.set_border_width_all(1)
	rail.set_corner_radius_all(6)
	rail.content_margin_top = 4
	rail.content_margin_bottom = 4
	var fill := StyleBoxFlat.new()
	fill.bg_color = UiPalette.HIGHLIGHT
	fill.set_corner_radius_all(6)
	fill.content_margin_top = 4
	fill.content_margin_bottom = 4
	slider.add_theme_stylebox_override("slider", rail)
	slider.add_theme_stylebox_override("grabber_area", fill)
	slider.add_theme_stylebox_override("grabber_area_highlight", fill)
	slider.add_theme_icon_override("grabber", _grabber)
	slider.add_theme_icon_override("grabber_highlight", _grabber)
	slider.add_theme_icon_override("grabber_disabled", _grabber)
	row.add_child(slider)

	var value_label: Label = UiKit.label("0%", 17, UiPalette.TEXT_ON_DARK, HORIZONTAL_ALIGNMENT_RIGHT)
	value_label.custom_minimum_size = Vector2(54, 0)
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(value_label)
	return [slider, value_label]

func _make_menu_button(text_value: String, icon_name: String, variant: String) -> Button:
	var button := Button.new()
	button.text = text_value
	button.icon = UiIcons.texture(icon_name)
	button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.expand_icon = false
	ButtonStyles.apply(button, variant, Vector2(0, 64), 21)
	return button

# ---------------------------------------------------------------- acoes
func _release_pause() -> void:
	is_open = false
	if tree_pause:
		get_tree().paused = false
	overlay.visible = false

# ---- Configuracoes (V0.14)
func _on_settings_pressed() -> void:
	_click()
	_show_settings(true)

func _on_settings_back_pressed() -> void:
	_click()
	_show_settings(false)

func _show_settings(value: bool) -> void:
	_in_settings = value
	if _main_box == null or _settings_scroll == null:
		return
	_main_box.visible = not value
	_settings_scroll.visible = value
	_settings_back_button.visible = value
	if value:
		_refresh_settings_view()
		_fit_settings_scroll()
		_settings_back_button.grab_focus()
	elif is_open:
		settings_button.grab_focus()

## Altura da rolagem das configuracoes: cabe na tela; se o conteudo for maior (fonte Grande/Extra grande), rola.
func _fit_settings_scroll() -> void:
	if _settings_scroll == null or _settings_box == null:
		return
	var view_height: float = get_viewport().get_visible_rect().size.y
	_settings_scroll.custom_minimum_size = Vector2(0, minf(_settings_box.get_combined_minimum_size().y, maxf(200.0, view_height - 120.0 - _settings_back_button.get_combined_minimum_size().y)))

## V0.16.3: fonte trocada enquanto o pause esta aberto - refaz os botoes na nova escala e reajusta a altura.
func _on_font_scale_changed(_level: String) -> void:
	if _settings_scroll == null or not _settings_scroll.visible:
		return
	_refresh_settings_view()
	await get_tree().process_frame
	_fit_settings_scroll()

func _refresh_settings_view() -> void:
	if _font_selector != null:
		_font_selector.refresh()
	_music_slider.set_value_no_signal(SettingsManager.get_music_volume())
	_sfx_slider.set_value_no_signal(SettingsManager.get_sfx_volume())
	_update_volume_labels()
	_set_toggle(_animations_button, "sparkles", "Animações visuais", SettingsManager.animations_enabled())
	# Campanha de quem joga pela 1a vez: tutoriais obrigatorios (mesma regra do botao Pular).
	var locked: bool = not TutorialManager.can_skip(host_node)
	_set_toggle(_tutorials_button, "compass", "Tutoriais", SettingsManager.tutorials_enabled() or locked)
	_tutorials_button.disabled = locked
	_tutorials_button.tooltip_text = "Obrigatórios até registrar a primeira campanha" if locked else ""
	var auto: bool = SettingsManager.novel_auto()
	_set_choice(_novel_auto_button, "Auto", auto)
	_set_choice(_novel_click_button, "Clique", not auto)

func _update_volume_labels() -> void:
	_music_value.text = "%d%%" % int(round(_music_slider.value * 100.0))
	_sfx_value.text = "%d%%" % int(round(_sfx_slider.value * 100.0))

func _set_toggle(button: Button, icon_name: String, label_text: String, enabled: bool) -> void:
	button.text = "%s: %s" % [label_text, "LIGADO" if enabled else "DESLIGADO"]
	button.icon = UiIcons.texture(icon_name)
	button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.expand_icon = false
	ButtonStyles.apply(button, "ui_toggle_on" if enabled else "ui_ghost", Vector2(0, 60), 19)

func _set_choice(button: Button, label_text: String, selected: bool) -> void:
	button.text = label_text
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	ButtonStyles.apply(button, "ui_toggle_on" if selected else "ui_ghost", Vector2(0, 60), 19)

func _on_music_changed(value: float) -> void:
	SettingsManager.set_music_volume(value)
	_update_volume_labels()

var _last_preview_msec: int = 0

func _on_sfx_changed(value: float) -> void:
	SettingsManager.set_sfx_volume(value)
	_update_volume_labels()
	var now_msec: int = Time.get_ticks_msec()
	if now_msec - _last_preview_msec >= 200:   # V0.15.6: previa limitada (nao um clique por tique do slider)
		_last_preview_msec = now_msec
		_click()

func _on_animations_pressed() -> void:
	_click()
	SettingsManager.toggle_animations_enabled()
	_refresh_settings_view()

func _on_tutorials_pressed() -> void:
	_click()
	SettingsManager.toggle_tutorials_enabled()
	_refresh_settings_view()

func _on_novel_mode_pressed(auto: bool) -> void:
	_click()
	SettingsManager.set_novel_auto(auto)
	_refresh_settings_view()

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
