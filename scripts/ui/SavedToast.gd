extends RefCounted
class_name SavedToast
## V0.16.1: card de feedback curto ("Configurações salvas com sucesso") que aparece no topo e some sozinho.
## Uso: SavedToast.show_on(self, "Configurações salvas com sucesso")

static func show_on(host: Control, text: String, seconds: float = 2.4) -> void:
	if host == null or not host.is_inside_tree():
		return
	var card := PanelContainer.new()
	card.name = "SavedToast"
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.z_index = 100
	card.add_theme_stylebox_override("panel", UiKit.panel_style(UiPalette.with_alpha(UiPalette.CARD, 0.97), UiPalette.SECONDARY, 18, 2, 14))
	var pad := UiKit.margin(26, 26, 14, 14)
	card.add_child(pad)
	var label: Label = UiKit.label(text, 20, UiPalette.TEXT_ON_DARK, HORIZONTAL_ALIGNMENT_CENTER)
	pad.add_child(label)
	host.add_child(card)
	card.set_anchors_preset(Control.PRESET_CENTER_TOP, true)
	card.position.y = 22.0
	card.modulate.a = 0.0
	var tween: Tween = host.create_tween()
	tween.tween_property(card, "modulate:a", 1.0, 0.18)
	tween.tween_interval(seconds)
	tween.tween_property(card, "modulate:a", 0.0, 0.35)
	tween.tween_callback(card.queue_free)
