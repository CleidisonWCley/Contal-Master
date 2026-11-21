class_name AnswerLayout
extends RefCounted
## V0.16.4 - Layout de RESPOSTAS e FEEDBACK que cresce para os lados (e rola, se precisar) em vez de cortar.
##
## POR QUE EXISTE: com a fonte "Extra grande" (V0.16.3) o painel de feedback (largura fixa ~760 px, centralizado) ficava
## mais alto que a tela: o titulo e o botao \"Continuar\" saiam do enquadramento e as respostas A/B/C/D cortavam o texto
## (altura fixa de 62 px, uma linha so). A solucao e unica para todos os minigames:
##   1) o painel de feedback LARGA conforme a fonte (Pequena/Media/Grande/Extra grande) ate o limite da tela;
##   2) o texto do feedback fica alinhado a ESQUERDA (leitura corrida) dentro de uma rolagem vertical: se ainda assim for
##      maior que a tela, o titulo e o \"Continuar\" continuam sempre visiveis e so o texto rola;
##   3) botoes de resposta alinham o texto a esquerda, quebram linha e CRESCEM em altura conforme a fonte.
## Tudo e medido por codigo (sem esperar frames), entao nao ha \"pulo\" visual ao abrir o feedback.

## Quanto o painel de feedback alarga em cada nivel de fonte (1.0 = largura base do minigame).
const WIDEN_BY_LEVEL: Dictionary = {
	"pequena": 1.10,
	"media": 1.20,
	"grande": 1.36,
	"extra_grande": 1.55,
}
## Folga (px) entre o painel e a borda da tela.
const EDGE_MARGIN: float = 44.0
## Folga vertical total reservada (topo: botoes de tela cheia/pausa; base: barras do sistema).
const VERTICAL_RESERVE: float = 112.0
## Altura minima da area de texto rolavel (nunca some por completo).
const MIN_BODY_HEIGHT: float = 120.0


## Fator de alargamento do nivel de fonte atual.
static func widen_factor() -> float:
	var level: String = "media"
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree != null and tree.root.has_node("FontScale"):
		level = str(tree.root.get_node("FontScale").call("get_level"))
	return float(WIDEN_BY_LEVEL.get(level, 1.2))


# ---------------------------------------------------------------- feedback
## Troca o `body` (Label ja dentro de `box`) por uma ScrollContainer que o contem. Devolve a rolagem.
## Chame logo depois do `box.add_child(body)`; o resto do codigo continua usando o mesmo Label.
static func install_body_scroll(box: Container, body: Label) -> ScrollContainer:
	var index: int = body.get_index()
	box.remove_child(body)
	var scroll := ScrollContainer.new()
	scroll.name = "FeedbackScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.add_child(scroll)
	box.move_child(scroll, index)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	body.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scroll.add_child(body)
	return scroll


## Ajusta a largura do painel e a altura da area de texto. Chamar DEPOIS de definir o texto, ao abrir o feedback.
## `base_width` = largura que o minigame usava (ex.: 760). `margins_x` = margens internas esquerda+direita do painel.
static func fit_feedback(panel: Control, scroll: ScrollContainer, body: Label, base_width: float, margins_x: float = 72.0) -> void:
	if panel == null or scroll == null or body == null or not panel.is_inside_tree():
		return
	var view: Vector2 = panel.get_viewport_rect().size
	var width: float = minf(base_width * widen_factor(), view.x - EDGE_MARGIN * 2.0)
	width = maxf(width, minf(base_width, view.x - EDGE_MARGIN * 2.0))
	panel.custom_minimum_size.x = width
	# Altura do texto na largura real da area de leitura.
	var text_width: float = maxf(120.0, width - margins_x)
	var needed: float = text_height(body, body.text, text_width) + 6.0
	# Altura do resto do painel (titulo + botao + margens), com a rolagem zerada.
	# A altura minima ORIGINAL do painel (ex.: 330) nao conta como \"resto\": guardamos, zeramos para medir e devolvemos.
	if not panel.has_meta("_al_base_h"):
		panel.set_meta("_al_base_h", panel.custom_minimum_size.y)
	var base_h: float = float(panel.get_meta("_al_base_h"))
	panel.custom_minimum_size.y = 0.0
	scroll.custom_minimum_size.y = 0.0
	var chrome: float = panel.get_combined_minimum_size().y
	var available: float = maxf(MIN_BODY_HEIGHT, view.y - VERTICAL_RESERVE - chrome)
	scroll.custom_minimum_size.y = minf(needed, available)
	panel.custom_minimum_size.y = minf(base_h, maxf(0.0, view.y - VERTICAL_RESERVE))
	scroll.scroll_vertical = 0


## Altura (px) que um texto ocupa quebrado em `width`, com a fonte/tamanho atuais do controle.
static func text_height(control: Control, text: String, width: float) -> float:
	if text == "":
		return 0.0
	var font: Font = control.get_theme_font("font")
	var font_size: int = control.get_theme_font_size("font_size")
	if font == null or font_size <= 0:
		return 0.0
	var size: Vector2 = font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, width, font_size)
	var line_h: float = maxf(1.0, font.get_height(font_size))
	var lines: float = maxf(1.0, round(size.y / line_h))
	var spacing: float = float(control.get_theme_constant("line_spacing")) if control.has_theme_constant("line_spacing") else 3.0
	# Uma linha so = altura exata da fonte (sem folga: o minimo original do botao ja comporta). Varias linhas: soma o
	# espacamento ENTRE linhas e +4% de folga para a quebra "inteligente" de palavras.
	if lines <= 1.0:
		return size.y
	return (size.y + spacing * (lines - 1.0)) * 1.04


# ---------------------------------------------------------------- respostas (botoes)
## Botao de resposta que quebra linha, alinha a esquerda e cresce em altura conforme a fonte.
## `button_width` = largura real do botao (px). `min_height` = altura minima do minigame (ex.: 62).
## `icon_extra` = largura que o icone lateral ocupa (px), descontada da area de texto; `icon_height` = altura do icone
## quando ele fica EM CIMA do texto (somada a altura do botao).
static func fit_option_button(button: Button, button_width: float, min_height: float, icon_extra: float = 0.0, icon_height: float = 0.0) -> void:
	if button == null:
		return
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.clip_text = true
	var style: StyleBox = button.get_theme_stylebox("normal")
	var pad_x: float = 0.0
	var pad_y: float = 0.0
	if style != null:
		pad_x = style.get_margin(SIDE_LEFT) + style.get_margin(SIDE_RIGHT)
		pad_y = style.get_margin(SIDE_TOP) + style.get_margin(SIDE_BOTTOM)
	var text_width: float = maxf(80.0, button_width - pad_x - icon_extra)
	var needed: float = text_height(button, button.text, text_width) + pad_y + icon_height
	button.custom_minimum_size.y = maxf(min_height, needed)


## Aplica `fit_option_button` em uma lista de botoes (todos com a mesma largura).
static func fit_option_buttons(buttons: Array, button_width: float, min_height: float, icon_extra: float = 0.0, icon_height: float = 0.0) -> void:
	for item in buttons:
		if item is Button and is_instance_valid(item):
			fit_option_button(item as Button, button_width, min_height, icon_extra, icon_height)
