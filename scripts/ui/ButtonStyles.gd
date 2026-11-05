extends RefCounted
class_name ButtonStyles

# V0.9.5 — Paleta fiel ao Pygame.
# Mantém o acabamento do Godot, mas usa as cores base/hover da versão original.

const WHITE := Color(1.0, 1.0, 1.0, 1.0)
const BLACK := Color(0.0, 0.0, 0.0, 1.0)
const TEXT_MUTED := Color(0.863, 0.878, 0.961, 1.0)
const BORDER_DARK := Color(0.118, 0.118, 0.118, 1.0)
const GOLD := Color(1.0, 0.843, 0.0, 1.0)
const GOLD_SOFT := Color(1.0, 0.875, 0.314, 1.0)

# Menu principal Pygame
const MAIN_START := Color(0.784, 0.275, 0.275, 0.98)
const MAIN_START_HOVER := Color(0.941, 0.431, 0.431, 1.0)
const MAIN_SETTINGS := Color(0.275, 0.431, 0.784, 0.98)
const MAIN_SETTINGS_HOVER := Color(0.471, 0.627, 0.980, 1.0)
const MAIN_EXIT := Color(0.314, 0.314, 0.314, 0.98)
const MAIN_EXIT_HOVER := Color(0.510, 0.510, 0.510, 1.0)

# Seleção de modo / modo livre
const MODE_CAMPAIGN := Color(0.784, 0.235, 0.235, 0.98)
const MODE_CAMPAIGN_HOVER := Color(0.941, 0.392, 0.392, 1.0)
const MODE_FREE := Color(0.235, 0.392, 0.784, 0.98)
const MODE_FREE_HOVER := Color(0.392, 0.549, 0.941, 1.0)
const MODE_BACK := Color(0.314, 0.314, 0.314, 0.98)
const MODE_BACK_HOVER := Color(0.471, 0.471, 0.471, 1.0)
const FREE_OPTION := Color(0.235, 0.235, 0.392, 0.98)
const FREE_OPTION_HOVER := Color(0.392, 0.392, 0.706, 1.0)
const FREE_BACK := Color(0.706, 0.196, 0.196, 0.98)
const FREE_BACK_HOVER := Color(0.863, 0.314, 0.314, 1.0)
const MAGIC_CARD := Color(0.075, 0.090, 0.180, 0.96)
const MAGIC_CARD_HOVER := Color(0.130, 0.170, 0.320, 1.0)
const MAGIC_GOLD_BORDER := Color(1.0, 0.820, 0.220, 1.0)
const MAGIC_CYAN_BORDER := Color(0.360, 0.900, 1.0, 1.0)
const MAGIC_CARD_PRESSED := Color(0.052, 0.068, 0.130, 1.0)

# Configurações Pygame
const SETTINGS_PANEL := Color(0.078, 0.098, 0.157, 0.94)
const SETTINGS_EASY := Color(0.196, 0.471, 0.863, 0.98)
const SETTINGS_EASY_HOVER := Color(0.353, 0.627, 1.0, 1.0)
const SETTINGS_NORMAL := Color(0.863, 0.706, 0.157, 0.98)
const SETTINGS_NORMAL_HOVER := Color(0.980, 0.843, 0.294, 1.0)
const SETTINGS_HARD := Color(0.784, 0.196, 0.196, 0.98)
const SETTINGS_HARD_HOVER := Color(0.941, 0.333, 0.333, 1.0)
const SETTINGS_GRAY := Color(0.314, 0.314, 0.353, 0.98)
const SETTINGS_GRAY_HOVER := Color(0.471, 0.471, 0.510, 1.0)
const SETTINGS_SUCCESS := Color(0.157, 0.588, 0.235, 0.98)
const SETTINGS_SUCCESS_HOVER := Color(0.275, 0.745, 0.353, 1.0)

static func apply_primary(button: BaseButton, min_size: Vector2 = Vector2.ZERO, font_size: int = 22) -> void:
	apply(button, "main_start", min_size, font_size)

static func apply_secondary(button: BaseButton, min_size: Vector2 = Vector2.ZERO, font_size: int = 20) -> void:
	apply(button, "main_settings", min_size, font_size)

static func apply_danger(button: BaseButton, min_size: Vector2 = Vector2.ZERO, font_size: int = 20) -> void:
	apply(button, "free_back", min_size, font_size)

static func apply_ghost(button: BaseButton, min_size: Vector2 = Vector2.ZERO, font_size: int = 18) -> void:
	apply(button, "mode_back", min_size, font_size)

static func apply_option(button: BaseButton, min_size: Vector2 = Vector2.ZERO, font_size: int = 18) -> void:
	apply(button, "free_option", min_size, font_size)

static func apply_cutscene(button: BaseButton, variant: String = "cutscene_menu", min_size: Vector2 = Vector2(104, 40), font_size: int = 16) -> void:
	apply(button, variant, min_size, font_size)

static func apply_toggle(button: BaseButton, label: String, enabled: bool, min_size: Vector2 = Vector2.ZERO, font_size: int = 18) -> void:
	if button == null:
		return
	button.text = "%s: %s" % [label, "ON" if enabled else "OFF"]
	apply(button, "toggle_on" if enabled else "toggle_off", min_size, font_size)

static func apply_difficulty(button: BaseButton, difficulty: String, min_size: Vector2 = Vector2.ZERO, font_size: int = 17) -> void:
	match difficulty:
		"facil":
			apply(button, "settings_easy", min_size, font_size)
		"dificil":
			apply(button, "settings_hard", min_size, font_size)
		_:
			apply(button, "settings_normal", min_size, font_size)

static func apply(button: BaseButton, variant: String = "main_settings", min_size: Vector2 = Vector2.ZERO, font_size: int = 20) -> void:
	if button == null:
		return
	var palette: Dictionary = _palette(variant)
	var normal_color: Color = _dict_color(palette, "normal", MAIN_SETTINGS)
	var hover_color: Color = _dict_color(palette, "hover", MAIN_SETTINGS_HOVER)
	var pressed_color: Color = _dict_color(palette, "pressed", normal_color.darkened(0.16))
	var border_color: Color = _dict_color(palette, "border", WHITE)
	var hover_border: Color = _dict_color(palette, "hover_border", WHITE)
	var pressed_border: Color = _dict_color(palette, "pressed_border", WHITE)
	var disabled_color: Color = _dict_color(palette, "disabled", normal_color.darkened(0.42))
	var text_color: Color = _dict_color(palette, "text", WHITE)
	var text_hover: Color = _dict_color(palette, "text_hover", WHITE)
	var text_pressed: Color = _dict_color(palette, "text_pressed", WHITE)
	var radius: int = int(palette.get("radius", 15))
	var border_width: int = int(palette.get("border_width", 2))
	# Variantes "accessible": foco por teclado/controle visivel, icones tingidos, texto por contraste.
	var accessible: bool = bool(palette.get("accessible", false))

	if min_size != Vector2.ZERO:
		button.custom_minimum_size = min_size
	button.focus_mode = Control.FOCUS_ALL if accessible else Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_color_override("font_hover_color", text_hover)
	button.add_theme_color_override("font_pressed_color", text_pressed)
	button.add_theme_color_override("font_disabled_color", Color(text_color.r, text_color.g, text_color.b, 0.5) if accessible else Color(1.0, 1.0, 1.0, 0.44))
	button.add_theme_color_override("font_focus_color", text_color if accessible else WHITE)
	if accessible:
		button.add_theme_color_override("icon_normal_color", text_color)
		button.add_theme_color_override("icon_hover_color", text_hover)
		button.add_theme_color_override("icon_pressed_color", text_pressed)
		button.add_theme_color_override("icon_focus_color", text_color)
		button.add_theme_color_override("icon_disabled_color", Color(text_color.r, text_color.g, text_color.b, 0.5))
		button.add_theme_constant_override("icon_max_width", int(round(font_size * 1.3)))
		button.add_theme_constant_override("h_separation", 12)
	button.add_theme_stylebox_override("normal", _make_style(normal_color, border_color, radius, border_width))
	button.add_theme_stylebox_override("hover", _make_style(hover_color, hover_border, radius, border_width))
	button.add_theme_stylebox_override("pressed", _make_style(pressed_color, pressed_border, radius, border_width))
	button.add_theme_stylebox_override("disabled", _make_style(disabled_color, Color(border_color.r, border_color.g, border_color.b, 0.42), radius, border_width))
	if accessible:
		button.add_theme_stylebox_override("focus", make_focus_ring(radius))
	else:
		button.add_theme_stylebox_override("focus", _make_style(Color(0.0, 0.0, 0.0, 0.0), hover_border, radius, 2))

## Anel de foco para teclado/controle: borda clara externa que contrasta com qualquer fundo.
static func make_focus_ring(radius: int = 14) -> StyleBoxFlat:
	var ring: StyleBoxFlat = StyleBoxFlat.new()
	ring.draw_center = false
	ring.border_color = UiPalette.TEXT_ON_DARK
	ring.set_border_width_all(3)
	ring.set_corner_radius_all(radius + 3)
	ring.set_expand_margin_all(4)
	return ring

static func apply_group(buttons: Array, variant: String = "main_settings", min_size: Vector2 = Vector2.ZERO, font_size: int = 20) -> void:
	for item in buttons:
		if item is BaseButton:
			apply(item as BaseButton, variant, min_size, font_size)

static func _palette(variant: String) -> Dictionary:
	match variant:
		"main_start":
			return _button_palette(MAIN_START, MAIN_START_HOVER, MAIN_START.darkened(0.18), WHITE, 22, 3)
		"main_settings":
			return _button_palette(MAIN_SETTINGS, MAIN_SETTINGS_HOVER, MAIN_SETTINGS.darkened(0.16), WHITE, 18, 3)
		"main_exit":
			return _button_palette(MAIN_EXIT, MAIN_EXIT_HOVER, MAIN_EXIT.darkened(0.14), WHITE, 18, 3)
		"mode_campaign_card":
			return _button_palette(Color(0.280, 0.190, 0.075, 0.98), Color(0.410, 0.285, 0.100, 1.0), Color(0.190, 0.120, 0.050, 1.0), MAGIC_GOLD_BORDER, 22, 3)
		"mode_free_card":
			return _button_palette(Color(0.075, 0.145, 0.300, 0.98), Color(0.110, 0.230, 0.470, 1.0), Color(0.055, 0.100, 0.210, 1.0), MAGIC_CYAN_BORDER, 22, 3)
		"minigame_card":
			return _button_palette(MAGIC_CARD, MAGIC_CARD_HOVER, MAGIC_CARD_PRESSED, MAGIC_CYAN_BORDER, 20, 2)
		"minigame_card_gold":
			return _button_palette(MAGIC_CARD, MAGIC_CARD_HOVER, MAGIC_CARD_PRESSED, MAGIC_GOLD_BORDER, 20, 2)
		"mode_campaign":
			return _button_palette(MODE_CAMPAIGN, MODE_CAMPAIGN_HOVER, MODE_CAMPAIGN.darkened(0.18), WHITE, 18, 3)
		"mode_free":
			return _button_palette(MODE_FREE, MODE_FREE_HOVER, MODE_FREE.darkened(0.16), WHITE, 18, 3)
		"mode_back":
			return _button_palette(MODE_BACK, MODE_BACK_HOVER, MODE_BACK.darkened(0.14), WHITE, 15, 2)
		"magic_back":
			return _button_palette(Color(0.085, 0.070, 0.140, 0.96), Color(0.150, 0.120, 0.230, 1.0), Color(0.050, 0.040, 0.090, 1.0), MAGIC_GOLD_BORDER, 16, 2)
		"free_option":
			return _button_palette(FREE_OPTION, FREE_OPTION_HOVER, FREE_OPTION.darkened(0.14), WHITE, 12, 2)
		"free_back":
			return _button_palette(FREE_BACK, FREE_BACK_HOVER, FREE_BACK.darkened(0.15), WHITE, 12, 2)
		"settings_easy":
			return _button_palette(SETTINGS_EASY, SETTINGS_EASY_HOVER, SETTINGS_EASY.darkened(0.16), WHITE, 14, 2)
		"settings_normal":
			return _button_palette(SETTINGS_NORMAL, SETTINGS_NORMAL_HOVER, SETTINGS_NORMAL.darkened(0.16), WHITE, 14, 2)
		"settings_hard":
			return _button_palette(SETTINGS_HARD, SETTINGS_HARD_HOVER, SETTINGS_HARD.darkened(0.16), WHITE, 14, 2)
		"toggle_on":
			return _button_palette(SETTINGS_SUCCESS, SETTINGS_SUCCESS_HOVER, SETTINGS_SUCCESS.darkened(0.16), WHITE, 14, 2)
		"toggle_off":
			return _button_palette(SETTINGS_GRAY, SETTINGS_GRAY_HOVER, SETTINGS_GRAY.darkened(0.12), WHITE, 14, 2)
		"cutscene_menu":
			return _button_palette(MODE_BACK, MODE_BACK_HOVER, MODE_BACK.darkened(0.14), WHITE, 13, 2)
		"cutscene_skip":
			return _button_palette(FREE_BACK, FREE_BACK_HOVER, FREE_BACK.darkened(0.15), WHITE, 13, 2)
		"cutscene_return":
			return _button_palette(MAIN_START, MAIN_START_HOVER, MAIN_START.darkened(0.18), WHITE, 15, 3)
		"success":
			return _button_palette(SETTINGS_SUCCESS, SETTINGS_SUCCESS_HOVER, SETTINGS_SUCCESS.darkened(0.16), WHITE, 14, 2)
		"danger":
			return _button_palette(FREE_BACK, FREE_BACK_HOVER, FREE_BACK.darkened(0.15), WHITE, 14, 2)
		"primary":
			return _button_palette(MAIN_START, MAIN_START_HOVER, MAIN_START.darkened(0.18), WHITE, 15, 3)
		"secondary":
			return _button_palette(MAIN_SETTINGS, MAIN_SETTINGS_HOVER, MAIN_SETTINGS.darkened(0.16), WHITE, 14, 2)
		"ghost":
			return _button_palette(MODE_BACK, MODE_BACK_HOVER, MODE_BACK.darkened(0.14), WHITE, 13, 2)
		"option":
			return _button_palette(FREE_OPTION, FREE_OPTION_HOVER, FREE_OPTION.darkened(0.14), WHITE, 12, 2)
		# ---- Paleta Contal Master (acessivel). menu_* = semitransparentes sobre o cenario.
		"menu_play":
			return _accessible_palette(UiPalette.PRIMARY, UiPalette.MENU_BUTTON_ALPHA, 18)
		"menu_settings":
			return _accessible_palette(UiPalette.SECONDARY, UiPalette.MENU_BUTTON_ALPHA, 18)
		"menu_scores":
			return _accessible_palette(UiPalette.ACCENT_REWARDS, UiPalette.MENU_BUTTON_ALPHA, 18)
		"menu_achievements":
			return _accessible_palette(UiPalette.ACCENT_ACHIEVEMENTS, UiPalette.MENU_BUTTON_ALPHA, 18)
		"menu_exit":
			return _accessible_palette(UiPalette.CARD, UiPalette.MENU_BUTTON_ALPHA, 18, UiPalette.HIGHLIGHT)
		# ---- Dentro de cartoes (fundo solido): opacidade total.
		"ui_primary":
			return _accessible_palette(UiPalette.PRIMARY, 1.0, 12)
		"ui_secondary":
			return _accessible_palette(UiPalette.SECONDARY, 1.0, 12)
		"ui_ghost":
			return _accessible_palette(UiPalette.CARD_RAISED, 1.0, 12, UiPalette.HIGHLIGHT)
		_:
			return _button_palette(MAIN_SETTINGS, MAIN_SETTINGS_HOVER, MAIN_SETTINGS.darkened(0.16), WHITE, 14, 2)

static func _button_palette(normal: Color, hover: Color, pressed: Color, border: Color, radius: int, border_width: int) -> Dictionary:
	return {
		"normal": normal,
		"hover": hover,
		"pressed": pressed,
		"border": border,
		"hover_border": WHITE,
		"pressed_border": WHITE,
		"text": WHITE,
		"radius": radius,
		"border_width": border_width
	}

## Paleta acessivel: texto escolhido por contraste, hover = opacidade total, pressionado = lilas.
static func _accessible_palette(base: Color, alpha: float, radius: int, border_override: Color = Color(0.0, 0.0, 0.0, 0.0)) -> Dictionary:
	var normal: Color = UiPalette.with_alpha(base, alpha)
	var hover: Color = UiPalette.with_alpha(base, 1.0)
	var pressed: Color = UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.97)
	var text: Color = UiPalette.readable_text_on(base)
	var border: Color = border_override if border_override.a > 0.0 else base.lightened(0.32)
	return {
		"normal": normal,
		"hover": hover,
		"pressed": pressed,
		"border": border,
		"hover_border": UiPalette.TEXT_ON_DARK,
		"pressed_border": UiPalette.TEXT_ON_DARK,
		"text": text,
		"text_hover": text,
		"text_pressed": UiPalette.readable_text_on(UiPalette.HIGHLIGHT),
		"radius": radius,
		"border_width": 2,
		"accessible": true
	}

static func _make_style(bg_color: Color, border_color: Color, radius: int = 14, border_width: int = 2) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.set_corner_radius_all(radius)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.34)
	style.shadow_size = 7
	return style

static func _dict_color(data: Dictionary, key: String, fallback: Color) -> Color:
	var value: Variant = data.get(key, fallback)
	if value is Color:
		return value
	return fallback
