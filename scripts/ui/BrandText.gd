extends RefCounted
## Marca do jogo: "Contal" em branco + "Master" em roxo, SEMPRE escrita junta: ContalMaster (+ versao).
## As cores vem de UiPalette (BRAND_*). Para mudar o tom do roxo, edite la, nao aqui.
## Uso:  const BrandText := preload("res://scripts/ui/BrandText.gd")
##
## >>> VERSAO DO JOGO: fonte unica = project.godot (config/version). DEFAULT_VERSION e so o reserva. <<<
## Ao subir de versao, altere os DOIS: project.godot e DEFAULT_VERSION abaixo.

const BRAND_NAME := "ContalMaster"
const DEFAULT_VERSION := "0.14.6"


## Versao atual do jogo (le project.godot; se faltar, usa DEFAULT_VERSION).
static func app_version() -> String:
	var configured: String = str(ProjectSettings.get_setting("application/config/version", ""))
	return configured if configured != "" else DEFAULT_VERSION

static func _hex(c: Color) -> String:
	return "#" + c.to_html(false)


## "ContalMaster" (ou "CONTALMASTER") em BBCode, com as duas cores e SEM espaco entre as partes.
static func brand_bbcode(uppercase: bool = false) -> String:
	var contal: String = "CONTAL" if uppercase else "Contal"
	var master: String = "MASTER" if uppercase else "Master"
	return "[color=%s]%s[/color][color=%s]%s[/color]" % [_hex(UiPalette.BRAND_CONTAL), contal, _hex(UiPalette.BRAND_MASTER), master]


## "ContalMaster V0.13.4" em BBCode. Sem argumento, usa a versao atual do jogo.
static func version_bbcode(version: String = "") -> String:
	var shown: String = version if version != "" else app_version()
	return "%s [color=%s]V%s[/color]" % [brand_bbcode(false), _hex(UiPalette.BRAND_VERSION), shown]


## Versao em texto simples (logs, fallback): "ContalMaster V0.13.4".
static func version_plain(version: String = "") -> String:
	var shown: String = version if version != "" else app_version()
	return "%s V%s" % [BRAND_NAME, shown]


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
