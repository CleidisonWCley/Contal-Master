extends RefCounted
class_name SceneLoader
## Troca de cena passando pela tela de Loading (barra de progresso + dicas).
##
##   SceneLoader.change_scene(get_tree(), Paths.SCENE_STOP)
##
## Regras (boas praticas):
##  - Cenas LEVES (menus) trocam direto: abrir a tela de loading so para voltar ao menu seria piscar a toa.
##  - Cenas PESADAS (minigames e cutscenes: fundos e sprites grandes) passam pela LoadingScreen.
##  - Cena que ja esta em cache (acabou de ser carregada) tambem troca direto.
## Para mudar o que e "pesado", edite SOMENTE HEAVY_PREFIXES.

const HEAVY_PREFIXES: Array[String] = [
	"res://scenes/minigames/",
	"res://scenes/cutscenes/"
]

## Preenchido por change_scene() e lido (uma unica vez) pela LoadingScreen.
## Vazio = primeira abertura do jogo (a LoadingScreen e a main_scene e abre o menu principal).
static var pending_scene: String = ""

static func wants_loading(path: String) -> bool:
	if ResourceLoader.has_cached(path):
		return false
	for prefix: String in HEAVY_PREFIXES:
		if path.begins_with(prefix):
			return true
	return false

static func change_scene(tree: SceneTree, path: String) -> Error:
	if wants_loading(path):
		pending_scene = path
		return tree.change_scene_to_file(Paths.SCENE_LOADING)
	pending_scene = ""
	return tree.change_scene_to_file(path)

static func take_pending() -> String:
	var path: String = pending_scene
	pending_scene = ""
	return path
