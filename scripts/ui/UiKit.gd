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
static func difficulty_chip(key: String, prefix: String = "Dificuldade") -> PanelContainer:
	var accent: Color = UiPalette.difficulty_color(key)
	var chip := PanelContainer.new()
	chip.add_theme_stylebox_override("panel", panel_style(UiPalette.with_alpha(UiPalette.CARD, 0.94), accent, 16, 2, 6))
	var pad := margin(16, 16, 4, 4)
	chip.add_child(pad)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	pad.add_child(row)
	row.add_child(label(prefix, 18, UiPalette.TEXT_MUTED))
	var pips := UiPips.new()
	pips.level = UiPalette.difficulty_level(key)
	pips.color = accent
	row.add_child(pips)
	row.add_child(label(ScoreManager.get_difficulty_label(key), 18, accent))
	return chip
