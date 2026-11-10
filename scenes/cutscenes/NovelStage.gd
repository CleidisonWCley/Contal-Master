extends Control
class_name NovelStage
## Apresentador de "novel" personagens GRANDES na tela, caixa de dialogo com
## efeito de digitacao e transicoes de personagem com fade + "subida" (o personagem levanta de baixo
## Usado por:
##   - StageTransition: Jales apresenta o anfitriao do minigame (3 quadros);
##   - CutsceneFinal: despedida do Jales, convite da Natalia, narracao de apoio, elenco reunido,
##     score e fala final.
##
## Uso:
##     var stage := NovelStage.new()
##     add_child(stage)
##     stage.configure({"accent": Color(...), "show_skip": true})
##     var completed: bool = await stage.play_frames(frames)
##
## Cada quadro (Dictionary):
##   speaker            id do personagem que fala (jales, priscila, ...). "" = narrador sem retrato
##   text               fala (o campo "title" do JSON nao e mais exibido)
##   show               ids visiveis NESTE quadro (padrao: mantem os do quadro anterior)
##   enter_on_complete  ids que entram (fade + subida) quando a fala termina de digitar
##   narration          true = sem retratos, texto centralizado (narracao de apoio)
##   name               nome exibido (padrao: nome do personagem)
##   dim                escurecimento do fundo (0..1)
##
## "Pular" e opcional (show_skip). Esc NAO e tratado aqui: fica com a cena que hospeda o novel.

signal skip_requested
signal frame_started(frame_index: int)

const TYPE_CHARS_PER_SECOND := 58.0
const ENTER_SECONDS := 0.48
const EXIT_SECONDS := 0.36
const RISE_PIXELS := 78.0
const DIMMED := Color(0.46, 0.45, 0.56, 1.0)

signal _text_done
signal _next_pressed

var accent: Color = Color(1.0, 0.82, 0.18)
var show_skip: bool = true
## id -> posicao horizontal (0..1) do ROSTO no modo "duo". Padrao: jales 0.26, demais 0.74.
var slots: Dictionary = {}
## Se nao vazio, os personagens ficam em fileira (elenco reunido), nesta ordem.
var row_ids: Array = []
## "v1" (novels, corpo inteiro acima do quadro), "v2" (cena final, pes no chao) ou "v3" (legado: recorte). Definido em configure().
var variant: String = "v1"
## Caixa de dialogo no topo da tela (personagens em pe no chao ocupam a parte de baixo).
var panel_top: bool = false
## Chao do cenario (so variante "v2"): {"front", "back", "ppm", "row_ppm"}; ver Paths.CUTSCENE_FLOOR.
var floor_info: Dictionary = {"front": 0.72, "back": 0.68, "ppm": 0.31, "row_ppm": 0.27}
var blur_strength: float = 1.0

var _sprites: Dictionary = {}
var _visible_ids: Array = []
var _speaker: String = ""
var _frames: Array = []
var _index: int = -1
var _typing: bool = false
var _waiting_next: bool = false
var _skipped: bool = false
var _narration: bool = false
var _type_tween: Tween
var _dim_tween: Tween

var _blur: ColorRect
var _dimmer: ColorRect
var _sprite_layer: Control
var _panel: PanelContainer
var _margin: MarginContainer
var _name_label: Label
var _counter_label: Label
var _text_label: Label
var _hint_label: Label
var _skip_button: Button
var _elapsed: float = 0.0


func configure(options: Dictionary = {}) -> void:
	accent = options.get("accent", accent) as Color
	show_skip = bool(options.get("show_skip", true))
	variant = str(options.get("variant", variant))
	blur_strength = float(options.get("blur", blur_strength))
	apply_layout(options)


## Posicao dos personagens e da caixa por bloco/cenario. Chaves opcionais:
##   slots, row_ids, panel_top, floor (Dictionary de Paths.CUTSCENE_FLOOR).
## Pode ser chamado entre blocos (CutsceneFinal troca de cenario sem recriar o NovelStage).
func apply_layout(layout: Dictionary) -> void:
	slots = layout.get("slots", {})
	row_ids = layout.get("row_ids", [])
	panel_top = bool(layout.get("panel_top", false))
	var floor_value: Variant = layout.get("floor", null)
	if floor_value is Dictionary:
		floor_info = (floor_value as Dictionary).duplicate()
	if _panel != null:
		_layout()


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	resized.connect(_layout)
	_layout()


func _process(delta: float) -> void:
	_elapsed += delta
	if _hint_label != null and _waiting_next and _animations_enabled():
		var alpha: float = 0.45 + absf(sin(_elapsed * 3.0)) * 0.45
		_hint_label.add_theme_color_override("font_color", Color(0.86, 0.88, 0.95, alpha))


# ---------------------------------------------------------------- API

## Executa os quadros em sequencia. Retorna true se o jogador chegou ao fim, false se pulou.
func play_frames(frames: Array) -> bool:
	_frames = frames
	_skipped = false
	for i in range(frames.size()):
		if _skipped or not is_inside_tree():
			break
		_index = i
		await _run_frame(frames[i] as Dictionary)
	if is_inside_tree():
		await exit_all()
	return not _skipped


## Todos os personagens saem (fade + descida) e a caixa de dialogo some.
func exit_all() -> void:
	for id in _visible_ids.duplicate():
		_set_sprite_visible(str(id), false, true)
	_visible_ids.clear()
	if _panel != null:
		var tween: Tween = create_tween()
		tween.tween_property(_panel, "modulate:a", 0.0, EXIT_SECONDS)
	if is_inside_tree():
		await get_tree().create_timer(EXIT_SECONDS + 0.05).timeout


## Posicao (area) do botao Pular, para o host ignorar cliques nele.
func is_over_skip(point: Vector2) -> bool:
	return _skip_button != null and _skip_button.is_visible_in_tree() and _skip_button.get_global_rect().has_point(point)


# ---------------------------------------------------------------- quadro

func _run_frame(frame: Dictionary) -> void:
	frame_started.emit(_index)
	_narration = bool(frame.get("narration", false))
	_speaker = str(frame.get("speaker", ""))
	_apply_panel_layout()
	_fade_dim(float(frame.get("dim", 0.62 if _narration else 0.30)))

	# Quem esta visivel neste quadro.
	var wanted: Array = []
	if _narration:
		wanted = []
	elif frame.has("show"):
		wanted = (frame.get("show", []) as Array).duplicate()
	else:
		wanted = _visible_ids.duplicate()
	if _speaker != "" and not _narration and not wanted.has(_speaker):
		wanted.append(_speaker)
	for id in _visible_ids.duplicate():
		if not wanted.has(id):
			_set_sprite_visible(str(id), false, true)
	var arriving: Array = []
	for id in wanted:
		if not _visible_ids.has(id):
			arriving.append(id)
	_visible_ids = wanted
	for id in arriving:
		_set_sprite_visible(str(id), true, true)
	_refresh_highlight(true)

	# Painel e texto.
	var info: Dictionary = TutorialManager.character(_speaker)
	var speaker_color: Color = info.get("color", accent) as Color
	_name_label.text = str(frame.get("name", info.get("name", "")))
	_name_label.add_theme_color_override("font_color", speaker_color)
	_name_label.visible = _name_label.text != ""
	_counter_label.text = "%d/%d" % [_index + 1, _frames.size()]
	_text_label.text = str(frame.get("text", ""))
	_panel.modulate.a = 1.0
	_hint_label.text = "Clique, Espaço ou Enter para continuar" if _index < _frames.size() - 1 else "Clique, Espaço ou Enter para seguir"
	_hint_label.visible = true
	_waiting_next = false
	_start_typing()
	if _typing:
		await _text_done
	if _skipped:
		return

	# Entradas depois da fala ("apresentando" o personagem).
	var late: Array = frame.get("enter_on_complete", [])
	if not late.is_empty():
		await get_tree().create_timer(0.25).timeout
		for id in late:
			if not _visible_ids.has(id):
				_visible_ids.append(id)
				_set_sprite_visible(str(id), true, true)
		_refresh_highlight(true)
	_waiting_next = true
	await _next_pressed
	_waiting_next = false


func _start_typing() -> void:
	if _type_tween != null and _type_tween.is_valid():
		_type_tween.kill()
	if not _animations_enabled() or _text_label.text.is_empty():
		_text_label.visible_ratio = 1.0
		_typing = false
		return
	_text_label.visible_ratio = 0.0
	_typing = true
	var duration: float = clampf(float(_text_label.text.length()) / TYPE_CHARS_PER_SECOND, 0.3, 5.0)
	_type_tween = create_tween()
	_type_tween.tween_property(_text_label, "visible_ratio", 1.0, duration)
	_type_tween.finished.connect(_on_type_finished)


func _on_type_finished() -> void:
	if _typing:
		_typing = false
		_text_done.emit()


func _advance() -> void:
	if _skipped:
		return
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	if _typing:
		if _type_tween != null and _type_tween.is_valid():
			_type_tween.kill()
		_text_label.visible_ratio = 1.0
		_typing = false
		_text_done.emit()
		return
	if _waiting_next:
		_next_pressed.emit()


func _on_skip_pressed() -> void:
	if _skipped:
		return
	_skipped = true
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	skip_requested.emit()
	if _type_tween != null and _type_tween.is_valid():
		_type_tween.kill()
	if _typing:
		_typing = false
		_text_done.emit()
	_next_pressed.emit()


# ---------------------------------------------------------------- personagens

func _ensure_sprite(id: String) -> TextureRect:
	if _sprites.has(id):
		return _sprites[id] as TextureRect
	if TutorialManager.character(id).is_empty():
		return null
	var texture: Texture2D = TutorialManager.sprite_texture(id, variant)
	if texture == null:
		push_warning("NovelStage: sprite '%s' (%s) nao encontrado." % [id, variant])
		return null
	var rect: TextureRect = TextureRect.new()
	rect.name = "Sprite_%s" % id
	rect.texture = texture  # imagem COMPLETA: nenhum recorte por codigo
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	rect.visible = false
	rect.modulate.a = 0.0
	_sprite_layer.add_child(rect)
	if variant == "v2":
		# Sombra de contato: ancora o personagem no chao do cenario (atras do sprite, acompanha o fade).
		var shadow: TextureRect = TextureRect.new()
		shadow.name = "FloorShadow"
		shadow.texture = _shadow_texture()
		shadow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		shadow.stretch_mode = TextureRect.STRETCH_SCALE
		shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		shadow.show_behind_parent = true
		rect.add_child(shadow)
	_sprites[id] = rect
	return rect


static var _shadow_tex: GradientTexture2D = null

static func _shadow_texture() -> GradientTexture2D:
	if _shadow_tex == null:
		var gradient: Gradient = Gradient.new()
		gradient.set_color(0, Color(0.0, 0.0, 0.0, 0.55))
		gradient.set_color(1, Color(0.0, 0.0, 0.0, 0.0))
		var texture: GradientTexture2D = GradientTexture2D.new()
		texture.gradient = gradient
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(0.5, 0.5)
		texture.fill_to = Vector2(1.0, 0.5)
		texture.width = 128
		texture.height = 128
		_shadow_tex = texture
	return _shadow_tex


## Altura (px) do topo do quadro de dialogo de BAIXO a partir do topo da tela. Espelha _apply_panel_layout().
static func bottom_panel_top_y(view_height: float, compact: bool) -> float:
	return view_height - (236.0 if compact else 272.0)


## Retangulo do sprite "_1" (novels: corpo inteiro com escala por ALTURA em METROS; o quadro de baixo cobre o final do corpo).
## Usado pelo NovelStage (transicoes) e pela CutsceneIntro (Jales), para os dois ficarem padronizados.
## >>> Para mudar o tamanho/enquadramento, edite Paths.NOVEL_LAYOUT ("ppm", "visible", "top_margin"). <<<
static func novel_rect(character_id: String, view: Vector2, compact: bool, center_x: float) -> Rect2:
	var data: Dictionary = TutorialManager.sprite_set(character_id, "v1")
	if data.is_empty():
		return Rect2(Vector2.ZERO, Vector2(view.x * 0.3, view.y * 0.6))
	var layout: Dictionary = Paths.NOVEL_LAYOUT
	var panel_top: float = bottom_panel_top_y(view.y, compact)
	var ppm: float = view.y * float(layout.get("ppm", 0.62)) * (float(layout.get("compact_factor", 0.92)) if compact else 1.0)
	var visible_part: float = clampf(float(layout.get("visible", 0.50)), 0.2, 1.0)
	# O mais alto mostra "visible" do corpo acima do quadro; nunca deixa a cabeca passar do topo da tela:
	# se passar, reduz TODOS na mesma proporcao (mantem as alturas relativas).
	var tallest_px: float = ppm * CharacterHeights.tallest_m()
	var room_above: float = panel_top - view.y * float(layout.get("top_margin", 0.03))
	if tallest_px * visible_part > room_above and tallest_px > 0.0:
		ppm *= room_above / (tallest_px * visible_part)
		tallest_px = ppm * CharacterHeights.tallest_m()
	# Pes do mais alto ficam abaixo da borda do quadro (escondidos atras dele); os outros usam a MESMA linha dos pes.
	var feet_y: float = panel_top + tallest_px * (1.0 - visible_part)
	return _rect_from_meters(data, CharacterHeights.meters(character_id), ppm, center_x, feet_y)


## Retangulo da IMAGEM COMPLETA a partir da altura real (metros) e da escala (px de tela por metro).
static func _rect_from_meters(data: Dictionary, meters: float, ppm: float, center_x: float, feet_y: float) -> Rect2:
	var canvas: Vector2 = Vector2(data.get("size", Vector2i(1536, 2304)) as Vector2i)
	var foot_px: float = float(data.get("foot_y", canvas.y))
	var top_px: float = float(data.get("top_y", 0.0))
	var figure_px: float = maxf(foot_px - top_px, 1.0)
	var scale_value: float = (meters * ppm) / figure_px
	var size_px: Vector2 = canvas * scale_value
	var head_px: float = float(data.get("head_x", canvas.x * 0.5))
	return Rect2(Vector2(center_x - head_px * scale_value, feet_y - foot_px * scale_value), size_px)


## Retangulo (a IMAGEM COMPLETA do sprite) na tela.
##  - "v1" (novels): ver novel_rect(); rosto no slot horizontal;
##  - "v2" (cena final): PES na linha do chao do cenario (Paths.CUTSCENE_FLOOR), escala por altura em metros; no elenco
##    reunido, duas fileiras em perspectiva (fundo no chao mais alto e um pouco menor, frente no chao mais baixo);
##  - "v3" (legado, da cintura para cima): base visivel encostada na base da tela.
## V0.11.1: a escala vem de CharacterHeights (alto e baixo respeitam a altura real de cada personagem).
func _sprite_rect(id: String) -> Rect2:
	var data: Dictionary = TutorialManager.sprite_set(id, variant)
	var view: Vector2 = size
	if view.x <= 0.0 or view.y <= 0.0:
		view = Vector2(1280, 720)
	if data.is_empty():
		return Rect2(Vector2.ZERO, Vector2(view.x * 0.4, view.y))
	var compact: bool = ScreenTools.is_compact(self)
	var default_x: float = 0.26 if id == "jales" else 0.74
	var center_x: float = float(slots.get(id, default_x)) * view.x
	if variant == "v1":
		return novel_rect(id, view, compact, center_x)
	if variant == "v2":
		var front_floor: float = float(floor_info.get("front", 0.72))
		var back_floor: float = float(floor_info.get("back", 0.68))
		var meters: float = CharacterHeights.meters(id)
		var ppm: float = view.y * float(floor_info.get("ppm", 0.31)) * (0.92 if compact else 1.0)
		var feet_y: float = view.y * front_floor
		if not row_ids.is_empty() and row_ids.has(id):
			var count: int = row_ids.size()
			var slot: int = row_ids.find(id)
			var front: bool = slot % 2 == 0
			ppm = view.y * float(floor_info.get("row_ppm", 0.27)) * (0.92 if compact else 1.0) * (1.0 if front else 0.90)
			feet_y = view.y * (front_floor if front else back_floor)
			var t: float = 0.5 if count <= 1 else float(slot) / float(count - 1)
			center_x = view.x * (0.075 + 0.85 * t)
		return _rect_from_meters(data, meters, ppm, center_x, feet_y)
	# "v3": legado (recorte da cintura para cima, ancorado na base da tela), com o fator de altura suavizado.
	var canvas: Vector2 = Vector2(data.get("size", Vector2i(1664, 2080)) as Vector2i)
	var head_ratio: float = float(data.get("head_x", canvas.x * 0.5)) / canvas.x
	var foot_ratio: float = float(data.get("foot_y", canvas.y)) / canvas.y
	var height: float = view.y * (0.94 if compact else 1.0) * CharacterHeights.bust_scale(id)
	var width: float = height * canvas.x / canvas.y
	return Rect2(Vector2(center_x - head_ratio * width, view.y - foot_ratio * height), Vector2(width, height))


## Pivo (px dentro do sprite) = ponto dos PES: a escala de destaque cresce a partir do chao.
func _sprite_pivot(id: String, rect: Rect2) -> Vector2:
	var data: Dictionary = TutorialManager.sprite_set(id, variant)
	var canvas: Vector2 = Vector2(data.get("size", Vector2i(1536, 2304)) as Vector2i)
	return Vector2(rect.size.x * float(data.get("head_x", canvas.x * 0.5)) / canvas.x, rect.size.y * float(data.get("foot_y", canvas.y)) / canvas.y)


## Atualiza tamanho, pivo e sombra de contato do sprite para o retangulo atual.
func _fit_sprite(id: String, sprite: TextureRect, rect: Rect2) -> void:
	sprite.size = rect.size
	sprite.pivot_offset = _sprite_pivot(id, rect)
	var shadow: TextureRect = sprite.get_node_or_null("FloorShadow") as TextureRect
	if shadow != null:
		var pivot: Vector2 = sprite.pivot_offset
		var shadow_size: Vector2 = Vector2(rect.size.y * 0.30, rect.size.y * 0.050)
		shadow.size = shadow_size
		shadow.position = pivot - shadow_size * 0.5 + Vector2(0.0, shadow_size.y * 0.10)


func _set_sprite_visible(id: String, make_visible: bool, animate: bool) -> void:
	var sprite: TextureRect = _ensure_sprite(id)
	if sprite == null:
		return
	var rect: Rect2 = _sprite_rect(id)
	_fit_sprite(id, sprite, rect)
	var tween: Tween = create_tween().set_parallel(true)
	if make_visible:
		sprite.visible = true
		if animate and _animations_enabled():
			sprite.position = rect.position + Vector2(0.0, RISE_PIXELS)
			sprite.modulate.a = 0.0
			tween.tween_property(sprite, "position", rect.position, ENTER_SECONDS).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.tween_property(sprite, "modulate:a", 1.0, ENTER_SECONDS * 0.8)
		else:
			sprite.position = rect.position
			sprite.modulate.a = 1.0
	else:
		if animate and _animations_enabled():
			tween.tween_property(sprite, "position", rect.position + Vector2(0.0, RISE_PIXELS * 0.7), EXIT_SECONDS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			tween.tween_property(sprite, "modulate:a", 0.0, EXIT_SECONDS)
			tween.chain().tween_callback(func() -> void: sprite.visible = false)
		else:
			sprite.modulate.a = 0.0
			sprite.visible = false


func _refresh_highlight(animate: bool) -> void:
	for id in _sprites.keys():
		var sprite: TextureRect = _sprites[id] as TextureRect
		var speaking: bool = str(id) == _speaker or _speaker == ""
		var target: Color = Color.WHITE if speaking else DIMMED
		target.a = sprite.modulate.a
		var in_row: bool = not row_ids.is_empty() and row_ids.has(str(id))
		var base_z: int = 1
		if in_row and row_ids.find(str(id)) % 2 == 1:
			base_z = 0
		sprite.z_index = 5 if str(id) == _speaker else base_z
		# Elenco em pe no chao: quem fala cresce um pouco a partir dos PES (nunca sai do chao).
		var target_scale: Vector2 = Vector2.ONE * (1.04 if (in_row and str(id) == _speaker) else 1.0)
		var base_position: Vector2 = _sprite_rect(str(id)).position
		if animate and _animations_enabled() and sprite.visible:
			var tween: Tween = create_tween().set_parallel(true)
			tween.tween_property(sprite, "modulate", Color(target.r, target.g, target.b, sprite.modulate.a), 0.25)
			tween.tween_property(sprite, "scale", target_scale, 0.25)
			if sprite.modulate.a > 0.9:
				tween.tween_property(sprite, "position", base_position, 0.25)
		else:
			sprite.modulate = target
			sprite.scale = target_scale
			if sprite.modulate.a > 0.9:
				sprite.position = base_position


# ---------------------------------------------------------------- UI

func _build_ui() -> void:
	# Desfoque do cenario (primeiro filho: desfoca so o que esta ATRAS do novel).
	_blur = NovelBlur.create(blur_strength)
	add_child(_blur)
	NovelBlur.fade_in(_blur)

	_dimmer = ColorRect.new()
	_dimmer.name = "Dimmer"
	_dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dimmer.color = Color(0.0, 0.0, 0.0, 0.30)
	_dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dimmer)

	_sprite_layer = Control.new()
	_sprite_layer.name = "Sprites"
	_sprite_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_sprite_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_sprite_layer)

	_panel = PanelContainer.new()
	_panel.name = "DialogPanel"
	_panel.z_index = 20
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_panel)

	_margin = MarginContainer.new()
	_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 8)
	_margin.add_child(box)

	var header: HBoxContainer = HBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_theme_constant_override("separation", 12)
	box.add_child(header)

	_name_label = Label.new()
	_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	_name_label.add_theme_constant_override("shadow_offset_x", 2)
	_name_label.add_theme_constant_override("shadow_offset_y", 2)
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(_name_label)

	_counter_label = Label.new()
	_counter_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0, 0.72))
	_counter_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(_counter_label)

	_text_label = Label.new()
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_text_label.add_theme_color_override("font_color", Color(0.95, 0.96, 1.0))
	_text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(_text_label)

	_hint_label = Label.new()
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.add_theme_color_override("font_color", Color(0.86, 0.88, 0.95, 0.85))
	_hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(_hint_label)

	_skip_button = Button.new()
	_skip_button.name = "SkipButton"
	_skip_button.text = "Pular"
	_skip_button.z_index = 40
	_skip_button.visible = show_skip
	_skip_button.pressed.connect(_on_skip_pressed)
	add_child(_skip_button)


func _layout() -> void:
	if _panel == null:
		return
	var compact: bool = ScreenTools.is_compact(self)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.04, 0.09, 0.90)
	style.border_color = Color(accent.r, accent.g, accent.b, 0.88)
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 10
	_panel.add_theme_stylebox_override("panel", style)
	var side: int = 22 if compact else 34
	_margin.add_theme_constant_override("margin_left", side)
	_margin.add_theme_constant_override("margin_right", side)
	_margin.add_theme_constant_override("margin_top", 16 if compact else 22)
	_margin.add_theme_constant_override("margin_bottom", 12 if compact else 16)
	_name_label.add_theme_font_size_override("font_size", 28 if compact else 34)
	_counter_label.add_theme_font_size_override("font_size", 15 if compact else 17)
	_text_label.add_theme_font_size_override("font_size", 19 if compact else 25)
	_text_label.custom_minimum_size = Vector2(0, (56 if compact else 66) if panel_top else (66 if compact else 94))
	_hint_label.add_theme_font_size_override("font_size", 14 if compact else 17)
	ButtonStyles.apply_cutscene(_skip_button, "cutscene_skip", ScreenTools.button_size(self, Vector2(106, 40), Vector2(92, 36)), ScreenTools.responsive_font(self, 17, 14))
	var skip_h: float = 44.0 if not compact else 38.0
	var skip_w: float = 120.0 if not compact else 104.0
	_skip_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_skip_button.offset_left = -skip_w - 24.0
	_skip_button.offset_right = -24.0
	_skip_button.offset_top = 20.0
	_skip_button.offset_bottom = 20.0 + skip_h
	_apply_panel_layout()
	for id in _sprites.keys():
		var sprite: TextureRect = _sprites[id] as TextureRect
		var rect: Rect2 = _sprite_rect(str(id))
		_fit_sprite(str(id), sprite, rect)
		if sprite.visible and sprite.modulate.a > 0.95:
			sprite.position = rect.position


func _apply_panel_layout() -> void:
	if _panel == null:
		return
	var compact: bool = ScreenTools.is_compact(self)
	if _narration:
		_panel.set_anchors_preset(Control.PRESET_CENTER)
		_panel.anchor_left = 0.12
		_panel.anchor_right = 0.88
		_panel.anchor_top = 0.26
		_panel.anchor_bottom = 0.74
		_panel.offset_left = 0.0
		_panel.offset_right = 0.0
		_panel.offset_top = 0.0
		_panel.offset_bottom = 0.0
		_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_text_label.add_theme_font_size_override("font_size", 23 if compact else 30)
	elif panel_top:
		# Personagens em pe no chao: a caixa fica no topo, mais baixa (so nome + fala + dica).
		_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
		_panel.offset_left = 34.0 if compact else 54.0
		# O botao "Pular" fica ao lado da caixa, na mesma linha (nao cobre os pes de ninguem).
		_panel.offset_right = -((104.0 if compact else 120.0) + 36.0) if show_skip else -_panel.offset_left
		_panel.offset_top = 12.0 if compact else 18.0
		_panel.offset_bottom = _panel.offset_top + (146.0 if compact else 164.0)
		_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		_text_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		_text_label.add_theme_font_size_override("font_size", 18 if compact else 23)
	else:
		_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		_panel.offset_left = 34.0 if compact else 54.0
		_panel.offset_right = -_panel.offset_left
		_panel.offset_top = -236.0 if compact else -272.0
		_panel.offset_bottom = -40.0 if compact else -58.0
		_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		_text_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		_text_label.add_theme_font_size_override("font_size", 19 if compact else 25)


func _fade_dim(alpha: float) -> void:
	if _dim_tween != null and _dim_tween.is_valid():
		_dim_tween.kill()
	if not _animations_enabled():
		_dimmer.color.a = alpha
		return
	_dim_tween = create_tween()
	_dim_tween.tween_property(_dimmer, "color:a", alpha, 0.4)


# ---------------------------------------------------------------- entrada

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree() or _skipped:
		return
	if event is InputEventMouseButton and event.pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		if is_over_skip((event as InputEventMouseButton).position):
			return
		_advance()
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch and event.pressed:
		if is_over_skip((event as InputEventScreenTouch).position):
			return
		_advance()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not (event as InputEventKey).echo:
		match (event as InputEventKey).keycode:
			KEY_SPACE, KEY_ENTER, KEY_KP_ENTER:
				_advance()
				get_viewport().set_input_as_handled()


func _animations_enabled() -> bool:
	return not has_node("/root/SettingsManager") or SettingsManager.animations_enabled()
