extends Control
class_name DLCarLights
## V0.16.9.6 - Luzes dos carros do Desvio Logico (todas desenhadas por codigo, sem PNG novo).
##   KIND_TAIL: lanternas vermelhas traseiras. Usadas nos NPCs e no Bionix a partir do Entardecer (DLConfig.CAR_TAILLIGHT_BY_ROUND).
##   KIND_HEAD: V0.16.11 - sem farois. Uma AUREOLA de luz branca suave a frente do Bionix (so nos horarios noturnos,
##              DLConfig.CAR_HEADLIGHT_BY_ROUND). Todos os ajustes em DLConfig.AURA_* (bloco "LUZ A FRENTE DO BIONIX").
## O no e FILHO do carro: herda posicao, escala, rotacao e transparencia (fade-out da saida, perspectiva dos NPCs).
## V0.16.11.1: a aureola ficou MINUSCULA (cone curto + poca pequena): so representa que o Bionix esta de luz acesa ao desviar dos cones.
## Nao ha trabalho por quadro no Bionix (desenha uma vez e so redesenha se o tamanho mudar).

const KIND_TAIL: int = 0
const KIND_HEAD: int = 1

## Proporcao do sprite dos carros (192x144). TextureRect com STRETCH_KEEP_ASPECT_CENTERED encaixa o sprite centralizado.
const SPRITE_ASPECT: float = 192.0 / 144.0
## Centro das fendas das lanternas, em fracao da area do sprite (medido no PNG: x 43,5 e 148,5 de 192; y 88,5 de 144).
const TAIL_X_LEFT: float = 0.2266
const TAIL_X_RIGHT: float = 0.7734
const TAIL_Y: float = 0.615

static var _glow_tex: Texture2D = null

var kind: int = KIND_TAIL
var intensity: float = 0.0

## Intensidade (0..1) das luzes do tipo `light_kind` no horario `round_index`.
static func round_intensity(light_kind: int, round_index: int) -> float:
	var table: Array = DLConfig.CAR_TAILLIGHT_BY_ROUND if light_kind == KIND_TAIL else DLConfig.CAR_HEADLIGHT_BY_ROUND
	if table.is_empty():
		return 0.0
	return clampf(float(table[clampi(round_index, 0, table.size() - 1)]), 0.0, 1.0)

## Textura radial suave (branco -> transparente), compartilhada por todas as luzes.
static func glow_texture() -> Texture2D:
	if _glow_tex != null:
		return _glow_tex
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 1.0, 1.0, 1.0))
	gradient.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
	gradient.add_point(0.45, Color(1.0, 1.0, 1.0, 0.30))
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 64
	tex.height = 64
	_glow_tex = tex
	return _glow_tex

## Configura o no (chamar antes ou depois de add_child). O farol fica ATRAS do sprite do carro; as lanternas, na frente.
func setup(light_kind: int, round_index: int) -> void:
	kind = light_kind
	name = "TailLights" if kind == KIND_TAIL else "HeadLights"
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	show_behind_parent = kind == KIND_HEAD
	set_round(round_index)

func set_round(round_index: int) -> void:
	intensity = round_intensity(kind, round_index)
	visible = intensity > 0.01
	queue_redraw()

## Area (dentro deste no) que o sprite realmente ocupa.
func _sprite_rect() -> Rect2:
	var w: float = minf(size.x, size.y * SPRITE_ASPECT)
	var h: float = w / SPRITE_ASPECT
	return Rect2((size - Vector2(w, h)) * 0.5, Vector2(w, h))

func _draw() -> void:
	if intensity <= 0.01:
		return
	var area: Rect2 = _sprite_rect()
	if area.size.x <= 2.0:
		return
	if kind == KIND_TAIL:
		_draw_taillights(area)
	else:
		_draw_headlights(area)

func _draw_taillights(area: Rect2) -> void:
	var glow: Texture2D = glow_texture()
	var low_end: bool = WebLite.low_end()
	var core_w: float = area.size.x * 0.085
	var core_h: float = maxf(area.size.y * 0.042, 1.5)
	for fx in [TAIL_X_LEFT, TAIL_X_RIGHT]:
		var c: Vector2 = area.position + Vector2(area.size.x * float(fx), area.size.y * TAIL_Y)
		if not low_end:
			# halo vermelho suave ao redor da lanterna
			var r: float = area.size.x * 0.11
			draw_texture_rect(glow, Rect2(c.x - r, c.y - r * 0.8, r * 2.0, r * 1.6), false, Color(1.0, 0.10, 0.08, 0.55 * intensity))
		draw_rect(Rect2(c.x - core_w * 0.5, c.y - core_h * 0.5, core_w, core_h), Color(1.0, 0.16, 0.12, 0.95 * intensity))
		# miolo quente (mais claro)
		draw_rect(Rect2(c.x - core_w * 0.30, c.y - core_h * 0.30, core_w * 0.60, core_h * 0.60), Color(1.0, 0.72, 0.66, 0.90 * intensity))

func _draw_headlights(area: Rect2) -> void:
	# V0.16.11: luz branca suave e curta a frente do Bionix: cone que abre e some + poca no asfalto (so aparelho forte).
	# O no fica ATRAS do sprite, entao a base do cone fica escondida sob o carro. Tudo em DLConfig.AURA_* / CAR_HEADLIGHT_BY_ROUND.
	var w: float = area.size.x
	var h: float = area.size.y
	var cx: float = area.position.x + w * 0.5
	var y0: float = area.position.y + h * DLConfig.AURA_CONE_START_Y
	var y1: float = y0 - h * DLConfig.AURA_CONE_LENGTH
	var a_near: float = DLConfig.AURA_CONE_ALPHA * intensity
	var white := Color(0.97, 0.98, 1.0)
	# V0.16.11.1c: UM cone de luz so (como na V0.16.11), com densidade menor (AURA_CONE_ALPHA 0.20 -> 0.15).
	for beam_x in [0.0]:
		var bx: float = cx + w * float(beam_x)
		for layer in [[1.30, 0.45], [0.85, 1.0]]:
			var k: float = float(layer[0])
			var near_w: float = w * DLConfig.AURA_CONE_NEAR_HALF_W * k
			var far_w: float = w * DLConfig.AURA_CONE_FAR_HALF_W * k
			var c_near := Color(white.r, white.g, white.b, a_near * float(layer[1]))
			var c_far := Color(white.r, white.g, white.b, 0.0)
			draw_polygon(PackedVector2Array([
				Vector2(bx - near_w, y0), Vector2(bx + near_w, y0),
				Vector2(bx + far_w, y1), Vector2(bx - far_w, y1)
			]), PackedColorArray([c_near, c_near, c_far, c_far]))
	if not WebLite.low_end() and DLConfig.AURA_POOL_ALPHA > 0.001:
		var pw: float = w * DLConfig.AURA_POOL_WIDTH
		var ph: float = h * DLConfig.AURA_POOL_HEIGHT
		var pc := Vector2(cx, area.position.y + h * DLConfig.AURA_POOL_Y)
		draw_texture_rect(glow_texture(), Rect2(pc.x - pw * 0.5, pc.y - ph * 0.5, pw, ph), false, Color(white.r, white.g, white.b, DLConfig.AURA_POOL_ALPHA * intensity))
