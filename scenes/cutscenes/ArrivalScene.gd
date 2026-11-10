extends Control
class_name ArrivalScene
## V0.13.2: cena de CHEGADA à sala de reunião (imagem 13_entrada_sala_reuniao.png).
##
## Fluxo (tudo em play()):
##   1) a tela está preta (o host acabou de sair do corredor) e surge uma PORTA fechada;
##   2) a porta ABRE (duas folhas deslizam, com brilho escapando pela fresta; com o som "porta", V0.13.4);
##   3) as LUZES SOBEM: a cena clareia, uma faixa de luz sobe pela tela e as luminárias acendem;
##   4) brilhos (partículas) flutuam ao redor durante toda a cena;
##   5) um CARD PEQUENO e transparente da Natalia surge suavemente e a frase é digitada.
##      Sem botão de continuar: clicar (ou Espaço/Enter) ACELERA a digitação; clicar de novo termina a frase;
##      com a frase completa, um clique encurta a pausa de leitura;
##   6) o card some PRIMEIRO; depois a cena escurece e play() retorna (a tela fica preta para o host seguir).
##
## Uso (CutsceneFinal):
##     var arrival := ArrivalScene.new()
##     add_child(arrival)
##     arrival.setup(texture, "Natalia", Color(...), "Chegamos! ...")
##     await arrival.play()      # ao retornar, a tela está preta
##
## Ajustes de ritmo/estética: constantes abaixo.

# ---- ritmo ----
const BLACK_HOLD_SECONDS := 0.30     # tela preta antes de a porta aparecer
const DOOR_APPEAR_SECONDS := 0.70    # porta fechada surgindo do preto
const DOOR_PAUSE_SECONDS := 0.35     # porta parada antes de abrir
const DOOR_OPEN_SECONDS := 1.90      # folhas deslizando
const LIGHTS_START_RATIO := 0.45     # as luzes comecam a subir quando a porta esta com 45% aberta
const LIGHTS_SECONDS := 2.20         # clareia + faixa de luz + luminarias
const CARD_FADE_IN_SECONDS := 0.85
const CARD_RISE_PIXELS := 16.0
const CARD_FADE_OUT_SECONDS := 0.60
const FADE_TO_BLACK_SECONDS := 0.95
const TYPE_CHARS_PER_SECOND := 34.0  # um pouco mais calmo que as novels (58)
const TYPE_FAST_MULTIPLIER := 5.0    # velocidade depois do 1o clique
const HOLD_MIN_SECONDS := 1.7        # leitura depois da frase completa
const HOLD_MAX_SECONDS := 4.2
const HOLD_PER_CHAR := 0.018
const CLICK_GUARD_SECONDS := 0.30    # ignora cliques colados (evita pular sem querer)

# ---- visual ----
const DIM_START := 0.14              # brilho da imagem quando a porta abre (1.0 = normal)
const SPARKLE_COUNT := 58
const SPARKLE_COLORS := [
	Color(1.00, 0.90, 0.62),   # dourado claro
	Color(1.00, 0.97, 0.88),   # branco quente
	Color(0.71, 0.42, 1.00),   # roxo da marca (#B66BFF)
	Color(0.19, 0.84, 0.82)    # ciano (#31D6D0)
]
## Luminarias do teto na imagem, como fracao da imagem (x, y). Se trocar a arte, ajuste aqui.
const LAMP_POINTS := [Vector2(0.287, 0.083), Vector2(0.504, 0.083), Vector2(0.709, 0.083)]
const LAMP_RADIUS_RATIO := 0.20      # raio do brilho da luminaria (fracao da altura da tela)
const DOOR_WOOD_DARK := Color(0.055, 0.035, 0.045)
const DOOR_WOOD_LIGHT := Color(0.15, 0.095, 0.10)
const LIGHT_WARM := Color(1.0, 0.80, 0.48)
## Card (pequeno e transparente: a cena inteira continua visivel)
const CARD_BG_ALPHA := 0.42
const CARD_WIDTH_RATIO := 0.46
const CARD_WIDTH_MIN := 380.0
const CARD_WIDTH_MAX := 660.0
const CARD_BOTTOM_MARGIN := 34.0

signal _typing_done
signal _hold_done

var _texture: Texture2D
var _speaker_name: String = "Natalia"
var _speaker_color: Color = Color(0.0, 0.88, 1.0)
var _text: String = ""

var _picture: TextureRect
var _lamp_layer: Control
var _lamps: Array[TextureRect] = []
var _band: TextureRect
var _sparkles: Control
var _spill: TextureRect
var _door_left: TextureRect
var _door_right: TextureRect
var _card_holder: Control
var _card: PanelContainer
var _name_label: Label
var _text_label: Label
var _blackout: ColorRect

var _door_amount: float = 0.0   # 0 fechada .. 1 aberta
var _light_amount: float = 0.0  # 0 escuro .. 1 aceso
var _sparkle_visibility: float = 0.0
var _particles: Array[Dictionary] = []
var _elapsed: float = 0.0

var _phase: String = "intro"    # intro | typing | hold | outro
var _typed: float = 0.0
var _fast: bool = false
var _hold_total: float = 0.0
var _hold_elapsed: float = 0.0
var _phase_time: float = 0.0
var _built: bool = false


func setup(texture: Texture2D, speaker_name: String, speaker_color: Color, text: String) -> void:
	_texture = texture
	_speaker_name = speaker_name
	_speaker_color = speaker_color
	_text = text
	if _built:  # setup() chamado depois do add_child(): atualiza o que ja foi construido
		_picture.texture = _texture
		_name_label.text = _speaker_name
		_name_label.add_theme_color_override("font_color", _speaker_color)
		_text_label.text = _text
		_layout()


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()
	resized.connect(_layout)
	_layout()


func _process(delta: float) -> void:
	_elapsed += delta
	_phase_time += delta
	if _animations_enabled() and _sparkles != null and _sparkle_visibility > 0.0:
		_update_particles(delta)
		_sparkles.queue_redraw()
	if _phase == "typing":
		_tick_typing(delta)
	elif _phase == "hold":
		_hold_elapsed += delta
		if _hold_elapsed >= _hold_total:
			_end_hold()


# ---------------------------------------------------------------- roteiro

func play() -> void:
	if not _built:
		_build()
	_phase = "intro"
	_text_label.visible_characters = 0
	_card_holder.modulate.a = 0.0
	_blackout.color.a = 1.0
	_apply_door(0.0)
	_apply_light(0.0)
	_sparkle_visibility = 0.0

	if not _animations_enabled():
		# Sem animacoes: porta aberta, cena acesa e o card ja no lugar.
		await _wait(0.25)
		_blackout.color.a = 0.0
		_apply_door(1.0)
		_apply_light(1.0)
		_card_holder.modulate.a = 1.0
	else:
		await _wait(BLACK_HOLD_SECONDS)
		var appear: Tween = create_tween()
		appear.tween_property(_blackout, "color:a", 0.0, DOOR_APPEAR_SECONDS)
		await appear.finished
		await _wait(DOOR_PAUSE_SECONDS)
		# Porta abre (V0.13.4: com o som da porta, ~2,5 s, alinhado a DOOR_OPEN_SECONDS); as luzes comecam a subir
		# quando ela esta quase na metade.
		if has_node("/root/AudioManager"):
			AudioManager.play_sfx("porta")
		var door: Tween = create_tween()
		door.tween_method(_apply_door, 0.0, 1.0, DOOR_OPEN_SECONDS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		await _wait(DOOR_OPEN_SECONDS * LIGHTS_START_RATIO)
		var lights: Tween = create_tween()
		lights.tween_method(_apply_light, 0.0, 1.0, LIGHTS_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		var sparkle: Tween = create_tween()
		sparkle.tween_property(self, "_sparkle_visibility", 1.0, LIGHTS_SECONDS)
		await lights.finished
		# Card: surge suavemente (fade + leve subida).
		_card_holder.position.y = CARD_RISE_PIXELS
		var card_in: Tween = create_tween().set_parallel(true)
		card_in.tween_property(_card_holder, "modulate:a", 1.0, CARD_FADE_IN_SECONDS)
		card_in.tween_property(_card_holder, "position:y", 0.0, CARD_FADE_IN_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		await card_in.finished

	if not is_inside_tree():
		return
	_sparkle_visibility = 1.0
	_begin_typing()
	# Sem animacoes a frase ja nasce completa (o sinal dispararia antes do await): so espera quem ainda nao terminou.
	if _phase == "typing":
		await _typing_done
	if _phase == "hold":
		await _hold_done
	await _outro()


func _begin_typing() -> void:
	_phase = "typing"
	_phase_time = 0.0
	_typed = 0.0
	_fast = false
	if not _animations_enabled() or _text.is_empty():
		_finish_typing()


func _tick_typing(delta: float) -> void:
	var speed: float = TYPE_CHARS_PER_SECOND * (TYPE_FAST_MULTIPLIER if _fast else 1.0)
	_typed += speed * delta
	var total: int = _text.length()
	_text_label.visible_characters = mini(int(_typed), total)
	if int(_typed) >= total:
		_finish_typing()


func _finish_typing() -> void:
	if _phase != "typing":
		return
	_text_label.visible_characters = -1
	_phase = "hold"
	_phase_time = 0.0
	_hold_elapsed = 0.0
	_hold_total = clampf(HOLD_MIN_SECONDS + float(_text.length()) * HOLD_PER_CHAR, HOLD_MIN_SECONDS, HOLD_MAX_SECONDS)
	_typing_done.emit()


func _end_hold() -> void:
	if _phase != "hold":
		return
	_phase = "outro"
	_hold_done.emit()


## O card some PRIMEIRO; so depois a cena escurece. Ao retornar a tela esta preta.
func _outro() -> void:
	if not is_inside_tree():
		return
	if _animations_enabled():
		var card_out: Tween = create_tween()
		card_out.tween_property(_card_holder, "modulate:a", 0.0, CARD_FADE_OUT_SECONDS)
		await card_out.finished
		await _wait(0.25)
		var dark: Tween = create_tween()
		dark.tween_property(_blackout, "color:a", 1.0, FADE_TO_BLACK_SECONDS)
		await dark.finished
	else:
		_card_holder.modulate.a = 0.0
		_blackout.color.a = 1.0
	_sparkle_visibility = 0.0


func _wait(seconds: float) -> void:
	# Tween (e nao SceneTreeTimer): se a cena for liberada no meio (Esc), a espera simplesmente nao retoma.
	var tween: Tween = create_tween()
	tween.tween_interval(maxf(seconds, 0.01))
	await tween.finished


# ---------------------------------------------------------------- entrada

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	var pressed: bool = false
	if event is InputEventMouseButton:
		var mouse: InputEventMouseButton = event as InputEventMouseButton
		pressed = mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventScreenTouch:
		pressed = (event as InputEventScreenTouch).pressed
	elif event is InputEventKey:
		var key: InputEventKey = event as InputEventKey
		pressed = key.pressed and not key.echo and (key.keycode == KEY_SPACE or key.keycode == KEY_ENTER or key.keycode == KEY_KP_ENTER)
	if not pressed:
		return
	if _on_advance():
		get_viewport().set_input_as_handled()


## true se o clique foi consumido.
func _on_advance() -> bool:
	match _phase:
		"typing":
			if _phase_time < CLICK_GUARD_SECONDS:
				return true
			if has_node("/root/AudioManager"):
				AudioManager.play_click()
			if _fast:
				_typed = float(_text.length())  # 2o clique: termina a frase na hora
				_text_label.visible_characters = -1
				_finish_typing()
			else:
				_fast = true                     # 1o clique: acelera
			return true
		"hold":
			if _phase_time >= CLICK_GUARD_SECONDS:
				_end_hold()
			return true
	return true  # durante a abertura da porta o clique so e engolido (nao pula nada)


# ---------------------------------------------------------------- construcao

func _build() -> void:
	if _built:
		return
	_built = true

	_picture = TextureRect.new()
	_picture.name = "Picture"
	_picture.texture = _texture
	_picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_picture.set_anchors_preset(Control.PRESET_FULL_RECT)
	_picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_picture)

	# Brilho que escapa pela fresta da porta (atras das folhas).
	_spill = TextureRect.new()
	_spill.name = "DoorSpill"
	_spill.texture = _horizontal_glow_texture()
	_spill.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_spill.stretch_mode = TextureRect.STRETCH_SCALE
	_spill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_spill.material = _additive_material()
	_spill.modulate = Color(LIGHT_WARM.r, LIGHT_WARM.g, LIGHT_WARM.b, 0.0)
	add_child(_spill)

	# Faixa de luz que SOBE pela tela.
	_band = TextureRect.new()
	_band.name = "LightBand"
	_band.texture = _vertical_band_texture()
	_band.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_band.stretch_mode = TextureRect.STRETCH_SCALE
	_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_band.material = _additive_material()
	_band.modulate = Color(1, 1, 1, 0)
	add_child(_band)

	# Luminarias (acendem em sequencia).
	_lamp_layer = Control.new()
	_lamp_layer.name = "Lamps"
	_lamp_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_lamp_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_lamp_layer)
	var lamp_texture: GradientTexture2D = _radial_glow_texture()
	for _i in LAMP_POINTS.size():
		var lamp: TextureRect = TextureRect.new()
		lamp.texture = lamp_texture
		lamp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		lamp.stretch_mode = TextureRect.STRETCH_SCALE
		lamp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lamp.material = _additive_material()
		lamp.modulate = Color(1.0, 0.84, 0.55, 0.0)
		_lamp_layer.add_child(lamp)
		_lamps.append(lamp)

	# Brilhos flutuando (mistura aditiva).
	_sparkles = Control.new()
	_sparkles.name = "Sparkles"
	_sparkles.set_anchors_preset(Control.PRESET_FULL_RECT)
	_sparkles.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sparkles.material = _additive_material()
	_sparkles.draw.connect(_on_sparkles_draw)
	add_child(_sparkles)
	_reset_particles()

	# Porta (duas folhas).
	_door_left = _make_door_leaf(true)
	add_child(_door_left)
	_door_right = _make_door_leaf(false)
	add_child(_door_right)

	_build_card()

	_blackout = ColorRect.new()
	_blackout.name = "Blackout"
	_blackout.color = Color(0, 0, 0, 1)
	_blackout.set_anchors_preset(Control.PRESET_FULL_RECT)
	_blackout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_blackout)


func _build_card() -> void:
	_card_holder = Control.new()
	_card_holder.name = "CardHolder"
	_card_holder.set_anchors_preset(Control.PRESET_FULL_RECT)
	_card_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card_holder.modulate.a = 0.0
	add_child(_card_holder)

	_card = PanelContainer.new()
	_card.name = "Card"
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card_holder.add_child(_card)

	var margin: MarginContainer = MarginContainer.new()
	margin.name = "Margin"
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 4)
	margin.add_child(box)

	_name_label = Label.new()
	_name_label.text = _speaker_name
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name_label.add_theme_color_override("font_color", _speaker_color)
	_name_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.55))
	_name_label.add_theme_constant_override("outline_size", 4)
	box.add_child(_name_label)

	_text_label = Label.new()
	_text_label.text = _text
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.visible_characters = 0
	_text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_text_label.add_theme_color_override("font_color", Color(1.0, 0.98, 1.0))
	_text_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.65))
	_text_label.add_theme_constant_override("outline_size", 5)
	box.add_child(_text_label)


func _layout() -> void:
	if not _built:
		return
	var view: Vector2 = size
	if view.x <= 0.0 or view.y <= 0.0:
		view = Vector2(1280, 720)
	var compact: bool = ScreenTools.is_compact(self)

	# Card pequeno, centralizado embaixo.
	var width: float = clampf(view.x * (0.86 if compact else CARD_WIDTH_RATIO), CARD_WIDTH_MIN * 0.8, CARD_WIDTH_MAX)
	width = minf(width, view.x - 24.0)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.03, 0.09, CARD_BG_ALPHA)
	style.border_color = Color(_speaker_color.r, _speaker_color.g, _speaker_color.b, 0.60)
	style.set_border_width_all(1)
	style.set_corner_radius_all(16)
	style.shadow_color = Color(0, 0, 0, 0.25)
	style.shadow_size = 8
	_card.add_theme_stylebox_override("panel", style)
	var side: int = 18 if compact else 24
	var margin: MarginContainer = _card.get_node("Margin") as MarginContainer
	margin.add_theme_constant_override("margin_left", side)
	margin.add_theme_constant_override("margin_right", side)
	margin.add_theme_constant_override("margin_top", 11 if compact else 14)
	margin.add_theme_constant_override("margin_bottom", 12 if compact else 16)
	_name_label.add_theme_font_size_override("font_size", 17 if compact else 21)
	_text_label.add_theme_font_size_override("font_size", 17 if compact else 22)
	_card.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_card.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_card.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_card.offset_left = -width * 0.5
	_card.offset_right = width * 0.5
	_card.offset_bottom = -(CARD_BOTTOM_MARGIN * (0.7 if compact else 1.0))
	_card.offset_top = _card.offset_bottom - 2.0

	# Porta, brilho e luzes acompanham o tamanho da tela.
	_door_left.size = Vector2(view.x * 0.5, view.y)
	_door_right.size = Vector2(view.x * 0.5, view.y)
	_spill.size = Vector2(view.x * 0.55, view.y)
	_band.size = Vector2(view.x, view.y * 0.85)
	_layout_lamps(view)
	_apply_door(_door_amount)
	_apply_light(_light_amount)
	_reset_particles()


## Posicao de um ponto da imagem (fracao x, y) na tela, respeitando o modo "cobrir" do fundo.
func _image_point_to_screen(fraction: Vector2, view: Vector2) -> Vector2:
	if _texture == null:
		return Vector2(fraction.x * view.x, fraction.y * view.y)
	var tex_size: Vector2 = _texture.get_size()
	var scale_value: float = maxf(view.x / tex_size.x, view.y / tex_size.y)
	var offset: Vector2 = (view - tex_size * scale_value) * 0.5
	return offset + Vector2(fraction.x * tex_size.x, fraction.y * tex_size.y) * scale_value


func _layout_lamps(view: Vector2) -> void:
	var radius: float = view.y * LAMP_RADIUS_RATIO
	for i in _lamps.size():
		var point: Vector2 = _image_point_to_screen(LAMP_POINTS[i] as Vector2, view)
		_lamps[i].size = Vector2(radius * 2.0, radius * 2.0)
		_lamps[i].position = point - Vector2(radius, radius)


func _make_door_leaf(is_left: bool) -> TextureRect:
	var leaf: TextureRect = TextureRect.new()
	leaf.name = "DoorLeft" if is_left else "DoorRight"
	leaf.texture = _door_texture(is_left)
	leaf.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	leaf.stretch_mode = TextureRect.STRETCH_SCALE
	leaf.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Moldura em relevo (so um friso): da cara de porta sem precisar de arte.
	var inset: Panel = Panel.new()
	inset.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inset.set_anchors_preset(Control.PRESET_FULL_RECT)
	inset.anchor_left = 0.12
	inset.anchor_right = 0.88
	inset.anchor_top = 0.10
	inset.anchor_bottom = 0.90
	inset.offset_left = 0.0
	inset.offset_right = 0.0
	inset.offset_top = 0.0
	inset.offset_bottom = 0.0
	var frame: StyleBoxFlat = StyleBoxFlat.new()
	frame.bg_color = Color(0, 0, 0, 0.0)
	frame.border_color = Color(1.0, 0.82, 0.55, 0.14)
	frame.set_border_width_all(2)
	frame.set_corner_radius_all(6)
	inset.add_theme_stylebox_override("panel", frame)
	leaf.add_child(inset)
	# Friso claro na borda interna (a que fica na fresta).
	var edge: ColorRect = ColorRect.new()
	edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	edge.color = Color(1.0, 0.86, 0.60, 0.55)
	edge.set_anchors_preset(Control.PRESET_FULL_RECT)
	edge.anchor_left = 1.0 if is_left else 0.0
	edge.anchor_right = 1.0 if is_left else 0.0
	edge.offset_left = -3.0 if is_left else 0.0
	edge.offset_right = 0.0 if is_left else 3.0
	leaf.add_child(edge)
	return leaf


func _door_texture(is_left: bool) -> GradientTexture2D:
	var gradient: Gradient = Gradient.new()
	# Mais escura no lado de fora da tela, um pouco mais clara perto da fresta.
	gradient.set_color(0, DOOR_WOOD_DARK if is_left else DOOR_WOOD_LIGHT)
	gradient.set_color(1, DOOR_WOOD_LIGHT if is_left else DOOR_WOOD_DARK)
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_LINEAR
	texture.fill_from = Vector2(0.0, 0.0)
	texture.fill_to = Vector2(1.0, 0.0)
	texture.width = 256
	texture.height = 8
	return texture


func _horizontal_glow_texture() -> GradientTexture2D:
	var gradient: Gradient = Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	gradient.colors = PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_LINEAR
	texture.fill_from = Vector2(0.0, 0.0)
	texture.fill_to = Vector2(1.0, 0.0)
	texture.width = 256
	texture.height = 8
	return texture


func _vertical_band_texture() -> GradientTexture2D:
	var gradient: Gradient = Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	gradient.colors = PackedColorArray([
		Color(LIGHT_WARM.r, LIGHT_WARM.g, LIGHT_WARM.b, 0.0),
		Color(LIGHT_WARM.r, LIGHT_WARM.g, LIGHT_WARM.b, 0.34),
		Color(LIGHT_WARM.r, LIGHT_WARM.g, LIGHT_WARM.b, 0.0)
	])
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_LINEAR
	texture.fill_from = Vector2(0.0, 0.0)
	texture.fill_to = Vector2(0.0, 1.0)
	texture.width = 8
	texture.height = 256
	return texture


func _radial_glow_texture() -> GradientTexture2D:
	var gradient: Gradient = Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.35, 1.0])
	gradient.colors = PackedColorArray([Color(1, 1, 1, 0.90), Color(1, 1, 1, 0.28), Color(1, 1, 1, 0.0)])
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 256
	texture.height = 256
	return texture


func _additive_material() -> CanvasItemMaterial:
	var additive: CanvasItemMaterial = CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return additive


# ---------------------------------------------------------------- animacao (porta e luzes)

## 0 = fechada, 1 = aberta. Chamada pelo tween e pelo _layout().
func _apply_door(amount: float) -> void:
	_door_amount = amount
	if _door_left == null:
		return
	var view: Vector2 = size
	if view.x <= 0.0:
		view = Vector2(1280, 720)
	var travel: float = view.x * 0.5 + 36.0
	_door_left.position = Vector2(-amount * travel, 0.0)
	_door_right.position = Vector2(view.x * 0.5 + amount * travel, 0.0)
	# Brilho pela fresta: nasce com a abertura e se dissolve quando a porta ja saiu da tela.
	var spill_alpha: float = clampf(amount * 3.0, 0.0, 1.0) * (1.0 - smoothstep(0.55, 1.0, amount)) * 0.95
	_spill.modulate.a = spill_alpha
	var spill_width: float = view.x * 0.10 + view.x * 0.55 * amount
	_spill.size = Vector2(spill_width, view.y)
	_spill.position = Vector2(view.x * 0.5 - spill_width * 0.5, 0.0)


## 0 = escuro, 1 = aceso. Chamada pelo tween e pelo _layout().
func _apply_light(amount: float) -> void:
	_light_amount = amount
	if _picture == null:
		return
	var view: Vector2 = size
	if view.y <= 0.0:
		view = Vector2(1280, 720)
	var brightness: float = lerpf(DIM_START, 1.0, smoothstep(0.0, 1.0, amount))
	_picture.modulate = Color(brightness, brightness, brightness * 1.02, 1.0)
	# Faixa de luz subindo (de baixo para cima), some no fim.
	var band_h: float = _band.size.y
	_band.position = Vector2(0.0, lerpf(view.y, -band_h, amount))
	_band.modulate.a = 1.0 - smoothstep(0.80, 1.0, amount)
	# Luminarias acendem em sequencia (esquerda, centro, direita).
	for i in _lamps.size():
		var local: float = clampf((amount * 1.7 - float(i) * 0.28) / 0.6, 0.0, 1.0)
		_lamps[i].modulate.a = smoothstep(0.0, 1.0, local) * 0.80


# ---------------------------------------------------------------- brilhos

func _reset_particles() -> void:
	_particles.clear()
	for _i in SPARKLE_COUNT:
		_particles.append({
			"pos": Vector2(randf(), randf()),
			"speed": randf_range(0.012, 0.045),   # fracao da altura por segundo (sobem devagar)
			"drift": randf_range(-0.010, 0.010),
			"size": randf_range(1.6, 4.6),
			"phase": randf() * TAU,
			"rate": randf_range(1.2, 3.2),
			"color": int(randi() % SPARKLE_COLORS.size()),
			"star": randf() < 0.30
		})


func _update_particles(delta: float) -> void:
	for particle in _particles:
		var pos: Vector2 = particle["pos"] as Vector2
		pos.y -= float(particle["speed"]) * delta
		pos.x += float(particle["drift"]) * delta + sin(_elapsed * 0.6 + float(particle["phase"])) * 0.0006
		if pos.y < -0.04:
			pos.y = 1.04
			pos.x = randf()
		particle["pos"] = pos


func _on_sparkles_draw() -> void:
	if _sparkle_visibility <= 0.0:
		return
	var view: Vector2 = _sparkles.size
	for particle in _particles:
		var pos: Vector2 = (particle["pos"] as Vector2) * view
		var twinkle: float = 0.30 + 0.70 * absf(sin(_elapsed * float(particle["rate"]) + float(particle["phase"])))
		var base: Color = SPARKLE_COLORS[int(particle["color"])] as Color
		var alpha: float = twinkle * _sparkle_visibility * 0.85
		var radius: float = float(particle["size"])
		_sparkles.draw_circle(pos, radius * 2.6, Color(base.r, base.g, base.b, alpha * 0.10))
		_sparkles.draw_circle(pos, radius, Color(base.r, base.g, base.b, alpha))
		if bool(particle["star"]):
			var arm: float = radius * 3.6 * twinkle
			var line_color: Color = Color(base.r, base.g, base.b, alpha * 0.8)
			_sparkles.draw_line(pos - Vector2(arm, 0.0), pos + Vector2(arm, 0.0), line_color, 1.3)
			_sparkles.draw_line(pos - Vector2(0.0, arm), pos + Vector2(0.0, arm), line_color, 1.3)


func _animations_enabled() -> bool:
	return not has_node("/root/SettingsManager") or SettingsManager.animations_enabled()
