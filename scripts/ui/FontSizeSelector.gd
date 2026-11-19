extends VBoxContainer
class_name FontSizeSelector
## V0.16.3 - Seletor "Fonte" (acessibilidade): Pequena | Media | Grande | Extra grande.
## Usado nas Configuracoes do menu e nas Configuracoes do pause (mesmo visual e mesma regra nos dois).
## Ao escolher, grava em SettingsManager; o autoload FontScale refaz o tamanho de todos os textos na hora.
##
## Uso:
##     var selector := FontSizeSelector.create(4)      # 4 colunas (tela larga) ou 2 (painel estreito)
##     parent.add_child(selector)
##     selector.refresh()                              # ao abrir a tela / depois de mudar a escala

signal level_selected(level: String)

var _grid: GridContainer
var _buttons: Dictionary = {}   # nivel -> Button
var _min_height: float = 50.0
var _base_font: int = 17
var _columns: int = 4

static func create(columns: int = 4, min_height: float = 50.0, base_font: int = 17) -> FontSizeSelector:
	var selector := FontSizeSelector.new()
	selector.name = "FontSizeSelector"
	selector._columns = columns
	selector._min_height = min_height
	selector._base_font = base_font
	selector._build()
	return selector

func _build() -> void:
	add_theme_constant_override("separation", 8)
	_grid = GridContainer.new()
	_grid.name = "FontOptions"
	_grid.columns = _columns
	_grid.add_theme_constant_override("h_separation", 10)
	_grid.add_theme_constant_override("v_separation", 10)
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(_grid)
	for level in SettingsManager.FONT_LEVELS:
		var button := Button.new()
		button.name = "Font_%s" % level
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.focus_mode = Control.FOCUS_ALL
		button.tooltip_text = "Tamanho da fonte: %s" % FontScale.level_label(level)
		button.clip_text = false
		button.pressed.connect(_on_pressed.bind(level))
		_grid.add_child(button)
		_buttons[level] = button
	refresh()

## Reaplica texto/estilo (selecionado = preenchido em lilas). Chamar tambem depois de mudar a escala.
func refresh() -> void:
	var current: String = SettingsManager.get_font_level()
	for level in SettingsManager.FONT_LEVELS:
		var button: Button = _buttons[level] as Button
		button.text = FontScale.level_label(level)
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		ButtonStyles.apply(button, "ui_toggle_on" if level == current else "ui_ghost", Vector2(0, _min_height), _base_font)

func set_columns(value: int) -> void:
	_columns = value
	if _grid != null:
		_grid.columns = value

func focus_current() -> void:
	var button: Button = _buttons.get(SettingsManager.get_font_level()) as Button
	if button != null:
		button.grab_focus()

func _on_pressed(level: String) -> void:
	if level == SettingsManager.get_font_level():
		return
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	SettingsManager.set_font_level(level)
	refresh()
	level_selected.emit(level)
