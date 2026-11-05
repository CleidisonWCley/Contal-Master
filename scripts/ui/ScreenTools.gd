extends RefCounted
class_name ScreenTools

# V0.10.2 — utilitários simples para layouts responsivos.
# Mantém a base 1280x720 e reduz tamanhos/margens quando a tela é compacta.

const BASE_SIZE := Vector2(1280.0, 720.0)
const COMPACT_WIDTH := 960.0
const COMPACT_HEIGHT := 650.0

static func get_viewport_size(node: Node) -> Vector2:
	var viewport: Viewport = null
	if node != null:
		viewport = node.get_viewport()
	if viewport == null:
		return BASE_SIZE
	var current_size: Vector2 = viewport.get_visible_rect().size
	if current_size.x <= 0.0 or current_size.y <= 0.0:
		return BASE_SIZE
	return current_size

static func scale_factor(node: Node, min_scale: float = 0.72, max_scale: float = 1.08) -> float:
	var current_size: Vector2 = get_viewport_size(node)
	var factor: float = minf(current_size.x / BASE_SIZE.x, current_size.y / BASE_SIZE.y)
	return clampf(factor, min_scale, max_scale)

static func is_compact(node: Node) -> bool:
	var current_size: Vector2 = get_viewport_size(node)
	return current_size.x < COMPACT_WIDTH or current_size.y < COMPACT_HEIGHT

static func is_short(node: Node) -> bool:
	return get_viewport_size(node).y < COMPACT_HEIGHT

static func is_narrow(node: Node) -> bool:
	return get_viewport_size(node).x < COMPACT_WIDTH

static func is_mobile_platform() -> bool:
	var os_name: String = OS.get_name()
	return os_name == "Android" or os_name == "iOS"

static func responsive_value(node: Node, desktop: float, compact: float) -> float:
	return compact if is_compact(node) else desktop

static func responsive_font(node: Node, desktop: int, compact: int) -> int:
	return compact if is_compact(node) else desktop

static func responsive_size(node: Node, desktop: Vector2, compact: Vector2) -> Vector2:
	return compact if is_compact(node) else desktop

static func apply_safe_margins(container: MarginContainer, node: Node, desktop_margin: int = 48, compact_margin: int = 24) -> void:
	if container == null:
		return
	var margin_value: int = compact_margin if is_compact(node) else desktop_margin
	if is_short(node):
		margin_value = mini(margin_value, 18)
	if is_narrow(node):
		margin_value = mini(margin_value, 18)
	container.add_theme_constant_override("margin_left", margin_value)
	container.add_theme_constant_override("margin_top", margin_value)
	container.add_theme_constant_override("margin_right", margin_value)
	container.add_theme_constant_override("margin_bottom", margin_value)

static func apply_inner_margins(container: MarginContainer, node: Node, desktop_margin: int = 32, compact_margin: int = 22) -> void:
	if container == null:
		return
	var margin_value: int = compact_margin if is_compact(node) else desktop_margin
	if is_short(node):
		margin_value = mini(margin_value, 16)
	container.add_theme_constant_override("margin_left", margin_value)
	container.add_theme_constant_override("margin_top", margin_value)
	container.add_theme_constant_override("margin_right", margin_value)
	container.add_theme_constant_override("margin_bottom", margin_value)

static func button_size(node: Node, desktop: Vector2, compact: Vector2) -> Vector2:
	return responsive_size(node, desktop, compact)

static func panel_size(node: Node, desktop: Vector2, compact: Vector2, horizontal_padding: float = 80.0, vertical_padding: float = 80.0) -> Vector2:
	var current_size: Vector2 = get_viewport_size(node)
	var desired: Vector2 = responsive_size(node, desktop, compact)
	desired.x = minf(desired.x, maxf(320.0, current_size.x - horizontal_padding))
	desired.y = minf(desired.y, maxf(280.0, current_size.y - vertical_padding))
	return desired

static func apply_label_font(label: Label, node: Node, desktop: int, compact: int) -> void:
	if label == null:
		return
	label.add_theme_font_size_override("font_size", responsive_font(node, desktop, compact))

static func apply_button(button: BaseButton, node: Node, variant: String, desktop_size: Vector2, compact_size: Vector2, desktop_font: int, compact_font: int) -> void:
	if button == null:
		return
	ButtonStyles.apply(button, variant, responsive_size(node, desktop_size, compact_size), responsive_font(node, desktop_font, compact_font))
