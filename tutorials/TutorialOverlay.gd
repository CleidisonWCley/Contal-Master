extends CanvasLayer
class_name TutorialOverlay
## UI REUTILIZAVEL de tutorial (V0.10). Uma unica cena para os 8 minigames.
##
## O que ela faz:
##  - escurece o jogo e abre um "foco" (spotlight) sobre o elemento REAL da interface que o passo
##    explica, com borda pulsante e seta apontando para ele (mesmo espirito do tutorial do Desvio
##    Logico, que ensina o jogador a mover o carro);
##  - mostra ate 2 personagens lado a lado (Jales + anfitriao do minigame). Quem esta falando fica
##    iluminado e em destaque; o outro escurece. Os retratos sao os sprites "_3" (recorte da cintura para cima) usados INTEIROS, sem recorte por codigo;
##  - cartao limpo (V0.12): nome do personagem e, logo abaixo, a fala com efeito de digitacao; Voltar / Proximo / Pular.
##    Sem etiqueta de tipo ("ESTRATEGIA", "COMO JOGAR"...) e sem titulo ao lado do nome.
##
## Dois modos:
##  - MODAL: bloqueia o jogo ate o jogador concluir ou pular (todos os minigames de pergunta).
##  - COACH: dica flutuante que NAO bloqueia nada (o Desvio Logico usa para a Natalia narrar por cima
##    do tutorial mecanico, enquanto o jogador pratica o desvio).
##
## Criar overlays diretamente nao e necessario: use TutorialManager.play(...) / create_overlay(...).

signal finished(completed: bool)
signal skip_requested
signal step_changed(step_index: int)

enum Mode { MODAL, COACH }

const LAYER_INDEX := 95  # acima do MinigamePause (90)
const TYPE_CHARS_PER_SECOND := 72.0
const SPOT_PADDING := 10.0
const NARROW_WIDTH := 760.0
const PORTRAIT_ASPECT := TutorialManager.BUST_ASPECT  # largura / altura do sprite "_3" (1664 x 2080)
## O sprite "_3" inteiro tem margem em cima; esta escala mantem o rosto do tamanho que o retrato recortado tinha.
const PORTRAIT_SCALE := 1.25
const DIM_COLOR := Color(0.035, 0.02, 0.08, 0.72)
const DIMMED_PORTRAIT := Color(0.34, 0.32, 0.44, 1.0)

var host: Node
var data: Dictionary = {}
var mode: int = Mode.MODAL
var options: Dictionary = {}
var steps: Array = []
var index: int = 0

var accent: Color = UiPalette.HIGHLIGHT
var host_id: String = ""
var partner_id: String = ""
var arrow_textures: Dictionary = {}

var _root: Control
var _canvas: Control
var _card: PanelContainer
var _margin: MarginContainer
var _name_label: Label
var _text_label: Label
var _counter_label: Label
var _back_button: Button
var _next_button: Button
var _skip_button: Button
var _portraits: Dictionary = {}

var _current_step: Dictionary = {}
var _speaker_id: String = ""
var _spot_target: Rect2 = Rect2()
var _spot_current: Rect2 = Rect2()
var _spot_has: bool = false
var _spot_outline: bool = true
var _anim_time: float = 0.0
var _card_y: float = 0.0
var _card_at_bottom: bool = true
var _type_tween: Tween
var _move_tween: Tween
var _closing: bool = false
var _built: bool = false

var _spot_style: StyleBoxFlat
var _ring_style: StyleBoxFlat


# ---------------------------------------------------------------- configuracao

## Chamado pelo TutorialManager ANTES de add_child.
func configure(host_node: Node, tutorial_data: Dictionary, overlay_mode: int, extra_options: Dictionary = {}) -> void:
	host = host_node
	data = tutorial_data
	mode = overlay_mode
	options = extra_options
	host_id = str(data.get("host", ""))
	partner_id = str(data.get("partner", ""))  # V0.10.1: tutorial tem so o anfitriao (Jales apresenta na novel)
	arrow_textures = options.get("arrow_textures", {})
	var host_info: Dictionary = TutorialManager.character(host_id)
	accent = host_info.get("color", UiPalette.HIGHLIGHT) as Color


func _ready() -> void:
	layer = LAYER_INDEX
	_build_ui()
	_built = true
	_layout()
	_root.resized.connect(_layout)
	_root.modulate.a = 0.0
	visible = false


## Inicia o tutorial MODAL com a lista de passos (ja filtrada pelo TutorialManager).
func start(step_list: Array) -> void:
	steps = step_list
	index = 0
	if steps.is_empty():
		close(false)
		return
	visible = true
	_apply_step(steps[0], true)
	_fade_to(1.0)
	step_changed.emit(0)


## Modo COACH: mostra (ou troca) a dica flutuante. Nao bloqueia o jogo.
func show_coach(step: Dictionary) -> void:
	if _closing:
		return
	visible = true
	_apply_step(step, true)
	_fade_to(1.0)


func hide_coach() -> void:
	if _closing or not _built:
		return
	_fade_to(0.0)


## True se o ponto (coordenadas da tela) esta sobre a interface do cartao. Quem le cliques em _input
## (Desvio Logico) usa para nao tratar o clique em "Pular" como movimento do carro.
func is_point_over_ui(point: Vector2) -> bool:
	if not _built or not visible or _root.modulate.a < 0.05:
		return false
	return Rect2(_card.position, _card.size).has_point(point)


func close(completed: bool = true) -> void:
	if _closing:
		return
	_closing = true
	if _root != null:
		_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	finished.emit(completed)
	if _root != null and _animations_enabled():
		var tween: Tween = create_tween()
		tween.tween_property(_root, "modulate:a", 0.0, 0.18)
		tween.tween_callback(queue_free)
	else:
		queue_free()


# ---------------------------------------------------------------- construcao da UI

func _build_ui() -> void:
	_root = Control.new()
	_root.name = "Root"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP if mode == Mode.MODAL else Control.MOUSE_FILTER_IGNORE
	_root.gui_input.connect(_on_root_gui_input)
	add_child(_root)

	_canvas = Control.new()
	_canvas.name = "SpotlightCanvas"
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.draw.connect(_on_canvas_draw)
	_root.add_child(_canvas)

	_spot_style = StyleBoxFlat.new()
	_spot_style.bg_color = Color(0, 0, 0, 0)
	_spot_style.set_border_width_all(3)
	_spot_style.set_corner_radius_all(12)
	_spot_style.shadow_size = 14
	_ring_style = StyleBoxFlat.new()
	_ring_style.bg_color = Color(0, 0, 0, 0)
	_ring_style.set_border_width_all(2)
	_ring_style.set_corner_radius_all(14)

	_card = PanelContainer.new()
	_card.name = "Card"
	_card.mouse_filter = Control.MOUSE_FILTER_STOP if mode == Mode.MODAL else Control.MOUSE_FILTER_IGNORE
	var card_style: StyleBoxFlat = StyleBoxFlat.new()
	card_style.bg_color = UiPalette.with_alpha(UiPalette.CARD, 0.95)
	card_style.border_color = accent
	card_style.set_border_width_all(3)
	card_style.set_corner_radius_all(22)
	card_style.shadow_color = Color(0, 0, 0, 0.45)
	card_style.shadow_size = 12
	_card.add_theme_stylebox_override("panel", card_style)
	_root.add_child(_card)

	_margin = MarginContainer.new()
	_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.add_child(_margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 6)
	_margin.add_child(box)

	var header: HBoxContainer = HBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_theme_constant_override("separation", 10)
	box.add_child(header)

	_name_label = Label.new()
	_name_label.add_theme_font_size_override("font_size", 20)
	_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(_name_label)

	_text_label = Label.new()
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_text_label.add_theme_color_override("font_color", UiPalette.TEXT_ON_DARK)
	_text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(_text_label)

	var footer: HBoxContainer = HBoxContainer.new()
	footer.add_theme_constant_override("separation", 10)
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(footer)

	_counter_label = Label.new()
	_counter_label.add_theme_font_size_override("font_size", 15)
	_counter_label.add_theme_color_override("font_color", UiPalette.TEXT_MUTED)
	_counter_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_counter_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	footer.add_child(_counter_label)

	_skip_button = Button.new()
	_skip_button.name = "SkipButton"
	_skip_button.text = "Pular"
	_skip_button.pressed.connect(_on_skip_pressed)
	footer.add_child(_skip_button)

	_back_button = Button.new()
	_back_button.name = "BackButton"
	_back_button.text = "Voltar"
	_back_button.pressed.connect(_go_back)
	footer.add_child(_back_button)

	_next_button = Button.new()
	_next_button.name = "NextButton"
	_next_button.text = "Próximo"
	_next_button.pressed.connect(_advance)
	footer.add_child(_next_button)

	if mode == Mode.COACH:
		_back_button.visible = false
		_next_button.visible = false
		_counter_label.visible = false

	# Retratos por ULTIMO: ficam na frente do cartao (cobrem as margens reservadas dele).
	for character_id in [partner_id, host_id]:
		if str(character_id) == "" or _portraits.has(character_id):
			continue
		var portrait: TextureRect = _make_portrait(str(character_id))
		if portrait != null:
			_portraits[str(character_id)] = portrait
			_root.add_child(portrait)


func _make_portrait(character_id: String) -> TextureRect:
	var texture: Texture2D = TutorialManager.sprite_texture(character_id, "v3")
	if texture == null:
		push_warning("TutorialOverlay: sprite '_3' nao encontrado para '%s'." % character_id)
		return null
	var rect: TextureRect = TextureRect.new()
	rect.name = "Portrait_%s" % character_id
	rect.texture = texture  # imagem COMPLETA: nenhum detalhe e cortado por codigo
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return rect


# ---------------------------------------------------------------- layout

func _layout(place: bool = true) -> void:
	if not _built or _root == null:
		return
	var view: Vector2 = _root.size
	if view.x <= 0.0 or view.y <= 0.0:
		view = ScreenTools.get_viewport_size(self)
	var compact: bool = ScreenTools.is_compact(self)
	var narrow: bool = view.x < NARROW_WIDTH
	var coach: bool = mode == Mode.COACH  # dica compacta: nao pode cobrir a pista
	var card_w: float = minf(view.x * 0.94, 820.0 if coach else 1060.0)
	var base_card_h: float = (140.0 if compact else 166.0) if coach else (166.0 if compact else 190.0)
	var portrait_w: float = (base_card_h + 34.0) * PORTRAIT_SCALE * PORTRAIT_ASPECT
	var shift: float = clampf((view.x - card_w) * 0.5, 0.0, 56.0)
	var reserve: float = 0.0 if narrow else maxf(portrait_w - shift - 2.0, 80.0)
	var text_size: int = 17 if compact else 21

	var has_partner: bool = partner_id != "" and partner_id != host_id and _portraits.has(partner_id)
	_margin.add_theme_constant_override("margin_left", (22 if (coach or not has_partner) else int(reserve) + 14))
	_margin.add_theme_constant_override("margin_right", int(reserve) + 14)
	_margin.add_theme_constant_override("margin_top", 12)
	_margin.add_theme_constant_override("margin_bottom", 10)
	_text_label.add_theme_font_size_override("font_size", text_size)
	_name_label.add_theme_font_size_override("font_size", 18 if compact else 20)
	_style_buttons(compact)
	# V0.11.1: a altura do cartao ACOMPANHA o texto (antes o cartao crescia e o retrato ficava preso na altura antiga).
	var card_h: float = _refit_card(view, card_w, base_card_h, text_size, compact, 22.0 if (coach or not has_partner) else reserve + 14.0, reserve + 14.0)
	if place:
		_place_card(_target_card_y(view, card_h), view, card_h, reserve, narrow, compact)


## Altura que o cartao precisa para mostrar nome + texto inteiro + botoes (minimo = altura base).
## Mede o texto com a fonte real, entao funciona antes do Godot recalcular o layout.
func _needed_card_height(card_w: float, base_h: float, text_size: int, compact: bool, margin_left: float, margin_right: float, view_h: float) -> float:
	var font: Font = _text_label.get_theme_font("font")
	var inner_w: float = maxf(card_w - 6.0 - margin_left - margin_right, 120.0)
	var text_h: float = 0.0
	if font != null and _text_label.text != "":
		text_h = font.get_multiline_string_size(_text_label.text, HORIZONTAL_ALIGNMENT_LEFT, inner_w, text_size).y + 4.0
	var name_h: float = (18.0 if compact else 20.0) + 12.0
	var buttons_h: float = 38.0 if compact else 44.0
	var needed: float = 12.0 + 10.0 + 6.0 + name_h + 6.0 + text_h + 6.0 + buttons_h
	return clampf(maxf(base_h, needed), base_h, view_h * 0.62)


## Aplica a altura certa ao cartao e devolve o valor. Chamado ao montar o layout e a CADA passo (texto novo).
func _refit_card(view: Vector2, card_w: float, base_h: float, text_size: int, compact: bool, margin_left: float, margin_right: float) -> float:
	var card_h: float = _needed_card_height(card_w, base_h, text_size, compact, margin_left, margin_right, view.y)
	_card.custom_minimum_size = Vector2(card_w, card_h)
	_card.size = Vector2(card_w, card_h)
	return card_h


func _style_buttons(compact: bool) -> void:
	var button_h: float = 38.0 if compact else 44.0
	var font_size: int = 15 if compact else 18
	ButtonStyles.apply(_next_button, "ui_primary", Vector2(128, button_h), font_size)
	ButtonStyles.apply(_back_button, "ui_ghost", Vector2(98, button_h), font_size)
	ButtonStyles.apply(_skip_button, "ui_ghost", Vector2(126, button_h), font_size - 2)


func _target_card_y(view: Vector2, card_h: float) -> float:
	var bottom_gap: float = 14.0 if ScreenTools.is_compact(self) else 24.0
	var top_gap: float = view.y * 0.105 if mode == Mode.COACH else (14.0 if ScreenTools.is_compact(self) else 22.0)
	if _current_step.has("card_y"):
		return view.y * clampf(float(_current_step["card_y"]), 0.0, 0.9)
	return view.y - card_h - bottom_gap if _card_at_bottom else top_gap


func _place_card(card_y: float, view: Vector2, card_h: float, reserve: float, narrow: bool, compact: bool) -> void:
	_card_y = card_y
	_card.position = Vector2((view.x - _card.size.x) * 0.5, card_y)
	# O retrato acompanha a altura REAL do cartao (card_h): sobe e desce junto, sempre apoiado na base dele.
	var base_portrait_h: float = (card_h + (34.0 if _card_at_bottom else -8.0)) * PORTRAIT_SCALE
	base_portrait_h = minf(base_portrait_h, card_y + card_h - 4.0)  # nunca sobe para fora da tela
	var shift: float = clampf(_card.position.x, 0.0, 56.0)
	for character_id in _portraits.keys():
		var portrait: TextureRect = _portraits[character_id] as TextureRect
		# V0.11.1: altura real de cada personagem (CharacterHeights), de forma suavizada nos retratos _3.
		var portrait_h: float = base_portrait_h * CharacterHeights.bust_scale(str(character_id))
		var portrait_w: float = portrait_h * PORTRAIT_ASPECT
		var left_x: float = _card.position.x - shift
		var right_x: float = _card.position.x + _card.size.x - portrait_w + shift
		var portrait_y: float = card_y + card_h - portrait_h - 4.0
		portrait.size = Vector2(portrait_w, portrait_h)
		portrait.pivot_offset = Vector2(portrait_w * 0.5, portrait_h)
		portrait.position = Vector2(left_x if character_id == partner_id and character_id != host_id else right_x, portrait_y)
		if narrow:
			portrait.visible = false


func _move_card(at_bottom: bool, animate: bool, force: bool = false) -> void:
	if not force and at_bottom == _card_at_bottom and _card_y != 0.0 and not _current_step.has("card_y") and absf(_card_y - _target_card_y(_root.size, _card.size.y)) < 1.0:
		return
	_card_at_bottom = at_bottom
	var view: Vector2 = _root.size
	var card_h: float = _card.size.y
	var target_y: float = _target_card_y(view, card_h)
	var reserve: float = 0.0
	if _move_tween != null and _move_tween.is_valid():
		_move_tween.kill()
	if animate and _animations_enabled() and _card_y != 0.0:
		var from_y: float = _card_y
		_move_tween = create_tween()
		_move_tween.tween_method(func(value: float) -> void:
			_place_card(value, view, card_h, reserve, view.x < NARROW_WIDTH, ScreenTools.is_compact(self)), from_y, target_y, 0.24).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	else:
		_place_card(target_y, view, card_h, reserve, view.x < NARROW_WIDTH, ScreenTools.is_compact(self))


# ---------------------------------------------------------------- passos

func _apply_step(step: Dictionary, animate: bool) -> void:
	_current_step = step
	var speaker: String = str(step.get("speaker", host_id))
	_speaker_id = speaker
	var speaker_info: Dictionary = TutorialManager.character(speaker)
	var speaker_color: Color = speaker_info.get("color", accent) as Color

	_name_label.text = str(speaker_info.get("name", speaker.capitalize()))
	_name_label.add_theme_color_override("font_color", speaker_color)

	_text_label.text = str(step.get("text", ""))
	_start_typing()

	if mode == Mode.MODAL:
		_counter_label.text = "Passo %d de %d   •   Enter ou clique para continuar" % [index + 1, steps.size()]
		_back_button.visible = index > 0
		var last_step: bool = index >= steps.size() - 1
		_next_button.text = str(step.get("next_label", data.get("cta", "Começar") if last_step else "Próximo"))
	# "Pular" (padrao) ou o rotulo do passo (ex.: "Continuar" na explicacao das rotas do Desvio Logico).
	# Na campanha, quem joga pela 1a vez nao pode pular: o botao some (passos com skip_label sempre aparecem).
	_skip_button.text = str(step.get("skip_label", "Pular"))
	_skip_button.visible = _skip_allowed()

	_update_portraits(step, animate)
	_resolve_spot(true)
	var side: String = str(step.get("card", "auto"))
	var at_bottom: bool = _card_at_bottom
	match side:
		"top":
			at_bottom = false
		"bottom":
			at_bottom = true
		_:
			if _spot_has:
				at_bottom = _spot_target.get_center().y < _root.size.y * 0.52
	var height_before: float = _card.size.y
	_layout(false)  # recalcula so a ALTURA do cartao para o texto deste passo; _move_card reposiciona (com animacao)
	_move_card(at_bottom, animate, absf(_card.size.y - height_before) > 0.5)


func _update_portraits(step: Dictionary, animate: bool) -> void:
	var shown: Array = step.get("show", [])
	for character_id in _portraits.keys():
		var portrait: TextureRect = _portraits[character_id] as TextureRect
		var is_shown: bool = shown.is_empty() or shown.has(character_id)
		if mode == Mode.COACH:
			is_shown = character_id == host_id
		var speaking: bool = character_id == _speaker_id
		var target_color: Color = Color.WHITE if speaking else DIMMED_PORTRAIT
		target_color.a = 1.0 if is_shown else 0.0
		var target_scale: Vector2 = Vector2.ONE if speaking else Vector2(0.92, 0.92)
		if animate and _animations_enabled():
			var tween: Tween = create_tween().set_parallel(true)
			tween.tween_property(portrait, "modulate", target_color, 0.22)
			tween.tween_property(portrait, "scale", target_scale, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		else:
			portrait.modulate = target_color
			portrait.scale = target_scale


func _start_typing() -> void:
	if _type_tween != null and _type_tween.is_valid():
		_type_tween.kill()
	if not _animations_enabled():
		_text_label.visible_ratio = 1.0
		return
	_text_label.visible_ratio = 0.0
	var duration: float = clampf(float(_text_label.text.length()) / TYPE_CHARS_PER_SECOND, 0.25, 3.2)
	_type_tween = create_tween()
	_type_tween.tween_property(_text_label, "visible_ratio", 1.0, duration)


func _is_typing() -> bool:
	return _type_tween != null and _type_tween.is_valid() and _text_label.visible_ratio < 1.0


func _advance() -> void:
	if _closing or mode != Mode.MODAL:
		return
	_click_sound()
	if _is_typing():
		_type_tween.kill()
		_text_label.visible_ratio = 1.0
		return
	if index >= steps.size() - 1:
		close(true)
		return
	index += 1
	_apply_step(steps[index], true)
	step_changed.emit(index)


func _go_back() -> void:
	if _closing or mode != Mode.MODAL or index <= 0:
		return
	_click_sound()
	index -= 1
	_apply_step(steps[index], true)
	step_changed.emit(index)


func _on_skip_pressed() -> void:
	_click_sound()
	_request_skip()


func _skip_allowed() -> bool:
	if _current_step.has("skip_label"):
		return true
	return TutorialManager.can_skip(host)


func _request_skip() -> void:
	if not _skip_allowed():
		return
	skip_requested.emit()
	if mode == Mode.MODAL:
		close(false)


# ---------------------------------------------------------------- entrada

func _input(event: InputEvent) -> void:
	if _closing or mode != Mode.MODAL or not visible:
		return
	if event is InputEventKey and (event as InputEventKey).pressed:
		var key_event: InputEventKey = event as InputEventKey
		if not key_event.echo:
			match key_event.keycode:
				KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_RIGHT:
					_advance()
				KEY_LEFT, KEY_BACKSPACE:
					_go_back()
				KEY_ESCAPE:
					_request_skip()
		# Durante o tutorial NENHUMA tecla chega ao jogo (ex.: letras da Forca, A-D do Show do Bilhao).
		get_viewport().set_input_as_handled()


func _on_root_gui_input(event: InputEvent) -> void:
	if mode != Mode.MODAL or _closing:
		return
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_advance()


# ---------------------------------------------------------------- foco (spotlight)

func _process(delta: float) -> void:
	if not _built or not visible:
		return
	_anim_time += delta
	_resolve_spot(false)
	if _spot_has:
		var weight: float = clampf(delta * 11.0, 0.0, 1.0)
		if _spot_current.size == Vector2.ZERO:
			_spot_current = _spot_target
		else:
			_spot_current = Rect2(_spot_current.position.lerp(_spot_target.position, weight), _spot_current.size.lerp(_spot_target.size, weight))
	_canvas.queue_redraw()


func _resolve_spot(snap: bool) -> void:
	var rects: Array[Rect2] = []
	for target_name in _current_step.get("targets", []):
		_collect_rects(host.get(str(target_name)) if host != null else null, rects)
	if rects.is_empty() and _current_step.has("target_rect"):
		var norm: Array = _current_step.get("target_rect", [])
		if norm.size() == 4:
			var view: Vector2 = _root.size
			rects.append(Rect2(float(norm[0]) * view.x, float(norm[1]) * view.y, float(norm[2]) * view.x, float(norm[3]) * view.y))
	_spot_outline = bool(_current_step.get("outline", true))
	if rects.is_empty():
		_spot_has = false
		_spot_current = Rect2()
		return
	var union: Rect2 = rects[0]
	for i in range(1, rects.size()):
		union = union.merge(rects[i])
	_spot_target = union
	_spot_has = true
	if snap or _spot_current.size == Vector2.ZERO:
		_spot_current = union


func _collect_rects(value: Variant, out: Array[Rect2]) -> void:
	if value is Control:
		var control: Control = value as Control
		if control.is_visible_in_tree() and control.size.x > 1.0 and control.size.y > 1.0:
			out.append(control.get_global_rect())
	elif value is Array:
		for item in value:
			_collect_rects(item, out)


func _on_canvas_draw() -> void:
	var view: Vector2 = _canvas.size
	if view.x <= 0.0 or view.y <= 0.0:
		return
	var pulse: float = 0.5 + 0.5 * sin(_anim_time * 4.2)
	var spot: Rect2 = _spot_current.grow(SPOT_PADDING).intersection(Rect2(Vector2.ZERO, view)) if _spot_has else Rect2()

	if mode == Mode.MODAL:
		if _spot_has and spot.size.x > 4.0 and spot.size.y > 4.0:
			_canvas.draw_rect(Rect2(0.0, 0.0, view.x, spot.position.y), DIM_COLOR)
			_canvas.draw_rect(Rect2(0.0, spot.end.y, view.x, view.y - spot.end.y), DIM_COLOR)
			_canvas.draw_rect(Rect2(0.0, spot.position.y, spot.position.x, spot.size.y), DIM_COLOR)
			_canvas.draw_rect(Rect2(spot.end.x, spot.position.y, view.x - spot.end.x, spot.size.y), DIM_COLOR)
		else:
			_canvas.draw_rect(Rect2(Vector2.ZERO, view), DIM_COLOR)

	if not _spot_has or spot.size.x <= 4.0 or spot.size.y <= 4.0:
		return
	if _spot_outline:
		_spot_style.border_color = Color(accent.r, accent.g, accent.b, 0.78 + 0.22 * pulse)
		_spot_style.shadow_color = Color(accent.r, accent.g, accent.b, 0.20 + 0.20 * pulse)
		_canvas.draw_style_box(_spot_style, spot)
		var ring_t: float = fposmod(_anim_time * 0.85, 1.0)
		_ring_style.border_color = Color(accent.r, accent.g, accent.b, (1.0 - ring_t) * 0.55)
		_canvas.draw_style_box(_ring_style, spot.grow(ring_t * 22.0))
	var example: Rect2 = _resolve_pointer_rect()
	if example.size.x > 1.0:
		_draw_example_target(example, view, pulse)
	else:
		_draw_pointer(spot, view, pulse, accent)


## Area de EXEMPLO (ex.: a celula D3 da Batalha Naval): pisca em vermelho e recebe uma seta grande.
func _resolve_pointer_rect() -> Rect2:
	var target: Variant = _current_step.get("pointer_target", null)
	if target == null or host == null:
		return Rect2()
	var member: String = ""
	var item_index: int = -1
	if target is Dictionary:
		member = str((target as Dictionary).get("member", ""))
		item_index = int((target as Dictionary).get("index", -1))
	else:
		member = str(target)
	var value: Variant = host.get(member)
	if value is Array and item_index >= 0 and item_index < (value as Array).size():
		value = (value as Array)[item_index]
	if value is Control:
		var control: Control = value as Control
		if control.is_visible_in_tree() and control.size.x > 1.0:
			return control.get_global_rect()
	return Rect2()


func _example_color() -> Color:
	return Color(str(_current_step.get("pointer_color", "#FF3B3B")))


func _draw_example_target(rect: Rect2, view: Vector2, pulse: float) -> void:
	var color: Color = _example_color()
	var blink: float = 0.5 + 0.5 * sin(_anim_time * 7.0)  # pisca forte
	var fill: Rect2 = rect.grow(2.0)
	_canvas.draw_rect(fill, Color(color.r, color.g, color.b, 0.12 + 0.38 * blink), true)
	_ring_style.border_color = Color(color.r, color.g, color.b, 0.55 + 0.45 * blink)
	_ring_style.set_border_width_all(4)
	_canvas.draw_style_box(_ring_style, rect.grow(5.0))
	_ring_style.set_border_width_all(2)
	_draw_pointer(rect.grow(5.0), view, pulse, color, true)


func _draw_pointer(spot: Rect2, view: Vector2, pulse: float, arrow_color: Color = Color.WHITE, force_auto: bool = false) -> void:
	var pointer: String = "auto" if force_auto else str(_current_step.get("pointer", "auto"))
	if pointer == "none":
		return
	if pointer == "arrow_left" or pointer == "arrow_right":
		var key: String = "left" if pointer == "arrow_left" else "right"
		var texture: Texture2D = arrow_textures.get(key, null) as Texture2D
		if texture != null:
			var arrow_size: Vector2 = Vector2(180.0, 54.0) * 1.28
			var bob: float = (-pulse if key == "left" else pulse) * 12.0
			var center: Vector2 = spot.get_center() + Vector2(bob, 0.0)
			_canvas.draw_texture_rect(texture, Rect2(center - arrow_size * 0.5, arrow_size), false)
		return
	# Seta "auto": parte da borda do foco que olha para o cartao e aponta para o elemento.
	if not force_auto and spot.get_area() > view.x * view.y * 0.5:
		return
	var card_center: Vector2 = _card.position + _card.size * 0.5
	var direction: Vector2 = card_center - spot.get_center()
	if direction.length() < 1.0:
		direction = Vector2.DOWN
	direction = direction.normalized()
	var half: Vector2 = spot.size * 0.5
	var t_x: float = half.x / maxf(absf(direction.x), 0.0001)
	var t_y: float = half.y / maxf(absf(direction.y), 0.0001)
	var edge: Vector2 = spot.get_center() + direction * minf(t_x, t_y)
	var tip: Vector2 = edge + direction * (6.0 + pulse * 12.0)
	var side: Vector2 = Vector2(-direction.y, direction.x)
	var scale_up: float = 1.35 if force_auto else 1.0
	var base: Vector2 = tip + direction * 34.0 * scale_up
	var points: PackedVector2Array = PackedVector2Array([tip, base + side * 20.0 * scale_up, base - side * 20.0 * scale_up])
	_canvas.draw_line(base, base + direction * 30.0 * scale_up, arrow_color, 9.0 * scale_up)
	_canvas.draw_colored_polygon(points, arrow_color)
	_canvas.draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[0]]), UiPalette.TEXT_ON_DARK, 2.0)


# ---------------------------------------------------------------- utilidades

func _fade_to(alpha: float) -> void:
	if not _built:
		return
	if _animations_enabled():
		var tween: Tween = create_tween()
		tween.tween_property(_root, "modulate:a", alpha, 0.2)
	else:
		_root.modulate.a = alpha


func _animations_enabled() -> bool:
	return host == null or not host.has_node("/root/SettingsManager") or SettingsManager.animations_enabled()


func _click_sound() -> void:
	if host != null and host.has_node("/root/AudioManager"):
		AudioManager.play_click()
