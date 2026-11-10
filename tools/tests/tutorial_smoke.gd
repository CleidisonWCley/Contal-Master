extends SceneTree
## Teste de fumaça do tutorial (NAO foi executado pelo autor do patch: o ambiente dele nao tinha Godot).
## Rode:  godot --headless --path . -s res://tools/tests/tutorial_smoke.gd
## Cobre o 1o card do tutorial com Animacoes LIGADAS e DESLIGADAS, e com a arvore pausada.
## Sai com codigo 0 se tudo passar, 1 se algo falhar.

var _failures: int = 0

func _check(cond: bool, msg: String) -> void:
	if cond:
		print("  ok   - ", msg)
	else:
		print("  FAIL - ", msg)
		_failures += 1

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var settings: Node = root.get_node("SettingsManager")
	var original: bool = settings.animations_enabled()
	for key in ["perseguicao", "show_do_bilhao", "stop"]:
		for anim in [true, false]:
			for paused in [false, true]:
				await _case(settings, key, anim, paused)
	settings.set_animations_enabled(original)
	print("RESULTADO: %s (%d falhas)" % ["OK" if _failures == 0 else "FALHOU", _failures])
	quit(0 if _failures == 0 else 1)

func _case(settings: Node, key: String, anim: bool, paused: bool) -> void:
	print("[%s] animacoes=%s arvore_pausada=%s" % [key, anim, paused])
	settings.set_animations_enabled(anim)
	var host: Control = Control.new()
	host.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(host)
	var overlay: TutorialOverlay = TutorialManager.create_overlay(host, key)
	_check(overlay != null, "overlay criado")
	if overlay == null:
		host.queue_free()
		return
	var steps: Array = TutorialManager.steps_for(host, key)
	_check(not steps.is_empty(), "passos carregados")
	overlay.start(steps)
	paused_toggle(paused)
	for i in 40:
		await process_frame
	var view: Vector2 = overlay._view_size()
	_check(overlay._root.modulate.a > 0.99, "card opaco depois do fade (alpha=%.2f)" % overlay._root.modulate.a)
	_check(overlay._card.size.y <= view.y * 0.62 + 1.0, "altura do card dentro do limite (%.0f <= %.0f)" % [overlay._card.size.y, view.y * 0.62])
	_check(overlay._text_label.get_combined_minimum_size().y < view.y * 0.62, "minimo de altura do texto sensato")
	var step_text: String = str(steps[0].get("text", ""))
	_check(overlay._text_label.text == step_text and step_text != "", "texto do passo 1 aplicado")
	_check(overlay._text_label.visible_ratio > 0.99 or anim, "texto completo com animacoes desligadas")
	var done: Array = [false]
	overlay.finished.connect(func(_c: bool) -> void: done[0] = true)
	for i in 3:
		overlay._advance()
		await process_frame
	overlay.close(false)
	paused_toggle(false)
	await create_timer(0.5).timeout
	_check(done[0], "finished emitido")
	_check(not is_instance_valid(overlay), "overlay liberado (sem tween preso)")
	host.queue_free()
	await process_frame

func paused_toggle(value: bool) -> void:
	paused = value
