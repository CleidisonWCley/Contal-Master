extends RefCounted
class_name SceneLoader
## Troca de cena passando pela tela de Loading (barra de progresso + dicas).
##
##   SceneLoader.change_scene(get_tree(), Paths.SCENE_STOP)
##   SceneLoader.change_scene(get_tree(), Paths.SCENE_STOP, [Paths.BG_STOP])   # V0.14.3: com pre-carregamento
##
## Regras (boas praticas):
##  - Cenas LEVES (menus) trocam direto: abrir a tela de loading so para voltar ao menu seria piscar a toa.
##  - Cenas PESADAS (minigames e cutscenes: fundos e sprites grandes) passam pela LoadingScreen.
##  - Cena que ja esta em cache (acabou de ser carregada) tambem troca direto.
## Para mudar o que e "pesado", edite SOMENTE HEAVY_PREFIXES.
##
## V0.14.3 - Pre-carregamento ("warm"):
##  O .tscn das cenas pesadas e minusculo; as imagens e a musica grandes eram carregadas DENTRO do _ready() da cena
##  nova (load() sincrono), DEPOIS da barra chegar a 100% - era ai que o aparelho fraco congelava. Agora quem chama
##  informa a lista de recursos pesados e a LoadingScreen carrega UM por quadro, mostrando a barra andar. Quando o
##  _ready() chama load(), o recurso ja esta no cache e a cena abre na hora.
##  As referencias ficam guardadas aqui (estaticas) ate a PROXIMA troca de cena; depois disso a memoria e liberada.

const HEAVY_PREFIXES: Array[String] = [
	"res://scenes/minigames/",
	"res://scenes/cutscenes/"
]

## Preenchido por change_scene() e lido (uma unica vez) pela LoadingScreen.
## Vazio = primeira abertura do jogo (a LoadingScreen e a main_scene e abre o menu principal).
static var pending_scene: String = ""
## Recursos pesados (caminhos res://) que a LoadingScreen carrega antes da cena. Lido uma unica vez.
static var pending_warm: Array = []
static var _warm_refs: Array = []

static func wants_loading(path: String) -> bool:
	if ResourceLoader.has_cached(path):
		return false
	for prefix: String in HEAVY_PREFIXES:
		if path.begins_with(prefix):
			return true
	return false

static func change_scene(tree: SceneTree, path: String, warm_paths: Array = []) -> Error:
	# Quem estava aquecido para a cena que esta SAINDO nao e mais necessario.
	release_warm()
	if wants_loading(path):
		pending_scene = path
		pending_warm = warm_paths.duplicate()
		return tree.change_scene_to_file(Paths.SCENE_LOADING)
	pending_scene = ""
	pending_warm = []
	return tree.change_scene_to_file(path)

static func take_pending() -> String:
	var path: String = pending_scene
	pending_scene = ""
	return path

static func take_pending_warm() -> Array:
	var list: Array = pending_warm
	pending_warm = []
	return list

## A LoadingScreen entrega aqui cada recurso carregado: enquanto a referencia existir, load() acerta o cache.
static func hold_warm(resource: Resource) -> void:
	if resource != null:
		_warm_refs.append(resource)

static func release_warm() -> void:
	_warm_refs.clear()
