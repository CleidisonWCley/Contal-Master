extends SceneTree
## V0.15.3 - teste de fumaca: confianca por estrelas, capitulos por recorde, plano da conversa e telas novas.
## Rode:  godot --headless --path . -s res://tools/tests/trust_smoke.gd
var _fail: int = 0
func _ck(c: bool, m: String) -> void:
	print(("  ok   - " if c else "  FAIL - ") + m)
	if not c: _fail += 1

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var lore: Node = root.get_node("LoreManager")
	lore.reset_all()
	_ck(lore.get_stars("anderson") == 0, "comeca com 0 estrelas")
	var rep := {"phase_key": "batalha_naval", "mode": "free", "difficulty": "normal", "total": 10, "correct": 9, "ratio": 0.9, "points": 300}
	var res: Dictionary = lore.record_stage(rep)
	_ck(int(res["trust_gain"]) == 10 + 6 + 3 + 5, "ganho de confianca 1a vez = %d" % int(res["trust_gain"]))
	_ck(lore.has_pending_star("anderson"), "estrela pendente apos 1a conclusao")
	var plan: Dictionary = DebriefBuilder.build("batalha_naval", "free", rep, "")
	var extras: Array = plan.get("extras", [])
	_ck(extras.size() >= 1 and str(extras[0]["owner"]) == "anderson", "plano tem a conversa do Anderson")
	_ck((extras[0]["frames"] as Array).size() >= 3 and (extras[0]["frames"] as Array).size() <= 4, "3 a 4 quadros")
	var g: Dictionary = lore.begin_talk("anderson", 1)
	_ck(bool(g["granted"]) and lore.get_stars("anderson") == 1, "estrela entregue")
	_ck(lore.get_trust_points("jales") == 10, "Jales ganhou pontos da conversa")
	_ck(not bool(lore.begin_talk("anderson", 1)["granted"]), "nao entrega 2x")
	# campanha nao gera conversa
	var cplan: Dictionary = DebriefBuilder.build("batalha_naval", "campaign", rep, "maleta_certa")
	_ck((cplan.get("extras", []) as Array).is_empty(), "campanha sem conversa extra")
	# V0.15.4: sem estrela pendente o Modo Livre NAO mostra cartao nenhum (so o feedback normal).
	lore.reset_all()
	var calm: Dictionary = DebriefBuilder.build("stop", "free", {"phase_key": "stop", "mode": "free", "difficulty": "facil", "total": 6, "correct": 1, "ratio": 0.17}, "")
	_ck((calm.get("extras", []) as Array).is_empty(), "sem estrela pendente: sem conversa extra")
	_ck(not calm.has("progress_for"), "sem faixa de andamento (progress_for removido)")
	# rostos pre-recortados existem para os 9 personagens
	for id in ["jales", "priscila", "anderson", "tiago", "julios", "ariel", "aline", "cleiton", "natalia"]:
		_ck(ResourceLoader.exists("res://assets/sprites/personagens/%s/%s_face.png" % [id, id]), "rosto %s existe" % id)
	# Julios visitante
	lore.add_trust_points("julios", 20)
	var p2: Dictionary = DebriefBuilder.build("stop", "free", {"phase_key": "stop", "mode": "free", "difficulty": "facil", "total": 6, "correct": 1, "ratio": 0.17}, "")
	var ex2: Array = p2.get("extras", [])
	var owners: Array = []
	for e in ex2: owners.append(str(e["owner"]))
	_ck(owners.has("julios"), "Julios passa pela sala: %s" % str(owners))
	# Jales pending
	lore.add_trust_points("jales", 30)
	_ck(lore.has_pending_star("jales"), "Jales com estrela pendente")
	# capitulos
	var ch: Dictionary = lore.get_chapter("ilha")
	_ck(int(ch.get("min_points", 0)) == 150, "capitulo ilha meta 150")
	print("  pontos de recorde:", lore.archive_points())
	# migracao
	var old := {"version": 1, "stations": {"stop": {"plays": 3, "goals": {"bronze": true, "prata": true, "ouro": false}}}}
	var f := FileAccess.open(lore.SAVE_PATH, FileAccess.WRITE); f.store_string(JSON.stringify(old)); f.close()
	lore._load_save()
	_ck(lore.get_stars("cleiton") == 2, "migracao: STOP prata -> Cleiton 2 estrelas")
	_ck(lore.get_trust_scene("cleiton", 3).size() > 0, "cena cleiton_3 existe")
	# telas
	for path in ["res://scenes/menus/TeamProfiles.tscn", "res://scenes/menus/FirmaArchive.tscn", "res://scenes/menus/AchievementsMenu.tscn", "res://scenes/menus/TeamArchive.tscn", "res://scenes/menus/ArchiveEntry.tscn"]:
		root.get_node("GameManager").archive_entry = "char:aline"
		var scene: Node = (load(path) as PackedScene).instantiate()
		root.add_child(scene)
		await process_frame
		await process_frame
		_ck(is_instance_valid(scene), "abre " + path.get_file())
		scene.queue_free()
		await process_frame
	lore.reset_all()
	print("RESULTADO: %s (%d falhas)" % ["OK" if _fail == 0 else "FALHOU", _fail])
	quit(0 if _fail == 0 else 1)
