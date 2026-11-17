extends RefCounted
class_name ArchiveArt
## V0.15.2 - Pecas compartilhadas pelas telas dos Arquivos da Equipe (hub, Firma, Perfis e Ficha).

const MINIGAME_NAMES := {
	"show_do_bilhao": "Show do Bilhão", "batalha_naval": "Batalha Naval", "maleta_certa": "Maleta Certa",
	"roleta_risco": "Roleta de Risco", "perseguicao": "Perseguição", "forca_tecnica": "Força Técnica",
	"stop": "STOP", "desvio_logico": "Desvio Lógico"
}


## Retrato = quadrado do topo do sprite "_3" (busto), sem depender de arquivo novo.
static func portrait_texture(character_id: String) -> Texture2D:
	var texture: Texture2D = TutorialManager.sprite_texture(character_id, "v3")
	if texture == null:
		return null
	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.atlas = texture
	var size: Vector2 = texture.get_size()
	var side: float = minf(size.x, size.y) * 0.62
	atlas.region = Rect2((size.x - side) * 0.5, 0.0, side, side)
	return atlas


## Cenario cortado do minigame do personagem. Jales (sem estacao) usa o escritorio.
static func scene_texture(character_id: String) -> Texture2D:
	var station: String = LoreManager.station_of_character(character_id)
	var path: String = Paths.BG_CUT_00_ESCRITORIO
	if station != "":
		path = str(Paths.CUTSCENE_BG_BY_PHASE.get(station, Paths.BG_CUT_00_ESCRITORIO))
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D


static func minigame_name(character_id: String) -> String:
	var station: String = LoreManager.station_of_character(character_id)
	if station == "":
		return "A Jornada ContalMaster"
	return str(MINIGAME_NAMES.get(station, station.capitalize()))


static func minigame_icon(character_id: String) -> String:
	var station: String = LoreManager.station_of_character(character_id)
	return "flag" if station == "" else UiIcons.for_minigame(station)


static func stars_text(level: int) -> String:
	return "★".repeat(level) + "☆".repeat(3 - level)


## Faixa com o cenario do minigame do personagem. Quem ainda nao foi conhecido aparece bem escurecido.
static func make_banner(character_id: String, height: float, locked: bool) -> SceneBanner:
	var banner: SceneBanner = SceneBanner.new()
	banner.texture = scene_texture(character_id)
	banner.custom_minimum_size = Vector2(0, height)
	banner.dim_top = 0.28 if locked else 1.0
	banner.dim_bottom = 0.12 if locked else 0.42
	banner.focus_y = 0.62
	return banner


## Barra de progresso no estilo do jogo (valor / maximo).
static func make_progress(value: int, max_value: int, height: float = 12.0) -> ProgressBar:
	var bar: ProgressBar = ProgressBar.new()
	bar.min_value = 0.0
	bar.max_value = float(maxi(max_value, 1))
	bar.value = float(value)
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, height)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_theme_stylebox_override("background", UiKit.panel_style(UiPalette.CARD_RAISED, UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.35), 8, 1, 0))
	bar.add_theme_stylebox_override("fill", UiKit.panel_style(UiPalette.ACCENT_REWARDS, Color(0, 0, 0, 0), 8, 0, 0))
	return bar


## Alternador no topo das duas telas: [Arquivos da Firma | Perfis da Equipe]. "active" = "firma" ou "perfis".
static func make_switch(active: String) -> Control:
	var holder: CenterContainer = CenterContainer.new()
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	holder.add_child(row)
	var firma: Button = Button.new()
	firma.name = "SwitchFirma"
	firma.text = "Arquivos da Firma"
	firma.icon = UiIcons.texture("archive")
	var perfis: Button = Button.new()
	perfis.name = "SwitchPerfis"
	perfis.text = "Perfis da Equipe"
	perfis.icon = UiIcons.texture("team")
	for pair in [[firma, "firma"], [perfis, "perfis"]]:
		var button: Button = pair[0] as Button
		var is_active: bool = str(pair[1]) == active
		button.expand_icon = true
		button.toggle_mode = false
		ButtonStyles.apply(button, "ui_toggle_on" if is_active else "ui_ghost", Vector2(0, 44), 16)
		row.add_child(button)
	if active != "firma":
		firma.pressed.connect(GameManager.open_firma_archive)
	if active != "perfis":
		perfis.pressed.connect(GameManager.open_team_profiles)
	return holder
