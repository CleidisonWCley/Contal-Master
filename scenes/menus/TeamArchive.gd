extends Control
## V0.15.2 - ARQUIVOS DA EQUIPE (hub). Antes tudo ficava junto numa tela so; agora o jogador escolhe entre dois cartoes:
##   ESQUERDA  "Arquivos da Firma"  -> FirmaArchive  (capitulos: a ilha, a origem, os valores)
##   DIREITA   "Perfis da Equipe"   -> TeamProfiles  (os 9 personagens, com o cenario do minigame de cada um)
## Mesmo visual da tela "Modo de jogo" (moldura em degrade, hover/foco animado). Lado a lado no desktop, empilhados no celular.

const CARD_BREAKPOINT := 760.0
const CARD_SIZE := Vector2(340, 330)
const CARD_SIZE_COMPACT := Vector2(280, 290)
const CARD_HEIGHT_STACKED := 236.0
const CARD_GAP := 48.0
const CARD_GAP_COMPACT := 24.0
const CARD_GAP_STACKED := 16.0
const TEXT_GAP := 14.0
const HOVER_SCALE := 1.045
const PRESS_SCALE := 0.975
const ANIM_TIME := 0.14

const FIRMA_LOOK := {
	"top": Color("#FFB02E"), "mid": Color("#FF5D8F"), "bottom": Color("#9B3DFF"),
	"glyph_top": Color("#FFE6B0"), "glyph_bottom": Color("#FFC4E0")
}
const PROFILES_LOOK := {
	"top": Color("#1FD3D0"), "mid": Color("#3F7BFF"), "bottom": Color("#9B3DFF"),
	"glyph_top": Color("#9BF3EC"), "glyph_bottom": Color("#C9B2FF")
}

var _safe: MarginContainer
var _main_box: VBoxContainer
var _title_label: Label
var _summary_label: Label
var _cards_box: BoxContainer
var _back_button: Button
var _firma_progress: Label
var _profiles_progress: Label
var _cards: Array[Dictionary] = []


func _ready() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_music("menu")
	UiBackdrop.attach(self)
	_build_ui()
	_apply_layout()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_layout()


func _build_ui() -> void:
	_safe = MarginContainer.new()
	_safe.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_safe)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_safe.add_child(scroll)
	var pad: MarginContainer = UiKit.margin(10, 10, 10, 10)
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(pad)
	_main_box = VBoxContainer.new()
	_main_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_main_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_main_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_main_box.add_theme_constant_override("separation", 12)
	pad.add_child(_main_box)

	var title_row: HBoxContainer = UiKit.screen_title("ARQUIVOS DA EQUIPE", UiPalette.FONT_TITLE.x, "archive", UiPalette.ACCENT_REWARDS)
	_title_label = title_row.get_node("TitleLabel") as Label
	_main_box.add_child(title_row)

	_summary_label = UiKit.label("", 16, UiPalette.TEXT_MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_main_box.add_child(_summary_label)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_main_box.add_child(spacer)

	_cards_box = BoxContainer.new()
	_cards_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_cards_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cards_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_main_box.add_child(_cards_box)

	var firma_button: Button = _make_card("btnFirma", "archive", FIRMA_LOOK, "ARQUIVOS DA FIRMA",
		"A ilha, como tudo começou e os valores da casa.", true)
	var profiles_button: Button = _make_card("btnPerfis", "team", PROFILES_LOOK, "PERFIS DA EQUIPE",
		"Conheça cada pessoa: gostos, história e relações.", false)
	firma_button.pressed.connect(_on_firma_pressed)
	profiles_button.pressed.connect(_on_profiles_pressed)

	var back_spacer: Control = Control.new()
	back_spacer.custom_minimum_size = Vector2(0, 18)
	back_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_main_box.add_child(back_spacer)
	var holder: CenterContainer = CenterContainer.new()
	_main_box.add_child(holder)
	_back_button = UiKit.back_button()
	_back_button.pressed.connect(_on_back_pressed)
	holder.add_child(_back_button)

	_refresh_progress()


func _make_card(node_name: String, icon_name: String, look: Dictionary, title: String, description: String, is_firma: bool) -> Button:
	var button: Button = Button.new()
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

	var art: UiFrameArt = UiFrameArt.new()
	art.name = "Art"
	art.gradient = UiFrameArt.make_gradient(look["top"] as Color, look["mid"] as Color, look["bottom"] as Color)
	art.glyph = UiIcons.texture(icon_name)
	art.glyph_top = look["glyph_top"] as Color
	art.glyph_bottom = look["glyph_bottom"] as Color
	art.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.add_child(art)

	var texts: VBoxContainer = VBoxContainer.new()
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
	var progress_label: Label = UiKit.label("", 14, UiPalette.TEXT_ON_DARK, HORIZONTAL_ALIGNMENT_CENTER)
	texts.add_child(progress_label)
	if is_firma:
		_firma_progress = progress_label
	else:
		_profiles_progress = progress_label

	UiKit.ignore_mouse(art)
	UiKit.ignore_mouse(texts)
	button.mouse_entered.connect(_set_card_flag.bind(button, art, "hover", true))
	button.mouse_exited.connect(_set_card_flag.bind(button, art, "hover", false))
	button.focus_entered.connect(_set_card_flag.bind(button, art, "focus", true))
	button.focus_exited.connect(_set_card_flag.bind(button, art, "focus", false))
	button.button_down.connect(_set_card_flag.bind(button, art, "down", true))
	button.button_up.connect(_set_card_flag.bind(button, art, "down", false))
	button.resized.connect(_update_pivot.bind(button))
	_cards.append({"button": button, "title": title_label, "desc": description_label, "best": progress_label, "art": art, "texts": texts})
	return button


func _card_style(fill: Color, alpha: float) -> StyleBoxFlat:
	return UiKit.panel_style(UiPalette.with_alpha(fill, alpha), Color(0, 0, 0, 0), 30, 0, 12)


func _refresh_progress() -> void:
	var chapters: Dictionary = LoreManager.count_chapters()
	var profiles: Dictionary = LoreManager.count_profiles()
	_firma_progress.text = "Capítulos: %d de %d" % [int(chapters.get("unlocked", 0)), int(chapters.get("total", 0))]
	_profiles_progress.text = "Conhecidos: %d de %d" % [int(profiles.get("met", 0)), int(profiles.get("total", 0))]
	var counts: Dictionary = LoreManager.count_items()
	_summary_label.text = "Liberado: %d de %d seções. Jogue a campanha e o Modo Livre para abrir mais." % [int(counts.get("unlocked", 0)), int(counts.get("total", 0))]


func _apply_layout() -> void:
	if _safe == null:
		return
	var view: Vector2 = ScreenTools.get_viewport_size(self)
	var compact: bool = ScreenTools.is_compact(self)
	var stacked: bool = view.x < CARD_BREAKPOINT
	var margin_x: int = 8 if compact else 28
	var margin_y: int = 4 if compact else 30
	_safe.add_theme_constant_override("margin_left", margin_x)
	_safe.add_theme_constant_override("margin_right", margin_x)
	_safe.add_theme_constant_override("margin_top", margin_y)
	_safe.add_theme_constant_override("margin_bottom", margin_y)
	_main_box.add_theme_constant_override("separation", 8 if compact else 12)
	_cards_box.vertical = stacked
	ScreenTools.apply_label_font(_title_label, self, UiPalette.FONT_TITLE.x, UiPalette.FONT_TITLE.y)
	ScreenTools.apply_label_font(_summary_label, self, 16, 14)
	var gap: float = CARD_GAP_STACKED if stacked else (CARD_GAP_COMPACT if compact else CARD_GAP)
	var base_size: Vector2 = CARD_SIZE_COMPACT if compact else CARD_SIZE
	_cards_box.add_theme_constant_override("separation", int(gap))
	var usable: float = view.x - 2.0 * margin_x - 40.0
	var count: float = float(_cards.size())
	var card_width: float = clampf((usable - (0.0 if stacked else gap * (count - 1.0))) / (1.0 if stacked else count), 200.0, base_size.x)
	var card_height: float = CARD_HEIGHT_STACKED if stacked else base_size.y
	var text_area: float = 132.0 if compact else 140.0
	for entry in _cards:
		var button: Button = entry["button"] as Button
		button.custom_minimum_size = Vector2(card_width, card_height)
		(entry["title"] as Label).add_theme_font_size_override("font_size", 19 if compact else 22)
		(entry["desc"] as Label).add_theme_font_size_override("font_size", 13 if compact else 14)
		(entry["best"] as Label).add_theme_font_size_override("font_size", 13 if compact else 14)
		var art: UiFrameArt = entry["art"] as UiFrameArt
		art.text_area = text_area
		art.inner_pad = 16.0 if compact else 22.0
		var texts: Control = entry["texts"] as Control
		texts.offset_left = 20.0
		texts.offset_right = -20.0
		texts.offset_top = -(text_area - TEXT_GAP)
		texts.offset_bottom = -20.0
	ButtonStyles.apply(_back_button, "ui_ghost", Vector2(222, 46 if compact else 52), 18)


func _update_pivot(button: Button) -> void:
	button.pivot_offset = button.size * 0.5


func _set_card_flag(button: Button, art: UiFrameArt, flag: String, value: bool) -> void:
	button.set_meta(flag, value)
	var hot: bool = bool(button.get_meta("hover", false)) or bool(button.get_meta("focus", false))
	var down: bool = bool(button.get_meta("down", false))
	_animate_card(button, art, hot, down)


func _animate_card(button: Button, art: UiFrameArt, hot: bool, down: bool) -> void:
	var target_scale: float = PRESS_SCALE if down else (HOVER_SCALE if hot else 1.0)
	var target_glow: float = 1.0 if (hot or down) else 0.0
	if button.has_meta("tween"):
		var old_tween: Variant = button.get_meta("tween")
		if old_tween is Tween and (old_tween as Tween).is_valid():
			(old_tween as Tween).kill()
		button.remove_meta("tween")
	if has_node("/root/SettingsManager") and not SettingsManager.animations_enabled():
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


func _on_firma_pressed() -> void:
	GameManager.open_firma_archive()


func _on_profiles_pressed() -> void:
	GameManager.open_team_profiles()


func _on_back_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	GameManager.open_mode_select()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()
		return
	if get_viewport().gui_get_focus_owner() == null:
		for action in ["ui_left", "ui_right", "ui_up", "ui_down", "ui_accept", "ui_focus_next"]:
			if event.is_action_pressed(action):
				get_viewport().set_input_as_handled()
				(_cards[0]["button"] as Button).grab_focus()
				return
