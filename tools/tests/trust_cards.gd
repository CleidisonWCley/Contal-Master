extends Node
## Roda como CENA (autoloads disponiveis): godot --headless --path . res://tools/tests/trust_cards.tscn
func _ready() -> void:
	var fails: int = 0
	var host := Control.new(); add_child(host)
	var card: TrustCard = TrustCard.star(host, "natalia", 2)
	await get_tree().process_frame
	await get_tree().process_frame
	print("card ok: ", is_instance_valid(card))
	card._close()
	var pill: TrustCard = TrustCard.progress(host, "ariel")
	await get_tree().process_frame
	pill._close()
	# StageDebrief completo com conversa
	LoreManager.reset_all()
	var rep := {"phase_key": "maleta_certa", "mode": "free", "difficulty": "normal", "total": 6, "correct": 5, "ratio": 0.83, "points": 400}
	LoreManager.record_stage(rep)
	GameManager.debrief_plan = DebriefBuilder.build("maleta_certa", "free", rep, "")
	print("extras: ", (GameManager.debrief_plan["extras"] as Array).size())
	var scene: Node = (load("res://scenes/cutscenes/StageDebrief.tscn") as PackedScene).instantiate()
	add_child(scene)
	for i in 6: await get_tree().process_frame
	print("debrief aberto: ", is_instance_valid(scene))
	await get_tree().create_timer(1.5).timeout
	scene.queue_free()
	LoreManager.reset_all()
	print("FIM")
	get_tree().quit()
