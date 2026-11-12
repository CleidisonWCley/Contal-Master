extends Control
## Tela de Loading do ContalMaster.
## - Fundo em degrade roxo/azul (so cores de UiPalette, nada pesado: esta tela precisa abrir NA HORA).
## - Engrenagem gira; o nucleo com o cifrao fica parado (duas camadas: Gear gira, Core nao).
## - Barra com trilho BRANCO e preenchimento ROXO + porcentagem.
## - Dica tematica que troca sozinha.
## - Funciona como main_scene (abre o menu) e como ponte para minigames/cutscenes (ver SceneLoader).
## - Se o carregamento falhar (ex.: web sem rede), mostra "Tentar novamente".

## Tempo minimo na tela: evita um "piscar" quando a cena ja carrega quase instantaneamente.
const MIN_SHOW_SECONDS := 0.55
## Velocidade maxima da barra (pontos de % por segundo). Suaviza saltos (ex.: web sem threads).
const BAR_SPEED := 150.0
const TIP_INTERVAL := 2.6
const SPIN_DEGREES_PER_SECOND := 140.0

const LOADING_TIPS: Array[String] = [
	"Carregando papéis de trabalho...",
	"Revisando as conformidades da NBC PA 11...",
	"Checando evidências nos papéis de trabalho...",
	"Aline está inspecionando o seu rigor normativo...",
	"Natalia está preparando os cenários do Desvio Lógico...",
	"Consultando as normas do CFC e CVM..."
]

## Vazio = usa SceneLoader.pending_scene; se tambem estiver vazio, abre o menu principal (primeira abertura).
@export_file("*.tscn") var scene_to_load: String = ""

@onready var background: TextureRect = %Background
@onready var gear: TextureRect = %Gear
@onready var status_label: Label = %StatusLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var percent_label: Label = %PercentLabel
@onready var error_buttons: HBoxContainer = %ErrorButtons
@onready var retry_button: Button = %RetryButton
@onready var back_button: Button = %BackButton
@onready var column: VBoxContainer = %VBoxContainer

var _path: String = ""
var _elapsed: float = 0.0
var _tip_timer: float = 0.0
var _tip_index: int = 0
var _shown_percent: float = 0.0
var _loading: bool = false
var _finished: bool = false
var _failed: bool = false
## V0.14.3: fila de carregamento = recursos pesados (pre-aquecimento) + a cena (SEMPRE o ultimo item).
var _items: Array[String] = []
var _item_index: int = 0
var _item_requested: bool = false
var _packed: PackedScene = null

func _ready() -> void:
	# Sobrevive a get_tree().paused (ex.: saiu de um minigame pausado).
	process_mode = Node.PROCESS_MODE_ALWAYS
	_path = scene_to_load if scene_to_load != "" else SceneLoader.take_pending()
	if _path == "":
		_path = Paths.SCENE_MAIN_MENU
	_build_style()
	_tip_index = randi() % LOADING_TIPS.size()
	status_label.text = LOADING_TIPS[_tip_index]
	retry_button.pressed.connect(_on_retry_pressed)
	back_button.pressed.connect(_on_back_pressed)
	gear.resized.connect(_update_pivot)
	_update_pivot()
	# Deixa 2 quadros desenharem a tela ANTES de iniciar o carregamento (que pode travar o thread principal na web).
	await get_tree().process_frame
	await get_tree().process_frame
	_notify_web_shell()
	_start_loading()

## V0.14.2 - Avisa o web/shell.html que esta tela JA foi desenhada: o overlay HTML (identico a esta tela)
## so some agora, sem "buraco" nem troca visual entre o shell e o jogo. Idempotente e inofensivo fora da web.
func _notify_web_shell() -> void:
	if not WebLite.is_web():
		return
	JavaScriptBridge.eval("if (window.cmShellReady) { window.cmShellReady(); }", true)

func _build_style() -> void:
	# Fundo: degrade vertical BG -> BG misturado com o roxo da marca.
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([UiPalette.BG, UiPalette.BG.lerp(UiPalette.PRIMARY, 0.30)])
	gradient.offsets = PackedFloat32Array([0.0, 1.0])
	var grad_tex := GradientTexture2D.new()
	grad_tex.gradient = gradient
	grad_tex.fill_from = Vector2(0.5, 0.0)
	grad_tex.fill_to = Vector2(0.5, 1.0)
	grad_tex.width = 8
	grad_tex.height = 256
	background.texture = grad_tex

	# Barra: trilho branco, preenchimento roxo.
	progress_bar.show_percentage = false
	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	progress_bar.value = 0.0
	var track := StyleBoxFlat.new()
	track.bg_color = Color.WHITE
	track.set_corner_radius_all(12)
	track.set_border_width_all(2)
	track.border_color = UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.55)
	track.set_content_margin_all(0)
	var fill := StyleBoxFlat.new()
	fill.bg_color = UiPalette.PRIMARY
	fill.set_corner_radius_all(12)
	fill.set_content_margin_all(0)
	progress_bar.add_theme_stylebox_override("background", track)
	progress_bar.add_theme_stylebox_override("fill", fill)

	# Textos
	status_label.add_theme_color_override("font_color", UiPalette.TEXT_ON_DARK)
	status_label.add_theme_font_size_override("font_size", UiPalette.FONT_BODY.x)
	percent_label.add_theme_color_override("font_color", UiPalette.TEXT_ON_DARK)
	percent_label.add_theme_font_size_override("font_size", UiPalette.FONT_VALUE.x)

	# Botoes do estado de erro
	ButtonStyles.apply(retry_button, "ui_primary", Vector2(220, 48), 18)
	ButtonStyles.apply(back_button, "ui_ghost", Vector2(220, 48), 18)

	# Em telas estreitas (celular na web) a coluna nao pode passar da largura da tela.
	var width: float = ScreenTools.get_viewport_size(self).x
	column.custom_minimum_size.x = clampf(width - 64.0, 280.0, 560.0)

func _update_pivot() -> void:
	gear.pivot_offset = gear.size * 0.5

func _start_loading() -> void:
	# V0.14.3: antes da cena, "aquece" (carrega) as imagens/musica pesadas que ela usaria no _ready,
	# UM recurso por quadro. A barra anda de verdade e nenhum quadro engole varios segundos de uma vez
	# (causa do "travou ao clicar em Continuar" em aparelhos de 4 GB, sobretudo na web sem threads).
	_items.clear()
	for warm_path in SceneLoader.take_pending_warm():
		var warm_str: String = str(warm_path)
		if warm_str != "" and warm_str != _path and not _items.has(warm_str) and ResourceLoader.exists(warm_str):
			_items.append(warm_str)
	_items.append(_path)
	_item_index = 0
	_item_requested = false
	_loading = true

func _process(delta: float) -> void:
	_elapsed += delta
	_spin(delta)
	_rotate_tip(delta)
	if not _loading or _finished or _failed:
		return

	var target_percent: float = _advance_loading()
	if _failed:
		return

	_shown_percent = move_toward(_shown_percent, target_percent, BAR_SPEED * delta)
	progress_bar.value = _shown_percent
	percent_label.text = "%d%%" % int(round(_shown_percent))

	if _packed != null and _shown_percent >= 100.0 and _elapsed >= MIN_SHOW_SECONDS:
		_finish()

## Avanca UM passo da fila por quadro e devolve o progresso alvo (0..100).
## Depois de cada ResourceLoader.load_threaded_request() devolvemos o controle ao motor: na web sem threads o
## pedido carrega o recurso inteiro na hora, e este "return" deixa o navegador desenhar um quadro entre um e outro.
func _advance_loading() -> float:
	if _packed != null:
		return 100.0
	var total: float = float(_items.size())
	var item: String = _items[_item_index]
	var is_scene: bool = _item_index == _items.size() - 1

	if not _item_requested:
		var err: Error = ResourceLoader.load_threaded_request(item)
		if err != OK:
			if is_scene:
				_fail("Não foi possível iniciar o carregamento (%s)." % error_string(err))
			else:
				_item_index += 1  # recurso de pre-aquecimento e opcional: segue sem ele
			return _shown_percent
		_item_requested = true
		return minf(float(_item_index) / total * 100.0, 99.0)

	var progress: Array = []
	var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(item, progress)
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		var fraction: float = float(progress[0]) if progress.size() > 0 else 0.0
		return minf((float(_item_index) + fraction) / total * 100.0, 99.0)

	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var loaded: Resource = ResourceLoader.load_threaded_get(item)
		if is_scene:
			_packed = loaded as PackedScene
			if _packed == null:
				_fail("A cena carregou, mas não pôde ser aberta.")
				return _shown_percent
			return 100.0
		SceneLoader.hold_warm(loaded)
		_item_index += 1
		_item_requested = false
		return minf(float(_item_index) / total * 100.0, 99.0)

	# FAILED ou INVALID_RESOURCE
	if is_scene:
		_fail("Não foi possível carregar o jogo. Verifique a conexão e tente de novo.")
	else:
		_item_index += 1
		_item_requested = false
	return _shown_percent

func _spin(delta: float) -> void:
	if has_node("/root/SettingsManager") and not SettingsManager.animations_enabled():
		return
	gear.rotation_degrees = fmod(gear.rotation_degrees + SPIN_DEGREES_PER_SECOND * delta, 360.0)

func _rotate_tip(delta: float) -> void:
	if _failed:
		return
	_tip_timer += delta
	if _tip_timer < TIP_INTERVAL:
		return
	_tip_timer = 0.0
	_tip_index = (_tip_index + 1) % LOADING_TIPS.size()
	var tween: Tween = create_tween()
	tween.tween_property(status_label, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func() -> void: status_label.text = LOADING_TIPS[_tip_index])
	tween.tween_property(status_label, "modulate:a", 1.0, 0.15)

func _finish() -> void:
	_finished = true
	set_process(false)
	if _packed == null:
		_fail("A cena carregou, mas não pôde ser aberta.")
		return
	get_tree().change_scene_to_packed(_packed)

func _fail(message: String) -> void:
	_failed = true
	_loading = false
	push_error("LoadingScreen: falha ao carregar %s" % _path)
	status_label.text = message
	status_label.modulate.a = 1.0
	percent_label.visible = false
	progress_bar.visible = false
	gear.pivot_offset = gear.size * 0.5
	error_buttons.visible = true
	# Se o que falhou foi o proprio menu, "Voltar ao menu" nao faz sentido.
	back_button.visible = _path != Paths.SCENE_MAIN_MENU
	retry_button.grab_focus()

func _on_retry_pressed() -> void:
	SceneLoader.pending_scene = _path
	get_tree().reload_current_scene()

func _on_back_pressed() -> void:
	GameManager.go_to_main_menu()
