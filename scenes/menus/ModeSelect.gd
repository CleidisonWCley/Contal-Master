extends Control
## Tela "Modo de jogo" (UI/UX v4.3 - cartoes compactos, mais respiro entre eles, hover/foco animado): titulo, seletor de dificuldade e dois cartoes com a moldura em
## degrade do icone de referencia (contorno duplo, cantoneiras e glifo). Sem lista de minigames:
## o jogador descobre jogando. A dificuldade pode ser trocada aqui mesmo (mesma opcao das Configuracoes).
## Toda a interface e montada por codigo, com as cores de UiPalette.

const CARD_BREAKPOINT := 820.0   # abaixo disso os cartoes ficam um embaixo do outro
const CARD_SIZE := Vector2(290, 330)          # desktop (antes 360x430)
const CARD_SIZE_COMPACT := Vector2(250, 290)  # telas compactas (lado a lado)
const CARD_HEIGHT_STACKED := 270.0            # um embaixo do outro (celular em pe)
const CARD_GAP := 72.0           # separacao Campanha | Livre (antes 24)
const CARD_GAP_COMPACT := 36.0
const CARD_GAP_STACKED := 16.0
const TEXT_GAP := 14.0           # respiro entre a moldura interna e o titulo
const HOVER_SCALE := 1.045       # zoom do cartao em hover/foco (antes 1.015, quase invisivel)
const PRESS_SCALE := 0.975
const ANIM_TIME := 0.14

# Paletas das molduras: topo / meio / base do degrade + degrade do glifo.
# Campanha = degrade do icone de referencia (azul -> roxo -> magenta). Livre = ciano -> azul -> roxo.
const CAMPAIGN_LOOK := {
	"top": Color("#1E6EFF"), "mid": Color("#7B4DFF"), "bottom": Color("#C524FF"),
	"glyph_top": Color("#8FD0FF"), "glyph_bottom": Color("#E4B5FF")
}
const FREE_LOOK := {
	"top": Color("#1FD3D0"), "mid": Color("#3F7BFF"), "bottom": Color("#9B3DFF"),
	"glyph_top": Color("#9BF3EC"), "glyph_bottom": Color("#C9B2FF")
}

var campaign_button: Button
var free_button: Button
var back_button: Button

var _safe_area: MarginContainer
var _main_box: VBoxContainer
var _title_label: Label
var _cards_box: BoxContainer
var _cards_spacer: Control
var _back_spacer: Control
var _difficulty_selector: DifficultySelector
var _campaign_best_label: Label
var _free_best_label: Label
# {"button", "title", "desc", "best", "art", "texts"} de cada cartao (para o layout responsivo)
var _cards: Array[Dictionary] = []

func _ready() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_music("menu")
	UiBackdrop.attach(self)
	_build_ui()
	_refresh_stats()
	_apply_responsive_layout()
	# Sem grab_focus automatico: o foco inicial deixava a Campanha sempre "acesa" e sem reacao ao mouse.
	# Teclado / controle: o primeiro direcional ou confirmar foca a Campanha (ver _unhandled_input).

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_responsive_layout()

# ---------------------------------------------------------------- construcao
func _build_ui() -> void:
	_safe_area = MarginContainer.new()
	_safe_area.name = "SafeArea"
	_safe_area.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_safe_area)

	var scroll := ScrollContainer.new()
	scroll.name = "Scroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_safe_area.add_child(scroll)

	# Folga interna: o anel de foco e o zoom do hover dos cartoes nao podem ser cortados pelo scroll.
	var inner_pad := UiKit.margin(10, 10, 10, 10)
	inner_pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner_pad.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(inner_pad)

	_main_box = VBoxContainer.new()
	_main_box.name = "MainBox"
	_main_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_main_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_main_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_main_box.add_theme_constant_override("separation", 12)
	inner_pad.add_child(_main_box)

	var title_row: HBoxContainer = UiKit.screen_title("MODO DE JOGO", UiPalette.FONT_TITLE.x)
	_title_label = title_row.get_node("TitleLabel") as Label
	_main_box.add_child(title_row)

	var selector_holder := CenterContainer.new()
	_main_box.add_child(selector_holder)
	_difficulty_selector = DifficultySelector.new()
	_difficulty_selector.name = "DifficultySelector"
	_difficulty_selector.font_px = 17
	_difficulty_selector.v_pad = 6
	selector_holder.add_child(_difficulty_selector)
	_difficulty_selector.difficulty_selected.connect(_on_difficulty_selected)

	# Respiro entre o seletor de dificuldade e os cartoes (o zoom do hover nunca encosta nele).
	_cards_spacer = Control.new()
	_cards_spacer.name = "CardsSpacer"
	_cards_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_main_box.add_child(_cards_spacer)

	_cards_box = BoxContainer.new()
	_cards_box.name = "Cards"
	_cards_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_cards_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cards_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_cards_box.add_theme_constant_override("separation", int(CARD_GAP))
	_main_box.add_child(_cards_box)

	campaign_button = _make_mode_card(
		"btnCampanha", "compass", CAMPAIGN_LOOK, "MODO CAMPANHA",
		"Jogue a jornada completa, um desafio após o outro.", true)
	free_button = _make_mode_card(
		"btnLivre", "gamepad", FREE_LOOK, "MODO LIVRE",
		"Escolha um minigame direto e bata seu recorde.", false)

	# Respiro entre os cartoes e o Voltar: o zoom do hover dos cartoes nao invade o botao.
	_back_spacer = Control.new()
	_back_spacer.name = "BackSpacer"
	_back_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_main_box.add_child(_back_spacer)

	var back_holder := CenterContainer.new()
	_main_box.add_child(back_holder)
	back_button = UiKit.back_button()
	back_holder.add_child(back_button)

	campaign_button.pressed.connect(_on_campaign_pressed)
	free_button.pressed.connect(_on_free_pressed)
	back_button.pressed.connect(_on_back_pressed)

## Cartao com a moldura em degrade: [moldura + glifo] em cima, titulo / descricao / melhor pontuacao embaixo.
func _make_mode_card(node_name: String, icon_name: String, look: Dictionary, title: String, description: String, is_campaign: bool) -> Button:
	var button := Button.new()
	button.name = node_name
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.custom_minimum_size = CARD_SIZE
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.tooltip_text = description
	button.add_theme_stylebox_override("normal", _card_style(UiPalette.CARD, 0.90))
	button.add_theme_stylebox_override("hover", _card_style(UiPalette.CARD_RAISED, 0.96))
	button.add_theme_stylebox_override("pressed", _card_style(UiPalette.CARD.darkened(0.25), 0.98))
	button.add_theme_stylebox_override("focus", ButtonStyles.make_focus_ring(30))
	_cards_box.add_child(button)

	var art := UiFrameArt.new()
	art.name = "Art"
	art.gradient = UiFrameArt.make_gradient(look["top"] as Color, look["mid"] as Color, look["bottom"] as Color)
	art.glyph = UiIcons.texture(icon_name)
	art.glyph_top = look["glyph_top"] as Color
	art.glyph_bottom = look["glyph_bottom"] as Color
	art.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.add_child(art)

	var texts := VBoxContainer.new()
	texts.name = "Texts"
	texts.alignment = BoxContainer.ALIGNMENT_CENTER
	texts.add_theme_constant_override("separation", 6)
	texts.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	texts.grow_vertical = Control.GROW_DIRECTION_BEGIN
	button.add_child(texts)

	var title_label: Label = UiKit.label(title, 22, UiPalette.TEXT_ON_DARK, HORIZONTAL_ALIGNMENT_CENTER)
	texts.add_child(title_label)
	var description_label: Label = UiKit.label(description, 14, UiPalette.TEXT_MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texts.add_child(description_label)
	var best_label: Label = UiKit.label("", 14, UiPalette.TEXT_ON_DARK, HORIZONTAL_ALIGNMENT_CENTER)
	texts.add_child(best_label)
	if is_campaign:
		_campaign_best_label = best_label
	else:
		_free_best_label = best_label

	UiKit.ignore_mouse(art)
	UiKit.ignore_mouse(texts)
	button.mouse_entered.connect(_set_card_flag.bind(button, art, "hover", true))
	button.mouse_exited.connect(_set_card_flag.bind(button, art, "hover", false))
	button.focus_entered.connect(_set_card_flag.bind(button, art, "focus", true))
	button.focus_exited.connect(_set_card_flag.bind(button, art, "focus", false))
	button.button_down.connect(_set_card_flag.bind(button, art, "down", true))
	button.button_up.connect(_set_card_flag.bind(button, art, "down", false))
	# O zoom sempre parte do centro do cartao, mesmo quando o layout muda de tamanho.
	button.resized.connect(_update_pivot.bind(button))
	_cards.append({"button": button, "title": title_label, "desc": description_label,
		"best": best_label, "art": art, "texts": texts})
	return button

func _card_style(fill: Color, alpha: float) -> StyleBoxFlat:
	# Fundo quase opaco: o texto branco nunca depende do cenario atras. A borda e desenhada pela moldura.
	return UiKit.panel_style(UiPalette.with_alpha(fill, alpha), Color(0, 0, 0, 0), 30, 0, 12)

## Melhor pontuacao de cada modo na dificuldade atual (muda quando o jogador troca a dificuldade).
func _refresh_stats() -> void:
	var difficulty: String = DifficultyManager.get_difficulty()
	var campaign_best: int = ScoreManager.get_campaign_total_score(difficulty)
	var free_best: int = 0
	for key in GameManager.FREE_PHASE_KEYS:
		free_best = maxi(free_best, ScoreManager.get_free_mode_best_score(str(key), difficulty))
	_campaign_best_label.text = "Melhor campanha: %s" % UiKit.format_points(campaign_best)
	_free_best_label.text = "Melhor recorde: %s" % UiKit.format_points(free_best)

# ---------------------------------------------------------------- layout
func _apply_responsive_layout() -> void:
	if _safe_area == null or back_button == null:
		return
	var view: Vector2 = ScreenTools.get_viewport_size(self)
	var compact: bool = ScreenTools.is_compact(self)
	var stacked: bool = view.x < CARD_BREAKPOINT
	var margin_x: int = 8 if compact else 28
	var margin_y: int = 4 if compact else 30
	_safe_area.add_theme_constant_override("margin_left", margin_x)
	_safe_area.add_theme_constant_override("margin_right", margin_x)
	_safe_area.add_theme_constant_override("margin_top", margin_y)
	_safe_area.add_theme_constant_override("margin_bottom", margin_y)
	_main_box.add_theme_constant_override("separation", 8 if compact else 12)
	_cards_box.vertical = stacked
	ScreenTools.apply_label_font(_title_label, self, UiPalette.FONT_TITLE.x, UiPalette.FONT_TITLE.y)
	_difficulty_selector.set_compact(view.x < 560.0)

	# Medidas por modo de tela: desktop / compacta (lado a lado) / empilhada (um embaixo do outro).
	var gap: float = CARD_GAP_STACKED if stacked else (CARD_GAP_COMPACT if compact else CARD_GAP)
	var base_size: Vector2 = CARD_SIZE_COMPACT if compact else CARD_SIZE
	_cards_box.add_theme_constant_override("separation", int(gap))
	_cards_spacer.custom_minimum_size = Vector2(0, 0 if compact else 10)
	_back_spacer.custom_minimum_size = Vector2(0, 12 if compact else 30)

	var usable_width: float = view.x - 2.0 * margin_x - 40.0   # 40 = folga interna do scroll + respiro
	var card_width: float = clampf((usable_width - (0.0 if stacked else gap)) / (1.0 if stacked else 2.0), 220.0, base_size.x)
	var card_height: float = CARD_HEIGHT_STACKED if stacked else base_size.y
	var text_area: float = 132.0 if compact else 140.0
	var title_px: int = 19 if compact else 22
	var body_px: int = 13 if compact else 14
	for entry in _cards:
		var button: Button = entry["button"] as Button
		button.custom_minimum_size = Vector2(card_width, card_height)
		(entry["title"] as Label).add_theme_font_size_override("font_size", title_px)
		(entry["desc"] as Label).add_theme_font_size_override("font_size", body_px)
		(entry["best"] as Label).add_theme_font_size_override("font_size", body_px)
		var art: UiFrameArt = entry["art"] as UiFrameArt
		art.text_area = text_area
		art.inner_pad = 16.0 if compact else 22.0
		# faixa de texto: da base da moldura interna (+ respiro) ate perto da borda de baixo
		var texts: Control = entry["texts"] as Control
		texts.offset_left = 20.0
		texts.offset_right = -20.0
		texts.offset_top = -(text_area - TEXT_GAP)
		texts.offset_bottom = -20.0
	ButtonStyles.apply(back_button, "ui_ghost", Vector2(222, 46 if compact else 52), 18)

func _update_pivot(button: Button) -> void:
	button.pivot_offset = button.size * 0.5

## Estados independentes (mouse, foco, clique) -> um unico estado visual por cartao.
func _set_card_flag(button: Button, art: UiFrameArt, flag: String, value: bool) -> void:
	button.set_meta(flag, value)
	var hot: bool = bool(button.get_meta("hover", false)) or bool(button.get_meta("focus", false))
	var down: bool = bool(button.get_meta("down", false))
	_animate_card(button, art, hot, down)

func _animate_card(button: Button, art: UiFrameArt, hot: bool, down: bool) -> void:
	var target_scale: float = PRESS_SCALE if down else (HOVER_SCALE if hot else 1.0)
	var target_glow: float = 1.0 if (hot or down) else 0.0
	# Um unico Tween por cartao: o novo cancela o anterior (sem animacoes brigando entre si).
	# V0.13.4: get_meta(chave, null) NAO conta como "tem padrao": no Godot 4.5 o null e tratado como "sem padrao" e,
	# na primeira animacao do cartao (ainda sem "tween"), gera "The object does not have any 'meta' values...".
	if button.has_meta("tween"):
		var old_tween: Variant = button.get_meta("tween")
		if old_tween is Tween and (old_tween as Tween).is_valid():
			(old_tween as Tween).kill()
	if not _animations_enabled():
		button.scale = Vector2.ONE * target_scale
		art.glow_amount = target_glow
		return
	_update_pivot(button)
	var tween: Tween = button.create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2.ONE * target_scale, ANIM_TIME)
	tween.tween_property(art, "glow_amount", target_glow, ANIM_TIME)
	button.set_meta("tween", tween)

# ---------------------------------------------------------------- acoes
func _on_difficulty_selected(_key: String) -> void:
	_refresh_stats()

func _on_campaign_pressed() -> void:
	_click()
	GameManager.start_campaign()

func _on_free_pressed() -> void:
	_click()
	GameManager.open_free_menu()

func _on_back_pressed() -> void:
	_click()
	GameManager.go_to_main_menu()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()
		return
	# Teclado / controle sem nada focado: o 1o direcional ou confirmar cai na Campanha.
	if get_viewport().gui_get_focus_owner() == null:
		for action in ["ui_left", "ui_right", "ui_up", "ui_down", "ui_accept", "ui_focus_next"]:
			if event.is_action_pressed(action):
				get_viewport().set_input_as_handled()
				campaign_button.grab_focus()
				return

func _click() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()

func _animations_enabled() -> bool:
	return not has_node("/root/SettingsManager") or SettingsManager.animations_enabled()
