@tool
extends Control
class_name DLEditorGuide
## V0.16.10 - Guia visual do editor (fundo da Manha a 55 %) para posicionar os markers.
## Antes era um TextureRect com o PNG 2816x1584 dentro da cena: carregava ~17,8 MB de memoria de video o jogo inteiro.
## Agora a imagem e desenhada SO no editor (load dentro do if), entao no jogo/na web nada e carregado.
## Para trocar a referencia, mude GUIDE_PATH.

const GUIDE_PATH := "res://assets/background/minegames/desviologico/background_dl_manha.png"

func _ready() -> void:
	if not Engine.is_editor_hint():
		visible = false
		return
	resized.connect(queue_redraw)

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	var tex: Texture2D = load(GUIDE_PATH) as Texture2D
	if tex == null or size.x <= 0.0 or size.y <= 0.0:
		return
	# mesmo enquadramento do antigo STRETCH_KEEP_ASPECT_COVERED
	var scale_f: float = maxf(size.x / tex.get_width(), size.y / tex.get_height())
	var draw_size: Vector2 = Vector2(tex.get_width(), tex.get_height()) * scale_f
	draw_texture_rect(tex, Rect2((size - draw_size) * 0.5, draw_size), false, Color(1, 1, 1, 0.55))
