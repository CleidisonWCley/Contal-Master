extends RefCounted
class_name ClickGuard
## V0.14.1: no navegador/celular um toque gera InputEventScreenTouch E um clique de mouse emulado.
## Sem protecao, uma novel avancava DOIS quadros por toque. accept() libera so 1 avanco a cada janela.

static var _last_ms: int = -100000

static func accept(window_ms: int = 160) -> bool:
	var now: int = Time.get_ticks_msec()
	if now - _last_ms < window_ms:
		return false
	_last_ms = now
	return true
