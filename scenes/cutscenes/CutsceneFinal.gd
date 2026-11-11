extends Control
## Cutscene final Roteiro em res://scripts/data/dialogues/final.json
##
## Sequencia (todos os blocos usam o NovelStage com os sprites "_2", corpo inteiro, com os PES no chao do cenario):
##   ESCRITORIO (09, noite)                 CORREDOR (012)                      SALA DE REUNIAO (10) - SEM cortes solo (V0.13.1)
##   1. Despedida do Jales                  3. Natalia (natalia_2) conversa     4. Elenco agradece em JANELA DE 3: um entra, o mais
##   2. Natalia chama para a reuniao           com o jogador: 1 quadro             antigo SAI andando pela lateral; os 3 ultimos ficam
##      (e SAI andando para o corredor                                          5. Todos saem; Jales volta pela ESQUERDA e Ariel pela
##       enquanto a cena troca)                                                    DIREITA e conversam para apresentar o placar
##                                                                              6. O score SOBE
##                                                                              7. Jales CENTRALIZADO: "Antes que voce va..." + fala final
##   8. Creditos (rolagem)
##   9. CENA FINAL (11): elenco reunido, cortina de brilho dourado, LOGO do ContalMaster + "Obrigado por jogar!"
##  10. A tela escurece -> GAME OVER -> voltar ao menu
## Cada bloco escolhe o cenario pela chave "backgrounds" do final.json (ids em Paths.CUTSCENE_BG_FINAL).
## "Pular" pula apenas o bloco atual; Esc volta ao menu.

const BrandText := preload("res://scripts/ui/BrandText.gd")

const CREDIT_SCROLL_SPEED := 48.0
## Cena final (V0.11): tempos em segundos.
const FINALE_REVEAL_SECONDS := 3.4      # cortina dourada revelando a imagem
const FINALE_HOLD_SECONDS := 1.5        # imagem limpa, so o brilho
const FINALE_TITLE_SWEEP_SECONDS := 2.3 # segunda cortina, mais suave, junto com o titulo
const FINALE_TITLE_FADE_SECONDS := 1.2
const FINALE_TITLE_HOLD_SECONDS := 4.6  # titulo na tela antes de escurecer (clique adianta)
const FINALE_DARKEN_SECONDS := 1.4
const FINALE_MIN_SKIP_SECONDS := 1.2
const FINALE_DIM_ALPHA := 0.52
const FINALE_VEIL_ALPHA := 0.86
const FINALE_GOLD := Color(1.0, 0.84, 0.34)
const FINALE_GOLD_DEEP := Color(1.0, 0.70, 0.16)
const FINALE_MAX_SPARKLES := 140
const SCORE_COUNT_SECONDS := 2.8
## ---- SALA DE REUNIAO (V0.13.1) --- ajustes manuais ficam aqui ----
## Quantos personagens ficam em cena ao mesmo tempo durante os agradecimentos.
const CAST_WINDOW := 3
## Posicao horizontal (0..1, centro do ROSTO) dos 3 lugares: esquerda, meio, direita.
const CAST_SLOTS := [0.20, 0.50, 0.80]
## Jales (esquerda) e Ariel (direita) na conversa do placar.
const SCORE_SLOT_JALES := 0.27
const SCORE_SLOT_ARIEL := 0.73
## Pausa (s) com a sala vazia antes de Jales e Ariel voltarem.
const EMPTY_ROOM_SECONDS := 0.45
## Jales centralizado na fala final.
const CLOSING_SLOT_JALES := 0.50
## Escritorio: lado por onde a Natalia sai andando rumo ao corredor ("left" ou "right").
const NATALIA_EXIT_SIDE := "right"
## Fracao da saida da Natalia que acontece ANTES de o fade para o corredor comecar (0.5 = sobrepoe metade).
const NATALIA_EXIT_WAIT := 0.5
## V0.13.2: conversa Jales <-> Natalia no escritorio. Jales na ESQUERDA e Natalia na DIREITA (antes o Jales ficava no centro).
const MEETING_SLOT_JALES := 0.24
const MEETING_SLOT_NATALIA := 0.76
## V0.13.2: cena estatica de CHEGADA a sala de reuniao (ArrivalScene), entre o corredor e os agradecimentos.
## >>> Para REMOVER a cena: ARRIVAL_ENABLED := false (o fluxo volta a ir direto do corredor para a sala). <<<
const ARRIVAL_ENABLED := true
## Pausa (s) com a tela preta antes de a sala de reuniao reaparecer depois da cena de chegada.
const ARRIVAL_TO_ROOM_SECONDS := 0.35
## Logo do jogo na cena final (V0.13.1). Tamanho (desktop / compacto), respeitando a proporcao 816x306.
const LOGO_SIZE := Vector2(760, 285)
const LOGO_SIZE_COMPACT := Vector2(420, 158)
const LOGO_BREATH_SCALE := 0.022
## Jogos que definem a referencia de pontuacao por dificuldade (mesma escala da conquista Platina).
const REFERENCE_GAMES := ["show_do_bilhao", "maleta_certa", "perseguicao", "stop", "batalha_naval"]
const GOLD := Color(1.0, 0.82, 0.16)

var particles: Array[Dictionary] = []
var elapsed: float = 0.0
var act: String = "novel"
var final_score: int = 0
var story: Dictionary = {}
var tier: Dictionary = {}
var can_click: bool = true
var counting: bool = false
var shown_score: float = 0.0

var background_rect: TextureRect
var background_id: String = ""
var dimmer: ColorRect
var effects_canvas: Control
var novel: NovelStage
var score_panel: PanelContainer
var score_layer: Control
var score_title_label: Label
var score_value_label: Label
var difficulty_label: Label
var tier_label: Label
var record_label: Label
var motivation_label: Label
var score_hint_label: Label
var credits_layer: Control
var credits_box: VBoxContainer
var gameover_layer: Control
var gameover_label: Label
var menu_button: Button
var fade_rect: ColorRect

# ---- cena final (V0.11) ----
var finale_layer: Control
var finale_veil: Control        # veu escuro que a cortina dourada "puxa" para revelar a imagem
var finale_dim: ColorRect       # escurece a imagem para o titulo ler bem
var finale_fx: Control          # faixa/cortina dourada + brilhos (mistura aditiva)
var finale_box: VBoxContainer
var finale_logo: TextureRect              # V0.13.1: logo contalmaster_logo.png (Paths.LOGO_CONTALMASTER)
var finale_title_label: RichTextLabel     # texto de reserva: so aparece se o logo nao carregar
var finale_line: ColorRect
var finale_thanks_label: Label
var finale_subtitle_label: Label
var finale_sparkles: Array[Dictionary] = []
var finale_sweep_pos: float = -1.0   # 0..1 = cortina atravessando a tela; -1 = inativa
var finale_veil_on: bool = false
var finale_stage: int = 0            # 0 revelando, 1 imagem limpa, 2 titulo na tela
var finale_leaving: bool = false
var finale_token: int = 0            # invalida corrotinas antigas (pular / sair)
var finale_tweens: Array[Tween] = []
var finale_spark_timer: float = 0.0

signal _score_continue

func _ready() -> void:
	randomize()
	final_score = ScoreManager.get_score()
	_load_story()
	_build_scene()
	_reset_particles(42)
	if has_node("/root/AudioManager"):
		AudioManager.play_music("musica_final")
	_fade_from_black()
	_run_story()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_responsive_layout()
		if _animations_enabled():
			_reset_particles(42)

func _process(delta: float) -> void:
	elapsed += delta
	if _animations_enabled():
		_update_particles(delta)
		if effects_canvas != null:
			effects_canvas.visible = act != "finale"  # a cena final tem o proprio brilho dourado
			effects_canvas.queue_redraw()
	else:
		if effects_canvas != null:
			effects_canvas.visible = false
	_update_credits(delta)
	_update_finale(delta)
	_update_gameover()
	_update_score_hint()

func _input(event: InputEvent) -> void:
	if not can_click:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		_return_to_menu()
		return
	if act == "novel" or act == "arrival":
		return # o NovelStage (ou a ArrivalScene) cuida de clique, Espaco e Enter
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_pointer_advance(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_handle_pointer_advance(event.position)
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE, KEY_ENTER, KEY_KP_ENTER:
				_advance_act()

func _handle_pointer_advance(point: Vector2) -> void:
	if not ClickGuard.accept():
		return
	if _is_pointer_on_menu_button(point):
		return
	_advance_act()

func _is_pointer_on_menu_button(point: Vector2) -> bool:
	return menu_button != null and menu_button.is_visible_in_tree() and menu_button.get_global_rect().has_point(point)

func _animations_enabled() -> bool:
	return not has_node("/root/SettingsManager") or SettingsManager.animations_enabled()

# ---------------------------------------------------------------- roteiro

func _load_story() -> void:
	story = {}
	if FileAccess.file_exists(Paths.DIALOGUE_FINAL):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(Paths.DIALOGUE_FINAL))
		if parsed is Dictionary:
			story = parsed as Dictionary
	tier = _pick_tier()

## Referencia de pontos por dificuldade: PLATINUM_SCORE_HARD escalado pelo valor dos acertos de cada nivel.
func _reference_score() -> float:
	var difficulty: String = DifficultyManager.get_difficulty()
	var current: float = 0.0
	var hard: float = 0.0
	for key in REFERENCE_GAMES:
		current += float(DifficultyManager.get_correct_points(key, difficulty))
		hard += float(DifficultyManager.get_correct_points(key, "dificil"))
	if hard <= 0.0:
		return float(AchievementManager.PLATINUM_SCORE_HARD)
	return float(AchievementManager.PLATINUM_SCORE_HARD) * current / hard

func _pick_tier() -> Dictionary:
	var tiers: Array = story.get("tiers", [])
	var ratio: float = float(final_score) / maxf(_reference_score(), 1.0)
	for item in tiers:
		if item is Dictionary and ratio >= float((item as Dictionary).get("min_ratio", 0.0)):
			return item as Dictionary
	if not tiers.is_empty() and tiers.back() is Dictionary:
		return tiers.back() as Dictionary
	return {"id": "recomeco", "title": "Revisor", "ariel": "Vamos ver o placar.", "jales": [{"title": "Obrigado!", "text": "Obrigado por jogar o ContalMaster!"}]}

func _frames_of(key: String) -> Array:
	var result: Array = []
	for item in story.get(key, []):
		if item is Dictionary:
			result.append((item as Dictionary).duplicate(true))
	return result

func _run_story() -> void:
	novel = NovelStage.new()
	novel.z_index = 30
	add_child(novel)
	# Cena final: sprites "_2" (corpo inteiro) com os pes no chao; fundo desfocado e caixa limpa (nome + fala).
	novel.configure({"accent": GOLD, "show_skip": true, "variant": "v2"})
	await get_tree().create_timer(0.6).timeout

	# ---- ESCRITORIO (noite) ----
	# 1) Despedida do Jales (sozinho, em pe no chao; a mesa fica a esquerda).
	await _play_block(_frames_of("farewell"), {"slots": {"jales": 0.60}})
	# 2) Natalia chega (sobe) e chama para a sala de reuniao; o Jales sai de cena no 2o quadro.
	#    V0.13.1: ao fim, a Natalia SAI ANDANDO pela lateral rumo ao corredor enquanto o fade da proxima cena ja comeca.
	await _cut()
	await _play_block(_frames_of("meeting_call"), {
		"slots": {"jales": MEETING_SLOT_JALES, "natalia": MEETING_SLOT_NATALIA},
		"exit_slide": true,
		"exit_dirs": {"natalia": NATALIA_EXIT_SIDE},
		"exit_wait": NATALIA_EXIT_WAIT
	})
	# ---- CORREDOR ----
	# 3) Corte para o corredor: Natalia (natalia_2) conversa com o jogador em 1 quadro de apoio (V0.13.4: resumo da narrativa; eram 2).
	await _cut(_bg_id("corridor"))
	#    V0.13.2: ao fim, a Natalia segue andando para a porta (lateral) e a tela escurece para a cena de chegada.
	await _play_block(_frames_of("corridor"), {
		"slots": {"natalia": 0.50},
		"exit_slide": ARRIVAL_ENABLED,
		"exit_dirs": {"natalia": "right"},
		"exit_wait": 0.7
	})
	# ---- CHEGADA (V0.13.2): tela escura, porta abre, luzes sobem e a Natalia recebe o jogador (card pequeno, sem botao) ----
	var arrived: bool = false
	if ARRIVAL_ENABLED:
		arrived = await _play_arrival()
	if not is_inside_tree():
		return
	# ---- SALA DE REUNIAO (V0.13.1: um unico corte para entrar; dali em diante NAO ha mais cortes solo) ----
	# 4) Agradecimentos: 3 personagens por vez; o mais antigo sai andando quando entra o proximo.
	#    Depois da cena de chegada a tela ja esta preta: so troca o cenario e clareia (sem novo corte).
	if arrived:
		await _enter_room_from_arrival()
	else:
		await _cut(_bg_id("cast_thanks"))
	await _play_block(_cast_frames(), {"exit_slide": true})
	if not is_inside_tree():
		return
	# Sala vazia por um instante: todos saíram.
	await get_tree().create_timer(EMPTY_ROOM_SECONDS if _animations_enabled() else 0.05).timeout
	# 5) Jales volta pela esquerda e Ariel pela direita e conversam para apresentar o placar (mesma cena, sem corte).
	await _play_block(_score_dialogue_frames(), {
		"slots": {"jales": SCORE_SLOT_JALES, "ariel": SCORE_SLOT_ARIEL},
		"exit_slide": true
	})
	# 6) O score sobe.
	await _show_score_act()
	# 7) Jales CENTRALIZADO, na mesma sala (sem corte): "Antes que você vá..." + fala final (4 variacoes). Depois, creditos.
	await _play_block(_closing_frames(), {"slots": {"jales": CLOSING_SLOT_JALES}})
	if is_inside_tree():
		_show_credits_act()

## V0.13.2: cena de CHEGADA (ArrivalScene). Retorna true se a cena rodou (a tela fica PRETA ao fim) e false se
## faltou a imagem/roteiro (aí o fluxo segue como antes, com o corte normal). Roteiro: final.json > arrival.
func _play_arrival() -> bool:
	var data: Dictionary = story.get("arrival", {}) as Dictionary
	var text_value: String = str(data.get("text", "")).strip_edges()
	var path: String = str(Paths.CUTSCENE_BG_FINAL.get(_bg_id("arrival") if _bg_id("arrival") != "" else "entrada_sala", ""))
	if text_value == "" or path == "" or not ResourceLoader.exists(path):
		push_warning("CutsceneFinal: cena de chegada ignorada (falta final.json > arrival ou a imagem 13_entrada_sala_reuniao).")
		return false
	var texture: Texture2D = _load_texture_safe(path)
	if texture == null:
		push_warning("CutsceneFinal: nao foi possivel carregar '%s' (reimporte a imagem no Godot). Cena de chegada ignorada." % path)
		return false
	var speaker: String = str(data.get("speaker", "natalia"))
	var info: Dictionary = TutorialManager.character(speaker)
	act = "arrival"
	novel.visible = false
	score_layer.visible = false
	var arrival: ArrivalScene = ArrivalScene.new()
	arrival.name = "ArrivalScene"
	arrival.z_index = 100  # acima do novel (30); o fade_rect (500) continua por cima de tudo
	arrival.setup(
		texture,
		str(data.get("name", info.get("name", "Natalia"))),
		info.get("color", Color(0.0, 0.88, 1.0)) as Color,
		text_value
	)
	add_child(arrival)
	await arrival.play()
	if not is_inside_tree():
		return true
	# A arrival termina com a tela preta: cobre com o fade do host ANTES de remove-la (sem piscar).
	fade_rect.color = Color(0.0, 0.0, 0.0, 1.0)
	arrival.queue_free()
	return true

## Carrega uma imagem sem gerar erro se o cache de importacao (.godot/imported) estiver faltando: nesse caso, no editor,
## le o PNG direto do disco. Em exportacao o cache sempre existe. Retorna null se nada funcionar.
func _load_texture_safe(path: String) -> Texture2D:
	var remap_ok: bool = true
	var import_path: String = path + ".import"
	if FileAccess.file_exists(import_path):
		var config: ConfigFile = ConfigFile.new()
		if config.load(import_path) == OK:
			var cached: String = str(config.get_value("remap", "path", ""))
			remap_ok = cached == "" or FileAccess.file_exists(cached)
	if remap_ok:
		var loaded: Resource = load(path)
		if loaded is Texture2D:
			return loaded as Texture2D
	if FileAccess.file_exists(path):
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
		if image != null and not image.is_empty():
			image.generate_mipmaps()
			return ImageTexture.create_from_image(image)
	return null

## Apos a cena de chegada: com a tela preta, volta o cenario da sala de reuniao e clareia.
func _enter_room_from_arrival() -> void:
	_set_background(_bg_id("cast_thanks"))
	if _animations_enabled():
		await get_tree().create_timer(ARRIVAL_TO_ROOM_SECONDS).timeout
		var tween: Tween = create_tween()
		tween.tween_property(fade_rect, "color:a", 0.0, 0.55)
	else:
		fade_rect.color.a = 0.0

## Mostra um bloco de novel. O chao e a posicao da caixa de dialogo vem do cenario atual (Paths.CUTSCENE_FLOOR).
func _play_block(frames: Array, layout: Dictionary) -> void:
	if frames.is_empty() or not is_inside_tree():
		return
	act = "novel"
	score_layer.visible = false
	var floor_data: Dictionary = Paths.CUTSCENE_FLOOR.get(background_id, {}) as Dictionary
	var full_layout: Dictionary = layout.duplicate()
	full_layout["floor"] = floor_data
	full_layout["panel_top"] = false  # V0.11.1: caixa SEMPRE embaixo (padrao das novels); ela cobre parte das pernas/pes
	novel.apply_layout(full_layout)
	novel.visible = true
	await novel.play_frames(frames)

## Agradecimentos em JANELA de CAST_WINDOW personagens (V0.13.1): quem fala entra (sobe) num lugar livre; quando a
## janela esta cheia, o mais antigo SAI andando pela lateral e o novo ocupa o lugar dele. Os ultimos 3 ficam em cena.
## Cada quadro recebe: show (quem esta em cena), slots (lugar de quem entra) e slide (quem sai e por qual lado).
func _cast_frames() -> Array:
	var frames: Array = _frames_of("cast_thanks")
	var window: Array = []       # ids em cena, do mais antigo ao mais novo
	var slot_of: Dictionary = {} # id -> indice do lugar (0 esq, 1 meio, 2 dir)
	var exits: int = 0
	for frame in frames:
		var speaker: String = str(frame.get("speaker", ""))
		var slide: Dictionary = {}
		var frame_slots: Dictionary = {}
		if speaker != "" and not window.has(speaker):
			if window.is_empty() and exits == 0:
				slide[speaker] = "left"  # V0.13.2: o primeiro (Jales) vem andando ate o jogador, pela esquerda
			var place: int = -1
			if window.size() >= CAST_WINDOW:
				var leaving: String = str(window.pop_front())
				place = int(slot_of.get(leaving, 0))
				slide[leaving] = _door_side(place, exits)
				exits += 1
			else:
				place = _free_place(window, slot_of)
			slot_of[speaker] = place
			window.append(speaker)
			frame_slots[speaker] = float(CAST_SLOTS[clampi(place, 0, CAST_SLOTS.size() - 1)])
		frame["show"] = window.duplicate()
		frame["slots"] = frame_slots
		frame["slide"] = slide
		frame["dim"] = 0.22
	return frames

## Primeiro lugar (0..CAST_WINDOW-1) que nenhum dos que estao em cena ocupa.
func _free_place(window: Array, slot_of: Dictionary) -> int:
	for place in range(CAST_WINDOW):
		var taken: bool = false
		for id in window:
			if int(slot_of.get(str(id), -1)) == place:
				taken = true
				break
		if not taken:
			return place
	return 0

## Lado da "porta" por onde sai quem estava no lugar dado; o do meio alterna (direita, esquerda, direita...).
func _door_side(place: int, exit_count: int) -> String:
	if place <= 0:
		return "left"
	if place >= CAST_WINDOW - 1:
		return "right"
	return "right" if exit_count % 2 == 0 else "left"

## Conversa Jales <-> Ariel para apresentar o placar (mesma sala, Jales na esquerda e Ariel na direita).
## Textos: final.json > score_dialogue (Jales) e tiers[].ariel (Ariel).
func _score_dialogue_frames() -> Array:
	var dialogue: Dictionary = story.get("score_dialogue", {}) as Dictionary
	var both: Array = ["jales", "ariel"]
	var slide_in: Dictionary = {"jales": "left", "ariel": "right"}
	var frames: Array = []
	var jales_text: String = str(dialogue.get("jales", ""))
	if jales_text != "":
		frames.append({"speaker": "jales", "show": both.duplicate(), "slide": slide_in, "dim": 0.22, "text": jales_text})
		slide_in = {}
	frames.append({"speaker": "ariel", "show": both.duplicate(), "slide": slide_in, "dim": 0.22, "text": str(tier.get("ariel", "Vamos ver o placar."))})
	return frames

## Fala final do Jales (4 variacoes por desempenho). A abertura "Antes que voce va, quero lhe dizer algo..."
## (final.json > closing_intro) e colada no inicio da 1a fala: NAO cria caixa nova. Vazia = desliga.
func _closing_frames() -> Array:
	var frames: Array = []
	var intro: String = str(story.get("closing_intro", "")).strip_edges()
	for item in tier.get("jales", []):
		var frame: Dictionary = (item as Dictionary).duplicate(true)
		frame["speaker"] = "jales"
		frame["show"] = ["jales"]
		if frames.is_empty() and intro != "":
			frame["text"] = "%s %s" % [intro, str(frame.get("text", ""))]
		frames.append(frame)
	return frames

## Cenario (ids de Paths.CUTSCENE_BG_FINAL) do bloco, lido de final.json > backgrounds.
func _bg_id(block: String) -> String:
	var map: Dictionary = story.get("backgrounds", {}) as Dictionary
	return str(map.get(block, ""))

## Troca o cenario de fundo (sem animar: so e chamada com a tela preta).
func _set_background(id: String) -> void:
	if id == "" or id == background_id or background_rect == null:
		return
	var path: String = str(Paths.CUTSCENE_BG_FINAL.get(id, ""))
	if path == "":
		push_warning("CutsceneFinal: cenario '%s' nao existe em Paths.CUTSCENE_BG_FINAL." % id)
		return
	var texture: Resource = load(path)
	if texture is Texture2D:
		background_rect.texture = texture as Texture2D
		background_id = id

## Corte entre blocos: fade para preto, troca o cenario (se pedido) e volta.
func _cut(new_background_id: String = "") -> void:
	if not is_inside_tree():
		return
	if not _animations_enabled():
		_set_background(new_background_id)
		return
	var tween: Tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 0.30)
	await tween.finished
	_set_background(new_background_id)
	tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, 0.40)

# ---------------------------------------------------------------- construcao

func _build_scene() -> void:
	background_rect = TextureRect.new()
	background_rect.name = "Background"
	background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background_rect)
	_set_background(_bg_id("farewell") if _bg_id("farewell") != "" else "escritorio_noite")

	dimmer = ColorRect.new()
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.0, 0.0, 0.0, 0.20)
	dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dimmer)

	effects_canvas = Control.new()
	effects_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	effects_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effects_canvas.draw.connect(_on_effects_canvas_draw)
	add_child(effects_canvas)

	_build_score_layer()
	_build_credits_layer()
	_build_finale_layer()
	_build_gameover_layer()

	fade_rect = ColorRect.new()
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.color = Color(0.0, 0.0, 0.0, 1.0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.z_index = 500
	add_child(fade_rect)
	_apply_responsive_layout()

func _build_score_layer() -> void:
	score_layer = Control.new()
	score_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	score_layer.visible = false
	score_layer.z_index = 40
	add_child(score_layer)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	score_layer.add_child(center)

	score_panel = PanelContainer.new()
	score_panel.custom_minimum_size = Vector2(760, 440)
	score_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.05, 0.11, 0.94), GOLD, 22, 3))
	center.add_child(score_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 42)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 42)
	margin.add_theme_constant_override("margin_bottom", 24)
	score_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)

	score_title_label = Label.new()
	score_title_label.text = "PONTUAÇÃO FINAL DA JORNADA"
	score_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_title_label.add_theme_font_size_override("font_size", 29)
	score_title_label.add_theme_color_override("font_color", Color(0.82, 0.84, 0.92))
	box.add_child(score_title_label)

	score_value_label = Label.new()
	score_value_label.text = "0"
	score_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_value_label.add_theme_font_size_override("font_size", 86)
	score_value_label.add_theme_color_override("font_color", GOLD)
	score_value_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.8))
	score_value_label.add_theme_constant_override("shadow_offset_x", 4)
	score_value_label.add_theme_constant_override("shadow_offset_y", 4)
	box.add_child(score_value_label)

	difficulty_label = Label.new()
	difficulty_label.text = "Dificuldade: %s" % DifficultyManager.get_label()
	difficulty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	difficulty_label.add_theme_font_size_override("font_size", 25)
	difficulty_label.add_theme_color_override("font_color", Color(0.42, 0.78, 1.0))
	box.add_child(difficulty_label)

	tier_label = Label.new()
	tier_label.text = str(tier.get("title", ""))
	tier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tier_label.add_theme_font_size_override("font_size", 34)
	tier_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.55))
	tier_label.modulate.a = 0.0
	box.add_child(tier_label)

	record_label = Label.new()
	record_label.text = _record_text()
	record_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	record_label.add_theme_font_size_override("font_size", 21)
	record_label.add_theme_color_override("font_color", Color(0.62, 1.0, 0.72))
	record_label.modulate.a = 0.0
	box.add_child(record_label)

	motivation_label = Label.new()
	motivation_label.text = "\"%s\"" % _get_motivation()
	motivation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	motivation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	motivation_label.add_theme_font_size_override("font_size", 20)
	motivation_label.add_theme_color_override("font_color", Color(0.82, 0.82, 0.86))
	motivation_label.modulate.a = 0.0
	box.add_child(motivation_label)

	score_hint_label = Label.new()
	score_hint_label.text = "Clique, Espaço ou Enter para continuar"
	score_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_hint_label.add_theme_font_size_override("font_size", 17)
	score_hint_label.add_theme_color_override("font_color", Color(0.86, 0.88, 0.95, 0.85))
	score_hint_label.modulate.a = 0.0
	box.add_child(score_hint_label)

## Mensagem de recorde (usa o resultado guardado pelo GameManager ao fechar a campanha).
func _record_text() -> String:
	var result: Dictionary = GameManager.last_campaign_result
	var saved: bool = bool(result.get("saved", false))
	var previous: int = int(result.get("previous_score", 0))
	if saved and previous > 0:
		return "NOVO RECORDE nesta dificuldade! (anterior: %s)" % previous
	if saved:
		return "Primeira campanha registrada nesta dificuldade!"
	return "Seu recorde nesta dificuldade: %s" % ScoreManager.get_campaign_total_score(DifficultyManager.get_difficulty())

func _build_credits_layer() -> void:
	credits_layer = Control.new()
	credits_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	credits_layer.visible = false
	add_child(credits_layer)

	credits_box = VBoxContainer.new()
	credits_box.alignment = BoxContainer.ALIGNMENT_CENTER
	credits_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	credits_box.add_theme_constant_override("separation", 12)
	credits_layer.add_child(credits_box)

	_add_credit_rich(BrandText.brand_bbcode(true), 48)
	_add_credit_rich(GameManager.get_app_version_bbcode() if has_node("/root/GameManager") else BrandText.version_bbcode(), 24)
	_add_credit_space(22)
	# --- IDEALIZAÇÃO, GAME DESIGN & GAMEPLAY ---
	_add_credit_label("Game Design, Lógica & Novels", 22, Color(0.62, 0.62, 0.68))
	_add_credit_label("Cleidison Raimundo dos Santos Lima", 32, Color(1.0, 1.0, 1.0))
	_add_credit_space(18)

	# --- PROGRAMAÇÃO & DESENVOLVIMENTO ---
	_add_credit_label("Desenvolvimento & Programação", 22, Color(0.62, 0.62, 0.68))
	_add_credit_label("Cleidison Raimundo dos Santos Lima", 32, Color(1.0, 1.0, 1.0))
	_add_credit_label("Victor Gabriel Cabral da Silva (Pair Programming)", 28, Color(0.85, 0.85, 0.90))
	_add_credit_space(18)

	# --- NARRATIVA & ARTES VISUAIS ---
	_add_credit_label("Roteiro & Design de Personagens", 22, Color(0.62, 0.62, 0.68))
	_add_credit_label("Marcelo Felipe Beckman", 32, Color(1.0, 1.0, 1.0))
	_add_credit_space(18)

	# --- PESQUISA & BANCO DE DADOS PEDAGÓGICO ---
	_add_credit_label("Pesquisa, Conteúdo & Banco de Dados", 22, Color(0.62, 0.62, 0.68))
	_add_credit_label("Daniel de Moura Melo Filho", 32, Color(1.0, 1.0, 1.0))
	_add_credit_label("Fernando Luiz Jales Da Rocha", 32, Color(1.0, 1.0, 1.0))
	_add_credit_space(18)

	# --- ÁUDIO & EFEITOS SONOROS ---
	_add_credit_label("Música & Efeitos Sonoros", 22, Color(0.62, 0.62, 0.68))
	_add_credit_label("Marcos França Gino Gonçalves", 32, Color(1.0, 1.0, 1.0))
	_add_credit_space(40)

## Camada da cena final (V0.11). A imagem em si e o proprio background_rect (11_cena_creditos);
## aqui ficam o veu da cortina, o escurecimento, o brilho dourado e o bloco de titulo.
func _build_finale_layer() -> void:
	finale_layer = Control.new()
	finale_layer.name = "FinaleLayer"
	finale_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	finale_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	finale_layer.visible = false
	finale_layer.z_index = 35
	add_child(finale_layer)

	finale_veil = Control.new()
	finale_veil.name = "CurtainVeil"
	finale_veil.set_anchors_preset(Control.PRESET_FULL_RECT)
	finale_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	finale_veil.draw.connect(_on_finale_veil_draw)
	finale_layer.add_child(finale_veil)

	finale_dim = ColorRect.new()
	finale_dim.name = "FinaleDim"
	finale_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	finale_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	finale_dim.color = Color(0.02, 0.01, 0.06, 0.0)
	finale_layer.add_child(finale_dim)

	finale_fx = Control.new()
	finale_fx.name = "GoldCurtainFX"
	finale_fx.set_anchors_preset(Control.PRESET_FULL_RECT)
	finale_fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var additive: CanvasItemMaterial = CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	finale_fx.material = additive
	finale_fx.draw.connect(_on_finale_fx_draw)
	finale_layer.add_child(finale_fx)

	var texts: Dictionary = story.get("finale", {}) as Dictionary
	finale_box = VBoxContainer.new()
	finale_box.name = "FinaleTitleBox"
	finale_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	finale_box.alignment = BoxContainer.ALIGNMENT_CENTER
	finale_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	finale_box.add_theme_constant_override("separation", 14)
	finale_box.modulate.a = 0.0
	finale_layer.add_child(finale_box)

	# V0.13.1: o titulo agora e o LOGO do jogo (assets/contalmaster_logo.png). Se a imagem nao carregar, cai no texto.
	var logo_texture: Texture2D = load(Paths.LOGO_CONTALMASTER) as Texture2D
	if logo_texture != null:
		finale_logo = TextureRect.new()
		finale_logo.name = "FinaleLogo"
		finale_logo.texture = logo_texture
		finale_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		finale_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		finale_logo.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		finale_logo.custom_minimum_size = LOGO_SIZE
		finale_logo.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		finale_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		finale_box.add_child(finale_logo)
	else:
		var title_text: String = str(texts.get("title", BrandText.BRAND_NAME.to_upper()))
		var is_brand: bool = title_text.replace(" ", "").to_upper() == BrandText.BRAND_NAME.to_upper()
		finale_title_label = BrandText.make_label(BrandText.brand_bbcode(true) if is_brand else title_text, 110, "center", true)
		finale_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		finale_box.add_child(finale_title_label)

	var line_holder: CenterContainer = CenterContainer.new()
	line_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	finale_box.add_child(line_holder)
	finale_line = ColorRect.new()
	finale_line.color = Color(FINALE_GOLD.r, FINALE_GOLD.g, FINALE_GOLD.b, 0.92)
	finale_line.custom_minimum_size = Vector2(560, 4)
	finale_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line_holder.add_child(finale_line)

	finale_thanks_label = Label.new()
	finale_thanks_label.text = str(texts.get("thanks", "Obrigado por jogar!"))
	finale_thanks_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	finale_thanks_label.add_theme_font_size_override("font_size", 54)
	finale_thanks_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.78))
	finale_thanks_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	finale_thanks_label.add_theme_constant_override("shadow_offset_x", 3)
	finale_thanks_label.add_theme_constant_override("shadow_offset_y", 3)
	finale_thanks_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	finale_box.add_child(finale_thanks_label)

	finale_subtitle_label = Label.new()
	finale_subtitle_label.text = str(texts.get("subtitle", ""))
	finale_subtitle_label.visible = finale_subtitle_label.text != ""
	finale_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	finale_subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	finale_subtitle_label.add_theme_font_size_override("font_size", 24)
	finale_subtitle_label.add_theme_color_override("font_color", Color(0.86, 0.88, 0.96, 0.92))
	finale_subtitle_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
	finale_subtitle_label.add_theme_constant_override("shadow_offset_x", 2)
	finale_subtitle_label.add_theme_constant_override("shadow_offset_y", 2)
	finale_subtitle_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	finale_box.add_child(finale_subtitle_label)

func _build_gameover_layer() -> void:
	gameover_layer = Control.new()
	gameover_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	gameover_layer.visible = false
	add_child(gameover_layer)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	gameover_layer.add_child(center)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 24)
	center.add_child(box)

	gameover_label = Label.new()
	gameover_label.text = "GAME OVER"
	gameover_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gameover_label.add_theme_font_size_override("font_size", 86)
	gameover_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	gameover_label.add_theme_color_override("font_shadow_color", Color(0.45, 0.72, 1.0, 0.95))
	gameover_label.add_theme_constant_override("shadow_offset_x", 4)
	gameover_label.add_theme_constant_override("shadow_offset_y", 4)
	box.add_child(gameover_label)

	var thanks: Label = Label.new()
	thanks.text = "agradecemos por sua aventura neste Desafio!"
	thanks.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	thanks.add_theme_font_size_override("font_size", 24)
	thanks.add_theme_color_override("font_color", Color(0.78, 0.82, 0.92))
	box.add_child(thanks)

	menu_button = Button.new()
	menu_button.text = "VOLTAR AO MENU"
	ButtonStyles.apply(menu_button, "cutscene_return", ScreenTools.button_size(self, Vector2(320, 58), Vector2(260, 50)), ScreenTools.responsive_font(self, 22, 18))
	menu_button.pressed.connect(_return_to_menu)
	box.add_child(menu_button)

func _apply_responsive_layout() -> void:
	if score_panel != null:
		score_panel.custom_minimum_size = ScreenTools.panel_size(self, Vector2(760, 440), Vector2(340, 380), 70.0, 70.0)
	ScreenTools.apply_label_font(score_value_label, self, 86, 62)
	ScreenTools.apply_label_font(difficulty_label, self, 25, 20)
	ScreenTools.apply_label_font(tier_label, self, 34, 26)
	ScreenTools.apply_label_font(record_label, self, 21, 17)
	ScreenTools.apply_label_font(motivation_label, self, 20, 16)
	if menu_button != null:
		ButtonStyles.apply(menu_button, "cutscene_return", ScreenTools.button_size(self, Vector2(320, 58), Vector2(260, 50)), ScreenTools.responsive_font(self, 22, 18))
	if finale_logo != null:
		finale_logo.custom_minimum_size = ScreenTools.responsive_size(self, LOGO_SIZE, LOGO_SIZE_COMPACT)
	if finale_title_label != null:
		BrandText.set_font_size(finale_title_label, ScreenTools.responsive_font(self, 110, 56))
	if finale_thanks_label != null:
		ScreenTools.apply_label_font(finale_thanks_label, self, 54, 32)
	if finale_subtitle_label != null:
		ScreenTools.apply_label_font(finale_subtitle_label, self, 24, 17)
	if finale_line != null:
		finale_line.custom_minimum_size = ScreenTools.responsive_size(self, Vector2(560, 4), Vector2(300, 3))

func _add_credit_label(text_value: String, font_size: int, color: Color) -> void:
	var label: Label = Label.new()
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	credits_box.add_child(label)

func _add_credit_rich(bbcode: String, font_size: int) -> void:
	var label: RichTextLabel = BrandText.make_label(bbcode, font_size, "center", true)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	credits_box.add_child(label)

func _add_credit_space(height: int) -> void:
	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, height)
	credits_box.add_child(spacer)

# ---------------------------------------------------------------- atos finais

## O score SOBE: contagem animada, depois titulo do desempenho, recorde e frase.
func _show_score_act() -> void:
	act = "score"
	elapsed = 0.0
	novel.visible = false
	score_layer.visible = true
	dimmer.color = Color(0.0, 0.0, 0.0, 0.72)
	score_value_label.text = "0"
	score_hint_label.modulate.a = 0.0
	counting = true
	if _animations_enabled():
		var tween: Tween = create_tween()
		tween.tween_method(_set_shown_score, 0.0, float(final_score), SCORE_COUNT_SECONDS).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		await tween.finished
	_set_shown_score(float(final_score))
	await _reveal_score_details()
	counting = false
	await _score_continue
	dimmer.color = Color(0.0, 0.0, 0.0, 0.20)
	score_layer.visible = false

func _set_shown_score(value: float) -> void:
	shown_score = value
	score_value_label.text = str(int(round(value)))

func _reveal_score_details() -> void:
	for label in [tier_label, record_label, motivation_label, score_hint_label]:
		if _animations_enabled():
			var tween: Tween = create_tween()
			tween.tween_property(label, "modulate:a", 1.0, 0.45)
			await get_tree().create_timer(0.35).timeout
		else:
			label.modulate.a = 1.0

func _show_credits_act() -> void:
	act = "credits"
	elapsed = 0.0
	_reset_particles(28)
	novel.visible = false
	score_layer.visible = false
	credits_layer.visible = true
	gameover_layer.visible = false
	finale_layer.visible = false
	dimmer.color = Color(0.0, 0.0, 0.0, 0.92)
	var viewport_size: Vector2 = get_viewport_rect().size
	credits_box.size = Vector2(viewport_size.x, 900)
	credits_box.position = Vector2(0.0, viewport_size.y + 60.0)

# ---------------------------------------------------------------- cena final (V0.11)
## Creditos terminaram: escurece, entra a imagem final (11_cena_creditos) e a cortina dourada a revela.
## Decisao criativa: (1) a imagem entra escura; (2) uma cortina de luz dourada atravessa a tela da esquerda
## para a direita "puxando" o veu e revelando o elenco, deixando brilhos no caminho; (3) o elenco respira
## limpo por um instante; (4) uma segunda cortina, mais suave, passa enquanto a imagem escurece de leve e o
## LOGO do ContalMaster (V0.13.1; texto de reserva se faltar a imagem) + "Obrigado por jogar!" surgem; (5) a tela escurece e vem o GAME OVER.
func _show_finale_act() -> void:
	if act == "finale" or act == "gameover":
		return
	act = "finale"
	finale_token += 1
	var token: int = finale_token
	elapsed = 0.0
	finale_stage = 0
	finale_leaving = false
	_kill_finale_tweens()
	finale_sparkles.clear()
	finale_spark_timer = 0.0
	novel.visible = false
	score_layer.visible = false
	gameover_layer.visible = false
	credits_layer.visible = false

	# Escurece (fim dos creditos), troca para a imagem final e volta com a cortina ainda fechada.
	if _animations_enabled():
		var close: Tween = _finale_tween()
		close.tween_property(fade_rect, "color:a", 1.0, 0.55)
		await close.finished
		if token != finale_token or not is_inside_tree():
			return
	_set_background(_bg_id("finale") if _bg_id("finale") != "" else "cena_creditos")
	dimmer.color = Color(0.0, 0.0, 0.0, 0.0)
	finale_layer.visible = true
	finale_dim.color.a = 0.0
	finale_box.modulate.a = 0.0
	finale_sweep_pos = -1.0
	finale_veil_on = _animations_enabled()
	finale_veil.queue_redraw()
	_apply_responsive_layout()

	if not _animations_enabled():
		# Sem animacoes: mostra direto a composicao final e segue o fluxo normal.
		fade_rect.color.a = 0.0
		_finale_apply_final_state()
		await get_tree().create_timer(FINALE_TITLE_HOLD_SECONDS * 0.6).timeout
		if token == finale_token and is_inside_tree():
			_finale_end()
		return

	var reveal_in: Tween = _finale_tween()
	reveal_in.tween_property(fade_rect, "color:a", 0.0, 0.7)
	await get_tree().create_timer(0.55).timeout
	if token != finale_token or not is_inside_tree():
		return

	# 1) Cortina dourada revela o elenco.
	finale_sweep_pos = 0.0
	var sweep: Tween = _finale_tween()
	sweep.tween_property(self, "finale_sweep_pos", 1.0, FINALE_REVEAL_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await sweep.finished
	if token != finale_token or not is_inside_tree():
		return
	finale_veil_on = false
	finale_sweep_pos = -1.0
	finale_veil.queue_redraw()
	finale_stage = 1

	# 2) Elenco limpo, so o brilho flutuando.
	await get_tree().create_timer(FINALE_HOLD_SECONDS).timeout
	if token != finale_token or not is_inside_tree():
		return

	# 3) Segunda cortina (suave) + imagem escurece de leve + titulo.
	var dim: Tween = _finale_tween()
	dim.tween_property(finale_dim, "color:a", FINALE_DIM_ALPHA, FINALE_TITLE_FADE_SECONDS + 0.6)
	var second: Tween = _finale_tween()
	finale_sweep_pos = 0.0
	second.tween_property(self, "finale_sweep_pos", 1.0, FINALE_TITLE_SWEEP_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	second.tween_callback(func() -> void: finale_sweep_pos = -1.0)
	await get_tree().create_timer(FINALE_TITLE_SWEEP_SECONDS * 0.42).timeout
	if token != finale_token or not is_inside_tree():
		return
	_finale_show_title(true)
	finale_stage = 2
	await get_tree().create_timer(FINALE_TITLE_FADE_SECONDS + FINALE_TITLE_HOLD_SECONDS).timeout
	if token != finale_token or not is_inside_tree():
		return
	_finale_end()

func _finale_tween() -> Tween:
	var tween: Tween = create_tween()
	finale_tweens.append(tween)
	return tween

func _kill_finale_tweens() -> void:
	for tween in finale_tweens:
		if tween != null and tween.is_valid():
			tween.kill()
	finale_tweens.clear()

## Titulo + agradecimento entram (fade e leve zoom-out, com brilho dourado atras).
func _finale_show_title(animate: bool) -> void:
	if not animate or not _animations_enabled():
		finale_box.modulate.a = 1.0
		finale_box.scale = Vector2.ONE
		return
	finale_box.pivot_offset = finale_box.size * 0.5
	finale_box.scale = Vector2(1.12, 1.12)
	var tween: Tween = _finale_tween().set_parallel(true)
	tween.tween_property(finale_box, "modulate:a", 1.0, FINALE_TITLE_FADE_SECONDS)
	tween.tween_property(finale_box, "scale", Vector2.ONE, FINALE_TITLE_FADE_SECONDS + 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

## Estado final da cena (usado ao pular ou com animacoes desligadas): sem veu, imagem escurecida, titulo visivel.
func _finale_apply_final_state() -> void:
	finale_veil_on = false
	finale_sweep_pos = -1.0
	finale_veil.queue_redraw()
	finale_dim.color.a = FINALE_DIM_ALPHA
	finale_box.modulate.a = 1.0
	finale_box.scale = Vector2.ONE
	finale_stage = 2

## Clique/Espaco/Enter na cena final: antes do titulo, pula para o titulo; com o titulo na tela, segue para o Game Over.
func _finale_advance() -> void:
	if finale_leaving or elapsed < FINALE_MIN_SKIP_SECONDS:
		return
	if finale_stage < 2:
		finale_token += 1
		var token: int = finale_token
		_kill_finale_tweens()
		fade_rect.color.a = 0.0
		_finale_apply_final_state()
		await get_tree().create_timer(FINALE_TITLE_HOLD_SECONDS * 0.6).timeout
		if token == finale_token and is_inside_tree():
			_finale_end()
		return
	finale_token += 1
	_finale_end()

## A tela escurece e entra o GAME OVER (com o botao VOLTAR AO MENU).
func _finale_end() -> void:
	if finale_leaving or act != "finale":
		return
	finale_leaving = true
	finale_token += 1
	var token: int = finale_token
	_kill_finale_tweens()
	if _animations_enabled():
		var darken: Tween = _finale_tween()
		darken.tween_property(fade_rect, "color:a", 1.0, FINALE_DARKEN_SECONDS)
		await darken.finished
		if token != finale_token or not is_inside_tree():
			return
	_show_gameover_act()
	if _animations_enabled():
		var back: Tween = _finale_tween()
		back.tween_property(fade_rect, "color:a", 0.0, 0.8)
	else:
		fade_rect.color.a = 0.0

func _update_finale(delta: float) -> void:
	if act != "finale" or not finale_layer.visible:
		return
	if not _animations_enabled():
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	# Zoom lento na imagem durante toda a cena.
	background_rect.pivot_offset = viewport_size * 0.5
	var zoom: float = 1.0 + minf(elapsed * 0.0042, 0.055)
	background_rect.scale = Vector2(zoom, zoom)

	var sweeping: bool = finale_sweep_pos >= 0.0 and finale_sweep_pos <= 1.0
	# Brilhos: nascem ao longo da cortina; depois, poeira dourada ambiente.
	finale_spark_timer -= delta
	if sweeping and finale_spark_timer <= 0.0:
		finale_spark_timer = 0.012
		var front: float = _finale_front_x(viewport_size)
		for _i in range(3):
			_spawn_sparkle(Vector2(front + randf_range(-viewport_size.x * 0.20, viewport_size.x * 0.04), randf_range(0.0, viewport_size.y)), 1.0)
	elif not sweeping and finale_stage >= 1 and finale_spark_timer <= 0.0:
		finale_spark_timer = 0.07
		_spawn_sparkle(Vector2(randf_range(0.0, viewport_size.x), randf_range(viewport_size.y * 0.25, viewport_size.y)), 0.7)
	var i: int = finale_sparkles.size() - 1
	while i >= 0:
		var sparkle: Dictionary = finale_sparkles[i]
		sparkle["age"] = float(sparkle.get("age", 0.0)) + delta
		sparkle["pos"] = _dict_vec2(sparkle, "pos", Vector2.ZERO) + _dict_vec2(sparkle, "vel", Vector2.ZERO) * delta
		if float(sparkle["age"]) >= float(sparkle.get("life", 1.0)):
			finale_sparkles.remove_at(i)
		else:
			finale_sparkles[i] = sparkle
		i -= 1
	finale_fx.queue_redraw()
	if finale_veil_on:
		finale_veil.queue_redraw()
	# Logo "respira" bem devagar enquanto esta na tela (barato: so escala, sem shader).
	if finale_logo != null and finale_stage >= 2:
		finale_logo.pivot_offset = finale_logo.size * 0.5
		var breath: float = 1.0 + LOGO_BREATH_SCALE * (0.5 + 0.5 * sin(elapsed * 1.6))
		finale_logo.scale = Vector2(breath, breath)

func _spawn_sparkle(origin: Vector2, strength: float) -> void:
	if finale_sparkles.size() >= FINALE_MAX_SPARKLES:
		return
	finale_sparkles.append({
		"pos": origin,
		"vel": Vector2(randf_range(-14.0, 14.0), randf_range(-46.0, -12.0)),
		"age": 0.0,
		"life": randf_range(0.9, 2.1),
		"size": randf_range(6.0, 20.0) * strength,
		"spin": randf_range(0.0, TAU)
	})

## x (em pixels) do centro da cortina na altura do meio da tela.
func _finale_front_x(viewport_size: Vector2) -> float:
	var band: float = viewport_size.x * 0.20
	return lerpf(-band * 0.6, viewport_size.x + band * 0.6, clampf(finale_sweep_pos, 0.0, 1.0))

## Veu escuro: cobre o que a cortina ainda nao revelou (a borda segue a inclinacao da faixa dourada).
func _on_finale_veil_draw() -> void:
	if not finale_veil_on:
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	var color: Color = Color(0.02, 0.01, 0.07, FINALE_VEIL_ALPHA)
	if finale_sweep_pos < 0.0:
		finale_veil.draw_rect(Rect2(Vector2.ZERO, viewport_size), color, true)
		return
	var skew: float = viewport_size.y * 0.16
	var front: float = _finale_front_x(viewport_size)
	# V0.13.4: no fim da varredura a borda esquerda ultrapassa a direita (front + skew/2 > largura + skew) e o
	# poligono vira invertido/degenerado: "Invalid polygon data, triangulation failed" a cada quadro.
	# Quando a cortina ja passou por toda a tela nao ha mais veu a desenhar.
	if front + skew * 0.5 >= viewport_size.x + skew - 1.0:
		return
	var points: PackedVector2Array = PackedVector2Array([
		Vector2(front + skew * 0.5, 0.0),
		Vector2(viewport_size.x + skew, 0.0),
		Vector2(viewport_size.x + skew, viewport_size.y),
		Vector2(front - skew * 0.5, viewport_size.y)
	])
	finale_veil.draw_colored_polygon(points, color)

func _on_finale_fx_draw() -> void:
	if act != "finale":
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	if finale_sweep_pos >= 0.0 and finale_sweep_pos <= 1.0:
		var band: float = viewport_size.x * 0.20
		var skew: float = viewport_size.y * 0.16
		var front: float = _finale_front_x(viewport_size)
		# "Dobras" da cortina atras da faixa principal (mais fracas e mais finas).
		for fold in range(3):
			var offset: float = band * (0.62 + 0.46 * float(fold))
			_draw_gold_band(front - offset, band * (0.34 - 0.07 * float(fold)), skew, viewport_size.y, 0.40 - 0.11 * float(fold))
		_draw_gold_band(front, band, skew, viewport_size.y, 1.0)
	for sparkle in finale_sparkles:
		var life: float = maxf(float(sparkle.get("life", 1.0)), 0.01)
		var t: float = clampf(float(sparkle.get("age", 0.0)) / life, 0.0, 1.0)
		var alpha: float = sin(t * PI)
		_draw_sparkle(_dict_vec2(sparkle, "pos", Vector2.ZERO), float(sparkle.get("size", 10.0)) * (0.6 + 0.4 * alpha), float(sparkle.get("spin", 0.0)) + t * 1.4, alpha)

## Faixa inclinada de luz dourada: gradiente longo atras, gradiente curto na frente e nucleo branco-quente.
func _draw_gold_band(x: float, width: float, skew: float, height: float, strength: float) -> void:
	var edge: Color = Color(FINALE_GOLD_DEEP.r, FINALE_GOLD_DEEP.g, FINALE_GOLD_DEEP.b, 0.0)
	var core: Color = Color(FINALE_GOLD.r, FINALE_GOLD.g, FINALE_GOLD.b, 0.72 * strength)
	var hot: Color = Color(1.0, 0.97, 0.84, 0.95 * strength)
	_draw_band_quad(x - width, x, skew, height, edge, core)
	_draw_band_quad(x, x + width * 0.30, skew, height, core, edge)
	_draw_band_quad(x - width * 0.035, x + width * 0.035, skew, height, hot, hot)

func _draw_band_quad(x_a: float, x_b: float, skew: float, height: float, color_a: Color, color_b: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array([
		Vector2(x_a + skew * 0.5, 0.0),
		Vector2(x_b + skew * 0.5, 0.0),
		Vector2(x_b - skew * 0.5, height),
		Vector2(x_a - skew * 0.5, height)
	])
	var colors: PackedColorArray = PackedColorArray([color_a, color_b, color_b, color_a])
	finale_fx.draw_polygon(points, colors)

## Brilho em estrela de 4 pontas.
func _draw_sparkle(center: Vector2, radius: float, rotation_angle: float, alpha: float) -> void:
	if alpha <= 0.01 or radius <= 0.5:
		return
	var points: PackedVector2Array = PackedVector2Array()
	for k in range(8):
		var angle: float = rotation_angle + float(k) * PI * 0.25
		var r: float = radius if k % 2 == 0 else radius * 0.24
		points.append(center + Vector2(cos(angle), sin(angle)) * r)
	finale_fx.draw_colored_polygon(points, Color(1.0, 0.92, 0.55, 0.85 * alpha))
	finale_fx.draw_circle(center, radius * 0.22, Color(1.0, 1.0, 0.9, 0.9 * alpha))

func _show_gameover_act() -> void:
	act = "gameover"
	elapsed = 0.0
	_reset_particles(40)
	novel.visible = false
	score_layer.visible = false
	credits_layer.visible = false
	finale_layer.visible = false
	gameover_layer.visible = true
	background_rect.scale = Vector2.ONE
	dimmer.color = Color(0.0, 0.0, 0.0, 0.96)

func _advance_act() -> void:
	if act == "score":
		if counting:
			# Clique durante a contagem: mostra o valor final na hora.
			_set_shown_score(float(final_score))
			return
		_score_continue.emit()
	elif act == "credits":
		_show_finale_act()
	elif act == "finale":
		_finale_advance()
	elif act == "gameover":
		_return_to_menu()

func _update_score_hint() -> void:
	if act != "score" or score_hint_label == null or counting:
		return
	var alpha: float = 0.42 + absf(sin(elapsed * 2.8)) * 0.48
	score_hint_label.add_theme_color_override("font_color", Color(0.86, 0.88, 0.95, alpha))

func _update_credits(delta: float) -> void:
	if act != "credits" or credits_box == null:
		return
	credits_box.position.y -= CREDIT_SCROLL_SPEED * delta
	if credits_box.position.y + credits_box.size.y < -40.0:
		_show_finale_act()

func _update_gameover() -> void:
	if act != "gameover" or gameover_label == null:
		return
	var pulse: float = 0.50 + absf(sin(elapsed * 3.4)) * 0.50
	gameover_label.add_theme_color_override("font_shadow_color", Color(0.36, 0.68, 1.0, 0.45 + pulse * 0.55))

func _reset_particles(amount: int) -> void:
	particles.clear()
	var viewport_size: Vector2 = get_viewport_rect().size
	for _i in range(amount):
		particles.append({
			"position": Vector2(randf_range(0.0, viewport_size.x), randf_range(0.0, viewport_size.y)),
			"speed": randf_range(18.0, 58.0),
			"radius": randf_range(1.6, 4.4),
			"alpha": randf_range(0.34, 0.95)
		})

func _update_particles(delta: float) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	for i in range(particles.size()):
		var particle: Dictionary = particles[i]
		var pos: Vector2 = _dict_vec2(particle, "position", Vector2.ZERO)
		pos.y -= float(particle.get("speed", 26.0)) * delta
		pos.x += sin(elapsed * 0.9 + float(i)) * 8.0 * delta
		if pos.y < -18.0:
			pos.y = viewport_size.y + randf_range(15.0, 110.0)
			pos.x = randf_range(0.0, viewport_size.x)
		particle["position"] = pos
		particles[i] = particle

func _on_effects_canvas_draw() -> void:
	if not _animations_enabled():
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	var accent: Color = Color(1.0, 0.82, 0.16)
	if act == "score":
		accent = Color(0.35, 0.70, 1.0)
	elif act == "gameover":
		accent = Color(0.78, 0.86, 1.0)
	effects_canvas.draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(accent.r, accent.g, accent.b, 0.045), true)
	for particle in particles:
		var pos: Vector2 = _dict_vec2(particle, "position", Vector2.ZERO)
		var radius: float = float(particle.get("radius", 2.4))
		var alpha: float = float(particle.get("alpha", 0.6))
		effects_canvas.draw_circle(pos, radius, Color(1.0, 1.0, 1.0, alpha))

func _dict_vec2(data: Dictionary, key: String, fallback: Vector2) -> Vector2:
	var value: Variant = data.get(key, fallback)
	if value is Vector2:
		return value
	return fallback

func _get_motivation() -> String:
	var diff: String = DifficultyManager.get_difficulty()
	if diff == "facil":
		return "Toda grande jornada começa por uma boa escolha."
	if diff == "dificil":
		return "Nos caminhos mais difíceis, o conhecimento mostra seu valor."
	return "Cada desafio vencido revela uma nova forma de pensar."

func _return_to_menu() -> void:
	if not can_click:
		return
	can_click = false
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	var tween: Tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0.0, 0.0, 0.0, 1.0), 0.36)
	await tween.finished
	if is_inside_tree():
		GameManager.go_to_main_menu()

func _fade_from_black() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0.0, 0.0, 0.0, 0.0), 0.50)

func _make_panel_style(bg_color: Color, border_color: Color, radius: int = 14, border_width: int = 1) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.38)
	style.shadow_size = 10
	return style
