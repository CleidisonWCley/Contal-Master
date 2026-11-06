extends PanelContainer
class_name DifficultySelector
## Seletor de dificuldade (v4.2): mantem a pilula "Dificuldade" de antes, mas agora os tres niveis
## sao botoes. Escolher grava em DifficultyManager/SettingsManager (a mesma opcao das Configuracoes).
## Funciona com mouse, toque, teclado (setas + Enter) e controle. Nunca depende so de cor (pontos 1/2/3).
## Uso: var s := DifficultySelector.new(); parent.add_child(s); s.difficulty_selected.connect(...)

signal difficulty_selected(key: String)

const KEYS := ["facil", "normal", "dificil"]

var font_px: int = 17
var v_pad: int = 5

var _compact: bool = false
var _prefix_label: Label
var _buttons: Dictionary = {}   # key -> Button
var _parts: Dictionary = {}     # key -> {"box": BoxContainer, "pips": UiPips, "label": Label}

func _ready() -> void:
	_build()
	_apply_compact()
	refresh()

func set_compact(value: bool) -> void:
	_compact = value
	if _prefix_label != null:
		_apply_compact()

func _build() -> void:
	var pad := UiKit.margin(14, 14, v_pad, v_pad)
	add_child(pad)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	pad.add_child(row)

	_prefix_label = UiKit.label("Dificuldade", font_px, UiPalette.TEXT_MUTED)
	_prefix_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(_prefix_label)

	for key in KEYS:
		var key_name: String = str(key)
		var button := Button.new()
		button.name = "Difficulty_%s" % key_name
		button.focus_mode = Control.FOCUS_ALL
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.tooltip_text = "Dificuldade %s" % ScoreManager.get_difficulty_label(key_name)
		row.add_child(button)

		var center := CenterContainer.new()
		center.set_anchors_preset(Control.PRESET_FULL_RECT)
		button.add_child(center)
		var line := BoxContainer.new()
		line.alignment = BoxContainer.ALIGNMENT_CENTER
		center.add_child(line)
		var pips := UiPips.new()
		pips.level = UiPalette.difficulty_level(key_name)
		line.add_child(pips)
		var name_label: Label = UiKit.label(ScoreManager.get_difficulty_label(key_name), font_px, UiPalette.TEXT_ON_DARK)
		line.add_child(name_label)
		UiKit.ignore_mouse(center)

		button.pressed.connect(_on_pressed.bind(key_name))
		_buttons[key_name] = button
		_parts[key_name] = {"box": line, "pips": pips, "label": name_label}

## Largo: pontos + nome lado a lado. Compacto (celular/janela pequena): nome embaixo dos pontos, sem o rotulo.
func _apply_compact() -> void:
	_prefix_label.visible = not _compact
	var button_size: Vector2 = Vector2(96, 58) if _compact else Vector2(136, 46)
	var font: int = maxi(font_px - 2, 13) if _compact else font_px
	for key in KEYS:
		var key_name: String = str(key)
		(_buttons[key_name] as Button).custom_minimum_size = button_size
		var parts: Dictionary = _parts[key_name]
		var box: BoxContainer = parts["box"] as BoxContainer
		box.vertical = _compact
		box.add_theme_constant_override("separation", 2 if _compact else 8)
		(parts["label"] as Label).add_theme_font_size_override("font_size", font)

## Selecionado = preenchido na cor da dificuldade (texto escuro). Os demais = so contorno.
func refresh() -> void:
	if _buttons.is_empty():
		return
	var current: String = DifficultyManager.get_difficulty()
	add_theme_stylebox_override("panel", UiKit.panel_style(UiPalette.with_alpha(UiPalette.CARD, 0.94), UiPalette.difficulty_color(current), 18, 2, 6))
	for key in KEYS:
		var key_name: String = str(key)
		var button: Button = _buttons[key_name] as Button
		var accent: Color = UiPalette.difficulty_color(key_name)
		var selected: bool = key_name == current
		var fill: Color = accent if selected else UiPalette.with_alpha(UiPalette.CARD_RAISED, 0.55)
		var hover_fill: Color = accent.lightened(0.08) if selected else UiPalette.with_alpha(UiPalette.CARD_RAISED, 0.95)
		var border: Color = UiPalette.TEXT_ON_DARK if selected else accent
		button.add_theme_stylebox_override("normal", UiKit.panel_style(fill, border, 14, 2, 4))
		button.add_theme_stylebox_override("hover", UiKit.panel_style(hover_fill, UiPalette.TEXT_ON_DARK, 14, 2, 4))
		button.add_theme_stylebox_override("pressed", UiKit.panel_style(accent.darkened(0.12), UiPalette.TEXT_ON_DARK, 14, 2, 4))
		button.add_theme_stylebox_override("focus", ButtonStyles.make_focus_ring(14))
		var parts: Dictionary = _parts[key_name]
		(parts["label"] as Label).add_theme_color_override("font_color", UiPalette.TEXT_ON_BRIGHT if selected else UiPalette.TEXT_ON_DARK)
		(parts["pips"] as UiPips).color = UiPalette.TEXT_ON_BRIGHT if selected else accent

func _on_pressed(key: String) -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	if key == DifficultyManager.get_difficulty():
		return
	DifficultyManager.set_difficulty(key)
	refresh()
	difficulty_selected.emit(key)
