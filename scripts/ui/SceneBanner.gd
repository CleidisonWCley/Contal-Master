extends Control
class_name SceneBanner
## V0.15.2 - Faixa com um cenario cortado (cutscene) e cantos arredondados, escurecendo de cima para baixo.
## O escurecimento e uma funcao LINEAR de y aplicada como cor de cada vertice, entao nao ha artefatos entre triangulos.
## Uso: var banner := SceneBanner.new(); banner.texture = ...; banner.custom_minimum_size = Vector2(0, 170)

var texture: Texture2D = null:
	set(value):
		texture = value
		queue_redraw()
var radius: float = 14.0
var dim_top: float = 1.0
var dim_bottom: float = 0.45
var focus_y: float = 0.5   # 0 = mostra o topo da imagem, 1 = a base
var border_color: Color = Color(0.71, 0.42, 1.0, 0.55)


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_horizontal = Control.SIZE_EXPAND_FILL


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	if size.x < 4.0 or size.y < 4.0:
		return
	var pts: PackedVector2Array = UiFrameArt.round_rect_points(Rect2(Vector2.ZERO, size), radius, 8, false)
	if texture == null:
		draw_colored_polygon(pts, UiPalette.CARD_RAISED)
	else:
		var tex_size: Vector2 = texture.get_size()
		var cover: float = maxf(size.x / tex_size.x, size.y / tex_size.y)
		var uv_w: float = size.x / (tex_size.x * cover)
		var uv_h: float = size.y / (tex_size.y * cover)
		var uv_x0: float = (1.0 - uv_w) * 0.5
		var uv_y0: float = (1.0 - uv_h) * focus_y
		var uvs: PackedVector2Array = PackedVector2Array()
		var cols: PackedColorArray = PackedColorArray()
		for p: Vector2 in pts:
			uvs.append(Vector2(uv_x0 + p.x / size.x * uv_w, uv_y0 + p.y / size.y * uv_h))
			var k: float = lerpf(dim_top, dim_bottom, clampf(p.y / size.y, 0.0, 1.0))
			cols.append(Color(k, k, k, 1.0))
		draw_polygon(pts, cols, uvs, texture)
	var outline: PackedVector2Array = pts.duplicate()
	outline.append(pts[0])
	draw_polyline(outline, border_color, 2.0, true)
