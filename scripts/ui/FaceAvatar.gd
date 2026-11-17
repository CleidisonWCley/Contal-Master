extends Control
class_name FaceAvatar
## V0.15.4 - Rosto de um personagem, sempre QUADRADO e centralizado, usado nas grades, fichas, conquistas e cartoes.
##
## O que mudou na 0.15.4: o rosto agora e um PNG pequeno PRE-RECORTADO (assets/sprites/personagens/<id>/<id>_face.png,
## 256x256) mostrado por um TextureRect comum. Antes a classe desenhava uma regiao do sprite "_3" (1120x1500) com _draw();
## no teste visual isso saia como quadrado branco e, alem disso, obrigava a carregar 9 texturas grandes (~6,7 MB de GPU
## cada) so para avatares de 56-150 px, o que pesa na web e no celular. Os PNGs de rosto pesam ~100 KB e ~256 KB de GPU.
##
## Para ajustar um rosto: mude o numero em FACES, rode  python tools/gerar_rostos.py  e abra o Godot (reimporta sozinho).
## Se o PNG de rosto nao existir, cai para o recorte do sprite "_3" via AtlasTexture (funciona, mas e mais pesado).
##
## Uso:   var face := FaceAvatar.create("anderson", 96.0)      # quadrado 96x96
##        face.locked = true                                   # silhueta escura (personagem ainda desconhecido)
## FACES = {id: Vector3(centro_x, centro_y, lado)} em FRACAO do PNG _3 (x e lado pela largura, y pela altura).

const FACES := {
	"jales": Vector3(0.533, 0.238, 0.493),
	"priscila": Vector3(0.433, 0.230, 0.650),
	"anderson": Vector3(0.433, 0.250, 0.447),
	"tiago": Vector3(0.480, 0.150, 0.467),
	"julios": Vector3(0.510, 0.200, 0.520),
	"ariel": Vector3(0.460, 0.200, 0.587),
	"aline": Vector3(0.527, 0.250, 0.553),
	"cleiton": Vector3(0.407, 0.250, 0.433),
	"natalia": Vector3(0.517, 0.215, 0.593)
}
const DEFAULT_FACE := Vector3(0.5, 0.22, 0.55)
const FACE_PATH := "res://assets/sprites/personagens/%s/%s_face.png"

## Cache id -> Texture2D (um rosto e usado em varias telas; carrega uma vez).
static var _textures: Dictionary = {}

var character_id: String = "":
	set(value):
		character_id = value
		_refresh()
var locked: bool = false:
	set(value):
		locked = value
		_refresh()
## Fundo opcional (quadrado arredondado atras do rosto). Transparente = so o rosto.
var backdrop: Color = Color(0, 0, 0, 0):
	set(value):
		backdrop = value
		queue_redraw()
var backdrop_radius: float = 14.0

var _image: TextureRect


static func create(id: String, side: float, is_locked: bool = false) -> FaceAvatar:
	var avatar: FaceAvatar = FaceAvatar.new()
	avatar.character_id = id
	avatar.locked = is_locked
	avatar.custom_minimum_size = Vector2(side, side)
	avatar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	avatar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return avatar


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	_image = TextureRect.new()
	_image.name = "Face"
	_image.set_anchors_preset(Control.PRESET_FULL_RECT)
	_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_image)


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if _image == null:
		return
	_image.texture = texture_for(character_id)
	# Personagem desconhecido: silhueta escura (mesma regra de antes).
	_image.modulate = Color(0.0, 0.0, 0.0, 0.85) if locked else Color.WHITE


## Retangulo (em pixels do PNG _3) que o rosto ocupa. Usado pelo gerador de rostos e pelo plano B.
static func source_rect(id: String, texture_size: Vector2) -> Rect2:
	var face: Vector3 = FACES.get(id, DEFAULT_FACE) as Vector3
	var side: float = face.z * texture_size.x
	return Rect2(face.x * texture_size.x - side * 0.5, face.y * texture_size.y - side * 0.5, side, side)


## Textura do rosto: o PNG pre-recortado; se nao existir, um AtlasTexture do sprite "_3" (recorte empurrado para dentro da imagem).
static func texture_for(id: String) -> Texture2D:
	if id == "":
		return null
	if _textures.has(id):
		return _textures[id] as Texture2D
	var texture: Texture2D = null
	var face_path: String = FACE_PATH % [id, id]
	if ResourceLoader.exists(face_path):
		texture = load(face_path) as Texture2D
	if texture == null:
		var sprite: Texture2D = TutorialManager.sprite_texture(id, "v3")
		if sprite != null:
			var tex_size: Vector2 = sprite.get_size()
			var region: Rect2 = source_rect(id, tex_size)
			region.size = Vector2(minf(region.size.x, tex_size.x), minf(region.size.y, tex_size.y))
			region.position = Vector2(clampf(region.position.x, 0.0, tex_size.x - region.size.x), clampf(region.position.y, 0.0, tex_size.y - region.size.y))
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = sprite
			atlas.region = region
			texture = atlas
		else:
			push_warning("FaceAvatar: sem rosto para '%s' (nem %s, nem sprite _3)." % [id, face_path])
	_textures[id] = texture
	return texture


func _draw() -> void:
	if backdrop.a <= 0.01:
		return
	var side: float = minf(size.x, size.y)
	if side < 2.0:
		return
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = backdrop
	style.set_corner_radius_all(int(backdrop_radius))
	draw_style_box(style, Rect2((size - Vector2(side, side)) * 0.5, Vector2(side, side)))
