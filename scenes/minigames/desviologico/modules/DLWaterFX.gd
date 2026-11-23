extends RefCounted
class_name DLWaterFX
## V0.16.12 - Agua do fundo "viva", feita por SHADER (GPU) em vez de centenas de linhas desenhadas por quadro na CPU.
## O fundo continua sendo uma imagem estatica; este overlay re-amostra a propria textura do fundo so na area do mar e faz o reflexo
## ondular (deslocamento horizontal em passos de 1 px, mais fino no horizonte) e brilhar onde o fundo ja e claro.
## Shader: assets/shaders/dl_water.gdshader. Custo na CPU: 1 atualizacao de uniforme por quadro. Sem hint_screen_texture (instavel no WebGL).

const WATER_SHADER: Shader = preload("res://assets/shaders/dl_water.gdshader")

var g: DesvioLogicoGame
var water_time: float = 0.0          # tambem usado pelo balanco do carro/HUD no jogo
var overlay: ColorRect
var _material: ShaderMaterial
var _applied_round: int = -99
var _has_texture: bool = false

func _init(game: DesvioLogicoGame) -> void:
	g = game

## Cria o overlay (ColorRect com o shader) como filho de `parent`, na camada entre o fundo e a pista.
func build_overlay(parent: Control) -> ColorRect:
	overlay = ColorRect.new()
	overlay.name = "WaterSurfaceOverlay"
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.color = Color.WHITE
	_material = ShaderMaterial.new()
	_material.shader = WATER_SHADER
	_material.set_shader_parameter("stage_w", g.STAGE_SIZE.x)
	_material.set_shader_parameter("stage_h", g.STAGE_SIZE.y)
	_material.set_shader_parameter("water_top", DLConfig.WATER_TOP_Y)
	_material.set_shader_parameter("water_bottom", DLConfig.WATER_BOTTOM_Y)
	_material.set_shader_parameter("edge_x0", DLConfig.WATER_EDGE_X0)
	_material.set_shader_parameter("edge_slope", DLConfig.WATER_EDGE_SLOPE)
	_material.set_shader_parameter("edge_margin", DLConfig.WATER_EDGE_MARGIN)
	overlay.material = _material
	overlay.visible = false
	parent.add_child(overlay)
	return overlay

## Chamado quando o fundo do desafio troca: o shader amostra a mesma textura do fundo (sem copia na memoria).
func set_background_texture(tex: Texture2D) -> void:
	if _material == null:
		return
	_has_texture = tex != null
	_material.set_shader_parameter("bg_tex", tex)
	_applied_round = -99

## Chamado todo quadro: atualiza so o tempo (e os parametros do horario quando o desafio muda).
func update_overlay() -> void:
	if overlay == null:
		return
	var quality: int = WebLite.water_quality(DLConfig.WATER_EFFECT_QUALITY)
	var show: bool = _has_texture and quality > 0 and g._animations_enabled()
	if overlay.visible != show:
		overlay.visible = show
	if not show:
		return
	if _applied_round != g.current_round:
		_applied_round = g.current_round
		var glint: Color = _water_glint_color(1.0)
		var simple: bool = WebLite.low_end()
		_material.set_shader_parameter("amp", DLConfig.WATER_WAVE_AMPLITUDE * (0.7 if simple else 1.0))
		_material.set_shader_parameter("speed", DLConfig.WATER_WAVE_SPEED)
		_material.set_shader_parameter("sparkle", DLConfig.WATER_SPARKLE * _water_stage_intensity())
		_material.set_shader_parameter("sparkle_color", Color(glint.r, glint.g, glint.b))
		_material.set_shader_parameter("light_x", _water_light_x_ratio())
		_material.set_shader_parameter("quality", 0.0 if simple else 1.0)
	_material.set_shader_parameter("t", water_time)

# ---- parametros por horario (indice do desafio: 0 manha ... 5 noite) ----
func _water_stage_intensity() -> float:
	match g.current_round:
		0:
			return 1.22
		1:
			return 1.28
		2:
			return 1.18
		3:
			return 1.18
		4:
			return 1.05
		_:
			return 0.92

func _water_light_x_ratio() -> float:
	match g.current_round:
		0:
			return 0.13
		1:
			return 0.53
		2:
			return 0.88
		3:
			return 0.14
		4:
			return 0.12
		_:
			return 0.84

func _water_glint_color(alpha: float) -> Color:
	match g.current_round:
		0, 2:
			return Color(1.0, 0.88, 0.36, alpha)
		1:
			return Color(0.94, 1.0, 1.0, alpha)
		3:
			return Color(1.0, 0.62, 0.30, alpha)
		4:
			return Color(0.98, 0.62, 1.0, alpha)
		_:
			return Color(0.66, 0.90, 1.0, alpha)

