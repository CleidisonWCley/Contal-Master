extends Node

# Substitui o seu sistema de cores do utils.py
const COLORS = {
	"accent": Color("#ffcc00"),
	"shadow": Color(0, 0, 0, 0.5),
	"white": Color(1, 1, 1)
}

# No Godot, em vez de 'draw_text' manual, usamos funções que instanciam Labels
# Mas podemos criar uma função de ajuda para efeitos simples:
func apply_float_animation(node: CanvasItem):
	var tween = create_tween().set_loops()
	tween.tween_property(node, "position:y", node.position.y - 10, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "position:y", node.position.y, 1.0).set_trans(Tween.TRANS_SINE)

# Função para instanciar sons rapidamente (substituindo lógicas do utils)
func play_quick_sfx(sound_path: String):
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = load(sound_path)
	player.play()
	player.finished.connect(player.queue_free)
