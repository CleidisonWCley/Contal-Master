extends Control
class_name TrustCard
## V0.15.5 - Aviso COMPACTO de conquista de confianca (canto superior direito), mostrado pela StageDebrief (Modo Livre).
##   TrustCard.star(parent, id, stars)   -> "Conquista desbloqueada" com o rosto e as estrelas do personagem.
##   TrustCard.progress(parent, id)      -> mesmo aviso compacto, so com o nome e as estrelas atuais.
## Nao tem barra de progresso, nao cobre a tela e NAO precisa de clique: some sozinho depois de ~3,5 s.
## Nunca captura o mouse/teclado, entao o jogador segue lendo a novel normalmente.
## Uso:  TrustCard.star(self, "anderson", 2)   (o sinal `closed` continua existindo, mas ninguem precisa esperar por ele)

signal closed

const SHOW_SECONDS: float = 3.5      # tempo total na tela (entrada + permanencia + saida)
const FADE_IN: float = 0.25
const FADE_OUT: float = 0.35
const FACE_SIZE: float = 52.0
const SCREEN_MARGIN: float = 16.0

var _mode: String = "star"
var _owner: String = ""
var _stars: int = 0
var _done: bool = false
var _panel: PanelContainer


static func star(parent: Node, character_id: String, stars: int) -> TrustCard:
	var card: TrustCard = TrustCard.new()
	card._mode = "star"
	card._owner = character_id
	card._stars = stars
	parent.add_child(card)
	return card


static func progress(parent: Node, character_id: String) -> TrustCard:
	var card: TrustCard = TrustCard.new()
	card._mode = "progress"
	card._owner = character_id
	card._stars = LoreManager.get_stars(character_id)
	parent.add_child(card)
	return card


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	z_index = 200
	mouse_filter = Control.MOUSE_FILTER_IGNORE   # nao bloqueia a novel
	set_process_input(false)

	# Ancora no canto superior direito; o painel cresce para a esquerda/baixo conforme o conteudo.
	var corner: MarginContainer = MarginContainer.new()
	corner.set_anchors_preset(Control.PRESET_FULL_RECT)
	corner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	corner.add_theme_constant_override("margin_left", int(SCREEN_MARGIN))
	corner.add_theme_constant_override("margin_right", int(SCREEN_MARGIN))
	corner.add_theme_constant_override("margin_top", int(SCREEN_MARGIN))
	corner.add_theme_constant_override("margin_bottom", int(SCREEN_MARGIN))
	add_child(corner)

	var align: VBoxContainer = VBoxContainer.new()
	align.mouse_filter = Control.MOUSE_FILTER_IGNORE
	corner.add_child(align)
	var row_holder: HBoxContainer = HBoxContainer.new()
	row_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row_holder.alignment = BoxContainer.ALIGNMENT_END
	align.add_child(row_holder)

	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_theme_stylebox_override("panel", UiKit.panel_style(UiPalette.CARD_RAISED, UiPalette.ACCENT_REWARDS, 14, 2, 8))
	row_holder.add_child(_panel)

	var pad: MarginContainer = UiKit.margin(10, 14, 8, 8)
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(pad)
	var row: HBoxContainer = HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 10)
	pad.add_child(row)

	var face: FaceAvatar = FaceAvatar.create(_owner, FACE_SIZE)
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(face)

	var col: VBoxContainer = VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 0)
	col.custom_minimum_size = Vector2(minf(190.0, maxf(120.0, get_viewport_rect().size.x - 130.0)), 0)
	row.add_child(col)

	var name_text: String = str(LoreManager.CHARACTER_NAMES.get(_owner, _owner.capitalize()))
	if _mode == "star":
		col.add_child(_ignore(UiKit.label("Conquista desbloqueada", 13, UiPalette.ACCENT_REWARDS)))
		col.add_child(_ignore(UiKit.label(name_text, 17, UiPalette.TEXT_ON_DARK)))
	else:
		col.add_child(_ignore(UiKit.label("Confiança", 13, UiPalette.TEXT_MUTED)))
		col.add_child(_ignore(UiKit.label(name_text, 17, UiPalette.TEXT_ON_DARK)))
	col.add_child(_ignore(UiKit.label(ArchiveArt.stars_text(_stars), 20, UiPalette.DIFF_NORMAL)))

	_play_lifetime()


## Entra deslizando da direita, fica parado e some com fade. Com animacoes desligadas, so aparece e some.
func _play_lifetime() -> void:
	if not _animations_enabled():
		get_tree().create_timer(SHOW_SECONDS).timeout.connect(_close)
		return
	_panel.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(_panel, "modulate:a", 1.0, FADE_IN)
	tween.tween_interval(maxf(SHOW_SECONDS - FADE_IN - FADE_OUT, 0.5))
	tween.tween_property(_panel, "modulate:a", 0.0, FADE_OUT)
	tween.finished.connect(_close)


func _ignore(control: Control) -> Control:
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return control


func _animations_enabled() -> bool:
	return not has_node("/root/SettingsManager") or SettingsManager.animations_enabled()


func _close() -> void:
	if _done:
		return
	_done = true
	closed.emit()
	queue_free()
