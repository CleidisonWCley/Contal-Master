extends RefCounted
class_name UiIcons
## Icones monocromaticos (brancos) do jogo. Substituem TODOS os emojis.
## Sao brancos de proposito: a cor vem do tema do botao (icon_normal_color) ou do modulate.
##   button.icon = UiIcons.texture("back")      |      UiIcons.make_rect("trophy", 40, UiPalette.ACCENT_REWARDS)

const PNG_ICONS := ["play", "settings", "exit", "trophy", "star"]  # demais sao .svg

# chave de minigame -> nome do icone
const MINIGAME_ICONS := {
	"show_do_bilhao": "dollar",
	"batalha_naval": "anchor",
	"maleta_certa": "briefcase",
	"roleta_risco": "roulette",
	"perseguicao": "danger",
	"forca_tecnica": "puzzle",
	"stop": "stop",
	"desvio_logico": "car"
}

static func path(icon_name: String) -> String:
	var ext: String = "png" if PNG_ICONS.has(icon_name) else "svg"
	return "%sicon_%s.%s" % [Paths.ICONS_UI_DIR, icon_name, ext]

static func texture(icon_name: String) -> Texture2D:
	return load(path(icon_name)) as Texture2D

static func for_minigame(minigame_key: String) -> String:
	return str(MINIGAME_ICONS.get(minigame_key, "star"))

## TextureRect pronto para uso em layouts (tamanho fixo, cor via modulate).
static func make_rect(icon_name: String, size_px: float, tint: Color = Color.WHITE) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = texture(icon_name)
	rect.custom_minimum_size = Vector2(size_px, size_px)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.modulate = tint
	return rect
