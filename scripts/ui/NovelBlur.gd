extends RefCounted
class_name NovelBlur
## Camada de desfoque para o fundo das novels (V0.12).
##
## Coloque a camada ACIMA do cenario e ABAIXO dos personagens e da caixa de dialogo:
##
##     var blur: ColorRect = NovelBlur.create()
##     add_child(blur)            # primeiro filho do NovelStage
##     NovelBlur.fade_in(blur)    # opcional
##
## Ela desfoca tudo que ja foi desenhado atras dela (shader assets/shaders/novel_blur.gdshader).
## strength: 1.0 = padrao (~3,6 px em 720p). 0 desliga o efeito (retorna uma camada invisivel).

const DEFAULT_RADIUS := 0.0065


static func create(strength: float = 1.0) -> ColorRect:
	var layer: ColorRect = ColorRect.new()
	layer.name = "NovelBlur"
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.color = Color.WHITE
	if strength <= 0.0:
		layer.visible = false
		return layer
	# V0.14.1 (web): o shader usa hint_screen_texture (copia da tela + 24 leituras por pixel em tela cheia).
	# No WebGL isso trava/derruba o contexto em varios aparelhos. Na web a camada vira uma pelicula escura
	# translucida (custo zero). Para forcar o desfoque real: abra a pagina com ?blur=1.
	if not WebLite.blur_enabled():
		layer.color = Color(0.05, 0.03, 0.12, 0.34)
		return layer
	if not ResourceLoader.exists(Paths.SHADER_NOVEL_BLUR):
		layer.visible = false
		return layer
	var shader: Shader = load(Paths.SHADER_NOVEL_BLUR) as Shader
	if shader == null:
		layer.visible = false
		return layer
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("radius", DEFAULT_RADIUS * strength)
	layer.material = material
	return layer


## Entrada suave do desfoque (respeita a configuracao de animacoes).
static func fade_in(layer: ColorRect, seconds: float = 0.6) -> void:
	if layer == null or not layer.is_inside_tree():
		return
	var animate: bool = not layer.has_node("/root/SettingsManager") or SettingsManager.animations_enabled()
	if not animate:
		layer.modulate.a = 1.0
		return
	layer.modulate.a = 0.0
	var tween: Tween = layer.create_tween()
	tween.tween_property(layer, "modulate:a", 1.0, seconds)
