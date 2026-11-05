extends Control
class_name UiBackdrop
## Fundo padrao de todas as telas de menu: cenario + escurecimento + particulas suaves.
## Uso: UiBackdrop.attach(self)   (as particulas respeitam a opcao "Animacoes visuais")

const PARTICLE_COUNT := 36

var dim_alpha: float = 0.68
var _dots: Control
var _particles: Array[Dictionary] = []
var _time: float = 0.0

static func attach(host: Control, dim: float = 0.68) -> UiBackdrop:
	var backdrop := UiBackdrop.new()
	backdrop.name = "Backdrop"
	backdrop.dim_alpha = dim
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(backdrop)
	host.move_child(backdrop, 0)
	return backdrop

func _ready() -> void:
	var picture := TextureRect.new()
	picture.name = "Scenery"
	picture.set_anchors_preset(Control.PRESET_FULL_RECT)
	picture.texture = load(Paths.BG_MENU_MAIN) as Texture2D
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(picture)

	var dimmer := ColorRect.new()
	dimmer.name = "Dimmer"
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = UiPalette.with_alpha(UiPalette.BG, dim_alpha)
	dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dimmer)

	_dots = Control.new()
	_dots.name = "Dots"
	_dots.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dots.draw.connect(_on_dots_draw)
	add_child(_dots)
	_reset_particles()

func _animations_enabled() -> bool:
	return not has_node("/root/SettingsManager") or SettingsManager.animations_enabled()

func _reset_particles() -> void:
	_particles.clear()
	var area: Vector2 = get_viewport_rect().size
	if area.x <= 0.0:
		area = Vector2(1280, 720)
	var tints: Array[Color] = [UiPalette.HIGHLIGHT, UiPalette.SECONDARY, UiPalette.ACCENT_REWARDS]
	for i in range(PARTICLE_COUNT):
		_particles.append({
			"pos": Vector2(randf_range(0.0, area.x), randf_range(0.0, area.y)),
			"speed": randf_range(10.0, 30.0),
			"radius": randf_range(1.6, 3.6),
			"alpha": randf_range(0.14, 0.42),
			"wave": randf_range(0.0, TAU),
			"tint": tints[i % tints.size()]
		})

func _process(delta: float) -> void:
	_dots.visible = _animations_enabled()
	if not _dots.visible:
		return
	_time += delta
	var area: Vector2 = get_viewport_rect().size
	for i in range(_particles.size()):
		var p: Dictionary = _particles[i]
		var pos: Vector2 = p["pos"]
		pos.y -= float(p["speed"]) * delta
		pos.x += sin(_time * 1.1 + float(p["wave"])) * 12.0 * delta
		if pos.y < -12.0:
			pos = Vector2(randf_range(0.0, area.x), area.y + randf_range(8.0, 80.0))
		p["pos"] = pos
		_particles[i] = p
	_dots.queue_redraw()

func _on_dots_draw() -> void:
	for p in _particles:
		var tint: Color = p["tint"]
		var color: Color = Color(tint.r, tint.g, tint.b, float(p["alpha"]))
		_dots.draw_circle(p["pos"], float(p["radius"]), color)
