extends Button
## V0.16.0 - Botao global "Tela cheia - ON / OFF" (build web/itch.io e desktop).
##
## POR QUE EXISTE: auditores e outros jogadores de fora do nicho nao sabiam que o jogo tem tela cheia (ela ficava escondida
## em Configuracoes). Este botao fica SEMPRE visivel, no canto superior ESQUERDO (o botao nativo do itch.io fica no canto
## inferior direito, entao nao ha conflito) e diz o ESTADO atual com palavras + icone, sem exigir familiaridade com jogos.
##
## Onde vive: FullscreenOverlay.tscn (CanvasLayer, layer 100, autoload). Layer 100 fica acima do pause (90) e abaixo da
## confirmacao de saida (200). O botao reserva a faixa y = 14..56 do canto; HUDs que usam o canto esquerdo (ex.: o score do
## Desvio Logico) comecam ABAIXO dela (ver HUD_RESERVED_BOTTOM).
##
## Estado: a verdade e DisplayServer.window_get_mode(). Na web o navegador responde de forma assincrona e o jogador pode sair
## da tela cheia com ESC sem o jogo saber, entao o texto e sincronizado por sinal de redimensionamento + checagem leve
## (4x por segundo). Depois de um clique mostramos o estado PEDIDO por um instante, para o texto mudar na hora.

# V0.16.9.4: botao COMPACTO ("TELA: ON" / "TELA: OFF"): ocupa menos da tela (libera o topo para HUDs e perguntas), e o estado
# continua dito com palavras + icone. A dica (tooltip) explica a acao por extenso.
const TEXT_ON: String = "TELA: ON"
const TEXT_OFF: String = "TELA: OFF"
## load() em vez de preload(): se os icones ainda nao foram importados (primeira abertura do projeto), o script nao quebra.
const ICON_ENTER_PATH: String = "res://assets/icons/ui/icon_fullscreen.svg"
const ICON_EXIT_PATH: String = "res://assets/icons/ui/icon_fullscreen_exit.svg"

const BUTTON_SIZE: Vector2 = Vector2(0.0, 38.0)   # largura = a do conteudo (icone + texto), cresce com a fonte
const FONT_SIZE: int = 15
## Margens do canto (px na base 1280x720). Alinhadas com o score do Desvio Logico.
const MARGIN_LEFT: float = 22.0
const MARGIN_TOP: float = 14.0
## Y (px) onde termina a faixa do botao. Qualquer HUD no canto esquerdo deve comecar daqui para baixo.
const HUD_RESERVED_BOTTOM: float = 60.0

## V0.16.2: botao mais transparente para nao competir com a cena. Fica "apagado" em repouso e volta a 100% ao passar o
## mouse / tocar, entao continua facil de achar para quem nao conhece jogos.
const IDLE_ALPHA: float = 0.42
const ACTIVE_ALPHA: float = 1.0

const POLL_INTERVAL: float = 0.25
const REQUEST_GRACE_MSEC: int = 1500

var _shown_fullscreen: bool = false
var _poll_left: float = 0.0
var _grace_until_msec: int = 0
var _icon_enter: Texture2D
var _icon_exit: Texture2D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	name = "FullscreenToggle"
	if not _is_supported():
		visible = false
		set_process(false)
		return

	set_anchors_preset(Control.PRESET_TOP_LEFT)
	offset_left = MARGIN_LEFT
	offset_top = MARGIN_TOP
	offset_right = MARGIN_LEFT   # largura vem do tamanho minimo do conteudo (BUTTON_SIZE.x = 0)
	offset_bottom = MARGIN_TOP + BUTTON_SIZE.y
	grow_horizontal = Control.GROW_DIRECTION_END
	icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	expand_icon = false
	# Sem foco: Enter/Espaco durante uma partida nunca podem "apertar" este botao sem querer. Mouse e toque funcionam normal.
	focus_mode = Control.FOCUS_NONE
	_icon_enter = load(ICON_ENTER_PATH) as Texture2D
	_icon_exit = load(ICON_EXIT_PATH) as Texture2D
	pressed.connect(_on_pressed)
	mouse_entered.connect(_set_alpha.bind(ACTIVE_ALPHA))
	mouse_exited.connect(_set_alpha.bind(IDLE_ALPHA))
	button_down.connect(_set_alpha.bind(ACTIVE_ALPHA))
	button_up.connect(_set_alpha.bind(IDLE_ALPHA))
	self_modulate = Color(1.0, 1.0, 1.0, IDLE_ALPHA)
	get_window().size_changed.connect(_sync_from_display)

	_shown_fullscreen = _is_real_fullscreen()
	_refresh_visuals()


func _process(delta: float) -> void:
	_poll_left -= delta
	if _poll_left > 0.0:
		return
	_poll_left = POLL_INTERVAL
	_sync_from_display()


# ---------------------------------------------------------------- acao
func _on_pressed() -> void:
	# V0.16.9.4 (celular/tablet no itch.io): o navegador ja abre o jogo ocupando a tela (sem a Fullscreen API). O botao ja mostra ON;
	# um clique so tenta a tela cheia "de verdade" (se o aparelho permitir) e NUNCA vira OFF nesse caso.
	if OS.has_feature("web") and _web_fs_state() == 2:
		_apply_mode(true)
		_shown_fullscreen = true
		_grace_until_msec = Time.get_ticks_msec() + REQUEST_GRACE_MSEC
		_refresh_visuals()
		_play_click()
		return
	# Durante a janela de graca vale o estado PEDIDO (cliques seguidos nao brigam com o navegador).
	var currently_fullscreen: bool = _shown_fullscreen if _in_grace() else _is_real_fullscreen()
	var target_fullscreen: bool = not currently_fullscreen
	_apply_mode(target_fullscreen)
	_shown_fullscreen = target_fullscreen
	_grace_until_msec = Time.get_ticks_msec() + REQUEST_GRACE_MSEC
	_refresh_visuals()
	_play_click()


func _apply_mode(fullscreen: bool) -> void:
	# Se o jogo tem o SettingsManager, passa por ele: assim o botao de Configuracoes fica igual a este e a escolha e salva.
	# Ele chama DisplayServer.window_set_mode() por dentro. Sem ele (script usado sozinho), muda a janela direto.
	var settings: Node = get_node_or_null("/root/SettingsManager")
	if settings != null and settings.has_method("set_fullscreen"):
		settings.call("set_fullscreen", fullscreen)
		return
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


# ---------------------------------------------------------------- sincronizacao (ESC no navegador, F11, Configuracoes...)
func _sync_from_display() -> void:
	if _in_grace():
		return
	var real_fullscreen: bool = _is_real_fullscreen()
	if real_fullscreen == _shown_fullscreen:
		return
	_shown_fullscreen = real_fullscreen
	_refresh_visuals()


func _in_grace() -> bool:
	return Time.get_ticks_msec() < _grace_until_msec


## 0 = janela normal | 1 = Fullscreen API ativa | 2 = o jogo ja ocupa a tela (celular/tablet/PWA), sem a API.
## Mesma regra do WebBridge (window.__cmFsState).
const JS_FS_STATE: String = """
(function () {
  var d = document;
  if (d.fullscreenElement || d.webkitFullscreenElement || d.mozFullScreenElement || d.msFullscreenElement) { return 1; }
  var mm = function (q) { try { return window.matchMedia(q).matches; } catch (e) { return false; } };
  if (mm('(display-mode: fullscreen)') || mm('(display-mode: standalone)') || mm('(display-mode: minimal-ui)') || window.navigator.standalone === true) { return 2; }
  var coarse = mm('(pointer: coarse)') || ('ontouchstart' in window && navigator.maxTouchPoints > 0);
  if (!coarse) { return 0; }
  var vv = window.visualViewport;
  var w = vv ? vv.width : window.innerWidth, h = vv ? vv.height : window.innerHeight;
  var big = Math.max(screen.width, screen.height), small = Math.min(screen.width, screen.height);
  var land = w >= h;
  var tw = land ? big : small, th = land ? small : big;
  return (w >= tw * 0.92 && h >= th * 0.80) ? 2 : 0;
})()
"""

func _web_fs_state() -> int:
	if not OS.has_feature("web"):
		return 0
	return int(JavaScriptBridge.eval(JS_FS_STATE, true))


func _is_real_fullscreen() -> bool:
	if OS.has_feature("web"):
		return _web_fs_state() > 0
	var mode: DisplayServer.WindowMode = DisplayServer.window_get_mode()
	return mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN


## Esconde o botao onde tela cheia nao existe ou nao funciona: apps Android/iOS (ja sao tela cheia) e navegadores que
## nao liberam a Fullscreen API (iPhone, iframe sem permissao). Um botao que nao faz nada confunde quem nao joga.
func _is_supported() -> bool:
	var os_name: String = OS.get_name()
	if os_name == "Android" or os_name == "iOS":
		return false
	if OS.has_feature("web"):
		var script: String = "!!(document.fullscreenEnabled || document.webkitFullscreenEnabled || document.mozFullScreenEnabled || document.msFullscreenEnabled)"
		return bool(JavaScriptBridge.eval(script, true))
	return true


# ---------------------------------------------------------------- visual
func _refresh_visuals() -> void:
	text = TEXT_ON if _shown_fullscreen else TEXT_OFF
	# O icone mostra o que o clique FAZ (OFF -> expandir; ON -> recolher); o texto diz o estado de agora.
	icon = _icon_exit if _shown_fullscreen else _icon_enter
	tooltip_text = "Clique para sair da tela cheia (ou aperte Esc)" if _shown_fullscreen else "Clique para jogar em tela cheia"
	ButtonStyles.apply(self, "ui_toggle_on" if _shown_fullscreen else "ui_ghost", BUTTON_SIZE, FONT_SIZE)
	focus_mode = Control.FOCUS_NONE  # ButtonStyles.apply devolve o foco; aqui ele precisa continuar desligado


func _set_alpha(alpha: float) -> void:
	# Em toque nao existe "mouse_exited" confiavel: o button_up devolve o botao ao estado apagado.
	var tween: Tween = create_tween()
	tween.tween_property(self, "self_modulate:a", alpha, 0.12)


func _play_click() -> void:
	var audio: Node = get_node_or_null("/root/AudioManager")
	if audio != null and audio.has_method("play_click"):
		audio.call("play_click")
