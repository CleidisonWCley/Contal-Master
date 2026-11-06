extends Control
class_name UiScrim
## Degrade escuro sutil com cantos arredondados (v4.2). Fica ATRAS do conteudo de um painel
## para garantir contraste do texto branco sobre cenarios claros, sem voltar ao bloco solido.

var top_color: Color = Color(0.063, 0.043, 0.122, 0.80)
var bottom_color: Color = Color(0.063, 0.043, 0.122, 0.50)
var border_color: Color = Color(0, 0, 0, 0)
var border_width: float = 2.0
var radius: float = 20.0

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	if size.x < 8.0 or size.y < 8.0:
		return
	var pts: PackedVector2Array = UiFrameArt.round_rect_points(Rect2(Vector2.ZERO, size), radius, 8, false)
	var cols := PackedColorArray()
	for p in pts:
		cols.append(top_color.lerp(bottom_color, clampf(p.y / size.y, 0.0, 1.0)))
	draw_polygon(pts, cols)
	if border_color.a > 0.0 and border_width > 0.0:
		var half: float = border_width * 0.5
		var line_pts: PackedVector2Array = UiFrameArt.round_rect_points(Rect2(Vector2(half, half), size - Vector2(border_width, border_width)), radius, 8, true)
		var line_cols := PackedColorArray()
		for p in line_pts:
			line_cols.append(border_color)
		draw_polyline_colors(line_pts, line_cols, border_width, true)
