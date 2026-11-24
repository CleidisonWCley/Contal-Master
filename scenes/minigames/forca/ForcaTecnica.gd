extends Control
## ContalMaster - Forca Tecnica (host: Aline).
##
## V0.16.15/16 - Reforma da Forca Tecnica: "Ja sei o termo!" (3 opcoes parecidas), pistas da Aline em cartao,
##   acento e cedilha automaticos (A revela A, Ã, Â; C revela Ç) e interface no estilo da Aline.
## V0.16.17 - Rebalanceamento: alfabeto completo (A a Z), NENHUMA letra revelada no inicio, pista sorteia uma letra
##   oculta e custa 15% dos pontos da rodada, cartao da Aline sempre aparece (faz parte da mecanica),
##   area da palavra menor e teclado/botoes laterais maiores.
var pause_menu: MinigamePause

const DynamicQuestionBank := preload("res://scripts/core/question_bank.gd")

const BACKGROUND_PATH := Paths.BG_FORCA
## V0.16.1: quantidade de rodadas vem das Configuracoes (campanha x modo livre).
var total_rounds: int = SettingsManager.get_current_questions_count()
const ERRORS_BY_DIFFICULTY := {"facil": 14, "normal": 10, "dificil": 6}
const SOLVE_BASE_POINTS := 100
const INTEGRITY_BONUS_CAP := 60
const SPEED_BONUS_MAX := 40              # V0.16.15: bonus maximo do "Ja sei o termo!"
const QUICK_GUESS_THRESHOLD := 0.40      # fracao das letras reveladas que libera o chute rapido
const MAX_HINTS_PER_ROUND := 2
const HINT_DISCOUNT := 0.15              # V0.16.17: cada pista tira 15% dos PONTOS da rodada (base + bonus)
const FEEDBACK_SECONDS := 1.45
const SYMBOL_PARTICLE_COUNT := 18
const FLOAT_SYMBOLS := ["A", "Ç", "Ã", "É", "Õ", "Á", "NBC", "CRE", "CFC", "PA 11", "Aa"]
## V0.16.18 (ajuste de UI): limites dos botoes do painel lateral (Pista da Aline / Ja sei o termo!).
const SIDE_BTN_FONT_MIN := 13
const SIDE_BTN_FONT_MAX := 22
const SIDE_BTN_FACTOR_CAP := 1.15       # no modo Extra Grande o painel lateral cresce no maximo 1,15x (e nao 1,35x)
const SIDE_BTN_MARGIN_X := 10.0         # content_margin horizontal dos botoes laterais

# Paleta da Aline: ameixa/lilas do jogo + papel de dicionario antigo + dourado.
const PAPER := Color(1.0, 0.95, 0.84, 0.97)
const PAPER_INK := Color(0.12, 0.07, 0.22, 1.0)
const GOLD := Color(1.0, 0.80, 0.38, 1.0)

const LINES_QUICK_PROVOKE: Array[String] = [
	"Já sabe? Vamos ver se é conhecimento ou apenas otimismo.",
	"Ah, a confiança de quem leu metade das letras. Escolha, então.",
	"Três termos, um só correto. Os outros são parecidos de propósito. Boa sorte.",
	"O diabo mora nos detalhes. A auditoria também.",
	"Palpite não é rigor. Mas já que insiste..."
]
const LINES_HINT_EXTRA := "Outra letra? Estou começando a achar que o dicionário é meu."

## Reserva (so usada se o banco de termos nao carregar): mesmo tema do jogo, revisao pelos pares.
const FALLBACK_BANK := [
	{"word": "Revisor", "area": "Papéis", "hint": "Auditor contratado pelo revisado para fazer a revisão."},
	{"word": "Amostra", "area": "Procedimentos", "hint": "Seleção limitada de clientes para revisar os papéis de trabalho."},
	{"word": "Independência", "area": "Princípios", "hint": "Capacidade de avaliar sem influências indevidas."},
	{"word": "Confidencialidade", "area": "Princípios", "hint": "Dever de não divulgar o que se soube na revisão."},
	{"word": "Plano de ação", "area": "Documentos", "hint": "Documento do revisado com as ações para corrigir fragilidades."},
	{"word": "Objetividade", "area": "Princípios", "hint": "Julgamento imparcial, sem se deixar influenciar."},
	{"word": "Fraude", "area": "Auditoria geral", "hint": "Ato intencional para obter vantagem indevida."},
	{"word": "Salvaguardas", "area": "Princípios", "hint": "Medidas que reduzem ameaças à independência a nível aceitável."}
]

var questions: Array = []
var term_pool: Array[Dictionary] = []        # {"word","area"} - glossario inteiro, base dos chutes parecidos
var current_question: Dictionary = {}
var current_round_index: int = 0
var guessed_letters: Dictionary = {}          # letra-base -> true
var keyboard_letters: Array[String] = []
var letter_buttons: Dictionary = {}
var word_cells: Array[Dictionary] = []
var cell_styles: Dictionary = {}
var hint_phrase_shown: bool = false
var kb_signature: String = ""
var fx_accum: float = 0.0
var hints_used: int = 0
var quick_used: bool = false
var quick_open: bool = false
var quick_ready_announced: bool = false
var errors_this_word: int = 0
var max_errors: int = 10
var success_count: int = 0
var failure_count: int = 0
var total_errors_count: int = 0
var earned_points: int = 0
var input_locked: bool = true
var finish_visible: bool = false
var elapsed: float = 0.0
var shake_strength: float = 0.0
var base_root_position: Vector2 = Vector2.ZERO
var symbol_particles: Array[Dictionary] = []
var ui_k: float = 1.0                         # fator do DynamicLayout (1.0 = visual original)
var layout_fit: DynamicLayout
var aline_hint_phrase: String = ""            # texto cru da pista (a quebra de linha e refeita conforme a largura)
var side_btn_sig: String = ""                 # cache do ajuste de fonte dos botoes laterais (evita recalculo em loop)

var root_margin: MarginContainer
var main_box: VBoxContainer
var effects_canvas: Control
var particle_layer: Control
var left_spacer: Control
var right_spacer: Control
var stage_panel: PanelContainer
var side_panel: PanelContainer
var clue_card: PanelContainer
var word_panel: PanelContainer
var title_label: Label
var subtitle_label: Label
var round_label: Label
var score_label: Label
var difficulty_label: Label
var record_label: Label
var area_label: Label                         # etiqueta "Categoria - N letras"
var hint_label: Label                         # definicao curta
var aline_hint_panel: PanelContainer
var aline_hint_label: Label
var word_label: HFlowContainer                # tiles da palavra (alvo do tutorial)
var keyboard_grid: VBoxContainer
var hint_button: Button
var quick_guess_button: Button
var integrity_bar: ProgressBar
var integrity_label: Label
var state_label: Label
var error_label: Label
var side_title_label: Label
var feedback_layer: Control
var feedback_title_label: Label
var feedback_body_label: Label
var feedback_body_scroll: ScrollContainer   # V0.16.4: texto do feedback rola se a fonte for muito grande
var feedback_panel: PanelContainer
var feedback_continue_button: Button
var finish_layer: Control
var finish_title_label: Label
var finish_body_label: Label
var quick_layer: Control
var quick_panel: PanelContainer
var quick_title_label: Label
var quick_sub_label: Label
var quick_options_box: VBoxContainer
var quick_cancel_button: Button

func _ready() -> void:
	randomize()
	_load_term_pool()
	_build_scene()
	pause_menu = MinigamePause.attach(self)
	_connect_score_signal()
	_prepare_questions()
	_on_score_changed(ScoreManager.get_score())
	if has_node("/root/AudioManager"):
		AudioManager.play_music("musica_forca_tecnica")
	if not FontScale.scale_changed.is_connected(_on_font_scale_changed):
		FontScale.scale_changed.connect(_on_font_scale_changed)
	await _start_round(0)
	# V0.10: tutorial da Aline ANTES da primeira palavra (teclado e botoes bloqueados durante o tutorial).
	input_locked = true
	_update_action_buttons()
	await TutorialManager.play(self, "forca_tecnica", {"placeholders": _tutorial_placeholders()})
	if not is_inside_tree():
		return
	input_locked = false
	_update_action_buttons()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_responsive_layout()
		if _animations_enabled():
			_reset_symbol_particles()
		if layout_fit != null and is_inside_tree():
			layout_fit.schedule()

func _on_font_scale_changed(_level: String) -> void:
	_apply_responsive_layout()
	if layout_fit != null and is_inside_tree():
		layout_fit.schedule()

func _process(delta: float) -> void:
	elapsed += delta
	if not _animations_enabled():
		if particle_layer != null:
			particle_layer.visible = false
		if effects_canvas != null:
			effects_canvas.visible = false
		if root_margin != null:
			root_margin.position = base_root_position
		return
	if particle_layer != null:
		particle_layer.visible = true
	if effects_canvas != null:
		effects_canvas.visible = true
		_update_effects_canvas(delta)
	_update_symbol_particles(delta)
	_update_screen_shake(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event: InputEventKey = event as InputEventKey
		if finish_visible:
			match key_event.keycode:
				KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
					_on_finish_continue_pressed()
			return
		# V0.16.15: aceita letra com acento digitada no teclado fisico (ã, ç, é...): vira a letra-base.
		var typed: String = ""
		if key_event.unicode > 0:
			typed = _normalize_text(String.chr(key_event.unicode))
		elif key_event.keycode >= KEY_A and key_event.keycode <= KEY_Z:
			typed = String.chr(97 + int(key_event.keycode) - int(KEY_A))
		if _is_letter_char(typed):
			_guess_letter(typed)

# ======================================================================
# CONSTRUCAO DA CENA
# ======================================================================
func _build_scene() -> void:
	_clear_scene_children()

	var background_rect: TextureRect = TextureRect.new()
	background_rect.name = "Background"
	background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	var bg_texture: Resource = load(BACKGROUND_PATH)
	if bg_texture is Texture2D:
		background_rect.texture = bg_texture as Texture2D
	add_child(background_rect)

	var dimmer: ColorRect = ColorRect.new()
	dimmer.name = "Dimmer"
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = UiPalette.with_alpha(UiPalette.BG, 0.52)
	add_child(dimmer)

	effects_canvas = Control.new()
	effects_canvas.name = "SoftGlowCanvas"
	effects_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	effects_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effects_canvas.draw.connect(_on_effects_canvas_draw)
	add_child(effects_canvas)

	particle_layer = Control.new()
	particle_layer.name = "FloatingLettersLayer"
	particle_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	particle_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(particle_layer)
	_create_symbol_particles()

	root_margin = MarginContainer.new()
	root_margin.name = "SafeArea"
	root_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root_margin)
	base_root_position = root_margin.position

	main_box = VBoxContainer.new()
	main_box.name = "MainLayout"
	main_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_box.alignment = BoxContainer.ALIGNMENT_CENTER
	root_margin.add_child(main_box)

	# ---- Barra do topo (compacta): [vaga do botao TELA] [titulo + chips] [vaga do botao PAUSAR] ----
	var top_row: HBoxContainer = HBoxContainer.new()
	top_row.name = "TopRow"
	top_row.add_theme_constant_override("separation", 10)
	main_box.add_child(top_row)

	left_spacer = Control.new()
	left_spacer.custom_minimum_size = Vector2(214, 0)
	left_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_child(left_spacer)

	var top_panel: PanelContainer = PanelContainer.new()
	top_panel.name = "TopPanel"
	top_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_panel.add_theme_stylebox_override("panel", _make_panel_style(UiPalette.with_alpha(UiPalette.CARD, 0.82), UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.85), 18, 2))
	top_row.add_child(top_panel)

	right_spacer = Control.new()
	right_spacer.custom_minimum_size = Vector2(176, 0)
	right_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_child(right_spacer)

	var top_margin: MarginContainer = MarginContainer.new()
	top_margin.add_theme_constant_override("margin_left", 14)
	top_margin.add_theme_constant_override("margin_top", 8)
	top_margin.add_theme_constant_override("margin_right", 14)
	top_margin.add_theme_constant_override("margin_bottom", 8)
	top_panel.add_child(top_margin)

	var top_box: HBoxContainer = HBoxContainer.new()
	top_box.add_theme_constant_override("separation", 12)
	top_margin.add_child(top_box)

	var top_face: FaceAvatar = FaceAvatar.create("aline", 48.0)
	top_face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_box.add_child(top_face)

	var title_box: VBoxContainer = VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.alignment = BoxContainer.ALIGNMENT_CENTER
	title_box.add_theme_constant_override("separation", 0)
	top_box.add_child(title_box)

	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "Forca Técnica"
	title_label.add_theme_color_override("font_color", UiPalette.TEXT_ON_DARK)
	title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.7))
	title_label.add_theme_constant_override("shadow_offset_x", 2)
	title_label.add_theme_constant_override("shadow_offset_y", 2)
	title_box.add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.name = "SubtitleLabel"
	subtitle_label.text = "Mentoria da Aline"
	subtitle_label.add_theme_color_override("font_color", GOLD)
	title_box.add_child(subtitle_label)

	round_label = _create_chip_label("RODADA 1/6", UiPalette.with_alpha(UiPalette.PRIMARY, 0.92), UiPalette.TEXT_ON_DARK)
	top_box.add_child(round_label)
	score_label = _create_chip_label("Pontuação: 0", UiPalette.with_alpha(UiPalette.BG, 0.88), UiPalette.TEXT_ON_DARK)
	top_box.add_child(score_label)

	# ---- Corpo: palco (pistas + palavra + teclado) | painel lateral (integridade, dificuldade, recorde) ----
	var content_row: HBoxContainer = HBoxContainer.new()
	content_row.name = "ContentRow"
	content_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_row.add_theme_constant_override("separation", 14)
	main_box.add_child(content_row)

	stage_panel = PanelContainer.new()
	stage_panel.name = "QuestionPanel"
	stage_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stage_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage_panel.add_theme_stylebox_override("panel", _make_panel_style(UiPalette.with_alpha(UiPalette.BG, 0.70), UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.70), 22, 2))
	content_row.add_child(stage_panel)

	var stage_margin: MarginContainer = MarginContainer.new()
	stage_margin.add_theme_constant_override("margin_left", 22)
	stage_margin.add_theme_constant_override("margin_top", 16)
	stage_margin.add_theme_constant_override("margin_right", 22)
	stage_margin.add_theme_constant_override("margin_bottom", 16)
	stage_panel.add_child(stage_margin)

	var stage_box: VBoxContainer = VBoxContainer.new()
	stage_box.name = "StageBox"
	stage_box.alignment = BoxContainer.ALIGNMENT_CENTER
	stage_box.add_theme_constant_override("separation", 12)
	stage_margin.add_child(stage_box)

	# Pistas em blocos curtos: [Categoria - N letras] / definicao / (pista da Aline, quando pedida)
	clue_card = PanelContainer.new()
	clue_card.name = "ClueCard"
	clue_card.add_theme_stylebox_override("panel", _make_panel_style(UiPalette.with_alpha(UiPalette.CARD, 0.78), UiPalette.with_alpha(UiPalette.TEXT_MUTED, 0.35), 16, 1))
	stage_box.add_child(clue_card)

	var clue_margin: MarginContainer = MarginContainer.new()
	clue_margin.add_theme_constant_override("margin_left", 16)
	clue_margin.add_theme_constant_override("margin_top", 10)
	clue_margin.add_theme_constant_override("margin_right", 16)
	clue_margin.add_theme_constant_override("margin_bottom", 10)
	clue_card.add_child(clue_margin)

	var clue_box: VBoxContainer = VBoxContainer.new()
	clue_box.add_theme_constant_override("separation", 8)
	clue_margin.add_child(clue_box)

	var tag_row: HBoxContainer = HBoxContainer.new()
	tag_row.alignment = BoxContainer.ALIGNMENT_CENTER
	clue_box.add_child(tag_row)

	area_label = Label.new()
	area_label.name = "AreaLabel"
	area_label.text = "Categoria"
	area_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	area_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	area_label.add_theme_color_override("font_color", UiPalette.TEXT_ON_DARK)
	area_label.add_theme_stylebox_override("normal", _make_tag_style(UiPalette.with_alpha(UiPalette.PRIMARY, 0.92), UiPalette.HIGHLIGHT))
	tag_row.add_child(area_label)

	hint_label = Label.new()
	hint_label.name = "HintLabel"
	hint_label.text = "Definição"
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint_label.add_theme_color_override("font_color", UiPalette.TEXT_ON_DARK)
	clue_box.add_child(hint_label)

	aline_hint_panel = PanelContainer.new()
	aline_hint_panel.name = "AlineHintPanel"
	aline_hint_panel.visible = true   # V0.16.18: SEMPRE no layout (so o alpha muda) -> usar a pista nao altera a altura
	aline_hint_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	aline_hint_panel.modulate.a = 0.0
	aline_hint_panel.add_theme_stylebox_override("panel", _make_panel_style(UiPalette.with_alpha(GOLD, 0.16), GOLD, 12, 2))
	clue_box.add_child(aline_hint_panel)

	var aline_hint_margin: MarginContainer = MarginContainer.new()
	aline_hint_margin.add_theme_constant_override("margin_left", 12)
	aline_hint_margin.add_theme_constant_override("margin_top", 6)
	aline_hint_margin.add_theme_constant_override("margin_right", 12)
	aline_hint_margin.add_theme_constant_override("margin_bottom", 6)
	aline_hint_panel.add_child(aline_hint_margin)

	aline_hint_label = Label.new()
	aline_hint_label.name = "AlineHintLabel"
	aline_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# V0.16.18: SEM autowrap nativo. Um Label com autowrap que acaba de ficar visivel reporta altura minima
	# gigante (largura 0 = uma letra por linha) e o DynamicLayout encolhia a tela inteira. A quebra de linha
	# agora e calculada por _wrap_hint_text() com a largura real do cartao.
	aline_hint_label.clip_text = true
	aline_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	aline_hint_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	aline_hint_label.add_theme_color_override("font_color", Color(1.0, 0.93, 0.74))
	aline_hint_margin.add_child(aline_hint_label)

	# Palavra em tiles (area de destaque, ocupa o espaco que sobra).
	word_panel = PanelContainer.new()
	word_panel.name = "WordPanel"
	word_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	word_panel.add_theme_stylebox_override("panel", _make_panel_style(UiPalette.with_alpha(UiPalette.CARD, 0.62), UiPalette.with_alpha(GOLD, 0.55), 20, 2))
	stage_box.add_child(word_panel)

	var word_margin: MarginContainer = MarginContainer.new()
	word_margin.add_theme_constant_override("margin_left", 20)
	word_margin.add_theme_constant_override("margin_top", 10)
	word_margin.add_theme_constant_override("margin_right", 20)
	word_margin.add_theme_constant_override("margin_bottom", 10)
	word_panel.add_child(word_margin)

	var word_center: VBoxContainer = VBoxContainer.new()
	word_center.alignment = BoxContainer.ALIGNMENT_CENTER
	word_margin.add_child(word_center)

	word_label = HFlowContainer.new()
	word_label.name = "WordLabel"
	word_label.alignment = FlowContainer.ALIGNMENT_CENTER
	word_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	word_label.add_theme_constant_override("h_separation", 26)
	word_label.add_theme_constant_override("v_separation", 12)
	word_center.add_child(word_label)

	# Teclado filtrado: linhas equilibradas e centralizadas (montadas em _layout_keyboard).
	keyboard_grid = VBoxContainer.new()
	keyboard_grid.name = "KeyboardGrid"
	keyboard_grid.alignment = BoxContainer.ALIGNMENT_CENTER
	keyboard_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	keyboard_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	keyboard_grid.add_theme_constant_override("separation", 8)
	stage_box.add_child(keyboard_grid)

	# ---- Painel lateral: integridade, dificuldade, recorde e comentario da Aline ----
	side_panel = PanelContainer.new()
	side_panel.name = "SystemPanel"
	side_panel.add_theme_stylebox_override("panel", _make_panel_style(UiPalette.with_alpha(UiPalette.BG, 0.74), UiPalette.with_alpha(UiPalette.SECONDARY, 0.70), 22, 2))
	side_panel.clip_contents = true   # V0.16.18: rede de seguranca - nada do painel lateral vaza para fora da moldura
	content_row.add_child(side_panel)

	var side_margin: MarginContainer = MarginContainer.new()
	side_margin.add_theme_constant_override("margin_left", 14)
	side_margin.add_theme_constant_override("margin_top", 16)
	side_margin.add_theme_constant_override("margin_right", 14)
	side_margin.add_theme_constant_override("margin_bottom", 16)
	side_panel.add_child(side_margin)

	var side_box: VBoxContainer = VBoxContainer.new()
	side_box.name = "SideBox"
	side_box.alignment = BoxContainer.ALIGNMENT_CENTER
	side_box.add_theme_constant_override("separation", 10)
	side_margin.add_child(side_box)

	side_title_label = Label.new()
	side_title_label.text = "INTEGRIDADE"
	side_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	side_title_label.add_theme_color_override("font_color", UiPalette.SECONDARY)
	side_box.add_child(side_title_label)

	integrity_bar = ProgressBar.new()
	integrity_bar.name = "IntegrityBar"
	integrity_bar.min_value = 0
	integrity_bar.max_value = 100
	integrity_bar.value = 100
	integrity_bar.show_percentage = false
	integrity_bar.add_theme_stylebox_override("background", _make_panel_style(Color(0, 0, 0, 0.45), Color(1, 1, 1, 0.22), 9, 1))
	side_box.add_child(integrity_bar)

	integrity_label = Label.new()
	integrity_label.name = "IntegrityLabel"
	integrity_label.text = "100%"
	integrity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	integrity_label.add_theme_color_override("font_color", UiPalette.TEXT_ON_DARK)
	side_box.add_child(integrity_label)

	state_label = Label.new()
	state_label.name = "StateLabel"
	state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	state_label.add_theme_color_override("font_color", UiPalette.TEXT_MUTED)
	side_box.add_child(state_label)

	error_label = Label.new()
	error_label.name = "ErrorLabel"
	error_label.text = "Erros: 0/6"
	error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	error_label.add_theme_color_override("font_color", UiPalette.TEXT_ON_DARK)
	side_box.add_child(error_label)

	difficulty_label = _create_chip_label("Dificuldade: Normal", UiPalette.with_alpha(UiPalette.BG, 0.88), UiPalette.TEXT_ON_DARK)
	difficulty_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side_box.add_child(difficulty_label)

	record_label = _create_chip_label("Recorde: —", UiPalette.with_alpha(UiPalette.CARD, 0.92), UiPalette.TEXT_ON_DARK)
	record_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side_box.add_child(record_label)

	# Acoes de apoio no painel lateral (no lugar do comentario da Aline): pista e chute rapido.
	var action_box: VBoxContainer = VBoxContainer.new()
	action_box.name = "ActionBox"
	action_box.add_theme_constant_override("separation", 10)
	side_box.add_child(action_box)

	hint_button = Button.new()
	hint_button.name = "HintButton"
	hint_button.text = "Pista da Aline (2)"
	hint_button.focus_mode = Control.FOCUS_NONE
	hint_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint_button.pressed.connect(_on_hint_button_pressed)
	action_box.add_child(hint_button)
	ScreenTools.apply_button(hint_button, self, "secondary", Vector2(0, 64), Vector2(0, 50), 22, 17)

	quick_guess_button = Button.new()
	quick_guess_button.name = "QuickGuessButton"
	quick_guess_button.text = "Já sei o termo!"
	quick_guess_button.focus_mode = Control.FOCUS_NONE
	quick_guess_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quick_guess_button.expand_icon = true
	quick_guess_button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	quick_guess_button.icon = UiIcons.texture("sparkles")
	quick_guess_button.pressed.connect(_open_quick_guess)
	action_box.add_child(quick_guess_button)
	ScreenTools.apply_button(quick_guess_button, self, "primary", Vector2(0, 64), Vector2(0, 50), 22, 17)
	FontScale.set_icon_ratio(quick_guess_button, 1.3)
	_prepare_side_button(hint_button)
	_prepare_side_button(quick_guess_button)
	side_panel.resized.connect(_fit_side_buttons)

	_build_quick_layer()
	_build_feedback_layer()
	_build_finish_layer()
	_apply_responsive_layout()

	# V0.16.7: padrao unico de layout dinamico (fonte grande / tela baixa nunca cortam o conteudo).
	layout_fit = DynamicLayout.new(self, root_margin, main_box, 20)
	layout_fit.add_gap(main_box, "separation", 14).add_gap(stage_box, "separation", 12).add_gap(side_box, "separation", 10).add_gap(action_box, "separation", 10)
	layout_fit.add_min_height(word_panel, 84.0, 56.0)
	layout_fit.set_buttons(Callable(self, "_fit_scaled"))

func _clear_scene_children() -> void:
	for child in get_children():
		child.queue_free()

func _apply_responsive_layout() -> void:
	if root_margin == null:
		return
	ScreenTools.apply_safe_margins(root_margin, self, 30, 14)
	_apply_sizes()

func _create_chip_label(text_value: String, bg_color: Color, text_color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(150, 34)
	label.add_theme_color_override("font_color", text_color)
	var style: StyleBoxFlat = _make_panel_style(bg_color, Color(1, 1, 1, 0.22), 12, 1)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	label.add_theme_stylebox_override("normal", style)
	return label

func _make_tag_style(bg_color: Color, border_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = _make_panel_style(bg_color, border_color, 14, 2)
	style.shadow_size = 0
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	return style

func _fit_scaled(k: float) -> void:
	ui_k = k
	_apply_sizes()
	if aline_hint_panel != null:
		# V0.16.18: a pista NUNCA some por causa da escala (antes: k < 0.7 escondia o painel DEPOIS de o
		# DynamicLayout ja ter encolhido a tela por causa dele = layout pequeno e pista invisivel).
		_set_aline_hint_visible(hint_phrase_shown)
		_reserve_aline_hint_space()
		_refresh_aline_hint_text()

func _apply_key_sizes() -> void:
	var size_px: Vector2 = ScreenTools.responsive_size(self, Vector2(66, 58), Vector2(46, 44))
	var font_px: int = _fs(23, 17)
	for button in letter_buttons.values():
		if button is Button:
			(button as Button).custom_minimum_size = Vector2(maxf(30.0, size_px.x * ui_k), maxf(30.0, size_px.y * ui_k))
			FontScale.set_size(button as Button, font_px)

# ======================================================================
# BANCO DE TERMOS / RODADAS
# ======================================================================
func _connect_score_signal() -> void:
	var callable: Callable = Callable(self, "_on_score_changed")
	if not ScoreManager.score_changed.is_connected(callable):
		ScoreManager.score_changed.connect(callable)

## Glossario inteiro (3 dificuldades + termos extras): base dos "2 termos parecidos" do chute rapido.
func _load_term_pool() -> void:
	term_pool.clear()
	var seen: Dictionary = {}
	for diff in ["facil", "normal", "dificil"]:
		for item in DynamicQuestionBank.get_bank("forca_tecnica", diff):
			var word: String = str((item as Dictionary).get("word", "")).strip_edges()
			var key: String = _normalize_text(word)
			if word == "" or seen.has(key):
				continue
			seen[key] = true
			term_pool.append({"word": word, "area": str((item as Dictionary).get("area", ""))})
	var extras: Dictionary = DynamicQuestionBank.get_stop_terms_by_initial()
	for initial in extras.keys():
		for extra in extras[initial]:
			var extra_word: String = str(extra).strip_edges()
			var extra_key: String = _normalize_text(extra_word)
			if extra_word == "" or seen.has(extra_key):
				continue
			seen[extra_key] = true
			term_pool.append({"word": extra_word, "area": ""})
	if term_pool.is_empty():
		for fallback in FALLBACK_BANK:
			term_pool.append({"word": str((fallback as Dictionary).get("word", "")), "area": str((fallback as Dictionary).get("area", ""))})

func _prepare_questions() -> void:
	total_errors_count = 0
	_configure_difficulty()
	questions.clear()
	var question_type: String = str(DifficultyManager.get_rules().get("pergunta_tipo", "normal"))
	questions = DynamicQuestionBank.pick_rounds("forca_tecnica", question_type, total_rounds)
	if questions.is_empty():
		var all_words: Array = FALLBACK_BANK.duplicate(true)
		all_words.shuffle()
		for item in all_words:
			if questions.size() >= total_rounds:
				break
			if item is Dictionary:
				questions.append(item as Dictionary)
	_configure_difficulty()

func _configure_difficulty() -> void:
	var diff: String = DifficultyManager.get_difficulty()
	max_errors = int(ERRORS_BY_DIFFICULTY.get(diff, 10))
	if difficulty_label != null:
		difficulty_label.text = "Dificuldade: %s" % DifficultyManager.get_label()
		DifficultyManager.apply_difficulty_chip(difficulty_label)
	_refresh_record_label()

## Recorde do minigame na dificuldade atual (modo livre = melhor pontuacao; campanha = pontuacao da estacao).
func _refresh_record_label() -> void:
	if record_label == null:
		return
	var diff: String = DifficultyManager.get_difficulty()
	var best: int = 0
	if has_node("/root/GameManager") and GameManager.is_free_mode():
		best = ScoreManager.get_free_mode_best_score("forca_tecnica", diff)
	else:
		best = ScoreManager.get_campaign_minigame_score("forca_tecnica", diff)
	record_label.text = "Recorde: %s" % (str(best) if best > 0 else "—")

func _start_round(index: int) -> void:
	if index >= total_rounds or index >= questions.size():
		_show_finish()
		return
	input_locked = true
	finish_visible = false
	current_round_index = index
	current_question = questions[current_round_index]
	guessed_letters.clear()
	errors_this_word = 0
	hints_used = 0
	quick_used = false
	quick_open = false
	quick_ready_announced = false
	_choose_keyboard_letters()
	_build_keyboard()
	_build_word_tiles()
	_update_round_ui()
	_update_integrity_ui()
	_update_word_display()
	_update_action_buttons()
	if layout_fit != null:
		layout_fit.schedule()
	await get_tree().create_timer(0.25, false).timeout
	if is_inside_tree():
		input_locked = false
		_update_action_buttons()

func _update_round_ui() -> void:
	round_label.text = "RODADA %s/%s" % [current_round_index + 1, total_rounds]
	var letters: int = _letter_indices().size()
	var words: int = _word().split(" ", false).size()
	var tag: String = "%s • %s letras" % [str(current_question.get("area", "Revisão pelos pares")), letters]
	if words > 1:
		tag += " • %s palavras" % words
	area_label.text = tag
	hint_label.text = str(current_question.get("hint", "Identifique o termo."))
	aline_hint_label.text = ""
	aline_hint_phrase = ""
	hint_phrase_shown = false
	_set_aline_hint_visible(false)
	_reserve_aline_hint_space()
	_refresh_record_label()

# ======================================================================
# PALAVRA, LETRAS E ACENTOS
# ======================================================================
func _word() -> String:
	return str(current_question.get("word", ""))

## Indices (no texto original) de cada letra; espacos e hifens ficam de fora.
func _letter_indices() -> Array[int]:
	var result: Array[int] = []
	var word: String = _word()
	for i in range(word.length()):
		if _is_letter_char(_normalize_text(word.substr(i, 1))):
			result.append(i)
	return result

## Letras-base unicas (sem acento) do termo, em ordem alfabetica.
func _unique_letters() -> Array[String]:
	var result: Array[String] = []
	var word: String = _word()
	for i in range(word.length()):
		var normalized: String = _normalize_text(word.substr(i, 1))
		if _is_letter_char(normalized) and not result.has(normalized):
			result.append(normalized)
	result.sort()
	return result

func _is_pos_revealed(index: int) -> bool:
	var normalized: String = _normalize_text(_word().substr(index, 1))
	return guessed_letters.has(normalized)

func _revealed_ratio() -> float:
	var indices: Array[int] = _letter_indices()
	if indices.is_empty():
		return 1.0
	var revealed: int = 0
	for i in indices:
		if _is_pos_revealed(i):
			revealed += 1
	return float(revealed) / float(indices.size())

func _is_word_solved() -> bool:
	for i in _letter_indices():
		if not _is_pos_revealed(i):
			return false
	return true

func _word_contains_letter(letter: String) -> bool:
	return _unique_letters().has(letter)

func _is_letter_char(value: String) -> bool:
	return value.length() == 1 and "abcdefghijklmnopqrstuvwxyz".find(value) >= 0

## V0.16.15: ACENTO E CEDILHA AUTOMATICOS. O jogo trabalha so com a letra-base: clicar A revela A, Á, Ã e Â;
## clicar C revela Ç; E revela É e Ê... O jogador nunca gasta tentativa adivinhando a acentuacao.
func _normalize_text(value: String) -> String:
	var result: String = value.to_lower()
	var pairs := {
		"á": "a", "à": "a", "ã": "a", "â": "a", "ä": "a",
		"é": "e", "è": "e", "ê": "e", "ë": "e",
		"í": "i", "ì": "i", "î": "i", "ï": "i",
		"ó": "o", "ò": "o", "õ": "o", "ô": "o", "ö": "o",
		"ú": "u", "ù": "u", "û": "u", "ü": "u",
		"ç": "c"
	}
	for key in pairs.keys():
		result = result.replace(str(key), str(pairs[key]))
	return result

# ======================================================================
# TECLADO (alfabeto completo, A a Z)
# ======================================================================
func _choose_keyboard_letters() -> void:
	keyboard_letters.clear()
	for code in range(97, 123):
		keyboard_letters.append(String.chr(code))

func _build_keyboard() -> void:
	if keyboard_grid == null:
		return
	_clear_keyboard_rows(true)
	kb_signature = ""
	letter_buttons.clear()
	for letter in keyboard_letters:
		var button: Button = Button.new()
		button.name = "Letter%s" % letter.to_upper()
		button.text = letter.to_upper()
		button.focus_mode = Control.FOCUS_NONE
		button.set_meta("letter", letter)
		button.pressed.connect(_on_letter_button_pressed.bind(letter))
		ScreenTools.apply_button(button, self, "secondary", Vector2(66, 58), Vector2(46, 44), 23, 17)
		letter_buttons[letter] = button
	_apply_key_sizes()
	_layout_keyboard()

func _on_letter_button_pressed(letter: String) -> void:
	_guess_letter(letter)

func _guess_letter(letter: String) -> void:
	if input_locked or finish_visible or quick_open:
		return
	letter = _normalize_text(letter)
	if letter.length() != 1 or not _is_letter_char(letter):
		return
	# Teclado fisico: so vale letra que existe no teclado da rodada (sem punir tecla "inutil").
	if not letter_buttons.has(letter):
		return
	if guessed_letters.has(letter):
		return
	guessed_letters[letter] = true
	var is_correct: bool = _word_contains_letter(letter)
	_update_letter_button(letter, "correct" if is_correct else "wrong")
	if is_correct:
		if has_node("/root/AudioManager"):
			AudioManager.play_sfx("correto")
		_update_word_display()
		_animate_reveal(letter)
		_after_reveal()
		if _is_word_solved():
			await _complete_round(true)
	else:
		var failed: bool = _register_error()
		if failed:
			_update_word_display(1)
			await _complete_round(false)

## Erro (letra errada ou chute rapido errado): -1 ponto de integridade. Devolve true se a integridade acabou.
func _register_error() -> bool:
	errors_this_word += 1
	total_errors_count += 1
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("errado")
	if _animations_enabled():
		shake_strength = 10.0 + float(errors_this_word) * 2.0
	_update_integrity_ui()
	_update_action_buttons()
	return errors_this_word >= max_errors

func _after_reveal() -> void:
	_update_action_buttons()

func _update_letter_button(letter: String, state: String) -> void:
	if not letter_buttons.has(letter):
		return
	var button: Button = letter_buttons[letter] as Button
	if button == null:
		return
	button.disabled = true
	var fill: Color = Color(0.04, 0.34, 0.34, 0.95)
	var border: Color = UiPalette.SECONDARY
	var text_color: Color = Color(0.88, 1.0, 0.98)
	match state:
		"wrong":
			fill = Color(0.52, 0.04, 0.10, 0.95)
			border = UiPalette.DIFF_HARD
			text_color = Color(1.0, 0.84, 0.82)
		"hint":
			fill = Color(0.46, 0.30, 0.04, 0.95)
			border = GOLD
			text_color = Color(1.0, 0.95, 0.80)
	button.add_theme_stylebox_override("disabled", _make_button_style(fill, border, 2))
	button.add_theme_color_override("font_disabled_color", text_color)

# ======================================================================
# PALAVRA EM TILES
# ======================================================================
func _build_word_tiles() -> void:
	for child in word_label.get_children():
		word_label.remove_child(child)
		child.queue_free()
	word_cells.clear()
	var word: String = _word()
	var group: HBoxContainer = null
	for i in range(word.length()):
		var ch: String = word.substr(i, 1)
		if ch == " ":
			group = null
			continue
		if group == null:
			group = HBoxContainer.new()
			group.mouse_filter = Control.MOUSE_FILTER_IGNORE
			group.add_theme_constant_override("separation", 5)
			word_label.add_child(group)
		var cell: PanelContainer = PanelContainer.new()
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var label: Label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		FontScale.skip(label)   # o tamanho do tile ja e calculado para caber; o texto acompanha o tile
		cell.add_child(label)
		group.add_child(cell)
		var is_letter: bool = _is_letter_char(_normalize_text(ch))
		word_cells.append({"index": i, "panel": cell, "label": label, "char": ch, "is_letter": is_letter})
	_apply_tile_sizes()

func _word_area_width() -> float:
	var width: float = 0.0
	if word_panel != null and word_panel.size.x > 100.0:
		width = word_panel.size.x - 40.0
	else:
		width = ScreenTools.get_viewport_size(self).x * 0.52
	return maxf(width, 160.0)

func _apply_tile_sizes() -> void:
	if word_cells.is_empty():
		return
	var longest: int = 1
	for token in _word().split(" ", false):
		longest = maxi(longest, str(token).length())
	var gap: float = 5.0
	var fit_w: float = (_word_area_width() - gap * float(longest - 1)) / float(longest)
	# V0.16.18: o tile acompanha a escala de fonte ativa (FontScale) e o fator do DynamicLayout.
	var comfy: float = ScreenTools.responsive_value(self, 46.0, 36.0) * clampf(FontScale.get_factor(), 1.0, 1.25) * ui_k
	var cell_w: float = clampf(minf(fit_w, comfy), 18.0, 80.0)
	var cell_h: float = cell_w * 1.28
	var font_px: int = maxi(12, int(cell_h * 0.55))
	for entry in word_cells:
		var panel: PanelContainer = entry["panel"] as PanelContainer
		var label: Label = entry["label"] as Label
		if panel == null or label == null:
			continue
		var is_letter: bool = bool(entry["is_letter"])
		panel.custom_minimum_size = Vector2(cell_w if is_letter else cell_w * 0.55, cell_h)
		label.add_theme_font_size_override("font_size", font_px)

func _cell_style(state: String) -> StyleBoxFlat:
	if cell_styles.has(state):
		return cell_styles[state] as StyleBoxFlat
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.set_corner_radius_all(9)
	style.content_margin_left = 2
	style.content_margin_right = 2
	style.content_margin_top = 2
	style.content_margin_bottom = 2
	match state:
		"revealed":
			style.bg_color = PAPER
			style.border_color = Color(0.82, 0.66, 0.36, 1.0)
			style.set_border_width_all(2)
		"missed":
			style.bg_color = Color(0.40, 0.06, 0.12, 0.95)
			style.border_color = UiPalette.DIFF_HARD
			style.set_border_width_all(2)
		_:
			style.bg_color = Color(0.0, 0.0, 0.0, 0.30)
			style.border_color = UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.85)
			style.border_width_bottom = 4
	cell_styles[state] = style
	return style

## mode 0 = jogo normal | 1 = falha (revela o termo, letras nao descobertas em vermelho) | 2 = vitoria (revela tudo).
func _update_word_display(mode: int = 0) -> void:
	for entry in word_cells:
		var panel: PanelContainer = entry["panel"] as PanelContainer
		var label: Label = entry["label"] as Label
		if panel == null or label == null:
			continue
		var index: int = int(entry["index"])
		var ch: String = str(entry["char"])
		if not bool(entry["is_letter"]):
			panel.add_theme_stylebox_override("panel", _cell_style("revealed"))
			label.text = ch
			label.add_theme_color_override("font_color", PAPER_INK)
			continue
		var revealed: bool = mode != 0 or _is_pos_revealed(index)
		if not revealed:
			panel.add_theme_stylebox_override("panel", _cell_style("hidden"))
			label.text = ""
			continue
		var state: String = "revealed"
		if mode == 1 and not _is_pos_revealed(index):
			state = "missed"
		panel.add_theme_stylebox_override("panel", _cell_style(state))
		label.text = ch.to_upper()
		label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.90) if state == "missed" else PAPER_INK)

# ======================================================================
# PISTA DA ALINE
# ======================================================================
## Pedir pista: a Aline aparece no cartao do tutorial com a pista; ao confirmar, a letra-chave surge animada.
func _on_hint_button_pressed() -> void:
	if input_locked or finish_visible or quick_open or hints_used >= MAX_HINTS_PER_ROUND:
		return
	var letter: String = _pick_hint_letter()
	if letter == "":
		return
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	var phrase: String = _hint_phrase(hints_used + 1)
	input_locked = true
	_update_action_buttons()
	var proceed: bool = await _play_aline_card("pista", {"pista": phrase})
	if not is_inside_tree():
		return
	input_locked = false
	if not proceed or finish_visible:
		_update_action_buttons()
		return
	hints_used += 1
	guessed_letters[letter] = true
	_update_letter_button(letter, "hint")
	aline_hint_phrase = "Pista: %s" % phrase
	hint_phrase_shown = true
	_set_aline_hint_visible(true)
	_refresh_aline_hint_text()
	_update_word_display()
	_animate_reveal(letter)
	_after_reveal()
	# V0.16.18: sem layout_fit.schedule() aqui - o espaco da pista ja esta reservado desde o inicio da rodada,
	# entao usar a dica nao muda a altura e nao deve disparar nova medicao (que fazia o nivel oscilar 0 <-> 1).
	if _is_word_solved():
		await get_tree().create_timer(0.8, false).timeout
		if is_inside_tree():
			await _complete_round(true)

## Letra da pista: uma letra ainda oculta, sorteada (antes era sempre a que mais se repetia).
func _pick_hint_letter() -> String:
	var hidden_letters: Array[String] = []
	var word: String = _word()
	for i in _letter_indices():
		if _is_pos_revealed(i):
			continue
		var letter: String = _normalize_text(word.substr(i, 1))
		if not hidden_letters.has(letter):
			hidden_letters.append(letter)
	if hidden_letters.is_empty():
		return ""
	return hidden_letters[randi() % hidden_letters.size()]

func _hint_phrase(hint_number: int) -> String:
	var word: String = _word()
	var association: String = str(current_question.get("pista_aline", "")).strip_edges()
	var practice: String = str(current_question.get("pratica", "")).strip_edges().replacen(word, "___")
	if hint_number == 1:
		if association != "":
			return association
		if practice != "":
			return practice
		return str(current_question.get("hint", "Releia a definição com calma."))
	if hint_number == 2 and practice != "" and practice != association:
		return practice
	return LINES_HINT_EXTRA

func _hidden_letters_left() -> bool:
	for i in _letter_indices():
		if not _is_pos_revealed(i):
			return true
	return false

# ======================================================================
# "JA SEI O TERMO!" - CHUTE RAPIDO COM 3 OPCOES
# ======================================================================
func _quick_available() -> bool:
	return not quick_used and _revealed_ratio() >= QUICK_GUESS_THRESHOLD and not _is_word_solved()

func _update_action_buttons() -> void:
	if hint_button == null or quick_guess_button == null:
		return
	var hints_left: int = MAX_HINTS_PER_ROUND - hints_used
	hint_button.disabled = input_locked or quick_open or hints_left <= 0 or not _hidden_letters_left()
	hint_button.text = "Pista da Aline (%s)" % maxi(hints_left, 0)
	hint_button.tooltip_text = "Revela 1 letra-chave e uma pista da Aline. Cada pista tira %s%% dos pontos da rodada." % int(HINT_DISCOUNT * 100.0)
	var available: bool = _quick_available()
	quick_guess_button.disabled = input_locked or quick_open or not available
	quick_guess_button.text = "Chute usado" if quick_used else "Já sei o termo!"
	if quick_used:
		quick_guess_button.tooltip_text = "Só 1 chute rápido por rodada."
	else:
		quick_guess_button.tooltip_text = "Libera com %s%% do termo revelado." % int(QUICK_GUESS_THRESHOLD * 100.0)
	if available and not quick_ready_announced and not input_locked:
		quick_ready_announced = true
		_pulse_control(quick_guess_button)

## Os 2 termos "parecidos". Quanto mais dificil, mais parecidos (prefixo, palavras em comum, edicao, tamanho e ate as
## letras ja reveladas na mesma posicao). No facil, um dos dois e claramente mais distante.
func _pick_decoys(answer: Dictionary) -> Array[String]:
	var word: String = str(answer.get("word", ""))
	var area: String = str(answer.get("area", ""))
	var norm: String = _normalize_text(word)
	var diff: String = DifficultyManager.get_difficulty()
	var jitter: float = 0.8 if diff == "dificil" else (1.6 if diff == "normal" else 3.0)
	var pattern_weight: float = 7.0 if diff == "dificil" else (4.0 if diff == "normal" else 1.0)
	var scored: Array[Dictionary] = []
	for entry in term_pool:
		var candidate: String = str(entry.get("word", ""))
		var candidate_norm: String = _normalize_text(candidate)
		if candidate_norm == norm or candidate_norm == "":
			continue
		var score: float = _term_similarity(word, candidate, area, str(entry.get("area", "")))
		score += _pattern_fit(word, candidate) * pattern_weight
		score += randf() * jitter
		scored.append({"word": candidate, "score": score})
	scored.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["score"]) > float(b["score"]))
	var result: Array[String] = []
	if scored.size() <= 2:
		for item in scored:
			result.append(str(item["word"]))
		return result
	if diff == "facil":
		result.append(str(scored[randi() % 3]["word"]))
		var low: int = mini(7, scored.size() - 1)
		var high: int = mini(14, scored.size() - 1)
		for attempt in range(8):
			var pick: String = str(scored[randi_range(low, high)]["word"])
			if not result.has(pick):
				result.append(pick)
				break
		if result.size() < 2:
			result.append(str(scored[3]["word"]))
	else:
		result.append(str(scored[0]["word"]))
		result.append(str(scored[1]["word"]))
	return result

func _tokens_of(normalized: String) -> PackedStringArray:
	return normalized.replace("-", " ").split(" ", false)

func _term_similarity(word_a: String, word_b: String, area_a: String, area_b: String) -> float:
	var a: String = _normalize_text(word_a)
	var b: String = _normalize_text(word_b)
	var score: float = 0.0
	var limit: int = mini(a.length(), b.length())
	var prefix: int = 0
	while prefix < limit and a.substr(prefix, 1) == b.substr(prefix, 1):
		prefix += 1
	score += minf(float(prefix), 8.0) * 0.9
	var tokens_a: PackedStringArray = _tokens_of(a)
	var tokens_b: PackedStringArray = _tokens_of(b)
	for ta in tokens_a:
		if ta.length() >= 4 and tokens_b.has(ta):
			score += 3.0
	for ta in tokens_a:
		for tb in tokens_b:
			if ta != tb and ta.length() >= 5 and tb.length() >= 5 and ta.substr(0, 5) == tb.substr(0, 5):
				score += 1.5
	var longest: int = maxi(maxi(a.length(), b.length()), 1)
	score += (1.0 - float(_edit_distance(a, b)) / float(longest)) * 6.0
	if area_a != "" and area_a == area_b:
		score += 2.0
	if tokens_a.size() == tokens_b.size():
		score += 1.0
	score -= absf(float(a.length() - b.length())) * 0.3
	return score

func _edit_distance(a: String, b: String) -> int:
	var n: int = a.length()
	var m: int = b.length()
	if n == 0:
		return m
	if m == 0:
		return n
	var prev: Array[int] = []
	for j in range(m + 1):
		prev.append(j)
	for i in range(1, n + 1):
		var cur: Array[int] = [i]
		for j in range(1, m + 1):
			var cost: int = 0 if a.substr(i - 1, 1) == b.substr(j - 1, 1) else 1
			cur.append(mini(mini(prev[j] + 1, cur[j - 1] + 1), prev[j - 1] + cost))
		prev = cur
	return prev[m]

## Quanto o candidato "combina" com o que o jogador ja ve na tela (mesmas letras nas mesmas posicoes, mesmo tamanho).
func _pattern_fit(answer: String, candidate: String) -> float:
	var a: String = _normalize_text(answer)
	var c: String = _normalize_text(candidate)
	var revealed_total: int = 0
	var matched: int = 0
	for i in range(a.length()):
		var ch: String = a.substr(i, 1)
		if not _is_letter_char(ch) or not _is_pos_revealed(i):
			continue
		revealed_total += 1
		if i < c.length() and c.substr(i, 1) == ch:
			matched += 1
	var fit: float = 0.0
	if revealed_total > 0:
		fit = float(matched) / float(revealed_total)
	if a.length() == c.length():
		fit += 0.5
	return fit

func _open_quick_guess() -> void:
	if input_locked or finish_visible or quick_open or not _quick_available():
		return
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	input_locked = true
	_update_action_buttons()
	# A Aline provoca no cartao do tutorial; so depois as 3 opcoes aparecem.
	var go: bool = await _play_aline_card("chute", {"provoca": _pick_line(LINES_QUICK_PROVOKE)})
	if not is_inside_tree():
		return
	if not go or finish_visible:
		input_locked = false
		_update_action_buttons()
		return
	quick_open = true
	var options: Array[String] = [_word()]
	for decoy in _pick_decoys(current_question):
		options.append(decoy)
	options.shuffle()
	for child in quick_options_box.get_children():
		quick_options_box.remove_child(child)
		child.queue_free()
	for option in options:
		var button: Button = Button.new()
		button.text = option
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(_on_quick_option_pressed.bind(option))
		quick_options_box.add_child(button)
		ScreenTools.apply_button(button, self, "option", Vector2(520, 56), Vector2(330, 46), 21, 16)
	quick_layer.visible = true
	_update_action_buttons()

func _on_quick_cancel_pressed() -> void:
	if not quick_open:
		return
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	quick_open = false
	quick_layer.visible = false
	input_locked = false
	_update_action_buttons()

func _on_quick_option_pressed(option: String) -> void:
	if not quick_open:
		return
	quick_open = false
	quick_used = true
	quick_layer.visible = false
	# V0.16.18: som de clique ao escolher o palpite e som de acerto (o erro ja toca em _register_error).
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	if _normalize_text(option) == _normalize_text(_word()):
		if has_node("/root/AudioManager"):
			AudioManager.play_sfx("correto")
		await _complete_round(true, true)
		return
	input_locked = false
	var failed: bool = _register_error()
	if failed:
		_update_word_display(1)
		await _complete_round(false)

## Bonus de velocidade: 40 pontos se chutou com 40% revelado, caindo ate 0 com o termo todo revelado.
func _quick_speed_bonus(ratio: float) -> int:
	var span: float = 1.0 - QUICK_GUESS_THRESHOLD
	return int(round(float(SPEED_BONUS_MAX) * clampf((1.0 - ratio) / span, 0.0, 1.0)))

func _pick_line(lines: Array[String]) -> String:
	if lines.is_empty():
		return ""
	return lines[randi() % lines.size()]

# ======================================================================
# FIM DE RODADA / PONTUACAO
# ======================================================================
func _complete_round(solved: bool, quick: bool = false) -> void:
	input_locked = true
	_update_action_buttons()
	for button in letter_buttons.values():
		if button is Button:
			(button as Button).disabled = true
	var word: String = _word()
	var explanation: String = _get_current_term_explanation() + FeedbackText.practice_line(str(current_question.get("pratica", "")))   # V0.16.2
	if solved:
		success_count += 1
		var speed_bonus: int = _quick_speed_bonus(_revealed_ratio()) if quick else 0
		_update_word_display(2)
		var integrity_bonus: int = int(round(float(_get_integrity_percent()) / 100.0 * float(INTEGRITY_BONUS_CAP)))
		var discount: float = float(hints_used) * HINT_DISCOUNT
		var gross_points: int = SOLVE_BASE_POINTS + integrity_bonus + speed_bonus
		var net_points: int = int(round(float(gross_points) * (1.0 - discount)))
		var round_points: int = roundi(float(net_points) * SettingsManager.question_score_scale("forca_tecnica"))   # V0.16.1
		earned_points += round_points
		ScoreManager.add_points(round_points)
		var extra_lines: String = ""
		if quick:
			extra_lines += "Palpite certeiro: +%s de bônus de velocidade\n" % speed_bonus
		if hints_used > 0:
			extra_lines += "Pistas da Aline: %s (−%s%% dos pontos)\n" % [hints_used, int(round(discount * 100.0))]
		await _show_feedback(true, "Palpite certeiro!" if quick else "Termo identificado!", "Resposta correta: %s\n%s\nIntegridade preservada: %s%%\n%s+%s pontos" % [word.to_upper(), explanation, _get_integrity_percent(), extra_lines, round_points])
	else:
		failure_count += 1
		await _show_feedback(false, "Faltou rigor!", "O termo correto era: %s\n%s\nIntegridade esgotada nesta rodada." % [word.to_upper(), explanation])
	if not is_inside_tree():
		return
	feedback_layer.visible = false
	_start_round(current_round_index + 1)

func _show_feedback(success: bool, title: String, body: String) -> void:
	feedback_title_label.text = title
	feedback_body_label.text = body
	feedback_title_label.add_theme_color_override("font_color", UiPalette.SECONDARY if success else UiPalette.DIFF_HARD)
	feedback_layer.visible = true
	AnswerLayout.fit_feedback(feedback_panel, feedback_body_scroll, feedback_body_label, 720.0, 72.0)
	await _wait_for_feedback_continue()

func _show_finish() -> void:
	input_locked = true
	finish_visible = true
	if has_node("/root/AchievementManager") and success_count >= total_rounds and total_errors_count <= 0:
		AchievementManager.unlock("sistema_intacto")
	if has_node("/root/AudioManager"):
		AudioManager.play_sfx("correto")
	var classification: String = _get_final_classification()
	finish_title_label.text = "Forca Técnica concluída!"
	finish_body_label.text = "Termos identificados: %s/%s\nRodadas perdidas: %s\nPontos obtidos no minigame: %s\nResultado: %s\nPontuação total: %s" % [success_count, total_rounds, failure_count, earned_points, classification, ScoreManager.get_score()]
	finish_layer.visible = true

## V0.16.15: classificacao por PROPORCAO (antes usava 6/4/2 fixos e nao acompanhava 2, 4, 8 ou 10 rodadas).
func _get_final_classification() -> String:
	var ratio: float = float(success_count) / float(maxi(total_rounds, 1))
	if ratio >= 1.0:
		return "Rigor impecável"
	if ratio >= 0.66:
		return "Domínio dos termos"
	if ratio >= 0.34:
		return "Terminologia em construção"
	return "Hora de reabrir o dicionário"

func _on_finish_continue_pressed() -> void:
	if not finish_visible:
		return
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	# V0.15: desempenho da estacao para o feedback do anfitriao (GameManager.report_stage).
	GameManager.report_stage({"total": total_rounds, "correct": success_count, "wrong": failure_count, "extra": {"erros_totais": total_errors_count}})
	GameManager.complete_current_stage(0)

func _get_current_term_explanation() -> String:
	var word: String = str(current_question.get("word", "termo"))
	var dynamic_explanation: String = str(current_question.get("explanation", "")).strip_edges()
	if dynamic_explanation != "" and dynamic_explanation.to_lower() != word.to_lower():
		return dynamic_explanation
	var hint: String = str(current_question.get("hint", "Representa um conceito importante da revisão pelos pares."))
	var area: String = str(current_question.get("area", "Revisão pelos pares"))
	return "%s é um termo de %s: %s" % [word.capitalize(), area, hint]

# ======================================================================
# INTEGRIDADE
# ======================================================================
func _update_integrity_ui() -> void:
	var integrity: int = _get_integrity_percent()
	integrity_bar.value = integrity
	integrity_label.text = "%s%%" % integrity
	error_label.text = "Erros: %s/%s" % [errors_this_word, max_errors]
	state_label.text = _get_system_state()
	var color: Color = _get_integrity_color()
	integrity_label.add_theme_color_override("font_color", color)
	integrity_bar.add_theme_stylebox_override("fill", _make_progress_style(color))

func _get_integrity_percent() -> int:
	if max_errors <= 0:
		return 0
	return maxi(0, int(round(100.0 - (float(errors_this_word) / float(max_errors)) * 100.0)))

func _get_system_state() -> String:
	var integrity: int = _get_integrity_percent()
	if integrity >= 100:
		return "Impecável"
	if integrity >= 75:
		return "Pequena oscilação"
	if integrity >= 50:
		return "Atenção redobrada"
	if integrity >= 25:
		return "Situação crítica"
	if integrity > 0:
		return "Última chance"
	return "Rigor esgotado"

func _get_integrity_color() -> Color:
	var integrity: int = _get_integrity_percent()
	if integrity >= 75:
		return UiPalette.SECONDARY
	if integrity >= 50:
		return UiPalette.DIFF_NORMAL
	if integrity > 0:
		return UiPalette.ACCENT_REWARDS
	return UiPalette.DIFF_HARD

# ======================================================================
# CAMADAS: CHUTE RAPIDO, FEEDBACK, FINAL
# ======================================================================
func _build_overlay_panel(layer: Control, panel_size: Vector2, border: Color, radius: int, overlay_alpha: float) -> PanelContainer:
	var overlay: ColorRect = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.03, 0.02, 0.07, overlay_alpha)
	layer.add_child(overlay)
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = panel_size
	panel.add_theme_stylebox_override("panel", _make_panel_style(UiPalette.with_alpha(UiPalette.CARD, 0.98), border, radius, 3))
	center.add_child(panel)
	return panel

func _build_quick_layer() -> void:
	quick_layer = Control.new()
	quick_layer.name = "QuickGuessLayer"
	quick_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	quick_layer.visible = false
	quick_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	quick_layer.z_index = 45
	add_child(quick_layer)
	quick_panel = _build_overlay_panel(quick_layer, Vector2(600, 0), UiPalette.HIGHLIGHT, 22, 0.72)
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 22)
	quick_panel.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)
	quick_title_label = Label.new()
	quick_title_label.text = "Já sabe o termo?"
	quick_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quick_title_label.add_theme_color_override("font_color", UiPalette.TEXT_ON_DARK)
	FontScale.set_size(quick_title_label, 30)
	box.add_child(quick_title_label)
	quick_sub_label = Label.new()
	quick_sub_label.text = "Escolha com atenção: errar custa 1 ponto de integridade. Acertar vence a rodada na hora."
	quick_sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quick_sub_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quick_sub_label.add_theme_color_override("font_color", UiPalette.TEXT_MUTED)
	FontScale.set_size(quick_sub_label, 17)
	box.add_child(quick_sub_label)
	quick_options_box = VBoxContainer.new()
	quick_options_box.add_theme_constant_override("separation", 10)
	box.add_child(quick_options_box)
	quick_cancel_button = Button.new()
	quick_cancel_button.text = "Ainda não, voltar"
	quick_cancel_button.focus_mode = Control.FOCUS_NONE
	quick_cancel_button.pressed.connect(_on_quick_cancel_pressed)
	box.add_child(quick_cancel_button)
	ScreenTools.apply_button(quick_cancel_button, self, "ghost", Vector2(260, 46), Vector2(210, 40), 18, 15)

func _build_feedback_layer() -> void:
	feedback_layer = Control.new()
	feedback_layer.name = "FeedbackLayer"
	feedback_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	feedback_layer.visible = false
	feedback_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	feedback_layer.z_index = 50
	add_child(feedback_layer)
	var panel: PanelContainer = _build_overlay_panel(feedback_layer, Vector2(720, 340), UiPalette.HIGHLIGHT, 22, 0.74)
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_bottom", 26)
	panel.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	margin.add_child(box)
	feedback_title_label = Label.new()
	feedback_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	FontScale.set_size(feedback_title_label, 38)
	box.add_child(feedback_title_label)
	feedback_body_label = Label.new()
	feedback_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	feedback_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	FontScale.set_size(feedback_body_label, 22)
	feedback_body_label.add_theme_color_override("font_color", UiPalette.TEXT_ON_DARK)
	box.add_child(feedback_body_label)
	feedback_body_scroll = AnswerLayout.install_body_scroll(box, feedback_body_label)
	feedback_panel = panel
	_create_feedback_continue_button(box)

func _create_feedback_continue_button(parent: VBoxContainer) -> void:
	feedback_continue_button = Button.new()
	feedback_continue_button.text = "Continuar"
	feedback_continue_button.focus_mode = Control.FOCUS_ALL
	parent.add_child(feedback_continue_button)
	ScreenTools.apply_button(feedback_continue_button, self, "success", Vector2(260, 52), Vector2(210, 46), 20, 17)

func _wait_for_feedback_continue() -> void:
	if feedback_continue_button == null:
		await get_tree().process_frame
		return
	feedback_continue_button.disabled = false
	_grab_continue_focus.call_deferred()
	await feedback_continue_button.pressed

## V0.16.18: so pede foco se o botao realmente puder recebe-lo (ScreenTools.apply_button / modo toque podem
## desligar o foco; chamar grab_focus assim gera o WARNING "This control can't grab focus").
func _grab_continue_focus() -> void:
	if feedback_continue_button == null or not is_instance_valid(feedback_continue_button):
		return
	if feedback_continue_button.focus_mode == Control.FOCUS_NONE or not feedback_continue_button.is_visible_in_tree():
		return
	feedback_continue_button.grab_focus()

func _build_finish_layer() -> void:
	finish_layer = Control.new()
	finish_layer.name = "FinishLayer"
	finish_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	finish_layer.visible = false
	finish_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	finish_layer.z_index = 60
	add_child(finish_layer)
	var panel: PanelContainer = _build_overlay_panel(finish_layer, Vector2(760, 380), GOLD, 24, 0.82)
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 38)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 38)
	margin.add_theme_constant_override("margin_bottom", 28)
	panel.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	margin.add_child(box)
	finish_title_label = Label.new()
	finish_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	FontScale.set_size(finish_title_label, 38)
	finish_title_label.add_theme_color_override("font_color", GOLD)
	box.add_child(finish_title_label)
	finish_body_label = Label.new()
	finish_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	finish_body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	finish_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	FontScale.set_size(finish_body_label, 22)
	finish_body_label.add_theme_color_override("font_color", UiPalette.TEXT_ON_DARK)
	box.add_child(finish_body_label)
	var continue_button: Button = Button.new()
	continue_button.text = "Continuar"
	continue_button.pressed.connect(_on_finish_continue_pressed)
	box.add_child(continue_button)
	ScreenTools.apply_button(continue_button, self, "success", Vector2(260, 58), Vector2(210, 46), 22, 17)

# ======================================================================
# EFEITOS (suaves: letras flutuantes e brilho; sem grade nem glitch)
# ======================================================================
func _create_symbol_particles() -> void:
	symbol_particles.clear()
	if particle_layer == null:
		return
	for i in range(WebLite.scaled_count(SYMBOL_PARTICLE_COUNT)):
		var label: Label = Label.new()
		label.text = str(FLOAT_SYMBOLS[i % FLOAT_SYMBOLS.size()])
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		FontScale.skip(label)
		label.add_theme_font_size_override("font_size", randi_range(20, 40))
		label.add_theme_color_override("font_color", Color(UiPalette.HIGHLIGHT.r, UiPalette.HIGHLIGHT.g, UiPalette.HIGHLIGHT.b, randf_range(0.10, 0.24)))
		particle_layer.add_child(label)
		var data: Dictionary = {
			"node": label,
			"speed": randf_range(10.0, 34.0),
			"drift": randf_range(-18.0, 18.0),
			"phase": randf_range(0.0, TAU),
			"rotation_speed": randf_range(-0.30, 0.30)
		}
		symbol_particles.append(data)
		_reset_symbol_particle(data, true)

func _reset_symbol_particles() -> void:
	for data in symbol_particles:
		_reset_symbol_particle(data, true)

func _reset_symbol_particle(data: Dictionary, random_y: bool = false) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(1280, 720)
	var label: Label = data["node"] as Label
	if label == null:
		return
	var next_y: float = randf_range(0.0, viewport_size.y) if random_y else viewport_size.y + randf_range(20.0, 120.0)
	label.position = Vector2(randf_range(12.0, maxf(viewport_size.x - 40.0, 40.0)), next_y)
	label.rotation = randf_range(-0.20, 0.20)

func _update_symbol_particles(delta: float) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var cheap: bool = WebLite.lite()   # navegador fraco: so move (sem rotacao nem pulso de transparencia)
	for data in symbol_particles:
		var label: Label = data["node"] as Label
		if label == null:
			continue
		var pos: Vector2 = label.position
		pos.y -= float(data.get("speed", 22.0)) * delta
		pos.x += sin(elapsed * 1.2 + float(data.get("phase", 0.0))) * float(data.get("drift", 0.0)) * delta
		label.position = pos
		if not cheap:
			label.rotation += float(data.get("rotation_speed", 0.0)) * delta
			label.modulate = Color(1.0, 1.0, 1.0, 0.60 + absf(sin(elapsed * 1.6 + float(data.get("phase", 0.0)))) * 0.40)
		if pos.y < -80.0 or pos.x < -110.0 or pos.x > viewport_size.x + 110.0:
			_reset_symbol_particle(data)

func _danger_ratio() -> float:
	return float(errors_this_word) / float(maxi(max_errors, 1))

## Redesenho a ~12 Hz (antes: todo quadro). No navegador "lite" so redesenha quando a moldura de perigo esta ativa.
func _update_effects_canvas(delta: float) -> void:
	if effects_canvas == null:
		return
	fx_accum += delta
	if fx_accum < 0.08:
		return
	fx_accum = 0.0
	if WebLite.lite() and _danger_ratio() < 0.6:
		return
	effects_canvas.queue_redraw()

func _on_effects_canvas_draw() -> void:
	if not _animations_enabled():
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	var pulse: float = (sin(elapsed * 1.8) + 1.0) * 0.5
	if not WebLite.lite():
		var glow: Color = UiPalette.PRIMARY
		effects_canvas.draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(glow.r, glow.g, glow.b, 0.04 + pulse * 0.02), true)
	# Integridade baixa: moldura vermelha pulsando nas bordas.
	var danger: float = _danger_ratio()
	if danger >= 0.6:
		effects_canvas.draw_rect(Rect2(Vector2(4, 4), viewport_size - Vector2(8, 8)), Color(1.0, 0.2, 0.25, (0.10 + pulse * 0.14) * danger), false, 8.0)

func _update_screen_shake(delta: float) -> void:
	if root_margin == null:
		return
	if shake_strength <= 0.0:
		if root_margin.position != base_root_position:
			root_margin.position = base_root_position
		return
	shake_strength = maxf(0.0, shake_strength - 34.0 * delta)
	var offset: Vector2 = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength * 0.65, shake_strength * 0.65))
	root_margin.position = base_root_position + offset

func _on_score_changed(new_score: int) -> void:
	if score_label != null:
		score_label.text = "Pontuação: %s" % new_score

func _animations_enabled() -> bool:
	return not has_node("/root/SettingsManager") or SettingsManager.animations_enabled()

func _make_panel_style(bg_color: Color, border_color: Color, radius: int = 14, border_width: int = 1) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0, 0, 0, 0.38)
	style.shadow_size = 10
	return style

func _make_button_style(bg_color: Color, border_color: Color, border_width: int = 2) -> StyleBoxFlat:
	var style: StyleBoxFlat = _make_panel_style(bg_color, border_color, 12, border_width)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 7
	style.content_margin_bottom = 7
	return style

func _make_progress_style(fill_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill_color
	style.set_corner_radius_all(8)
	return style

## Fonte em px ja multiplicada pelo fator do DynamicLayout (fonte grande + tela baixa nao cortam mais).
func _fs(desktop: int, compact: int) -> int:
	return maxi(11, int(round(float(ScreenTools.responsive_font(self, desktop, compact)) * ui_k)))

## Todas as medidas que dependem do tamanho da tela, da fonte escolhida e do fator ui_k (1.0 = visual original).
func _apply_sizes() -> void:
	if root_margin == null:
		return
	var compact: bool = ScreenTools.is_compact(self)
	if left_spacer != null:
		left_spacer.custom_minimum_size.x = 150.0 if compact else 214.0
	if right_spacer != null:
		right_spacer.custom_minimum_size.x = 140.0 if compact else 176.0
	if title_label != null:
		FontScale.set_size(title_label, _fs(30, 22))
	if subtitle_label != null:
		FontScale.set_size(subtitle_label, _fs(15, 12))
	for chip in [round_label, score_label]:
		if chip is Label:
			FontScale.set_size(chip as Label, _fs(16, 12))
			var chip_min: Vector2 = ScreenTools.responsive_size(self, Vector2(150, 34), Vector2(100, 28))
			(chip as Label).custom_minimum_size = Vector2(chip_min.x * maxf(ui_k, 0.7), chip_min.y * maxf(ui_k, 0.8))
	if difficulty_label != null:
		FontScale.set_size(difficulty_label, _fs(17, 13))
		difficulty_label.custom_minimum_size.y = 34.0 * maxf(ui_k, 0.7)
	if record_label != null:
		FontScale.set_size(record_label, _fs(17, 13))
		record_label.custom_minimum_size.y = 34.0 * maxf(ui_k, 0.7)
	if area_label != null:
		FontScale.set_size(area_label, _fs(18, 14))
	if hint_label != null:
		FontScale.set_size(hint_label, _fs(21, 15))
	if aline_hint_label != null:
		FontScale.set_size(aline_hint_label, _fs(17, 13))
	if side_title_label != null:
		FontScale.set_size(side_title_label, _fs(19, 14))
	if integrity_bar != null:
		var bar_min: Vector2 = ScreenTools.responsive_size(self, Vector2(200, 26), Vector2(140, 22))
		integrity_bar.custom_minimum_size = Vector2(bar_min.x, bar_min.y * maxf(ui_k, 0.7))
	if integrity_label != null:
		FontScale.set_size(integrity_label, _fs(30, 22))
	if state_label != null:
		FontScale.set_size(state_label, _fs(16, 12))
	if error_label != null:
		FontScale.set_size(error_label, _fs(18, 14))
	if side_panel != null:
		var side_min: Vector2 = ScreenTools.responsive_size(self, Vector2(320, 0), Vector2(220, 0))
		side_panel.custom_minimum_size = Vector2(side_min.x * clampf(ui_k, 0.8, 1.0), 0)
	if stage_panel != null:
		stage_panel.custom_minimum_size = Vector2(300, 0)
	for button in [hint_button, quick_guess_button]:
		if button is Button:
			(button as Button).custom_minimum_size = Vector2(0.0, maxf(34.0, ScreenTools.responsive_value(self, 64.0, 50.0) * ui_k))
	_fit_side_buttons()
	_reserve_aline_hint_space()
	_refresh_aline_hint_text()
	_apply_key_sizes()
	_apply_tile_sizes()
	_layout_keyboard()

## ======================================================================
## V0.16.18 - AJUSTES DE UI (botoes laterais e pista da Aline)
## ======================================================================
## Prepara um botao do painel lateral: largura minima NAO depende do texto (clip + autowrap de seguranca)
## e margens internas curtas, para o botao caber na coluna mesmo no modo Extra Grande.
func _prepare_side_button(button: Button) -> void:
	if button == null:
		return
	button.clip_text = true
	button.set("autowrap_mode", TextServer.AUTOWRAP_WORD_SMART)   # via set(): inofensivo em versoes sem esta propriedade
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for style_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		var base: StyleBox = button.get_theme_stylebox(style_name)
		if base == null:
			continue
		var copy: StyleBox = base.duplicate() as StyleBox
		copy.content_margin_left = SIDE_BTN_MARGIN_X
		copy.content_margin_right = SIDE_BTN_MARGIN_X
		button.add_theme_stylebox_override(style_name, copy)

## Fonte dos botoes laterais: grande, mas com teto proprio (fator ate 1,15x) e reduzida o minimo necessario
## para o MAIOR texto possivel ("Pista da Aline (2)") caber na largura real da coluna.
func _fit_side_buttons() -> void:
	if hint_button == null or quick_guess_button == null or side_panel == null:
		return
	var column_w: float = side_panel.size.x
	if column_w < 60.0:
		column_w = side_panel.custom_minimum_size.x
	var avail: float = column_w - 28.0 - 4.0   # margens laterais do painel (14 + 14) e borda
	var factor: float = maxf(FontScale.get_factor(), 1.0)
	var wanted: int = clampi(int(round(float(_fs(22, 17)) * minf(factor, SIDE_BTN_FACTOR_CAP))), SIDE_BTN_FONT_MIN, SIDE_BTN_FONT_MAX)
	var font: Font = hint_button.get_theme_font("font")
	var fitted: int = wanted
	if font != null and avail > 40.0:
		var icon_extra: float = 0.0
		while fitted > SIDE_BTN_FONT_MIN:
			icon_extra = float(fitted) * 1.3 + 8.0   # icone do "Ja sei o termo!"
			var w_hint: float = font.get_string_size("Pista da Aline (2)", HORIZONTAL_ALIGNMENT_LEFT, -1.0, fitted).x
			var w_quick: float = font.get_string_size("Já sei o termo!", HORIZONTAL_ALIGNMENT_LEFT, -1.0, fitted).x + icon_extra
			if maxf(w_hint, w_quick) + SIDE_BTN_MARGIN_X * 2.0 + 6.0 <= avail:
				break
			fitted -= 1
	var sig: String = "%s|%s|%s" % [fitted, int(avail), factor]
	if sig == side_btn_sig:
		return
	side_btn_sig = sig
	# FontScale.set_size multiplica pelo fator ativo; pre-compensamos para o resultado final ser `fitted`.
	var base_px: int = maxi(SIDE_BTN_FONT_MIN - 2, int(round(float(fitted) / factor)))
	FontScale.set_size(hint_button, base_px)
	FontScale.set_size(quick_guess_button, base_px)

## Mostra/esconde a pista SEM tirar o painel do layout (so alpha): a altura reservada nunca muda.
func _set_aline_hint_visible(shown: bool) -> void:
	if aline_hint_panel == null:
		return
	aline_hint_panel.visible = true
	aline_hint_panel.modulate.a = 1.0 if shown else 0.0

## Quebra manual (palavra a palavra) na largura real do cartao. Altura previsivel (nao depende de autowrap).
func _wrap_hint_lines(text: String) -> Array[String]:
	var lines: Array[String] = []
	var font: Font = aline_hint_label.get_theme_font("font")
	var px: int = aline_hint_label.get_theme_font_size("font_size")
	if font == null or px <= 0:
		lines.append(text)
		return lines
	var card_w: float = clue_card.size.x if clue_card != null and clue_card.size.x > 100.0 else _keyboard_area_width()
	var max_w: float = maxf(card_w - 16.0 * 2.0 - 12.0 * 2.0 - 8.0, 120.0)
	var current: String = ""
	for word in text.split(" ", false):
		var candidate: String = word if current == "" else current + " " + word
		if current != "" and font.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1.0, px).x > max_w:
			lines.append(current)
			current = word
		else:
			current = candidate
	if current != "":
		lines.append(current)
	return lines

func _refresh_aline_hint_text() -> void:
	if aline_hint_label == null or aline_hint_panel == null:
		return
	if aline_hint_phrase == "":
		aline_hint_label.text = ""
		return
	var wrapped: String = "\n".join(PackedStringArray(_wrap_hint_lines(aline_hint_phrase)))
	if aline_hint_label.text != wrapped:
		aline_hint_label.text = wrapped

## Reserva, desde o INICIO da rodada, a altura da maior pista possivel (pista 1 ou 2). Assim o DynamicLayout ja
## calcula a escala com esse espaco e pedir a pista nao muda mais a altura nem a escala da tela.
func _reserve_aline_hint_space() -> void:
	if aline_hint_label == null or current_question.is_empty():
		return
	var font: Font = aline_hint_label.get_theme_font("font")
	var px: int = aline_hint_label.get_theme_font_size("font_size")
	if font == null or px <= 0:
		return
	var max_lines: int = 1
	for n in range(1, MAX_HINTS_PER_ROUND + 1):
		max_lines = maxi(max_lines, _wrap_hint_lines("Pista: %s" % _hint_phrase(n)).size())
	max_lines = clampi(max_lines, 1, 3)
	aline_hint_label.custom_minimum_size.y = ceilf(font.get_height(px) * float(max_lines))

func _keyboard_area_width() -> float:
	if stage_panel != null and stage_panel.size.x > 100.0:
		return stage_panel.size.x - 44.0
	return ScreenTools.get_viewport_size(self).x * 0.55

## Teclas em linhas EQUILIBRADAS (15 teclas = 8 + 7, nunca 14 + 1) e centralizadas. So refaz as linhas quando muda.
func _layout_keyboard() -> void:
	if keyboard_grid == null or letter_buttons.is_empty():
		return
	var keys: Array[Button] = []
	for letter in keyboard_letters:
		if letter_buttons.has(letter):
			keys.append(letter_buttons[letter] as Button)
	if keys.is_empty():
		return
	var gap: int = maxi(4, int(round(8.0 * ui_k)))
	var key_w: float = maxf(keys[0].custom_minimum_size.x, 30.0)
	var per_row: int = maxi(1, int(floor((_keyboard_area_width() + float(gap)) / (key_w + float(gap)))))
	var rows: int = int(ceil(float(keys.size()) / float(per_row)))
	var balanced: int = int(ceil(float(keys.size()) / float(rows)))
	var signature: String = "%s|%s|%s|%s" % [keys.size(), balanced, gap, keyboard_letters.hash()]
	if signature == kb_signature:
		return
	kb_signature = signature
	_clear_keyboard_rows(false)
	keyboard_grid.add_theme_constant_override("separation", gap)
	var index: int = 0
	for r in range(rows):
		var row: HBoxContainer = HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", gap)
		keyboard_grid.add_child(row)
		for i in range(balanced):
			if index < keys.size():
				row.add_child(keys[index])
				index += 1

## free_buttons = true apaga tambem os botoes (nova rodada); false so desmonta as linhas para remontar.
func _clear_keyboard_rows(free_buttons: bool) -> void:
	for row in keyboard_grid.get_children():
		for key in row.get_children():
			row.remove_child(key)
			if free_buttons:
				key.queue_free()
		keyboard_grid.remove_child(row)
		row.queue_free()

## Cartao da Aline (o mesmo visual do tutorial) para pista e chute rapido. true = seguir; false = o jogador desistiu.
## Faz parte da MECANICA do minigame: aparece mesmo com os tutoriais desligados nas Configuracoes.
func _play_aline_card(phase: String, extra: Dictionary) -> bool:
	var holders: Dictionary = _tutorial_placeholders()
	holders.merge(extra, true)
	var steps: Array = TutorialManager.steps_for(self, "forca_tecnica", phase, holders)
	if steps.is_empty():
		return true
	var overlay: TutorialOverlay = TutorialManager.create_overlay(self, "forca_tecnica", {"phase": phase, "placeholders": holders}, TutorialOverlay.Mode.MODAL)
	if overlay == null:
		return true
	overlay.start(steps)
	var completed: bool = await overlay.finished
	return completed

func _tutorial_placeholders() -> Dictionary:
	return {
		"errors": max_errors, "base": SOLVE_BASE_POINTS, "bonus": INTEGRITY_BONUS_CAP,
		"speed": SPEED_BONUS_MAX, "hintcost": int(HINT_DISCOUNT * 100.0),
		"quick": int(QUICK_GUESS_THRESHOLD * 100.0)
	}

## Letra que "pula" para dentro da palavra (escala + brilho dourado); cada ocorrencia entra 0,12 s depois da anterior.
func _animate_reveal(letter: String) -> void:
	if not _animations_enabled():
		return
	var delay: float = 0.0
	for entry in word_cells:
		if not bool(entry["is_letter"]):
			continue
		if _normalize_text(str(entry["char"])) != letter:
			continue
		var panel: PanelContainer = entry["panel"] as PanelContainer
		if panel == null:
			continue
		panel.pivot_offset = panel.size * 0.5
		panel.scale = Vector2(0.2, 0.2)
		panel.modulate = Color(1.0, 0.90, 0.50, 1.0)
		var tween: Tween = create_tween().set_parallel(true)
		tween.tween_property(panel, "scale", Vector2.ONE, 0.45).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(panel, "modulate", Color.WHITE, 0.6).set_delay(delay)
		delay += 0.12

func _pulse_control(control: Control) -> void:
	if control == null or not _animations_enabled():
		return
	control.pivot_offset = control.size * 0.5
	var tween: Tween = create_tween()
	tween.tween_property(control, "scale", Vector2(1.08, 1.08), 0.16)
	tween.tween_property(control, "scale", Vector2.ONE, 0.22)
