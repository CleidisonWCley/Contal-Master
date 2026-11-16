extends Control
## V0.15 - Conversa DEPOIS de cada minigame.
##
## Campanha:   anfitriao comenta o desempenho -> (dica) -> Jales chama para a proxima estacao.
##             Desvio Logico (ultima): a Natalia comenta, faz o CORTE (reuniao no escritorio, "vou me arrumar") e roda o
##             INTERLUDIO da estrada a noite antes da cena final.
## Modo livre: anfitriao comenta o desempenho -> UMA novidade de lore (perfil / trecho) ou uma dica.
##
## Quem monta os quadros e DebriefBuilder (plano em GameManager.debrief_plan). Esta cena so os exibe com o NovelStage
## (mesmo motor das transicoes: cenario da fase desfocado, sprites "_1", caixa de dialogo embaixo).
## "Pular" (ou Esc) encerra a conversa inteira e segue o fluxo normal. Ao fim chama GameManager.after_debrief().
##
## INTERLUDIO: o cenario vem de Paths.CUTSCENE_BG_INTERLUDE[id]. Se NENHUM arquivo existir (hoje: 14_estrada.png), a cena
## pinta um gradiente noturno (Paths.INTERLUDE_FALLBACK[id]). Basta colocar a imagem em assets/background/14_estrada.png
## (ou assets/background/cutcines/14_estrada.png) para ela entrar sozinha, sem mexer em codigo.
##
## Web: nada pesado e carregado no quadro do clique; GameManager._warm_for_debrief() aquece cenario e sprites na LoadingScreen.

const StageTransitionScript := preload("res://scenes/cutscenes/StageTransition.gd")

const FADE_IN_SECONDS := 0.35
const FADE_OUT_SECONDS := 0.30
const INTERLUDE_FADE_SECONDS := 0.5
const SHADE_ALPHA := 0.34

var plan: Dictionary = {}
var phase_key: String = ""
var accent: Color = Color(1.0, 0.84, 0.12)

var novel: NovelStage
var background_image: TextureRect
var background_shade: ColorRect
var blur_layer: ColorRect
var fade_rect: ColorRect
var _finished: bool = false
var _skip_all: bool = false


func _ready() -> void:
	plan = GameManager.debrief_plan
	phase_key = str(plan.get("phase_key", ""))
	if (plan.get("frames", []) as Array).is_empty():
		call_deferred("_finish")
		return
	_build_scene()
	_fade_from_black()
	NovelBlur.fade_in(blur_layer, 0.7)
	_run()


func _input(event: InputEvent) -> void:
	if _finished:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		_skip_all = true
		if novel != null:
			novel._on_skip_pressed()
		else:
			_finish()


func _animations_enabled() -> bool:
	return not has_node("/root/SettingsManager") or SettingsManager.animations_enabled()


# ---------------------------------------------------------------- cena

func _style(field: String, fallback: Color) -> Color:
	var style: Dictionary = StageTransitionScript.STYLE_MAP.get(phase_key, {}) as Dictionary
	var value: Variant = style.get(field, fallback)
	return value if value is Color else fallback


func _build_scene() -> void:
	accent = _style("accent", Color(1.0, 0.84, 0.12))
	var bg_color: Color = _style("bg", Color(0.02, 0.02, 0.12))

	var base: ColorRect = ColorRect.new()
	base.name = "Background"
	base.set_anchors_preset(Control.PRESET_FULL_RECT)
	base.color = bg_color
	add_child(base)

	background_image = TextureRect.new()
	background_image.name = "NovelBackground"
	background_image.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg_path: String = str(Paths.CUTSCENE_BG_BY_PHASE.get(phase_key, ""))
	if bg_path != "" and ResourceLoader.exists(bg_path):
		var texture: Resource = load(bg_path)
		if texture is Texture2D:
			background_image.texture = texture as Texture2D
	add_child(background_image)

	background_shade = ColorRect.new()
	background_shade.name = "NovelBackgroundShade"
	background_shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background_shade.color = Color(bg_color.r, bg_color.g, bg_color.b, SHADE_ALPHA if background_image.texture != null else 0.0)
	add_child(background_shade)

	blur_layer = NovelBlur.create(1.0)
	blur_layer.name = "DebriefBlur"
	add_child(blur_layer)

	novel = NovelStage.new()
	novel.z_index = 30
	add_child(novel)
	# Mesmo padrao das transicoes: sprites "_1" (corpo inteiro); o desfoque do cenario ja e do blur_layer.
	novel.configure({"accent": accent, "show_skip": true, "variant": "v1", "blur": 0.0})
	novel.frame_started.connect(_on_frame_started)

	fade_rect = ColorRect.new()
	fade_rect.name = "Fade"
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.color = Color(0.0, 0.0, 0.0, 1.0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.z_index = 100
	add_child(fade_rect)


# ---------------------------------------------------------------- fluxo

func _run() -> void:
	var frames: Array = plan.get("frames", []) as Array
	await get_tree().create_timer(0.3).timeout
	if not is_inside_tree():
		return
	var completed: bool = await novel.play_frames(frames)
	if not is_inside_tree() or _finished:
		return
	if completed and not _skip_all:
		await _play_interlude()
	_finish()


## Marca perfil/trecho de lore como visto quando o quadro COMECA (quem pula antes dele nao perde a novidade).
func _on_frame_started(frame_index: int) -> void:
	var frames: Array = novel._frames if novel != null else []
	if frame_index < 0 or frame_index >= frames.size():
		return
	var lore: Dictionary = (frames[frame_index] as Dictionary).get("lore", {}) as Dictionary
	if lore.is_empty():
		return
	if str(lore.get("kind", "")) == "profile":
		LoreManager.mark_profile_seen(str(lore.get("id", "")))
	else:
		LoreManager.mark_fragment_seen(str(lore.get("id", "")))


## Corte para o interludio (ex.: estrada a noite): escurece, troca o cenario, mostra a narracao e segue.
func _play_interlude() -> void:
	var interlude: Dictionary = plan.get("interlude", {}) as Dictionary
	var frames: Array = interlude.get("frames", []) as Array
	if interlude.is_empty() or frames.is_empty():
		return
	await _fade_to(1.0, INTERLUDE_FADE_SECONDS)
	if not is_inside_tree():
		return
	_show_interlude_background(str(interlude.get("background", "")))
	await _fade_to(0.0, INTERLUDE_FADE_SECONDS)
	if not is_inside_tree():
		return
	await novel.play_frames(frames)


## Cenario do interludio: imagem se existir; senao gradiente noturno de reserva (nunca tela vazia).
func _show_interlude_background(interlude_id: String) -> void:
	if blur_layer != null:
		blur_layer.visible = false
	var candidates: Array = Paths.CUTSCENE_BG_INTERLUDE.get(interlude_id, []) as Array
	var path: String = Paths.first_existing(candidates)
	if path != "":
		var texture: Resource = load(path)
		if texture is Texture2D:
			background_image.texture = texture as Texture2D
			background_shade.color = Color(0.0, 0.0, 0.0, 0.18)
			return
		push_warning("StageDebrief: '%s' existe mas nao e uma imagem; usando a cor de reserva." % path)
	background_image.texture = _fallback_texture(interlude_id)
	background_shade.color = Color(0.0, 0.0, 0.0, 0.0)


static func _fallback_texture(interlude_id: String) -> GradientTexture2D:
	var colors: Array = Paths.INTERLUDE_FALLBACK.get(interlude_id, [Color(0.02, 0.03, 0.08), Color(0.07, 0.05, 0.15)]) as Array
	var gradient: Gradient = Gradient.new()
	gradient.set_color(0, colors[0] as Color)
	gradient.set_color(1, colors[1] as Color)
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_LINEAR
	texture.fill_from = Vector2(0.5, 0.0)
	texture.fill_to = Vector2(0.5, 1.0)
	texture.width = 8
	texture.height = 256
	return texture


func _fade_from_black() -> void:
	await _fade_to(0.0, FADE_IN_SECONDS)


func _fade_to(alpha: float, seconds: float) -> void:
	if fade_rect == null or not is_inside_tree():
		return
	if not _animations_enabled() or seconds <= 0.0:
		fade_rect.color = Color(0.0, 0.0, 0.0, alpha)
		return
	var tween: Tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0.0, 0.0, 0.0, alpha), seconds)
	await tween.finished


func _finish() -> void:
	if _finished:
		return
	_finished = true
	if fade_rect != null:
		await _fade_to(1.0, FADE_OUT_SECONDS)
	if is_inside_tree():
		GameManager.after_debrief()
