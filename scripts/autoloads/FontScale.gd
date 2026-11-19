extends Node
## V0.16.3 - Acessibilidade: tamanho da fonte (Pequena / Media / Grande / Extra grande).
##
## COMO FUNCIONA (ponto unico):
##   * Todo tamanho de letra do jogo passa por aqui. Os scripts NAO chamam mais
##     add_theme_font_size_override(...) direto: chamam FontScale.set_size(controle, TAMANHO_BASE).
##   * O TAMANHO_BASE e o tamanho "Media" (o padrao de sempre do jogo). O que aparece na tela e
##     base x fator do nivel escolhido (Pequena 0,85 | Media 1,00 | Grande 1,20 | Extra grande 1,40).
##   * O tamanho base fica guardado no proprio no (meta "_fs_base"). Quando o jogador muda a opcao
##     "Fonte" - no menu OU no pause de um minigame - TODOS os textos vivos na tela sao recalculados
##     na hora, sem reiniciar a cena e sem acumular escala (sempre base x fator, nunca fator x fator).
##   * Controles que vem de um .tscn com theme_override_font_sizes/... (ou que alguem esqueceu de passar
##     pelo set_size) sao "adotados" automaticamente quando entram na arvore: o valor que ja tinham vira o base.
##
## NOME DO AUTOLOAD: "FontScale" (sem class_name - o Godot nao deixa class_name igual ao nome de um autoload).

signal scale_changed(level: String)

## Fatores por nivel. Media = 1.0 EXATO: quem nao mexe na opcao ve o jogo identico ao da v0.16.2.
const FACTORS: Dictionary = {
	"pequena": 0.85,
	"media": 1.0,
	"grande": 1.2,
	"extra_grande": 1.4,
}
const LABELS: Dictionary = {
	"pequena": "Pequena",
	"media": "Média",
	"grande": "Grande",
	"extra_grande": "Extra grande",
}
## Nomes de tema de fonte que o jogo usa (Label/Button/LineEdit = font_size; RichTextLabel = normal/bold).
const THEME_NAMES: Array[String] = ["font_size", "normal_font_size", "bold_font_size"]
const META_BASE := "_fs_base"        # Dictionary { nome_do_tema: tamanho_base }
const META_ICON_RATIO := "_fs_icon_ratio"   # Button: icon_max_width = fonte_atual x razao
const META_OUTLINE := "_fs_outline_div"     # RichTextLabel: outline_size = max(3, fonte_atual / divisor)
const META_SKIP := "_fs_skip"        # true = nunca escalar (decoracao: simbolos flutuantes do fundo)
## Menor tamanho que ainda e legivel: so vale quando a escala e REDUZIDA (Pequena).
const MIN_READABLE_PX: int = 11
## Acima deste tamanho base o texto e "de destaque" (titulos, letra da roleta) e cresce proporcionalmente menos.
const DISPLAY_FROM_PX: int = 28

var _level: String = "media"
var _factor: float = 1.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_level = _sanitize(SettingsManager.get_font_level())
	_factor = float(FACTORS[_level])
	get_tree().node_added.connect(_on_node_added)
	SettingsManager.settings_changed.connect(_on_settings_changed)

# ---------------------------------------------------------------- consulta
func get_level() -> String:
	return _level

func get_factor() -> float:
	return _factor

func level_label(level: String) -> String:
	return str(LABELS.get(level, LABELS["media"]))

func current_label() -> String:
	return level_label(_level)

## Tamanho final (px) para um tamanho base. Media devolve o proprio base.
func px(base: int) -> int:
	return _scaled(base, _factor)

## Igual a px(), mas para um nivel especifico (usado para mostrar a previa de cada opcao).
func px_for(base: int, level: String) -> int:
	return _scaled(base, float(FACTORS[_sanitize(level)]))

## Escala "suave" para ICONES/margens ao lado do texto: acompanha a fonte pela raiz, para o icone
## crescer sem estourar o layout (fator 1.5 -> ~1.22).
func soft_px(base: float) -> float:
	return base * sqrt(_factor)

func _scaled(base: int, factor: float) -> int:
	if is_equal_approx(factor, 1.0):
		return base
	# Titulos/letras de destaque (base > 28 px) ja sao grandes: crescem menos, senao estouram a tela
	# (ex.: titulo de 54 px nao vira 76 px). Texto de leitura (<= 28 px) cresce o fator inteiro.
	if factor > 1.0 and base > DISPLAY_FROM_PX:
		factor = 1.0 + (factor - 1.0) * (float(DISPLAY_FROM_PX) / float(base))
	var value: int = int(round(float(base) * factor))
	if factor < 1.0:
		return maxi(mini(base, MIN_READABLE_PX), value)
	return value

func _sanitize(level: String) -> String:
	return level if FACTORS.has(level) else "media"

# ---------------------------------------------------------------- aplicacao
## Ponto unico para definir tamanho de letra. `base` = tamanho no nivel Media.
func set_size(control: Control, base: int, theme_name: String = "font_size") -> void:
	if control == null:
		return
	var bases: Dictionary = _bases_of(control)
	bases[theme_name] = base
	control.set_meta(META_BASE, bases)
	_apply_name(control, theme_name, base)
	_apply_extras(control)

## Atalho para RichTextLabel: normal + bold + contorno proporcional (o contorno acompanha a fonte).
func set_rich_size(label: RichTextLabel, base: int, outline_divisor: float = 0.0) -> void:
	if label == null:
		return
	set_size(label, base, "normal_font_size")
	set_size(label, base, "bold_font_size")
	if outline_divisor > 0.0:
		label.set_meta(META_OUTLINE, outline_divisor)
		_apply_extras(label)

## Botao: icone ao lado do texto acompanha a fonte (icon_max_width = fonte atual x razao).
func set_icon_ratio(button: Control, ratio: float) -> void:
	button.set_meta(META_ICON_RATIO, ratio)
	_apply_extras(button)

## Marca um no para NUNCA escalar (ex.: simbolos decorativos que flutuam no fundo).
func skip(control: Control) -> void:
	if control != null:
		control.set_meta(META_SKIP, true)

## Tamanho base guardado (0 se o controle nunca passou por aqui).
func base_of(control: Control, theme_name: String = "font_size") -> int:
	if control != null and control.has_meta(META_BASE):
		return int((control.get_meta(META_BASE) as Dictionary).get(theme_name, 0))
	return 0

func _bases_of(control: Control) -> Dictionary:
	if control.has_meta(META_BASE):
		return control.get_meta(META_BASE) as Dictionary
	return {}

func _apply_name(control: Control, theme_name: String, base: int) -> void:
	if control.has_meta(META_SKIP):
		control.add_theme_font_size_override(theme_name, base)
		return
	var target: int = _scaled(base, _factor)
	if control.has_theme_font_size_override(theme_name) and control.get_theme_font_size(theme_name) == target:
		return
	control.add_theme_font_size_override(theme_name, target)

func _apply_extras(control: Control) -> void:
	if control.has_meta(META_SKIP):
		return
	var current: int = 0
	for theme_name in THEME_NAMES:
		if control.has_theme_font_size_override(theme_name):
			current = control.get_theme_font_size(theme_name)
			break
	if current <= 0:
		return
	if control.has_meta(META_ICON_RATIO):
		control.add_theme_constant_override("icon_max_width", int(round(float(current) * float(control.get_meta(META_ICON_RATIO)))))
	if control.has_meta(META_OUTLINE):
		control.add_theme_constant_override("outline_size", maxi(3, int(float(current) / float(control.get_meta(META_OUTLINE)))))

func _apply_node(control: Control) -> void:
	if control.has_meta(META_SKIP):
		return
	var bases: Dictionary = _bases_of(control)
	# Adocao: overrides que vieram do .tscn (ou de codigo antigo) e ainda nao tem base guardado.
	for theme_name in THEME_NAMES:
		if not bases.has(theme_name) and control.has_theme_font_size_override(theme_name):
			bases[theme_name] = control.get_theme_font_size(theme_name)
			control.set_meta(META_BASE, bases)
	for theme_name in bases.keys():
		_apply_name(control, str(theme_name), int(bases[theme_name]))
	if not bases.is_empty():
		_apply_extras(control)

func _on_node_added(node: Node) -> void:
	if node is Control:
		_apply_node(node as Control)

# ---------------------------------------------------------------- mudanca de nivel
func _on_settings_changed(_settings: Dictionary) -> void:
	var wanted: String = _sanitize(SettingsManager.get_font_level())
	if wanted == _level:
		return
	_level = wanted
	_factor = float(FACTORS[_level])
	_refresh_tree(get_tree().root)
	scale_changed.emit(_level)

func _refresh_tree(node: Node) -> void:
	if node is Control:
		_apply_node(node as Control)
	for child in node.get_children():
		_refresh_tree(child)
