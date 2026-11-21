class_name DynamicLayout
extends RefCounted
## V0.16.7 - PADRAO UNICO de layout dinamico dos minigames (fonte maior / tela menor nunca corta o conteudo).
##
## IDEIA: cada minigame informa as medidas ORIGINAIS ("base") do seu visual normal. Se a coluna principal nao cabe na
## altura da tela (fonte Grande/Extra grande, janela baixa, tela cheia diferente...), o helper reaplica TODAS as medidas
## multiplicadas por um fator de 4 niveis (1,00 -> 0,82 -> 0,66 -> 0,54) e para no primeiro nivel que cabe.
## Nivel 0 = visual original, entao nada muda quando ja cabe. Nenhum numero de "nivel" fica dentro dos minigames.
##
## USO (no fim do _build_scene do minigame):
##   layout_fit = DynamicLayout.new(self, root_margin, main_box, 34)
##   layout_fit.add_gap(main_box, "separation", 16).add_gap(options_box, "separation", 12)
##   layout_fit.add_min_height(question_panel, 120.0).add_icon(icon_a, Vector2(70, 70)).add_optional(hint_label)
##   layout_fit.set_buttons(Callable(self, "_fit_buttons_scaled"))   # recebe o fator k (1.0 .. 0.54)
## e chame `layout_fit.schedule()` quando o conteudo mudar (nova pergunta, troca de fonte, resize da janela).
## (Guarde a instancia em uma variavel do minigame: ela precisa continuar viva.)

## Fatores de cada nivel (0 = visual original).
const TIER_SCALES: Array = [1.0, 0.82, 0.66, 0.54]
## A partir deste nivel os itens "opcionais" (dicas de atalho etc.) ficam ocultos para sobrar altura.
const OPTIONAL_HIDE_FROM_TIER: int = 2
const MIN_MARGIN: int = 12
const MIN_GAP: int = 4
const MIN_ICON: float = 32.0

var current_tier: int = 0
var _last_logged_tier: int = -1
var _last_logged_fit: bool = false

var _host: Control
var _root_margin: MarginContainer
var _column: Control
var _base_margin: int
var _gaps: Array = []         # [Control, nome_da_constante, base_int]
var _min_heights: Array = []  # [Control, base_h, piso_h]
var _icons: Array = []        # [Control, base_size]
var _optional: Array = []     # [Control]
var _buttons_fit: Callable = Callable()


func _init(host: Control, root_margin: MarginContainer, column: Control, base_margin: int) -> void:
	_host = host
	_root_margin = root_margin
	_column = column
	_base_margin = base_margin


## Espacamento (theme constant) de um container, ex.: add_gap(box, "separation", 16).
func add_gap(container: Control, const_name: String, base: int) -> DynamicLayout:
	if container != null:
		_gaps.append([container, const_name, base])
	return self


## Altura minima de um painel/barra (ex.: painel da pergunta 120). `floor_h` = menor valor permitido.
func add_min_height(control: Control, base_h: float, floor_h: float = 0.0) -> DynamicLayout:
	if control != null:
		_min_heights.append([control, base_h, floor_h])
	return self


## Icone decorativo com tamanho minimo base (ex.: Vector2(70, 70)).
func add_icon(control: Control, base_size: Vector2) -> DynamicLayout:
	if control != null:
		_icons.append([control, base_size])
	return self


## Item nao essencial: some nos niveis mais apertados (ex.: texto de atalhos).
func add_optional(control: Control) -> DynamicLayout:
	if control != null:
		_optional.append(control)
	return self


## Callable(k: float) que refaz os botoes de resposta do minigame com o fator k (use AnswerLayout.fit_option_buttons).
func set_buttons(callable: Callable) -> DynamicLayout:
	_buttons_fit = callable
	return self


func _alive() -> bool:
	return _host != null and is_instance_valid(_host) and _host.is_inside_tree() \
		and _column != null and is_instance_valid(_column) \
		and _root_margin != null and is_instance_valid(_root_margin)


## Aplica o primeiro nivel em que a coluna cabe na altura da tela (ou o ultimo, se nenhum couber).
func fit() -> void:
	if not _alive():
		return
	var view: Vector2 = _host.get_viewport_rect().size
	var fits: bool = false
	for i in TIER_SCALES.size():
		current_tier = i
		var k: float = float(TIER_SCALES[i])
		var margin: int = maxi(MIN_MARGIN, int(round(float(_base_margin) * k)))
		_apply(k, i, margin)
		if _column.get_combined_minimum_size().y <= view.y - float(margin) * 2.0:
			fits = true
			break
	# V0.16.9.1: DEVOLVE o SafeArea ao tamanho da tela. Durante a medicao dos niveis a coluna chega a medir
	# 1700-4000 px (textos com autowrap ainda sem largura) e o MarginContainer ancorado em tela cheia CRESCE junto;
	# ao encolher o conteudo ele NAO volta sozinho. A coluna e centralizada nele, entao o jogo inteiro (titulo,
	# pergunta, respostas, barra de tempo) ficava ~1700 px abaixo da tela: so o tutorial (outra camada) aparecia.
	_restore_root_size()
	# Se nem o ultimo nivel coube, a coluna alinha pelo TOPO: o excesso vai para baixo (antes, centralizada, cortava
	# titulo e rodape ao mesmo tempo e podia parecer uma tela vazia).
	if _column is BoxContainer:
		(_column as BoxContainer).alignment = BoxContainer.ALIGNMENT_CENTER if fits else BoxContainer.ALIGNMENT_BEGIN
	if OS.is_debug_build() and (current_tier != _last_logged_tier or fits != _last_logged_fit):
		_last_logged_tier = current_tier
		_last_logged_fit = fits
		print("[DynamicLayout] %s: nivel=%d cabe=%s conteudo=%.0f tela=%.0f" % [_host.name, current_tier, str(fits), _column.get_combined_minimum_size().y, view.y])


## Volta o MarginContainer raiz para "tela cheia" (offsets 0). Se o conteudo ainda for maior que a tela, o Godot
## mantem o tamanho minimo e a coluna (alinhada pelo topo) simplesmente passa da borda de baixo.
func _restore_root_size() -> void:
	_root_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root_margin.position = Vector2.ZERO

## fit() agora + 2 vezes nos proximos frames: o texto novo / autowrap so tem a altura final depois do layout.
func schedule() -> void:
	fit()
	if not _alive():
		return
	var tree: SceneTree = _host.get_tree()
	await tree.process_frame
	fit()
	if not _alive():
		return
	await tree.process_frame
	fit()


func _apply(k: float, tier: int, margin: int) -> void:
	_root_margin.add_theme_constant_override("margin_top", margin)
	_root_margin.add_theme_constant_override("margin_bottom", margin)
	for entry in _gaps:
		var node: Control = entry[0] as Control
		if is_instance_valid(node):
			node.add_theme_constant_override(str(entry[1]), maxi(MIN_GAP, int(round(float(entry[2]) * k))))
	for entry in _min_heights:
		var node2: Control = entry[0] as Control
		if is_instance_valid(node2):
			var size: Vector2 = node2.custom_minimum_size
			size.y = maxf(float(entry[2]), float(entry[1]) * k)
			node2.custom_minimum_size = size
	for entry in _icons:
		var node3: Control = entry[0] as Control
		if is_instance_valid(node3):
			var base: Vector2 = entry[1]
			var kk: float = maxf(k, MIN_ICON / maxf(minf(base.x, base.y), 1.0))
			node3.custom_minimum_size = base * minf(kk, 1.0)
	for node4 in _optional:
		if is_instance_valid(node4):
			(node4 as Control).visible = tier < OPTIONAL_HIDE_FROM_TIER
	if _buttons_fit.is_valid():
		_buttons_fit.call(k)
