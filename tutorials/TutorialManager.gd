extends RefCounted
class_name TutorialManager
## Ponto de entrada UNICO do sistema de tutoriais dos minigames (V0.10).
##
## Como usar em qualquer minigame (campanha OU modo livre — a cena e a mesma):
##
##     # depois de montar a UI e carregar o primeiro conteudo da rodada:
##     input_locked = true
##     await TutorialManager.play(self, "show_do_bilhao")
##     if not is_inside_tree():
##         return
##     question_start_msec = Time.get_ticks_msec()   # o relogio da rodada so comeca AGORA
##     input_locked = false
##
## O tutorial le res://tutorials/data/<minigame>.json, monta o TutorialOverlay por cima do jogo
## (escurece a tela, destaca os elementos reais da interface e deixa o anfitriao explicar) e so
## devolve o controle quando o jogador conclui ou pula. Se os tutoriais estiverem desligados em
## Configuracoes, play() retorna na hora e a rodada comeca normalmente.

const OVERLAY_SCENE := Paths.TUTORIAL_OVERLAY_SCENE

## id -> dados de exibicao. MEDIDOS nos PNGs de assets/sprites/personagens (V0.10.2):
##  - "bbox"   = area real do personagem (sem a margem transparente), em pixels do PNG;
##  - "head_x" = centro horizontal da cabeca, em pixels do PNG (alinha o rosto no slot da tela).
## Estes dados descrevem os sprites "_1" (antes sem numero).
## Novels e tutoriais usam os "_3" e a cena final usa os "_2": ver SPRITE_SETS mais abaixo.
const CHARACTERS := {
	"jales": {"name": "Jales", "sprite": Paths.CHAR_JALES, "bbox": Rect2i(456, 46, 880, 2308), "head_x": 978, "color": Color("#B66BFF")},
	"priscila": {"name": "Priscila", "sprite": Paths.CHAR_PRISCILA, "bbox": Rect2i(406, 0, 726, 2027), "head_x": 760, "color": Color(1.0, 0.82, 0.12)},
	"anderson": {"name": "Anderson", "sprite": Paths.CHAR_ANDERSON, "bbox": Rect2i(525, 46, 791, 2303), "head_x": 928, "color": Color(0.25, 0.78, 1.0)},
	"tiago": {"name": "Tiago", "sprite": Paths.CHAR_TIAGO, "bbox": Rect2i(408, 16, 840, 2120), "head_x": 791, "color": Color(1.0, 0.66, 0.20)},
	"julios": {"name": "Julios", "sprite": Paths.CHAR_JULIOS, "bbox": Rect2i(462, 17, 717, 2126), "head_x": 855, "color": Color(1.0, 0.35, 1.0)},
	"ariel": {"name": "Ariel", "sprite": Paths.CHAR_ARIEL, "bbox": Rect2i(448, 46, 895, 2308), "head_x": 803, "color": Color(1.0, 0.30, 0.26)},
	"cleiton": {"name": "Cleiton", "sprite": Paths.CHAR_CLEITON, "bbox": Rect2i(452, 46, 785, 2304), "head_x": 876, "color": Color(0.62, 1.0, 0.66)},
	"aline": {"name": "Aline", "sprite": Paths.CHAR_ALINE, "bbox": Rect2i(312, 13, 978, 2008), "head_x": 720, "color": Color(0.46, 1.0, 0.82)},
	"natalia": {"name": "Natalia", "sprite": Paths.CHAR_NATALIA, "bbox": Rect2i(144, 24, 1402, 2096), "head_x": 724, "color": Color(0.0, 0.88, 1.0)}
}


# ---------------------------------------------------------------- API publica

## Configuracoes > Tutoriais (padrao: ligado).
static func is_enabled(host: Node) -> bool:
	if host != null and host.has_node("/root/SettingsManager"):
		return bool(SettingsManager.get_setting("tutorials_enabled", true))
	return true


## O jogador pode pular os tutoriais?
##  - Modo livre: sempre.
##  - Campanha: so depois de registrar a PRIMEIRA campanha (quem joga pela 1a vez nao pula).
static func can_skip(host: Node) -> bool:
	if not _is_campaign(host):
		return true
	return host.has_node("/root/ScoreManager") and ScoreManager.has_any_campaign_record()


## Tutorial completo em tela cheia (modal). Use com await. Retorna true se o jogador chegou ao fim,
## false se pulou, se os tutoriais estao desligados ou se o arquivo nao existe.
## options: {"phase": "main", "placeholders": {...}, "arrow_textures": {...}}
static func play(host: Node, minigame_key: String, options: Dictionary = {}) -> bool:
	if host == null or not host.is_inside_tree() or not is_enabled(host):
		return false
	var overlay: TutorialOverlay = create_overlay(host, minigame_key, options, TutorialOverlay.Mode.MODAL)
	if overlay == null:
		return false
	var steps: Array = steps_for(host, minigame_key, str(options.get("phase", "main")), options.get("placeholders", {}))
	if steps.is_empty():
		overlay.queue_free()
		return false
	overlay.start(steps)
	var completed: bool = await overlay.finished
	return completed


## Cria o overlay sem iniciar (modo COACH: dica flutuante que nao bloqueia o jogo; usado pelo Desvio Logico).
static func create_overlay(host: Node, minigame_key: String, options: Dictionary = {}, mode: int = TutorialOverlay.Mode.MODAL) -> TutorialOverlay:
	var data: Dictionary = load_data(minigame_key)
	if data.is_empty():
		return null
	var scene: PackedScene = load(OVERLAY_SCENE) as PackedScene
	if scene == null:
		push_warning("TutorialManager: cena do overlay nao encontrada: %s" % OVERLAY_SCENE)
		return null
	var overlay: TutorialOverlay = scene.instantiate() as TutorialOverlay
	overlay.configure(host, data, mode, options)
	host.add_child(overlay)
	return overlay


## Passos de um tutorial ja filtrados (modo campanha/livre e fase) e com {placeholders} resolvidos.
static func steps_for(host: Node, minigame_key: String, phase: String = "main", extra_placeholders: Dictionary = {}) -> Array:
	var data: Dictionary = load_data(minigame_key)
	var result: Array = []
	if data.is_empty():
		return result
	var mode_key: String = "campaign" if _is_campaign(host) else "free"
	var context: Dictionary = placeholders(host, minigame_key)
	context.merge(extra_placeholders, true)
	for raw in data.get("steps", []):
		if not (raw is Dictionary):
			continue
		var step: Dictionary = (raw as Dictionary).duplicate(true)
		if str(step.get("phase", "main")) != phase:
			continue
		var modes: Array = step.get("modes", [])
		if not modes.is_empty() and not modes.has(mode_key):
			continue
		step["title"] = format_text(str(step.get("title", "")), context)
		step["text"] = format_text(str(step.get("text", "")), context)
		step["callout"] = format_text(str(step.get("callout", "")), context)
		result.append(step)
	return result


## Carrega e valida o JSON do minigame. Retorna {} se nao existir ou estiver invalido.
static func load_data(minigame_key: String) -> Dictionary:
	var path: String = str(Paths.TUTORIAL_DATA.get(minigame_key, ""))
	if path == "" or not FileAccess.file_exists(path):
		push_warning("TutorialManager: sem tutorial para '%s'." % minigame_key)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary) or not (parsed as Dictionary).has("steps"):
		push_warning("TutorialManager: JSON invalido em %s" % path)
		return {}
	return parsed as Dictionary


static func character(character_id: String) -> Dictionary:
	return CHARACTERS.get(character_id, {})


## (legado) proporcao dos sprites "_3" antigos (1664 x 2080). Os retratos dos tutoriais NAO usam mais: ver BUST_FRAMES.
const BUST_ASPECT := 0.80

## ENQUADRAMENTO dos retratos "_3" dos TUTORIAIS (medido nos PNGs atuais, 1120 x 1500, pixels com alpha > 24).
## Os sprites novos NAO ocupam o canvas do mesmo jeito: o desenho vai de ~76% (Cleiton, Aline) a ~99% (Priscila) da
## altura do PNG, com margem vazia diferente em cima. Por isso o retrato NAO e mais dimensionado pelo canvas inteiro
## e sim pelo DESENHO VISIVEL (cabeca ate o corte da cintura), assim todo mundo ocupa o card do mesmo jeito.
##  - "rect" = retangulo do desenho em FRACAO do canvas (x, y, largura, altura; 0..1). Em fracao, continua valido se o
##    PNG for reexportado em outra resolucao com o mesmo enquadramento. Se o desenho for REFEITO, remeça (ver
##    docs/TABELA_TAMANHOS_PERSONAGENS.md) ou apague a entrada: sem ela, o jogo mede o PNG sozinho (bust_frame).
##  - "fit"  = ajuste manual de tamanho no card (1.0 = padrao; 1.1 = 10% maior; 0.9 = 10% menor).
## A diferenca de altura entre personagens (CharacterHeights.bust_scale) continua sendo aplicada por cima.
const BUST_FRAMES := {
	"jales": {"rect": Rect2(0.0875, 0.1093, 0.7991, 0.8493), "fit": 1.0},
	"priscila": {"rect": Rect2(0.0098, 0.0067, 0.9768, 0.9907), "fit": 1.0},
	"anderson": {"rect": Rect2(0.0848, 0.1093, 0.8304, 0.8493), "fit": 1.0},
	"tiago": {"rect": Rect2(0.0045, 0.0393, 0.9875, 0.9580), "fit": 1.0},
	"julios": {"rect": Rect2(0.1125, 0.0367, 0.7937, 0.9300), "fit": 1.0},
	"ariel": {"rect": Rect2(0.0955, 0.0367, 0.8152, 0.9213), "fit": 1.0},
	"cleiton": {"rect": Rect2(0.0500, 0.2013, 0.9000, 0.7573), "fit": 1.0},
	"aline": {"rect": Rect2(0.0500, 0.1900, 0.9000, 0.7687), "fit": 1.0},
	"natalia": {"rect": Rect2(0.0705, 0.0507, 0.8875, 0.9467), "fit": 1.0}
}

## Cache das medicoes feitas em tempo de execucao (personagens sem entrada em BUST_FRAMES).
static var _measured_frames: Dictionary = {}


## Enquadramento do retrato "_3": {"rect": Rect2 em fracao do canvas, "fit": float}.
## Usa BUST_FRAMES; se o personagem nao estiver la, mede o PNG (area nao transparente) e guarda em cache.
static func bust_frame(character_id: String, texture: Texture2D = null) -> Dictionary:
	var entry: Dictionary = BUST_FRAMES.get(character_id, {})
	if not entry.is_empty():
		return entry
	if _measured_frames.has(character_id):
		return _measured_frames[character_id]
	var measured: Dictionary = {"rect": Rect2(0.0, 0.0, 1.0, 1.0), "fit": 1.0}
	if texture != null:
		var image: Image = texture.get_image()
		if image != null and not image.is_empty():
			var used: Rect2i = image.get_used_rect()
			var size: Vector2 = Vector2(image.get_size())
			if used.size.x > 0 and used.size.y > 0 and size.x > 0.0 and size.y > 0.0:
				measured["rect"] = Rect2(Vector2(used.position) / size, Vector2(used.size) / size)
	_measured_frames[character_id] = measured
	return measured

## V0.11.1: sprites por VARIANTE, medidos nos PNGs (alpha > 24). REGRA DE NUMERACAO:
##   "_1" = corpo inteiro das NOVELS (transicoes dos minigames e introducao; tamanhos de canvas diferentes por personagem);
##   "_2" = corpo inteiro da CENA FINAL; "_3" = recorte da cintura para cima dos TUTORIAIS.
##   top_y / foot_y = topo da cabeca e linha dos pes (px do PNG): com eles a escala vem da ALTURA em metros (CharacterHeights).
## V0.12: (historico) "_2" = corpo inteiro, 1536x2304 (cena final, equipe reunida);
##   "_3" = recorte da cintura para cima, 1664x2080 (novels e tutoriais). Usado INTEIRO: nada e cortado por codigo.
## head_x = centro horizontal da cabeca (px do PNG); foot_y = linha dos pes (_2) ou da base visivel (_3), em px do PNG.
## Todos os PNGs de uma variante tem o mesmo tamanho de tela, entao a ESCALA e unica e as proporcoes entre os
## personagens seguem o desenho original.
const SPRITE_SETS := {
	"jales": {"v1": {"path": Paths.CHAR_JALES_1, "size": Vector2i(1792, 2400), "head_x": 978, "foot_y": 2353, "top_y": 46}, "v2": {"path": Paths.CHAR_JALES_2, "size": Vector2i(1536, 2304), "head_x": 794, "foot_y": 2260, "top_y": 35}, "v3": {"path": Paths.CHAR_JALES_3, "size": Vector2i(1664, 2080), "head_x": 894, "foot_y": 2062}},
	"priscila": {"v1": {"path": Paths.CHAR_PRISCILA_1, "size": Vector2i(1529, 2048), "head_x": 760, "foot_y": 2024, "top_y": 0}, "v2": {"path": Paths.CHAR_PRISCILA_2, "size": Vector2i(1536, 2304), "head_x": 727, "foot_y": 2265, "top_y": 20}, "v3": {"path": Paths.CHAR_PRISCILA_3, "size": Vector2i(1664, 2080), "head_x": 807, "foot_y": 2080}},
	"anderson": {"v1": {"path": Paths.CHAR_ANDERSON_1, "size": Vector2i(1792, 2400), "head_x": 928, "foot_y": 2346, "top_y": 46}, "v2": {"path": Paths.CHAR_ANDERSON_2, "size": Vector2i(1536, 2304), "head_x": 724, "foot_y": 2278, "top_y": 23}, "v3": {"path": Paths.CHAR_ANDERSON_3, "size": Vector2i(1664, 2080), "head_x": 704, "foot_y": 2062}},
	"tiago": {"v1": {"path": Paths.CHAR_TIAGO_1, "size": Vector2i(1632, 2176), "head_x": 791, "foot_y": 2134, "top_y": 17}, "v2": {"path": Paths.CHAR_TIAGO_2, "size": Vector2i(1536, 2304), "head_x": 790, "foot_y": 2263, "top_y": 19}, "v3": {"path": Paths.CHAR_TIAGO_3, "size": Vector2i(1664, 2080), "head_x": 743, "foot_y": 2062}},
	"julios": {"v1": {"path": Paths.CHAR_JULIOS_1, "size": Vector2i(1632, 2176), "head_x": 855, "foot_y": 2142, "top_y": 18}, "v2": {"path": Paths.CHAR_JULIOS_2, "size": Vector2i(1536, 2304), "head_x": 789, "foot_y": 2264, "top_y": 19}, "v3": {"path": Paths.CHAR_JULIOS_3, "size": Vector2i(1664, 2080), "head_x": 838, "foot_y": 2080}},
	"ariel": {"v1": {"path": Paths.CHAR_ARIEL_1, "size": Vector2i(1792, 2400), "head_x": 803, "foot_y": 2353, "top_y": 46}, "v2": {"path": Paths.CHAR_ARIEL_2, "size": Vector2i(1536, 2304), "head_x": 724, "foot_y": 2260, "top_y": 44}, "v3": {"path": Paths.CHAR_ARIEL_3, "size": Vector2i(1664, 2080), "head_x": 705, "foot_y": 2062}},
	"cleiton": {"v1": {"path": Paths.CHAR_CLEITON_1, "size": Vector2i(1792, 2400), "head_x": 876, "foot_y": 2349, "top_y": 47}, "v2": {"path": Paths.CHAR_CLEITON_2, "size": Vector2i(1536, 2304), "head_x": 726, "foot_y": 2234, "top_y": 43}, "v3": {"path": Paths.CHAR_CLEITON_3, "size": Vector2i(1664, 2080), "head_x": 697, "foot_y": 2062}},
	"aline": {"v1": {"path": Paths.CHAR_ALINE_1, "size": Vector2i(1529, 2048), "head_x": 720, "foot_y": 2019, "top_y": 13}, "v2": {"path": Paths.CHAR_ALINE_2, "size": Vector2i(1536, 2304), "head_x": 758, "foot_y": 2271, "top_y": 12}, "v3": {"path": Paths.CHAR_ALINE_3, "size": Vector2i(1664, 2080), "head_x": 816, "foot_y": 2062}},
	"natalia": {"v1": {"path": Paths.CHAR_NATALIA_1, "size": Vector2i(1632, 2176), "head_x": 724, "foot_y": 2119, "top_y": 25}, "v2": {"path": Paths.CHAR_NATALIA_2, "size": Vector2i(1536, 2304), "head_x": 721, "foot_y": 2264, "top_y": 26}, "v3": {"path": Paths.CHAR_NATALIA_3, "size": Vector2i(1664, 2080), "head_x": 782, "foot_y": 2062}}
}


## Dados de sprite de um personagem numa variante ("v2" corpo inteiro, "v3" recorte). {} se nao existir.
static func sprite_set(character_id: String, variant: String = "v3") -> Dictionary:
	var entry: Dictionary = SPRITE_SETS.get(character_id, {})
	return entry.get(variant, {})


## Textura COMPLETA da variante (sem recorte), pronta para um TextureRect.
## V0.14.7: o caminho passa por resolve_sprite_path() (tolera diferenca de maiuscula/minuscula da pasta no build web).
static func sprite_texture(character_id: String, variant: String = "v3") -> Texture2D:
	var path: String = resolve_sprite_path(character_id, variant)
	if path == "":
		return null
	var texture: Texture2D = load(path) as Texture2D
	if texture == null:
		push_warning("TutorialManager: nao foi possivel carregar o sprite '%s' (%s): %s" % [character_id, variant, path])
	return texture


## Cache id|variante -> caminho que realmente existe no build.
static var _sprite_paths: Dictionary = {}


## V0.14.7 (hotfix sprites web): devolve o caminho do sprite que EXISTE de verdade no build.
## Causa do bug: o build web (Linux/PCK) diferencia maiuscula de minuscula e o .pck publicado tinha as pastas
## "Ariel/", "Cleiton/", "Natalia/" e "Priscilla/", enquanto o codigo pede "ariel/", "cleiton/"... No Windows isso
## funciona (nao diferencia); na web o load() falha e o personagem some. Tenta, nesta ordem: o caminho padrao
## (minusculo), a pasta com a 1a letra maiuscula e, para a Priscila, a grafia antiga "Priscilla". Se nada existir,
## devolve o caminho padrao (o load() acusa o erro no console) e avisa UMA vez.
static func resolve_sprite_path(character_id: String, variant: String = "v3") -> String:
	var key: String = "%s|%s" % [character_id, variant]
	if _sprite_paths.has(key):
		return str(_sprite_paths[key])
	var path: String = str(sprite_set(character_id, variant).get("path", ""))
	if path == "":
		return ""
	var file_name: String = path.get_file()
	var folder_path: String = path.get_base_dir()
	var folder: String = folder_path.get_file()
	var parent: String = folder_path.get_base_dir()
	var candidates: Array[String] = [path, "%s/%s/%s" % [parent, folder.capitalize(), file_name]]
	if folder == "priscila":
		candidates.append("%s/Priscilla/%s" % [parent, file_name])
		candidates.append("%s/Priscila/%s" % [parent, file_name])
	var chosen: String = path
	var found: bool = false
	for candidate: String in candidates:
		if ResourceLoader.exists(candidate):
			chosen = candidate
			found = true
			break
	if not found:
		push_warning("TutorialManager: sprite '%s' (%s) nao existe no build: %s" % [character_id, variant, path])
	elif chosen != path:
		push_warning("TutorialManager: sprite '%s' (%s) achado com outra caixa de pasta: %s (padrao: %s). Renomeie a pasta e reexporte." % [character_id, variant, chosen, path])
	_sprite_paths[key] = chosen
	return chosen


## Valores reais do jogo injetados nos textos ({correct}, {wrong}, {stage}...): o tutorial nunca fica
## desatualizado quando a pontuacao ou a dificuldade mudam.
static func placeholders(host: Node, minigame_key: String) -> Dictionary:
	var ctx: Dictionary = {"rounds": 6, "stage": 1, "total": 8, "difficulty": "Normal", "correct": 0, "wrong": 0, "threats": 0, "chase_time": 0}
	if host == null or not host.has_node("/root/DifficultyManager"):
		return ctx
	ctx["difficulty"] = DifficultyManager.get_label()
	ctx["correct"] = DifficultyManager.get_correct_points(minigame_key)
	ctx["wrong"] = absi(DifficultyManager.get_wrong_points(minigame_key))
	ctx["threats"] = DifficultyManager.get_naval_quantity()
	ctx["chase_time"] = int(round(DifficultyManager.get_chase_time()))
	if host.has_node("/root/GameManager"):
		ctx["stage"] = GameManager.get_current_stage_number()
		ctx["total"] = GameManager.get_total_stages()
	return ctx


static func format_text(template: String, context: Dictionary) -> String:
	var text: String = template
	for key in context.keys():
		text = text.replace("{%s}" % str(key), str(context[key]))
	return text


static func _is_campaign(host: Node) -> bool:
	return host != null and host.has_node("/root/GameManager") and GameManager.is_campaign_mode()
