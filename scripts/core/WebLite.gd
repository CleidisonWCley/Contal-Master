extends RefCounted
class_name WebLite
## V0.14.1 - Perfil "web leve".
## Centraliza o que muda quando o jogo roda no navegador (itch.io): efeitos caros ficam desligados.
## Para testar o perfil no editor/desktop, rode o jogo com o argumento de usuario:  -- --lite
## Na web, para forcar o desfoque de tela cheia em PC forte, abra a pagina com  ?blur=1

static var _checked: bool = false
static var _web: bool = false
static var _lite: bool = false
static var _force_blur: bool = false

static func _init_flags() -> void:
	if _checked:
		return
	_checked = true
	_web = OS.has_feature("web")
	_lite = _web or OS.get_cmdline_user_args().has("--lite")
	if _web:
		var value: Variant = JavaScriptBridge.eval("new URLSearchParams(window.location.search).get('blur') === '1'", true)
		_force_blur = bool(value)

static func is_web() -> bool:
	_init_flags()
	return _web

static func lite() -> bool:
	_init_flags()
	return _lite

## Desfoque de tela cheia (shader com hint_screen_texture): caro/instavel no WebGL.
static func blur_enabled() -> bool:
	_init_flags()
	return not _lite or _force_blur

## Qualidade do efeito de agua do Desvio Logico (0 desligado, 1 leve, 2 medio).
static func water_quality(default_quality: int) -> int:
	return mini(default_quality, 1) if lite() else default_quality

## Intervalo entre redesenhos da agua (segundos).
static func water_interval(default_interval: float) -> float:
	return maxf(default_interval, 0.1) if lite() else default_interval
