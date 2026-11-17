extends Node
class_name TouchScroll
## V0.15.6 - Rolagem por TOQUE (celular, tablet, qualquer tela touch) para um ScrollContainer.
##
## POR QUE EXISTE: os cartoes/paineis das telas novas (Perfis da Equipe, Arquivos da Firma, Conquistas...) sao
## PanelContainer/Button com mouse_filter STOP. Eles "engolem" o toque antes do ScrollContainer, entao arrastar o
## dedo sobre um cartao nao rolava nada (so a barrinha de rolagem, que ninguem acerta com o dedo).
##
## COMO FUNCIONA: escuta o toque cru em _input (antes de qualquer botao/painel), entao nao depende de mouse_filter.
##   - toque curto (sem arrastar) continua sendo um CLIQUE normal no botao;
##   - arrastou alem da zona morta -> rola o conteudo, com inercia ao soltar, e CANCELA o clique do botao que estava
##     sob o dedo (rolar nao abre ficha nem seleciona personagem sem querer).
##   - mouse de PC nao e afetado (roda do mouse e barra continuam nativos). So reage a InputEventScreenTouch/Drag.
##
## USO (uma linha por tela):   TouchScroll.attach(meu_scroll_container)

const DEADZONE: float = 12.0          # px (do viewport) antes de virar "arrastar"
const FRICTION: float = 5.5           # quanto maior, mais rapido a inercia para
const MIN_FLING_SPEED: float = 140.0  # px/s abaixo disso nao ha inercia
const MAX_FLING_SPEED: float = 4200.0
const FAR_AWAY: Vector2 = Vector2(-90000.0, -90000.0)
const FAKE_META: StringName = &"touchscroll_fake"

var _scroll: ScrollContainer
var _index: int = -1
var _start: Vector2 = Vector2.ZERO
var _dragging: bool = false
var _pos: float = 0.0                 # posicao em float (scroll_vertical e inteiro)
var _velocity: float = 0.0            # px/s
var _fling: bool = false
var _last_ms: int = 0


static func attach(scroll: ScrollContainer) -> TouchScroll:
	if scroll == null:
		return null
	for child in scroll.get_children():
		if child is TouchScroll:
			return child as TouchScroll
	var helper: TouchScroll = TouchScroll.new()
	helper.name = "TouchScroll"
	helper._scroll = scroll
	scroll.add_child(helper)
	return helper


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(false)
	if _scroll == null and get_parent() is ScrollContainer:
		_scroll = get_parent() as ScrollContainer


func _max_scroll() -> float:
	var bar: VScrollBar = _scroll.get_v_scroll_bar()
	return maxf(0.0, bar.max_value - bar.page)


func _input(event: InputEvent) -> void:
	if _scroll == null or not is_instance_valid(_scroll) or event.has_meta(FAKE_META):
		return   # evento sintetico nosso: nao tratar

	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed:
			if _index == -1 and _scroll.is_visible_in_tree() and _scroll.get_global_rect().has_point(touch.position):
				_index = touch.index
				_start = touch.position
				_dragging = false
				_fling = false
				set_process(false)
				_pos = float(_scroll.scroll_vertical)
				_velocity = 0.0
				_last_ms = Time.get_ticks_msec()
		elif touch.index == _index:
			_finish()
		return

	if event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event as InputEventScreenDrag
		if drag.index != _index:
			return
		if not _dragging:
			if absf(drag.position.y - _start.y) < DEADZONE:
				return
			_begin_drag()
		var max_scroll: float = _max_scroll()
		_pos = clampf(_pos - drag.relative.y, 0.0, max_scroll)
		_scroll.scroll_vertical = int(roundf(_pos))
		var now: int = Time.get_ticks_msec()
		var dt: float = maxf(float(now - _last_ms) / 1000.0, 0.001)
		_last_ms = now
		var instant: float = -drag.relative.y / dt
		_velocity = lerpf(_velocity, instant, 0.35)
		get_viewport().set_input_as_handled()   # o ScrollContainer nativo nao rola em dobro
		return

	# Toque tambem gera mouse "emulado". Durante o arraste ele nao pode chegar aos botoes.
	if _dragging and event is InputEventMouse and event.device == InputEvent.DEVICE_ID_EMULATION:
		get_viewport().set_input_as_handled()


func _begin_drag() -> void:
	_dragging = true
	# O botao sob o dedo ja recebeu o "apertou". Mandamos o mouse para longe: ele entende que o dedo saiu de cima
	# e NAO dispara o clique na soltura. Eventos sinteticos sao marcados para nao serem tratados por nos.
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = FAR_AWAY
	motion.global_position = FAR_AWAY
	motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	motion.set_meta(FAKE_META, true)
	Input.parse_input_event(motion)


func _finish() -> void:
	var was_dragging: bool = _dragging
	_index = -1
	_dragging = false
	if was_dragging:
		var release: InputEventMouseButton = InputEventMouseButton.new()
		release.button_index = MOUSE_BUTTON_LEFT
		release.pressed = false
		release.position = FAR_AWAY
		release.global_position = FAR_AWAY
		release.set_meta(FAKE_META, true)
		Input.parse_input_event(release)
		if absf(_velocity) >= MIN_FLING_SPEED and (Time.get_ticks_msec() - _last_ms) < 120:
			_velocity = clampf(_velocity, -MAX_FLING_SPEED, MAX_FLING_SPEED)
			_fling = true
			set_process(true)


func _process(delta: float) -> void:
	if not _fling or _scroll == null or not is_instance_valid(_scroll):
		set_process(false)
		return
	_pos = clampf(_pos + _velocity * delta, 0.0, _max_scroll())
	_scroll.scroll_vertical = int(roundf(_pos))
	_velocity *= exp(-FRICTION * delta)
	if absf(_velocity) < 12.0 or _pos <= 0.0 or _pos >= _max_scroll():
		_fling = false
		set_process(false)
