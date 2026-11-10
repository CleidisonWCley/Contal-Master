extends Control
## Transicao antes de cada minigame da campanha (V0.12).
##
## V0.11.1: cenario desfocado durante o titulo e a novel; novel com sprites "_1" (sem numero antes) em pe acima do quadro.
##
## Fluxo: [titulo no TOPO por ~5,5 s]  ->  novel narrativa (Jales + anfitriao)  ->  minigame.
##
## V0.12:
##  - titulo centralizado no TOPO da tela (antes ficava no meio) e por mais tempo (TITLE_SECONDS), para dar tempo de ler;
##  - removidos a "bola" pulsante no fundo e o tremor (escala do titulo, rotacao do icone): so o cenario, o titulo
##    e as particulas novas (TransitionFX: sem letras de TI);
##  - o som de fundo da transicao e a MUSICA do proprio minigame (AudioManager.PHASE_MUSIC), que segue sem corte
##    quando o minigame comeca;
##  - a novel usa os sprites "_3" inteiros, fundo desfocado e caixa de dialogo so com nome + fala.

const ICON_PATHS := {
	"show_do_bilhao": Paths.ICON_MONEY,
	"batalha_naval": Paths.ICON_NAVAL,
	"maleta_certa": Paths.ICON_SUITCASE,
	"roleta_risco": Paths.ICON_DANGER,
	"perseguicao": Paths.ICON_LOCK,
	"forca_tecnica": Paths.ICON_LOCK,
	"stop": Paths.ICON_STOP,
	"desvio_logico": Paths.ICON_PLAY
}

const STYLE_MAP := {
	"show_do_bilhao": {"bg": Color(0.025, 0.018, 0.080), "accent": Color(1.0, 0.82, 0.12), "secondary": Color(1.0, 0.52, 0.08)},
	"batalha_naval": {"bg": Color(0.015, 0.060, 0.170), "accent": Color(0.25, 0.78, 1.0), "secondary": Color(0.14, 0.42, 1.0)},
	"maleta_certa": {"bg": Color(0.110, 0.035, 0.020), "accent": Color(1.0, 0.66, 0.20), "secondary": Color(1.0, 0.28, 0.18)},
	"roleta_risco": {"bg": Color(0.105, 0.012, 0.155), "accent": Color(1.0, 0.35, 1.0), "secondary": Color(0.12, 0.16, 1.0)},
	"perseguicao": {"bg": Color(0.025, 0.025, 0.035), "accent": Color(1.0, 0.22, 0.18), "secondary": Color(0.12, 0.25, 1.0)},
	"forca_tecnica": {"bg": Color(0.010, 0.060, 0.085), "accent": Color(0.46, 1.0, 0.82), "secondary": Color(0.22, 0.64, 1.0)},
	"stop": {"bg": Color(0.018, 0.110, 0.040), "accent": Color(0.82, 1.0, 0.82), "secondary": Color(0.22, 0.72, 0.28)},
	"desvio_logico": {"bg": Color(0.020, 0.008, 0.070), "accent": Color(0.0, 0.88, 1.0), "secondary": Color(1.0, 0.42, 0.05)}
}

const TITLE_SECONDS := 5.5         # tempo do cartao de titulo antes da novel (5 a 6 s para dar tempo de ler)
const CAN_CONTINUE_SECONDS := 1.6  # a partir daqui um clique adianta o titulo (antes disso evita pular sem querer)
## Zoom lento do cenario por segundo (0 = cenario parado). Sem pulsos nem rotacao.
const BACKGROUND_DRIFT_PER_SECOND := 0.004
const BACKGROUND_DRIFT_MAX := 0.045

var elapsed: float = 0.0
var can_continue: bool = false
var started: bool = false
var novel_started: bool = false
var title_center: CenterContainer
var novel: NovelStage
var phase_info: Dictionary = {}
var phase_key: String = "show_do_bilhao"

var background_image: TextureRect
var background_shade: ColorRect
var blur_layer: ColorRect
var day_banner: Label
var title_label: Label
var score_label: Label
var stage_label: Label
var icon_rect: TextureRect
var fade_rect: ColorRect

func _ready() -> void:
	phase_info = GameManager.get_current_phase_info()
	phase_key = str(phase_info.get("key", "show_do_bilhao"))
	_build_scene()
	# Som da transicao = musica do proprio minigame (continua sem corte quando o minigame comeca).
	if has_node("/root/AudioManager"):
		AudioManager.play_music(AudioManager.music_key_for_phase(phase_key))
	_fade_from_black()
	_fade_in_title()
	NovelBlur.fade_in(blur_layer, 0.9)

func _process(delta: float) -> void:
	elapsed += delta
	_update_background_drift()
	if elapsed >= CAN_CONTINUE_SECONDS:
		can_continue = true
	if elapsed >= TITLE_SECONDS and not novel_started:
		_begin_novel()

func _input(event: InputEvent) -> void:
	if started:
		return
	# Durante a novel o proprio NovelStage trata clique/Espaco/Enter; aqui so sobra o Esc.
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		started = true
		GameManager.go_to_main_menu()
		return
	if novel_started:
		return
	# Cartao de titulo: um clique adianta a novel.
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if can_continue:
			_begin_novel()
	elif event is InputEventScreenTouch and event.pressed:
		if can_continue:
			_begin_novel()
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE, KEY_ENTER, KEY_KP_ENTER:
				if can_continue:
					_begin_novel()

func _animations_enabled() -> bool:
	return not has_node("/root/SettingsManager") or SettingsManager.animations_enabled()

func _build_scene() -> void:
	var bg_color: Color = _get_style_color("bg", Color(0.02, 0.02, 0.12))
	var accent: Color = _get_style_color("accent", Color(1.0, 0.84, 0.12))
	var secondary: Color = _get_style_color("secondary", accent.darkened(0.2))

	var background: ColorRect = ColorRect.new()
	background.name = "Background"
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.color = bg_color
	add_child(background)

	# Cada minigame tem o proprio cenario de novel (assets/background/cutcines/NN_*.png).
	background_image = TextureRect.new()
	background_image.name = "NovelBackground"
	background_image.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg_path: String = str(Paths.CUTSCENE_BG_BY_PHASE.get(phase_key, ""))
	if bg_path != "" and ResourceLoader.exists(bg_path):
		var bg_texture: Resource = load(bg_path)
		if bg_texture is Texture2D:
			background_image.texture = bg_texture as Texture2D
	else:
		push_warning("StageTransition: sem background de cutscene para '%s'." % phase_key)
	add_child(background_image)

	# Leve veu na cor do tema do minigame: mantem o titulo legivel sem esconder o cenario.
	background_shade = ColorRect.new()
	background_shade.name = "NovelBackgroundShade"
	background_shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background_shade.color = Color(bg_color.r, bg_color.g, bg_color.b, 0.34 if background_image.texture != null else 0.0)
	add_child(background_shade)

	# V0.11.1: cenario DESFOCADO enquanto o titulo (e depois a novel) esta na tela. Fica acima do cenario e do veu
	# e abaixo das particulas, do titulo e dos personagens.
	blur_layer = NovelBlur.create(1.0)
	blur_layer.name = "TransitionBlur"
	add_child(blur_layer)

	# Particulas novas (brilhos, bolhas e riscos de luz; sem letras). Ficam ATRAS do titulo e da novel.
	var fx: TransitionFX = TransitionFX.new()
	fx.name = "TransitionFX"
	fx.setup(phase_key, accent, secondary)
	add_child(fx)

	# Titulo centralizado no TOPO.
	var center: CenterContainer = CenterContainer.new()
	center.name = "TitleTop"
	center.set_anchors_preset(Control.PRESET_TOP_WIDE)
	var top_gap: float = ScreenTools.responsive_value(self, 26.0, 14.0)
	center.offset_top = top_gap
	center.offset_bottom = top_gap
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.z_index = 10
	add_child(center)
	title_center = center

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = ScreenTools.panel_size(self, Vector2(820, 0), Vector2(360, 0), 70.0, 70.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.02, 0.025, 0.055, 0.66), Color(accent.r, accent.g, accent.b, 0.74), 28, 2))
	center.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	var inner_margin: int = 20 if ScreenTools.is_compact(self) else 34
	margin.add_theme_constant_override("margin_left", inner_margin)
	margin.add_theme_constant_override("margin_top", 14 if ScreenTools.is_compact(self) else 20)
	margin.add_theme_constant_override("margin_right", inner_margin)
	margin.add_theme_constant_override("margin_bottom", 14 if ScreenTools.is_compact(self) else 20)
	panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 8 if ScreenTools.is_compact(self) else 12)
	margin.add_child(box)

	# Faixa "DIA 1 / DIA 2": so na transicao que ABRE um dia (Show do Bilhao e Desvio Logico).
	_build_day_banner(box, accent)

	stage_label = Label.new()
	stage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stage_label.text = _get_stage_header()
	stage_label.add_theme_font_size_override("font_size", ScreenTools.responsive_font(self, 26, 20))
	stage_label.add_theme_color_override("font_color", Color(0.82, 0.84, 0.92))
	box.add_child(stage_label)

	# Icone + nome da fase lado a lado (parados: sem rotacao nem pulso).
	var title_row: HBoxContainer = HBoxContainer.new()
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	title_row.add_theme_constant_override("separation", 16)
	box.add_child(title_row)

	icon_rect = TextureRect.new()
	icon_rect.custom_minimum_size = ScreenTools.responsive_size(self, Vector2(76, 76), Vector2(54, 54))
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var icon_path: String = str(ICON_PATHS.get(phase_key, ICON_PATHS["show_do_bilhao"]))
	var texture: Resource = load(icon_path)
	if texture is Texture2D:
		icon_rect.texture = texture as Texture2D
	title_row.add_child(icon_rect)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.text = str(phase_info.get("name", "Próxima Fase"))
	title_label.add_theme_font_size_override("font_size", ScreenTools.responsive_font(self, _get_title_font_size(), 32))
	title_label.add_theme_color_override("font_color", accent)
	title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.88))
	title_label.add_theme_constant_override("shadow_offset_x", 4)
	title_label.add_theme_constant_override("shadow_offset_y", 4)
	title_row.add_child(title_label)

	score_label = Label.new()
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.text = "Pontuação total: %s" % ScoreManager.get_score()
	score_label.add_theme_font_size_override("font_size", ScreenTools.responsive_font(self, 22, 17))
	score_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.92))
	score_label.add_theme_stylebox_override("normal", _make_panel_style(Color(0.0, 0.0, 0.0, 0.30), Color(secondary.r, secondary.g, secondary.b, 0.38), 14, 1))
	score_label.custom_minimum_size = ScreenTools.responsive_size(self, Vector2(340, 40), Vector2(260, 36))
	box.add_child(score_label)

	fade_rect = ColorRect.new()
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.color = Color(0.0, 0.0, 0.0, 1.0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.z_index = 100
	add_child(fade_rect)

func _build_day_banner(box: VBoxContainer, accent: Color) -> void:
	if not GameManager.is_first_phase_of_day(phase_key):
		return
	var day: int = GameManager.get_day_for_phase(phase_key)
	day_banner = Label.new()
	day_banner.name = "DayBanner"
	day_banner.text = str(GameManager.DAY_LABELS.get(day, "DIA %d" % day))
	day_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	day_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	day_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	day_banner.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	day_banner.custom_minimum_size = ScreenTools.responsive_size(self, Vector2(400, 46), Vector2(270, 40))
	day_banner.add_theme_font_size_override("font_size", ScreenTools.responsive_font(self, 26, 20))
	day_banner.add_theme_color_override("font_color", Color(1.0, 0.95, 0.78))
	day_banner.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
	day_banner.add_theme_constant_override("shadow_offset_x", 3)
	day_banner.add_theme_constant_override("shadow_offset_y", 3)
	day_banner.add_theme_stylebox_override("normal", _make_panel_style(Color(0.02, 0.025, 0.055, 0.78), Color(accent.r, accent.g, accent.b, 0.9), 24, 2))
	box.add_child(day_banner)

## Entrada suave do cartao de titulo (so transparencia: nada de escala, rotacao ou deslocamento).
func _fade_in_title() -> void:
	if title_center == null:
		return
	if not _animations_enabled():
		title_center.modulate.a = 1.0
		return
	title_center.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_interval(0.25)
	tween.tween_property(title_center, "modulate:a", 1.0, 0.7)

## Zoom lento e linear no cenario (sem pulso). Ajuste BACKGROUND_DRIFT_PER_SECOND = 0 para cenario parado.
func _update_background_drift() -> void:
	if background_image == null or background_image.texture == null:
		return
	if not _animations_enabled() or BACKGROUND_DRIFT_PER_SECOND <= 0.0:
		background_image.scale = Vector2.ONE
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	background_image.pivot_offset = viewport_size * 0.5
	var zoom: float = 1.0 + minf(elapsed * BACKGROUND_DRIFT_PER_SECOND, BACKGROUND_DRIFT_MAX)
	background_image.scale = Vector2(zoom, zoom)

## Depois do titulo, entra a novel narrativa: Jales apresenta o anfitriao do minigame.
func _begin_novel() -> void:
	if novel_started or started:
		return
	novel_started = true
	var frames: Array = _build_novel_frames()
	if frames.is_empty():
		can_continue = true
		_start_stage()
		return
	if title_center != null:
		var fade: Tween = create_tween()
		fade.tween_property(title_center, "modulate:a", 0.0, 0.35)
	novel = NovelStage.new()
	novel.z_index = 30
	add_child(novel)
	# Sprites "_1" (corpo inteiro, novels) em pe acima do quadro. O desfoque do cenario ja e da transicao (blur_layer),
	# entao o NovelStage nao aplica um segundo desfoque por cima ("blur": 0).
	novel.configure({"accent": _get_style_color("accent", Color(1.0, 0.84, 0.12)), "show_skip": true, "variant": "v1", "blur": 0.0})
	await get_tree().create_timer(0.3).timeout
	await novel.play_frames(frames)
	if not is_inside_tree():
		return
	can_continue = true
	_start_stage()

func _build_novel_frames() -> Array:
	var frames: Array = []
	var path: String = str(Paths.DIALOGUE_MINIGAMES.get(phase_key, ""))
	if path == "" or not FileAccess.file_exists(path):
		return frames
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary):
		return frames
	var data: Dictionary = parsed as Dictionary
	var host_name: String = str((data.get("character", {}) as Dictionary).get("name", "")).to_lower()
	var quadros: Array = data.get("presentation_dialogues", [])
	for i in range(quadros.size()):
		var quadro: Dictionary = quadros[i] as Dictionary
		var frame: Dictionary = {
			"speaker": str(quadro.get("speaker", "Jales")).to_lower(),
			"text": str(quadro.get("text", ""))
		}
		if i == 0:
			# Jales abre sozinho e o anfitriao SOBE na tela quando ele termina de apresenta-lo.
			frame["show"] = ["jales"]
			frame["enter_on_complete"] = [host_name]
		else:
			frame["show"] = ["jales", host_name]
		frames.append(frame)
	return frames

func _start_stage() -> void:
	if not can_continue or started:
		return
	started = true
	can_continue = false
	var tween: Tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0.0, 0.0, 0.0, 1.0), 0.28)
	await tween.finished
	if is_inside_tree():
		GameManager.start_current_campaign_stage()

func _fade_from_black() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0.0, 0.0, 0.0, 0.0), 0.35)

func _get_stage_header() -> String:
	var day: int = GameManager.get_day_for_phase(phase_key)
	if phase_key == "roleta_risco":
		return "DIA %d · RODADA BÔNUS" % day
	return "DIA %d · FASE %s/%s" % [day, GameManager.get_current_stage_number(), GameManager.get_total_stages()]

func _get_title_font_size() -> int:
	if phase_key == "show_do_bilhao":
		return 58
	if phase_key == "roleta_risco":
		return 56
	if phase_key == "desvio_logico":
		return 54
	return 60

func _get_style_color(field: String, fallback: Color) -> Color:
	var style: Dictionary = STYLE_MAP.get(phase_key, STYLE_MAP["show_do_bilhao"])
	var value: Variant = style.get(field, fallback)
	if value is Color:
		return value
	return fallback

func _make_panel_style(bg_color: Color, border_color: Color, radius: int = 14, border_width: int = 1) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.38)
	style.shadow_size = 14
	return style
