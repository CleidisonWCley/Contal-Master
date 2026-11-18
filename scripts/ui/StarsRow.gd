extends Control
class_name StarsRow
## V0.15.6 - Estrelas de confianca DESENHADAS em codigo (poligonos), sem depender de glifos da fonte.
## Na build web a fonte nao tem os caracteres ★/☆ e eles viravam quadradinhos. Aqui nao ha texto algum.
##   StarsRow.make(2, 18.0)            -> 2 cheias + 1 vazia (3 no total)
##   StarsRow.make(level, 14.0, 3, UiPalette.DIFF_NORMAL, true)   -> centralizada no pai

const GAP_RATIO: float = 0.22
const INNER_RATIO: float = 0.45

var level: int = 0
var max_stars: int = 3
var star_size: float = 16.0
var filled_color: Color = Color(1.0, 0.84, 0.12)
var empty_color: Color = Color(1.0, 1.0, 1.0, 0.22)


static func make(stars_level: int, size_px: float = 16.0, total: int = 3, color: Color = Color(1.0, 0.84, 0.12), centered: bool = false) -> StarsRow:
	var row: StarsRow = StarsRow.new()
	row.level = clampi(stars_level, 0, total)
	row.max_stars = total
	row.star_size = size_px
	row.filled_color = color
	row.empty_color = Color(color.r, color.g, color.b, 0.22)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.custom_minimum_size = row._content_size()
	row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER if centered else Control.SIZE_SHRINK_BEGIN
	row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return row


func _content_size() -> Vector2:
	var gap: float = star_size * GAP_RATIO
	return Vector2(star_size * float(max_stars) + gap * float(maxi(max_stars - 1, 0)), star_size)


func _draw() -> void:
	var gap: float = star_size * GAP_RATIO
	var radius: float = star_size * 0.5
	for i in range(max_stars):
		var center: Vector2 = Vector2(radius + float(i) * (star_size + gap), size.y * 0.5)
		var points: PackedVector2Array = PackedVector2Array()
		for p in range(10):
			var angle: float = -PI * 0.5 + float(p) * PI / 5.0
			var r: float = radius if p % 2 == 0 else radius * INNER_RATIO
			points.append(center + Vector2(cos(angle), sin(angle)) * r)
		if i < level:
			draw_colored_polygon(points, filled_color)
		else:
			draw_colored_polygon(points, empty_color)
