extends RefCounted
class_name UiKit
## Utilitarios de layout/estilo compartilhados pelas telas de menu.

static func panel_style(bg: Color, border: Color, radius: int, border_width: int = 2, shadow: int = 10) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	style.shadow_color = Color(0, 0, 0, 0.34)
	style.shadow_size = shadow
	return style

## Cartao padrao (quase opaco: o texto nunca depende do cenario atras).
static func card_style(radius: int = 22) -> StyleBoxFlat:
	return panel_style(UiPalette.with_alpha(UiPalette.CARD, 0.96), UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.45), radius, 2, 12)

static func margin(left: int, right: int, top: int, bottom: int) -> MarginContainer:
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", left)
	m.add_theme_constant_override("margin_right", right)
	m.add_theme_constant_override("margin_top", top)
	m.add_theme_constant_override("margin_bottom", bottom)
	return m

static func label(text: String, size_px: int, color: Color = UiPalette.TEXT_ON_DARK, align: int = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = align as HorizontalAlignment
	l.add_theme_font_size_override("font_size", size_px)
	l.add_theme_color_override("font_color", color)
	return l

static func circle_texture(diameter: int, color: Color) -> ImageTexture:
	var img := Image.create(diameter, diameter, false, Image.FORMAT_RGBA8)
	var r: float = diameter * 0.5
	for y in range(diameter):
		for x in range(diameter):
			var d: float = Vector2(x + 0.5, y + 0.5).distance_to(Vector2(r, r))
			var a: float = clampf(r - d, 0.0, 1.0)
			img.set_pixel(x, y, Color(color.r, color.g, color.b, a))
	return ImageTexture.create_from_image(img)

## Faz o no e todos os filhos ignorarem o mouse (para conteudo desenhado sobre um Button).
static func ignore_mouse(node: Node) -> void:
	if node is Control:
		(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		ignore_mouse(child)

## Pilula com a dificuldade atual: nome + pontos, na cor da dificuldade.
## font/v_pad deixam o chip maior nas telas de menu (referencia de design) sem mudar os usos antigos.
static func difficulty_chip(key: String, prefix: String = "Dificuldade", font: int = 18, v_pad: int = 4) -> PanelContainer:
	var accent: Color = UiPalette.difficulty_color(key)
	var chip := PanelContainer.new()
	chip.add_theme_stylebox_override("panel", panel_style(UiPalette.with_alpha(UiPalette.CARD, 0.94), accent, 16, 2, 6))
	var pad := margin(18, 18, v_pad, v_pad)
	chip.add_child(pad)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	pad.add_child(row)
	row.add_child(label(prefix, font, UiPalette.TEXT_MUTED))
	var pips := UiPips.new()
	pips.level = UiPalette.difficulty_level(key)
	pips.color = accent
	row.add_child(pips)
	row.add_child(label(ScoreManager.get_difficulty_label(key), font, accent))
	return chip

# ---- Blocos compartilhados pelas telas de menu (visual unico) -------------------------------

## Titulo padrao de tela: [icone opcional] + TEXTO em branco, centralizado.
static func screen_title(text: String, font: int = 36, icon_name: String = "", icon_color: Color = UiPalette.TEXT_ON_DARK) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	if icon_name != "":
		var icon := UiIcons.make_rect(icon_name, font * 0.9, icon_color)
		icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(icon)
	var title := label(text, font, UiPalette.TEXT_ON_DARK, HORIZONTAL_ALIGNMENT_CENTER)
	title.name = "TitleLabel"
	row.add_child(title)
	return row

## Botao "Voltar" padrao (seta + texto), igual em todas as telas.
static func back_button(min_size: Vector2 = Vector2(222, 52), font: int = 18) -> Button:
	var button := Button.new()
	button.name = "BackButton"
	button.text = "Voltar"
	button.icon = UiIcons.texture("back")
	button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.expand_icon = false
	ButtonStyles.apply(button, "ui_ghost", min_size, font)
	return button

## Quadrado arredondado com icone branco no centro (selos dos cartoes).
static func icon_badge(icon_name: String, box_px: float, fill: Color, border: Color, radius: int, icon_ratio: float = 0.5) -> PanelContainer:
	var badge := PanelContainer.new()
	badge.custom_minimum_size = Vector2(box_px, box_px)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_theme_stylebox_override("panel", panel_style(fill, border, radius, 1, 0))
	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_child(center)
	center.add_child(UiIcons.make_rect(icon_name, box_px * icon_ratio, UiPalette.TEXT_ON_DARK))
	return badge

## Pilula de texto (ex.: "8 desafios em sequencia").
static func pill(text: String, font: int, fill: Color, border: Color, text_color: Color = UiPalette.TEXT_ON_DARK) -> PanelContainer:
	var chip := PanelContainer.new()
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_theme_stylebox_override("panel", panel_style(fill, border, 12, 1, 0))
	var pad := margin(18, 18, 7, 7)
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_child(pad)
	var text_label := label(text, font, text_color, HORIZONTAL_ALIGNMENT_CENTER)
	text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.add_child(text_label)
	return chip

## Formata 1900 -> "1.900 pts" (milhar pt-BR).
static func format_points(points: int) -> String:
	var digits: String = str(maxi(points, 0))
	var out: String = ""
	var count: int = 0
	for i in range(digits.length() - 1, -1, -1):
		out = digits[i] + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = "." + out
	return "%s pts" % out
