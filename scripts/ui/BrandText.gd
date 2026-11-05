extends RefCounted
## Marca do jogo: "Contal" em branco + "Master" em roxo (+ versao).
## As cores vem de UiPalette (BRAND_*). Para mudar o tom do roxo, edite la, nao aqui.
## Uso:  const BrandText := preload("res://scripts/ui/BrandText.gd")

static func _hex(c: Color) -> String:
	return "#" + c.to_html(false)


## "Contal Master" (ou "CONTAL MASTER") em BBCode, com as duas cores.
static func brand_bbcode(uppercase: bool = false) -> String:
	var contal: String = "CONTAL" if uppercase else "Contal"
	var master: String = "MASTER" if uppercase else "Master"
	return "[color=%s]%s[/color] [color=%s]%s[/color]" % [_hex(UiPalette.BRAND_CONTAL), contal, _hex(UiPalette.BRAND_MASTER), master]


## "Contal Master V0.9.2.1" em BBCode.
static func version_bbcode(version: String) -> String:
	return "%s [color=%s]V%s[/color]" % [brand_bbcode(false), _hex(UiPalette.BRAND_VERSION), version]


## Versao em texto simples (logs, fallback): "Contal Master V0.9.2.1".
static func version_plain(version: String) -> String:
	return "Contal Master V%s" % version


## RichTextLabel pronto para exibir BBCode da marca. align: "left", "center" ou "right".
## fit_content=true deixa a altura se ajustar ao texto (use em VBox/creditos).
static func make_label(body_bbcode: String, font_size: int, align: String = "left", fit_content: bool = false) -> RichTextLabel:
	var label: RichTextLabel = RichTextLabel.new()
	label.bbcode_enabled = true
	label.scroll_active = false
	label.fit_content = fit_content
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = "[%s]%s[/%s]" % [align, body_bbcode, align]
	set_font_size(label, font_size)
	label.add_theme_color_override("default_color", UiPalette.BRAND_CONTAL)
	label.add_theme_color_override("font_outline_color", UiPalette.BRAND_OUTLINE)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.82))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	return label


## RichTextLabel nao usa "font_size": os temas sao normal_font_size/bold_font_size.
static func set_font_size(label: RichTextLabel, font_size: int) -> void:
	label.add_theme_font_size_override("normal_font_size", font_size)
	label.add_theme_font_size_override("bold_font_size", font_size)
	label.add_theme_constant_override("outline_size", maxi(3, int(font_size / 6.0)))
