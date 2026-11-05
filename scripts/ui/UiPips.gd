extends Control
class_name UiPips
## Indicador de nivel (1-3 pontos). A dificuldade nunca depende so de cor.

var level: int = 1:
	set(value):
		level = value
		queue_redraw()
var color: Color = Color.WHITE:
	set(value):
		color = value
		queue_redraw()

func _init() -> void:
	custom_minimum_size = Vector2(56, 22)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var radius: float = 6.5
	var gap: float = 6.0
	var total: float = 6.0 * radius + 2.0 * gap
	var x: float = (size.x - total) * 0.5 + radius
	var y: float = size.y * 0.5
	for i in range(3):
		var center: Vector2 = Vector2(x + i * (radius * 2.0 + gap), y)
		if i < level:
			draw_circle(center, radius, color)
		else:
			draw_arc(center, radius - 1.0, 0.0, TAU, 24, color, 2.0)
