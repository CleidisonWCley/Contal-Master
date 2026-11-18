extends Node
## V0.15.6 - Rolagem por TOQUE (celular/tablet) para TODA ScrollContainer do jogo (Arquivo da Equipe, Conquistas, Pontuacao...).
##
## Por que existe: o toque que comeca em cima de um cartao/botao (PanelContainer, Button = mouse_filter STOP) nao chega ate o
## ScrollContainer, entao arrastar o dedo nao rolava nada. Aqui escutamos o toque ANTES da interface (_input), medimos o
## arrasto dentro da area da lista e rolamos nos dois eixos que a lista permite, com inercia ao soltar.
##  - Toque curto (sem arrastar) continua sendo um clique normal nos botoes/cartoes.
##  - Ao passar do limiar de arrasto, o clique e cancelado (nao abre o perfil sem querer) e o botao volta ao normal.
##  - Mouse e roda do mouse seguem pelo comportamento nativo do Godot (nada muda no PC).
## Nenhuma tela precisa chamar nada: toda ScrollContainer nova e registrada automaticamente.

const DRAG_THRESHOLD: float = 10.0       # px antes de virar "arrasto"
const FRICTION: float = 4.5              # queda exponencial da inercia (1/s)
const MIN_VELOCITY: float = 40.0         # px/s abaixo disso a inercia para
const MAX_VELOCITY: float = 5000.0

var _scrolls: Array[ScrollContainer] = []
var _target: ScrollContainer = null
var _touch_index: int = -1
var _start_pos: Vector2 = Vector2.ZERO
var _dragging: bool = false
var _swallow_mouse_release: bool = false
var _velocity: Vector2 = Vector2.ZERO
var _last_msec: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().node_added.connect(_on_node_added)
	_register_existing(get_tree().root)


func _register_existing(node: Node) -> void:
	if node is ScrollContainer:
		_register(node as ScrollContainer)
	for child in node.get_children():
		_register_existing(child)


func _on_node_added(node: Node) -> void:
	if node is ScrollContainer:
		_register(node as ScrollContainer)


func _register(scroll: ScrollContainer) -> void:
	if not _scrolls.has(scroll):
		_scrolls.append(scroll)
		scroll.tree_exited.connect(_on_scroll_exited.bind(scroll))


func _on_scroll_exited(scroll: ScrollContainer) -> void:
	# tree_exited tambem dispara quando o no apenas sai da arvore (ex.: troca de aba); so descartamos se foi liberado.
	if not is_instance_valid(scroll) or scroll.is_queued_for_deletion():
		_scrolls.erase(scroll)
		if _target == scroll:
			_stop()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_on_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_on_drag(event as InputEventScreenDrag)
	elif _dragging and event is InputEventMouseMotion:
		get_viewport().set_input_as_handled()      # movimento "emulado" do toque: nao deve passar para a interface
	elif _swallow_mouse_release and event is InputEventMouseButton and not (event as InputEventMouseButton).pressed:
		_swallow_mouse_release = false
		get_viewport().set_input_as_handled()      # solta o dedo apos arrastar: nao dispara "pressed" no botao


func _on_touch(touch: InputEventScreenTouch) -> void:
	if touch.pressed:
		if _touch_index != -1:
			return                                   # so um dedo por vez
		var scroll: ScrollContainer = _find_scroll_at(touch.position)
		if scroll == null:
			return
		_target = scroll
		_touch_index = touch.index
		_start_pos = touch.position
		_dragging = false
		_velocity = Vector2.ZERO
		_last_msec = Time.get_ticks_msec()
	elif touch.index == _touch_index:
		if _dragging:
			_swallow_mouse_release = true            # a liberacao emulada do mouse vem logo em seguida
		else:
			_velocity = Vector2.ZERO
		_touch_index = -1
		if not _dragging:
			_target = null
		_dragging = false


func _on_drag(drag: InputEventScreenDrag) -> void:
	if drag.index != _touch_index or _target == null or not is_instance_valid(_target):
		return
	if not _dragging:
		if drag.position.distance_to(_start_pos) < DRAG_THRESHOLD:
			return
		_dragging = true
		_cancel_button_press()
	var now: int = Time.get_ticks_msec()
	var dt: float = maxf(float(now - _last_msec) / 1000.0, 0.001)
	_last_msec = now
	var delta_px: Vector2 = drag.relative
	_apply_scroll(_target, -delta_px)
	var instant: Vector2 = (-delta_px) / dt
	_velocity = _velocity.lerp(instant, 0.4).clampf(-MAX_VELOCITY, MAX_VELOCITY)
	get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	# Inercia depois de soltar o dedo.
	if _touch_index != -1 or _target == null:
		return
	if not is_instance_valid(_target) or _velocity.length() < MIN_VELOCITY:
		_stop()
		return
	_apply_scroll(_target, _velocity * delta)
	_velocity *= exp(-FRICTION * delta)


func _stop() -> void:
	_target = null
	_velocity = Vector2.ZERO


func _apply_scroll(scroll: ScrollContainer, amount: Vector2) -> void:
	if scroll.vertical_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED and absf(amount.y) > 0.0:
		scroll.scroll_vertical = int(roundf(float(scroll.scroll_vertical) + amount.y))
	if scroll.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED and absf(amount.x) > 0.0:
		scroll.scroll_horizontal = int(roundf(float(scroll.scroll_horizontal) + amount.x))


## A lista mais "funda" (mais interna) que contem o ponto e realmente tem o que rolar.
func _find_scroll_at(pos: Vector2) -> ScrollContainer:
	var best: ScrollContainer = null
	var best_depth: int = -1
	for scroll in _scrolls.duplicate():
		if not is_instance_valid(scroll) or not scroll.is_inside_tree():
			continue
		if not scroll.is_visible_in_tree() or not scroll.can_process():
			continue
		if not scroll.get_global_rect().has_point(pos):
			continue
		if not _can_scroll(scroll):
			continue
		var depth: int = scroll.get_path().get_name_count()
		if depth > best_depth:
			best = scroll
			best_depth = depth
	return best


func _can_scroll(scroll: ScrollContainer) -> bool:
	if scroll.vertical_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED:
		var vbar: VScrollBar = scroll.get_v_scroll_bar()
		if vbar.max_value - vbar.page > 1.0:
			return true
	if scroll.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED:
		var hbar: HScrollBar = scroll.get_h_scroll_bar()
		if hbar.max_value - hbar.page > 1.0:
			return true
	return false


## O toque ja "apertou" o botao sob o dedo; ao virar arrasto, devolvemos o botao ao estado normal (sem disparar o clique).
func _cancel_button_press() -> void:
	var viewport: Viewport = get_viewport()
	if viewport == null or not viewport.has_method("gui_get_hovered_control"):
		return
	var control: Control = viewport.call("gui_get_hovered_control") as Control
	var guard: int = 0
	while control != null and guard < 12:
		if control is BaseButton:
			# BaseButton zera o estado "pressionado" ao receber o inicio/fim de um arrasto do motor.
			control.notification(Control.NOTIFICATION_DRAG_BEGIN)
			control.notification(Control.NOTIFICATION_DRAG_END)
		var parent_node: Node = control.get_parent()
		control = parent_node as Control
		guard += 1
