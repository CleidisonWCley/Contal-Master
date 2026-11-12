extends RefCounted
class_name WebLite
## V0.14.1 - Perfil "web leve".
## Centraliza o que muda quando o jogo roda no navegador (itch.io): efeitos caros ficam desligados.
## Para testar o perfil no editor/desktop, rode o jogo com o argumento de usuario:  -- --lite
## Na web, para forcar o desfoque de tela cheia em PC forte, abra a pagina com  ?blur=1
##
## V0.14.3 - Perfil "aparelho fraco" (low_end), POR CIMA do perfil web leve.
## Liga sozinho quando o navegador diz que o aparelho tem <= 4 GB de RAM (navigator.deviceMemory) ou <= 4 nucleos
## (navigator.hardwareConcurrency), ou quando o WebBridge mede FPS baixo por alguns segundos (mark_slow_device()).
##   ?low=1  na URL  -> forca o perfil fraco (para testar em PC forte)
##   ?low=0  na URL  -> desliga a deteccao automatica
##   -- --low no editor -> mesmo efeito de ?low=1

static var _checked: bool = false
static var _web: bool = false
static var _lite: bool = false
static var _force_blur: bool = false
static var _low_end: bool = false
static var _slow_measured: bool = false

static func _init_flags() -> void:
	if _checked:
		return
	_checked = true
	_web = OS.has_feature("web")
	_lite = _web or OS.get_cmdline_user_args().has("--lite")
	if _web:
		var value: Variant = JavaScriptBridge.eval("new URLSearchParams(window.location.search).get('blur') === '1'", true)
		_force_blur = bool(value)
		_low_end = _detect_low_end_web()
	elif OS.get_cmdline_user_args().has("--low"):
		_low_end = true
		_lite = true

## Le a URL (?low=1 / ?low=0) e as capacidades do aparelho. Nunca lanca erro: na duvida, aparelho normal.
static func _detect_low_end_web() -> bool:
	var js: String = """
(function () {
  try {
	var q = new URLSearchParams(window.location.search);
	if (q.get('low') === '1') { return 1; }
	if (q.get('low') === '0') { return 0; }
	var mem = navigator.deviceMemory || 0;
	var cores = navigator.hardwareConcurrency || 0;
	if (mem > 0 && mem <= 4) { return 1; }
	if (cores > 0 && cores <= 4) { return 1; }
	return 0;
  } catch (e) { return 0; }
})()
"""
	var value: Variant = JavaScriptBridge.eval(js, true)
	if value == null:
		return false
	return float(value) > 0.5

static func is_web() -> bool:
	_init_flags()
	return _web

static func lite() -> bool:
	_init_flags()
	return _lite

## V0.14.3: aparelho fraco (detectado ou medido). Implica lite().
static func low_end() -> bool:
	_init_flags()
	return _low_end or _slow_measured

## V0.14.3: o WebBridge mediu FPS baixo de forma sustentada. A partir daqui o jogo roda no perfil fraco.
static func mark_slow_device() -> void:
	_init_flags()
	_slow_measured = true
	_lite = true

static func is_slow_measured() -> bool:
	return _slow_measured

## Desfoque de tela cheia (shader com hint_screen_texture): caro/instavel no WebGL.
static func blur_enabled() -> bool:
	_init_flags()
	return not _lite or _force_blur

## Qualidade do efeito de agua do Desvio Logico (0 desligado, 1 leve, 2 medio).
static func water_quality(default_quality: int) -> int:
	return mini(default_quality, 1) if lite() else default_quality

## V0.14.5: densidade do efeito de agua (fracao da quantidade de linhas/brilhos desenhados). Desktop = 1.0.
## Cada redesenho da agua gera centenas de comandos de desenho; na web isso pesava igual ao desktop.
static func water_density() -> float:
	if low_end():
		return 0.35
	return 0.6 if lite() else 1.0

## Intervalo entre redesenhos da agua (segundos). No aparelho fraco, no maximo 5 redesenhos por segundo.
static func water_interval(default_interval: float) -> float:
	if low_end():
		return maxf(default_interval, 0.2)
	return maxf(default_interval, 0.1) if lite() else default_interval

## V0.14.3: fator para quantidade de particulas/brilhos decorativos (1.0 = como no desktop).
static func fx_scale() -> float:
	if low_end():
		return 0.4
	return 0.75 if lite() else 1.0

## V0.14.3: quantidade de itens decorativos (particulas feitas de Label etc.) ja ajustada ao perfil.
## No desktop devolve base; nunca devolve menos que minimum (nem mais que base).
static func scaled_count(base: int, minimum: int = 4) -> int:
	return maxi(int(round(float(base) * fx_scale())), mini(minimum, base))

## V0.14.3: "pre-aquecimento" de CPUParticles2D (simula N segundos de uma vez no primeiro quadro).
## Era 10 s por emissor: um pico de CPU logo ao abrir cada transicao. No aparelho fraco vira 1,5 s.
static func preprocess_seconds(default_seconds: float) -> float:
	if low_end():
		return minf(default_seconds, 1.5)
	return minf(default_seconds, 4.0) if lite() else default_seconds

## Texto curto para o log ?debug=1.
static func describe() -> String:
	_init_flags()
	return "web=%s lite=%s low_end=%s (medido=%s)" % [_web, _lite, low_end(), _slow_measured]
