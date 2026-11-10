extends Control
class_name TransitionFX
## Particulas das transicoes 
## Uso:
##     var fx := TransitionFX.new()
##     fx.setup("batalha_naval", accent, secondary)
##     add_child(fx)
##
## Com "Animacoes" desligadas nas Configuracoes nenhuma particula e criada.

# Tipo de movimento por minigame. kind: mote | bubble | streak
const THEMES := {
	"show_do_bilhao": {"kind": "mote", "amount": 22, "life": 10.0, "dir": Vector2(0.0, 1.0), "spread": 18.0, "speed": [18.0, 42.0], "size": [0.22, 0.55], "alpha": 0.60},
	"batalha_naval": {"kind": "bubble", "amount": 18, "life": 9.0, "dir": Vector2(0.0, -1.0), "spread": 14.0, "speed": [22.0, 52.0], "size": [0.18, 0.52], "alpha": 0.55},
	"maleta_certa": {"kind": "mote", "amount": 20, "life": 11.0, "dir": Vector2(1.0, 0.2), "spread": 30.0, "speed": [10.0, 30.0], "size": [0.20, 0.50], "alpha": 0.52},
	"roleta_risco": {"kind": "mote", "amount": 24, "life": 9.0, "dir": Vector2(0.0, -1.0), "spread": 180.0, "speed": [10.0, 34.0], "size": [0.20, 0.55], "alpha": 0.62, "orbit": 0.25},
	"perseguicao": {"kind": "streak", "amount": 9, "life": 2.2, "dir": Vector2(-1.0, 0.0), "spread": 2.0, "speed": [380.0, 620.0], "size": [0.7, 1.5], "alpha": 0.40},
	"forca_tecnica": {"kind": "mote", "amount": 22, "life": 10.0, "dir": Vector2(0.0, -1.0), "spread": 25.0, "speed": [14.0, 38.0], "size": [0.20, 0.50], "alpha": 0.55},
	"stop": {"kind": "mote", "amount": 20, "life": 10.0, "dir": Vector2(0.0, 1.0), "spread": 22.0, "speed": [16.0, 40.0], "size": [0.20, 0.50], "alpha": 0.50},
	"desvio_logico": {"kind": "streak", "amount": 7, "life": 3.2, "dir": Vector2(-1.0, 0.0), "spread": 2.0, "speed": [200.0, 340.0], "size": [0.6, 1.2], "alpha": 0.34}
}
const DEFAULT_THEME := {"kind": "mote", "amount": 18, "life": 10.0, "dir": Vector2(0.0, -1.0), "spread": 25.0, "speed": [14.0, 36.0], "size": [0.20, 0.50], "alpha": 0.5}

static var _tex_cache: Dictionary = {}

var phase_key: String = ""
var accent: Color = Color(1.0, 0.84, 0.12)
var secondary: Color = Color(1.0, 0.5, 0.1)
var _emitters: Array[CPUParticles2D] = []


func setup(key: String, accent_color: Color, secondary_color: Color) -> void:
	phase_key = key
	accent = accent_color
	secondary = secondary_color


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if has_node("/root/SettingsManager") and not SettingsManager.animations_enabled():
		return
	_build()
	resized.connect(_fit_emitters)
	_fit_emitters()


func _build() -> void:
	var fx_theme: Dictionary = THEMES.get(phase_key, DEFAULT_THEME)
	var kind: String = str(fx_theme.get("kind", "mote"))
	var amount: int = int(fx_theme.get("amount", 18))
	# Duas camadas (accent e secondary) para o brilho nao ficar de uma cor so.
	for layer in range(2):
		var color: Color = accent if layer == 0 else secondary.lerp(Color.WHITE, 0.25)
		var emitter: CPUParticles2D = CPUParticles2D.new()
		emitter.name = "Fx%d" % layer
		emitter.amount = maxi(int(round(float(amount) * (0.62 if layer == 0 else 0.38))), 2)
		emitter.lifetime = float(fx_theme.get("life", 10.0))
		emitter.preprocess = emitter.lifetime  # a tela ja nasce "povoada"
		emitter.explosiveness = 0.0
		emitter.randomness = 1.0
		emitter.local_coords = false
		emitter.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		emitter.direction = fx_theme.get("dir", Vector2(0.0, -1.0)) as Vector2
		emitter.spread = float(fx_theme.get("spread", 25.0))
		emitter.gravity = Vector2.ZERO
		var speed: Array = fx_theme.get("speed", [14.0, 36.0])
		emitter.initial_velocity_min = float(speed[0])
		emitter.initial_velocity_max = float(speed[1])
		var fx_size: Array = fx_theme.get("size", [0.2, 0.5])
		emitter.scale_amount_min = float(fx_size[0])
		emitter.scale_amount_max = float(fx_size[1])
		if float(fx_theme.get("orbit", 0.0)) > 0.0:
			emitter.orbit_velocity_min = -float(fx_theme.get("orbit", 0.0))
			emitter.orbit_velocity_max = float(fx_theme.get("orbit", 0.0))
		emitter.color_ramp = _life_ramp(float(fx_theme.get("alpha", 0.5)) * (1.0 if layer == 0 else 0.8))
		emitter.color = color
		emitter.texture = _texture_for(kind)
		emitter.emitting = true
		add_child(emitter)
		_emitters.append(emitter)


func _fit_emitters() -> void:
	var view: Vector2 = size
	if view.x <= 0.0 or view.y <= 0.0:
		view = Vector2(1280, 720)
	var kind: String = str((THEMES.get(phase_key, DEFAULT_THEME) as Dictionary).get("kind", "mote"))
	for emitter in _emitters:
		emitter.position = view * 0.5
		# Riscos de luz nascem logo fora da borda direita e atravessam a tela; os demais nascem espalhados.
		if kind == "streak":
			emitter.emission_rect_extents = Vector2(40.0, view.y * 0.42)
			emitter.position = Vector2(view.x + 60.0, view.y * 0.5)
		else:
			emitter.emission_rect_extents = view * 0.5


## Transparente -> visivel -> transparente ao longo da vida da particula (sem "pop").
static func _life_ramp(peak_alpha: float) -> Gradient:
	var gradient: Gradient = Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.18, 0.78, 1.0])
	gradient.colors = PackedColorArray([Color(1, 1, 1, 0.0), Color(1, 1, 1, peak_alpha), Color(1, 1, 1, peak_alpha * 0.8), Color(1, 1, 1, 0.0)])
	return gradient


static func _texture_for(kind: String) -> Texture2D:
	if _tex_cache.has(kind):
		return _tex_cache[kind] as Texture2D
	var texture: GradientTexture2D = GradientTexture2D.new()
	var gradient: Gradient = Gradient.new()
	match kind:
		"bubble":
			# Anel fino com um miolo quase transparente: bolha.
			gradient.offsets = PackedFloat32Array([0.0, 0.62, 0.86, 1.0])
			gradient.colors = PackedColorArray([Color(1, 1, 1, 0.05), Color(1, 1, 1, 0.08), Color(1, 1, 1, 0.9), Color(1, 1, 1, 0.0)])
			texture.fill = GradientTexture2D.FILL_RADIAL
			texture.fill_from = Vector2(0.5, 0.5)
			texture.fill_to = Vector2(1.0, 0.5)
			texture.width = 64
			texture.height = 64
		"streak":
			# Risco horizontal de luz (afinando nas pontas).
			gradient.offsets = PackedFloat32Array([0.0, 0.7, 1.0])
			gradient.colors = PackedColorArray([Color(1, 1, 1, 0.0), Color(1, 1, 1, 0.9), Color(1, 1, 1, 0.0)])
			texture.fill = GradientTexture2D.FILL_LINEAR
			texture.fill_from = Vector2(0.0, 0.5)
			texture.fill_to = Vector2(1.0, 0.5)
			texture.width = 160
			texture.height = 3
		_:
			# Brilho suave.
			gradient.offsets = PackedFloat32Array([0.0, 0.4, 1.0])
			gradient.colors = PackedColorArray([Color(1, 1, 1, 0.95), Color(1, 1, 1, 0.35), Color(1, 1, 1, 0.0)])
			texture.fill = GradientTexture2D.FILL_RADIAL
			texture.fill_from = Vector2(0.5, 0.5)
			texture.fill_to = Vector2(1.0, 0.5)
			texture.width = 64
			texture.height = 64
	texture.gradient = gradient
	_tex_cache[kind] = texture
	return texture
