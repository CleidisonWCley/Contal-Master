extends Node
## V0.14.1 - Ponte com o navegador (build web / itch.io).
##
## O que resolve:
##  - Botao "Sair": get_tree().quit() derruba o runtime WASM (tela travada/erro). Na web o jogo agora
##    encerra "por fora": salva, silencia, congela o motor e mostra uma tela de despedida em HTML.
##  - Botao VOLTAR / sair do navegador: vira confirmacao dentro do jogo (ou abre o pause num minigame).
##    Apertar Voltar de novo com a confirmacao aberta sai de verdade.
##  - Aba escondida / pagina fechando: pausa a musica e persiste o progresso.
##  - Diagnostico: abra a pagina com ?debug=1 e veja no console (F12) memoria, texturas, nos e FPS.
##
## V0.14.3:
##  - Tela cheia / redimensionamento: sair da tela cheia (Esc, F11, gesto do celular), girar o aparelho, mexer na barra de
##    enderecos ou voltar de outra aba/janela agora re-mede a tela em varios instantes (os navegadores atualizam
##    innerWidth/innerHeight DEPOIS do evento), avisa o jogo (sinal display_refit) e alinha a opcao "Tela cheia" das
##    Configuracoes com o estado REAL do navegador.
##  - Aba escondida durante um minigame: abre o PAUSE sozinho (ao voltar, o jogo esta parado e nada "pulou").
##  - Medidor de FPS: se um minigame/cutscene roda abaixo de ~36 FPS por 8 s seguidos, liga o perfil de aparelho fraco
##    (WebLite.mark_slow_device) e limita o motor a 30 FPS (ritmo estavel em vez de oscilar).

signal exit_confirm_opened
signal exit_confirm_closed
## V0.14.3: a tela do navegador mudou (tela cheia, rotacao, voltar de outra aba...). size = tamanho atual da janela.
signal display_refit(size: Vector2)
## V0.14.3: o medidor de FPS ligou o perfil de aparelho fraco.
signal performance_degraded(measured_fps: float)

const REFIT_DELAY := 0.15
const PERF_WINDOW_SECONDS := 4.0
const PERF_SLOW_FPS := 36.0
const PERF_SLOW_WINDOWS_NEEDED := 2
const PERF_GRACE_SECONDS := 3.0
const SLOW_DEVICE_MAX_FPS := 30

var _cb_visibility: JavaScriptObject
var _cb_pagehide: JavaScriptObject
var _cb_back: JavaScriptObject
var _exit_done: bool = false
var _confirm_layer: CanvasLayer
var _debug: bool = false
var _debug_timer: float = 0.0
var _last_scene_path: String = ""
var _saved_max_fps: int = 0
var _cb_display: JavaScriptObject
var _hidden: bool = false
var _refit_timer: float = -1.0
var _perf_time: float = 0.0
var _perf_frames: int = 0
var _perf_grace: float = PERF_GRACE_SECONDS
var _perf_slow_windows: int = 0
var _perf_scene: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().set_auto_accept_quit(false)
	if WebLite.is_web():
		_install_web_hooks()
		_debug = bool(JavaScriptBridge.eval("new URLSearchParams(window.location.search).has('debug')", true))
	elif OS.get_cmdline_user_args().has("--debug"):
		_debug = true
	set_process(_debug or WebLite.is_web())

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_persist()
		get_tree().quit()

# ---------------------------------------------------------------- saida
## Chamado pelo botao Sair do menu. Seguro em qualquer plataforma.
func request_exit() -> void:
	if not WebLite.is_web():
		_persist()
		get_tree().quit()
		return
	if _exit_done:
		return
	_exit_done = true
	close_exit_confirm()
	_persist()
	if has_node("/root/AudioManager"):
		AudioManager.stop_music()
		AudioManager.stop_all_sfx()
	AudioServer.set_bus_mute(0, true)
	_show_exit_overlay()
	# Nao chamamos quit(): congelamos o motor num estado ocioso (sem custo e sem crash).
	_saved_max_fps = Engine.max_fps
	Engine.max_fps = 4
	get_tree().paused = true

func _persist() -> void:
	# Os autoloads gravam a cada mudanca; aqui so garantimos o que e mais barato regravar.
	if has_node("/root/SettingsManager"):
		SettingsManager.save_settings()

func _show_exit_overlay() -> void:
	var js: String = """
(function () {
  try { window.close(); } catch (e) {}
  if (document.getElementById('cm-exit-overlay')) { return; }
  var box = document.createElement('div');
  box.id = 'cm-exit-overlay';
  box.style.cssText = 'position:fixed;inset:0;z-index:99999;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:18px;background:#100B1F;color:#FFF9FF;font-family:Arial,Helvetica,sans-serif;text-align:center;padding:24px';
  var title = document.createElement('div');
  title.textContent = 'Obrigado por jogar ContalMaster!';
  title.style.cssText = 'font-size:28px;font-weight:700';
  var sub = document.createElement('div');
  sub.textContent = 'Seu progresso foi salvo. Você já pode fechar esta aba.';
  sub.style.cssText = 'font-size:17px;color:#CFC2E8';
  var btn = document.createElement('button');
  btn.textContent = 'Jogar novamente';
  btn.style.cssText = 'font-size:18px;font-weight:700;padding:12px 28px;border:0;border-radius:14px;background:#8B3DFF;color:#FFF9FF;cursor:pointer';
  btn.onclick = function () { window.location.reload(); };
  box.appendChild(title); box.appendChild(sub); box.appendChild(btn);
  document.body.appendChild(box);
})();
"""
	JavaScriptBridge.eval(js, true)

# ---------------------------------------------------------------- ganchos do navegador
func _install_web_hooks() -> void:
	_cb_visibility = JavaScriptBridge.create_callback(_on_js_visibility)
	_cb_pagehide = JavaScriptBridge.create_callback(_on_js_pagehide)
	_cb_back = JavaScriptBridge.create_callback(_on_js_back)
	_cb_display = JavaScriptBridge.create_callback(_on_js_display)
	var window: JavaScriptObject = JavaScriptBridge.get_interface("window")
	window.__cm_onVisibility = _cb_visibility
	window.__cm_onPageHide = _cb_pagehide
	window.__cm_onBack = _cb_back
	window.__cm_onDisplay = _cb_display
	var js: String = """
(function () {
  if (window.__cmHooked) { return; }
  window.__cmHooked = true;
  document.addEventListener('visibilitychange', function () { window.__cm_onVisibility(document.hidden); });
  window.addEventListener('pagehide', function () { window.__cm_onPageHide(); });
  try { history.pushState({ cm: 1 }, '', window.location.href); } catch (e) {}
  window.addEventListener('popstate', function () {
    try { history.pushState({ cm: 1 }, '', window.location.href); } catch (e) {}
    window.__cm_onBack();
  });
})();
"""
	JavaScriptBridge.eval(js, true)
	_install_display_hooks()

func _on_js_visibility(args: Array) -> void:
	var hidden: bool = args.size() > 0 and bool(args[0])
	_hidden = hidden
	if has_node("/root/AudioManager"):
		AudioManager.set_suspended(hidden)
	if hidden:
		# V0.14.3: aba escondida/app em segundo plano durante um minigame -> abre o pause. Ao voltar, o jogo esta
		# parado (o navegador congela os quadros escondidos e o tempo "pulava" para tras do jogador).
		_auto_pause_current_minigame()
	else:
		_perf_reset()
		_refit_timer = REFIT_DELAY

func _on_js_pagehide(_args: Array) -> void:
	_persist()
	if has_node("/root/AudioManager"):
		AudioManager.set_suspended(true)

# ---------------------------------------------------------------- V0.14.3: tela cheia / redimensionamento
func _install_display_hooks() -> void:
	var js: String = """
(function () {
  if (window.__cmDisplayHooked) { return; }
  window.__cmDisplayHooked = true;
  var timers = [];
  function isFs() {
	return !!(document.fullscreenElement || document.webkitFullscreenElement ||
			  document.mozFullScreenElement || document.msFullscreenElement);
  }
  // Os navegadores atualizam innerWidth/innerHeight DEPOIS do evento (sair da tela cheia, barra de enderecos do
  // celular, girar o aparelho). Re-medimos em varios instantes: o evento 'resize' sintetico faz o Godot ler o
  // tamanho novo, e o jogo recebe o estado real da tela cheia.
  function nudge() {
	timers.forEach(clearTimeout);
	timers = [0, 120, 350, 800, 1600].map(function (ms) {
	  return setTimeout(function () {
		try { window.dispatchEvent(new Event('resize')); } catch (e) {}
		try { window.__cm_onDisplay(isFs()); } catch (e) {}
	  }, ms);
	});
  }
  ['fullscreenchange', 'webkitfullscreenchange', 'mozfullscreenchange', 'MSFullscreenChange'].forEach(function (name) {
	document.addEventListener(name, nudge);
  });
  window.addEventListener('orientationchange', nudge);
  window.addEventListener('pageshow', nudge);
  window.addEventListener('focus', nudge);
  if (window.visualViewport) { window.visualViewport.addEventListener('resize', nudge); }
})();
"""
	JavaScriptBridge.eval(js, true)

## O JS avisa que a tela mudou. args[0] = o navegador esta em tela cheia (Fullscreen API) agora?
func _on_js_display(args: Array) -> void:
	if _exit_done:
		return
	var real_fullscreen: bool = args.size() > 0 and bool(args[0])
	if has_node("/root/SettingsManager"):
		SettingsManager.sync_fullscreen_state(real_fullscreen)
	_refit_timer = REFIT_DELAY  # junta as rajadas de avisos num unico refit

func _apply_refit() -> void:
	_refit_timer = -1.0
	var root: Window = get_tree().root
	var canvas_size: Vector2i = DisplayServer.window_get_size()
	if canvas_size.x > 0 and canvas_size.y > 0 and canvas_size != root.size:
		# O canvas ja tem o tamanho novo, mas a janela do jogo ainda nao percebeu: forca os Controls a recalcularem.
		root.size_changed.emit()
	display_refit.emit(Vector2(root.size))

func _auto_pause_current_minigame() -> void:
	var scene: Node = get_tree().current_scene
	if scene == null:
		return
	var pause_node: Node = scene.get_node_or_null("MinigamePause")
	if pause_node != null and pause_node is MinigamePause:
		var pause: MinigamePause = pause_node as MinigamePause
		if not pause.is_open:
			pause.open()  # respeita pause.can_pause (nao abre em tutorial/intro/fim de fase)

# ---------------------------------------------------------------- V0.14.3: medidor de FPS (aparelho fraco)
func _perf_reset(grace: float = PERF_GRACE_SECONDS) -> void:
	_perf_time = 0.0
	_perf_frames = 0
	_perf_slow_windows = 0
	_perf_grace = grace

func _is_heavy_scene(path: String) -> bool:
	for prefix: String in SceneLoader.HEAVY_PREFIXES:
		if path.begins_with(prefix):
			return true
	return false

func _sample_performance(delta: float) -> void:
	if WebLite.is_slow_measured() or _exit_done or _hidden:
		return
	var scene: Node = get_tree().current_scene
	var path: String = scene.scene_file_path if scene != null else ""
	if path != _perf_scene:
		_perf_scene = path
		_perf_reset()
		return
	# So mede minigames e cutscenes, rodando (pause, LoadingScreen e menus parados nao contam).
	if get_tree().paused or not _is_heavy_scene(path):
		_perf_reset(1.0)
		return
	if _perf_grace > 0.0:
		_perf_grace -= delta
		return
	_perf_time += delta
	_perf_frames += 1
	if _perf_time < PERF_WINDOW_SECONDS:
		return
	var fps: float = float(_perf_frames) / _perf_time
	_perf_time = 0.0
	_perf_frames = 0
	if fps < PERF_SLOW_FPS:
		_perf_slow_windows += 1
	else:
		_perf_slow_windows = 0
	if _perf_slow_windows >= PERF_SLOW_WINDOWS_NEEDED:
		_degrade_for_slow_device(fps)

func _degrade_for_slow_device(fps: float) -> void:
	WebLite.mark_slow_device()
	Engine.max_fps = SLOW_DEVICE_MAX_FPS
	print("[CM-PERF] FPS medio %.0f: perfil de aparelho fraco ligado (limite %d FPS)." % [fps, SLOW_DEVICE_MAX_FPS])
	performance_degraded.emit(fps)

## Botao Voltar do navegador.
func _on_js_back(_args: Array) -> void:
	if _exit_done:
		return
	if is_exit_confirm_open():
		request_exit()
		return
	var scene: Node = get_tree().current_scene
	if scene == null or scene.scene_file_path == Paths.SCENE_LOADING:
		return
	var pause: Node = scene.get_node_or_null("MinigamePause")
	if pause != null and pause is MinigamePause:
		(pause as MinigamePause).toggle()
		return
	open_exit_confirm()

# ---------------------------------------------------------------- confirmacao dentro do jogo
func is_exit_confirm_open() -> bool:
	return _confirm_layer != null and is_instance_valid(_confirm_layer)

func open_exit_confirm() -> void:
	if is_exit_confirm_open():
		return
	_confirm_layer = CanvasLayer.new()
	_confirm_layer.name = "ExitConfirm"
	_confirm_layer.layer = 200
	_confirm_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_confirm_layer)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	_confirm_layer.add_child(root)
	var shade := ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = UiPalette.with_alpha(UiPalette.BG, 0.78)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(440, 0)
	panel.add_theme_stylebox_override("panel", UiKit.card_style(24))
	center.add_child(panel)
	var pad := UiKit.margin(30, 30, 26, 24)
	panel.add_child(pad)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 14)
	pad.add_child(stack)
	stack.add_child(UiKit.label("Sair do ContalMaster?", 28, UiPalette.TEXT_ON_DARK, HORIZONTAL_ALIGNMENT_CENTER))
	var info: Label = UiKit.label("Seu progresso salvo será mantido. Apertar Voltar de novo também sai.", 16, UiPalette.TEXT_MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(info)
	var stay := Button.new()
	stay.text = "Continuar jogando"
	ButtonStyles.apply(stay, "ui_primary", Vector2(220, 48), 18)
	stay.pressed.connect(close_exit_confirm)
	stack.add_child(stay)
	var leave := Button.new()
	leave.text = "Sair"
	ButtonStyles.apply(leave, "ui_ghost", Vector2(220, 48), 18)
	leave.pressed.connect(request_exit)
	stack.add_child(leave)
	stay.grab_focus()
	exit_confirm_opened.emit()

func close_exit_confirm() -> void:
	if not is_exit_confirm_open():
		return
	_confirm_layer.queue_free()
	_confirm_layer = null
	exit_confirm_closed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if is_exit_confirm_open() and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_exit_confirm()

# ---------------------------------------------------------------- diagnostico (?debug=1)
func _process(delta: float) -> void:
	if _refit_timer >= 0.0:
		_refit_timer -= delta
		if _refit_timer < 0.0:
			_apply_refit()
	if WebLite.is_web():
		_sample_performance(delta)
	if _debug:
		_debug_tick(delta)

func _debug_tick(delta: float) -> void:
	_debug_timer += delta
	var scene: Node = get_tree().current_scene
	var path: String = scene.scene_file_path if scene != null else ""
	if _debug_timer < 5.0 and path == _last_scene_path:
		return
	_debug_timer = 0.0
	_last_scene_path = path
	print("[CM-DEBUG] cena=%s | mem=%.0fMB | texturas=%.0fMB | nos=%d | fps=%d | %s" % [
		path.get_file(),
		float(OS.get_static_memory_usage()) / 1048576.0,
		Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1048576.0,
		int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),
		int(Performance.get_monitor(Performance.TIME_FPS)),
		WebLite.describe()
	])
