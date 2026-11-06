extends Control
class_name UiFrameArt
## Moldura em degrade no estilo do icone de referencia (v4.2):
## contorno externo + contorno interno arredondados, cantoneiras (topo-esquerda / base-direita)
## e um glifo com degrade no centro. O degrade e vertical e continuo por toda a moldura.
## Fica atras do texto do cartao: o conteudo (titulo/descricao) vai na faixa de baixo (text_area).

const LINE_W := 4.0
const OUTER_RADIUS := 28.0
const INNER_RADIUS := 18.0

var gradient: Gradient
var glyph: Texture2D
var glyph_top: Color = Color("#8FD0FF")
var glyph_bottom: Color = Color("#E4B5FF")

## Altura reservada, dentro da moldura externa, para o texto abaixo da moldura interna.
var text_area: float = 150.0:
	set(value):
		text_area = value
		queue_redraw()
var inner_pad: float = 22.0:
	set(value):
		inner_pad = value
		queue_redraw()
## Intensidade do brilho (0..1), animavel por Tween (hover / foco por teclado).
var glow_amount: float = 0.0:
	set(value):
		glow_amount = clampf(value, 0.0, 1.0)
		queue_redraw()
## Atalho: liga/desliga o brilho na hora, sem animacao.
var glow: bool = false:
	set(value):
		glow = value
		glow_amount = 1.0 if value else 0.0

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	gradient = make_gradient(Color("#1E6EFF"), Color("#7B4DFF"), Color("#C524FF"))

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

## Degrade de 3 pontos (topo / meio / base), como o icone: azul -> roxo -> magenta.
static func make_gradient(top: Color, mid: Color, bottom: Color) -> Gradient:
	var g := Gradient.new()
	g.set_color(0, top)
	g.set_color(1, bottom)
	g.add_point(0.55, mid)
	return g

## Pontos de um retangulo com cantos arredondados (sentido horario). close=true repete o 1o ponto no fim.
static func round_rect_points(rect: Rect2, radius: float, segments: int = 8, close: bool = true) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var r: float = minf(radius, minf(rect.size.x, rect.size.y) * 0.5)
	var centers: Array[Vector2] = [
		Vector2(rect.end.x - r, rect.position.y + r),
		Vector2(rect.end.x - r, rect.end.y - r),
		Vector2(rect.position.x + r, rect.end.y - r),
		Vector2(rect.position.x + r, rect.position.y + r)
	]
	var starts: Array[float] = [-PI * 0.5, 0.0, PI * 0.5, PI]
	for corner in range(4):
		for i in range(segments + 1):
			var a: float = starts[corner] + (PI * 0.5) * float(i) / float(segments)
			pts.append(centers[corner] + Vector2(cos(a), sin(a)) * r)
	if close:
		pts.append(pts[0])
	return pts

func _color_at(y: float) -> Color:
	return gradient.sample(clampf(y / maxf(size.y, 1.0), 0.0, 1.0))

func _inner_rect() -> Rect2:
	return Rect2(Vector2(inner_pad, inner_pad), Vector2(size.x - inner_pad * 2.0, size.y - inner_pad - text_area))

func _draw() -> void:
	if gradient == null or size.x < 60.0 or size.y < 60.0:
		return
	var half: float = LINE_W * 0.5
	var outer := Rect2(Vector2(half, half), size - Vector2(LINE_W, LINE_W))
	if glow_amount > 0.01:
		_stroke(outer, OUTER_RADIUS, LINE_W + 10.0, 0.30 * glow_amount)
	_stroke(outer, OUTER_RADIUS, LINE_W, 1.0)

	var inner: Rect2 = _inner_rect()
	if inner.size.x < 60.0 or inner.size.y < 60.0:
		return
	var inner_line := Rect2(inner.position + Vector2(half, half), inner.size - Vector2(LINE_W, LINE_W))
	if glow_amount > 0.01:
		_stroke(inner_line, INNER_RADIUS, LINE_W + 6.0, 0.20 * glow_amount)
	_stroke(inner_line, INNER_RADIUS, LINE_W, 1.0)
	_draw_brackets(inner)
	_draw_glyph(inner)

func _stroke(rect: Rect2, radius: float, width: float, alpha: float) -> void:
	var pts: PackedVector2Array = round_rect_points(rect, radius, 8, true)
	var cols := PackedColorArray()
	for p in pts:
		var c: Color = _color_at(p.y)
		c.a *= alpha
		cols.append(c)
	draw_polyline_colors(pts, cols, width, true)

func _polyline(pts: PackedVector2Array, width: float) -> void:
	var cols := PackedColorArray()
	for p in pts:
		cols.append(_color_at(p.y))
	draw_polyline_colors(pts, cols, width, true)

## Cantoneiras em "L" com canto externo arredondado: topo-esquerda e base-direita.
func _draw_brackets(inner: Rect2) -> void:
	var m: float = minf(inner.size.x, inner.size.y)
	var pad: float = m * 0.13
	var length: float = m * 0.24
	var r: float = m * 0.07
	var tl: Vector2 = inner.position + Vector2(pad, pad)
	var br: Vector2 = inner.end - Vector2(pad, pad)

	var a_pts := PackedVector2Array()
	a_pts.append(Vector2(tl.x, tl.y + length))
	a_pts.append(Vector2(tl.x, tl.y + r))
	for i in range(1, 7):
		var a: float = PI + (PI * 0.5) * float(i) / 6.0
		a_pts.append(Vector2(tl.x + r, tl.y + r) + Vector2(cos(a), sin(a)) * r)
	a_pts.append(Vector2(tl.x + length, tl.y))
	_polyline(a_pts, LINE_W)

	var b_pts := PackedVector2Array()
	b_pts.append(Vector2(br.x, br.y - length))
	b_pts.append(Vector2(br.x, br.y - r))
	for i in range(1, 7):
		var b: float = (PI * 0.5) * float(i) / 6.0
		b_pts.append(Vector2(br.x - r, br.y - r) + Vector2(cos(b), sin(b)) * r)
	b_pts.append(Vector2(br.x - length, br.y))
	_polyline(b_pts, LINE_W)

## Glifo (icone branco de UiIcons) com degrade vertical claro: azul-ceu -> lilas.
func _draw_glyph(inner: Rect2) -> void:
	if glyph == null:
		return
	var g: float = minf(inner.size.x, inner.size.y) * 0.42
	var center: Vector2 = inner.get_center()
	var q := Rect2(center - Vector2(g, g) * 0.5, Vector2(g, g))
	var pts := PackedVector2Array([q.position, Vector2(q.end.x, q.position.y), q.end, Vector2(q.position.x, q.end.y)])
	var cols := PackedColorArray([glyph_top, glyph_top, glyph_bottom, glyph_bottom])
	var uvs := PackedVector2Array([Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)])
	draw_polygon(pts, cols, uvs, glyph)
