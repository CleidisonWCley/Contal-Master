extends RefCounted
class_name DebriefBuilder
## V0.15 - Monta os quadros (frames do NovelStage) da conversa DEPOIS de cada minigame.
##
## Entrada: chave da fase, modo ("campaign" | "free"), relatorio da estacao e a proxima fase da campanha.
## Dados: res://scripts/data/debrief/<fase>.json (ver notes dentro dos JSON) e LoreManager (lore do modo livre).
##
##   CAMPANHA  (a narrativa continua a mesma; so ganha o "depois" do minigame)
##     1. anfitriao comenta o desempenho (faixa perfeito/otimo/medio/fraco; Roleta: bom/ruim);
##     2. (opcional) o mesmo anfitriao deixa 1 dica pratica, quando o desempenho nao foi perfeito;
##     3. Jales entra e chama o jogador para a proxima estacao ("jales_next").
##     Ultima estacao (Desvio Logico): em vez do Jales, a Natalia faz o CORTE ("campaign_cut"): avisa da reuniao no
##     escritorio e que vai se arrumar (justifica a roupa formal da cena final) e roda o INTERLUDIO da estrada a noite.
##
##   MODO LIVRE  (conhecer os personagens e juntar lore; sem Jales)
##     1. anfitriao comenta o desempenho;
##     2. V0.15.3: se ha ESTRELA de confianca pendente, a CONVERSA (plan["extras"]: cena do personagem com o Jales, narracao
##        centralizada e cartao de estrela); senao so a dica pratica.
##        V0.15.4: o cartao de confianca NUNCA aparece sem estrela nova (antes uma faixa de andamento surgia apos todo minigame).
##
## O resultado e um "plano" (Dictionary) guardado em GameManager.debrief_plan e tocado por StageDebrief:
##   {"phase_key", "mode", "host", "frames": [...], "interlude": {...}, "characters": [ids], "has_content": bool}
## Um quadro pode trazer "lore": {"kind", "id"}: StageDebrief marca como visto quando o quadro COMECA (quem pula nao perde).

const MODE_CAMPAIGN := "campaign"
const MODE_FREE := "free"


static func load_debrief(phase_key: String) -> Dictionary:
	var path: String = "%s%s.json" % [Paths.DEBRIEF_DIR, phase_key]
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary:
		return parsed as Dictionary
	push_warning("DebriefBuilder: JSON invalido em %s" % path)
	return {}


static func empty_plan(phase_key: String, mode: String) -> Dictionary:
	return {"phase_key": phase_key, "mode": mode, "host": "", "frames": [], "interlude": {}, "background": "", "characters": [], "has_content": false}


static func build(phase_key: String, mode: String, report: Dictionary, next_phase_key: String = "") -> Dictionary:
	var plan: Dictionary = empty_plan(phase_key, mode)
	var data: Dictionary = load_debrief(phase_key)
	if data.is_empty():
		return plan
	var host: String = str(data.get("host", "")).to_lower()
	plan["host"] = host
	plan["background"] = str(data.get("background", ""))
	var tier: String = LoreManager.tier_for_report(report)
	var frames: Array = []

	# 1) o anfitriao comenta o desempenho
	var reaction: String = _pick_line(phase_key, "tier_" + tier, _tier_lines(data, tier))
	if reaction != "":
		frames.append({"speaker": host, "show": [host], "text": reaction})
	var tip: String = str((data.get("tips", {}) as Dictionary).get(tier, ""))
	if tier == "perfeito":
		tip = ""

	if mode == MODE_CAMPAIGN:
		var cut: Array = data.get("campaign_cut", []) as Array
		if not cut.is_empty():
			# Ultima estacao: corte da Natalia (sem dica, sem Jales) + interludio da estrada.
			for item in cut:
				var entry: Dictionary = item as Dictionary
				var speaker: String = str(entry.get("speaker", host)).to_lower()
				frames.append({"speaker": speaker, "show": [speaker], "text": str(entry.get("text", ""))})
			plan["interlude"] = (data.get("interlude", {}) as Dictionary).duplicate(true)
		else:
			if tip != "":
				frames.append({"speaker": host, "show": [host], "text": tip})
			var next_line: String = _pick_line(phase_key, "next", (data.get("jales_next", []) as Array))
			if next_line != "" and next_phase_key != "":
				frames.append({"speaker": "jales", "show": ["jales", host], "text": next_line})
	else:
		# V0.15.3: MODO LIVRE = conversa de confianca (a estrela pendente do anfitriao, ou do Julios) + o Jales em todas.
		var extras: Array = []
		for talk in LoreManager.plan_talks(phase_key):
			var built: Dictionary = _talk_sequence(talk as Dictionary)
			if not built.is_empty():
				extras.append(built)
		plan["extras"] = extras
		if extras.is_empty():
			if tip != "":
				frames.append({"speaker": host, "show": [host], "text": tip})
	plan["frames"] = frames
	plan["has_content"] = not frames.is_empty() or not (plan.get("extras", []) as Array).is_empty()
	var chars: Array = _characters_in(frames)
	for extra in plan.get("extras", []) as Array:
		for id in (extra as Dictionary).get("characters", []) as Array:
			if not chars.has(id):
				chars.append(id)
	plan["characters"] = chars
	return plan


## Quadros de UMA conversa (3 a 4 quadros do personagem + Jales), a narracao centralizada e o cartao de estrela.
static func _talk_sequence(talk: Dictionary) -> Dictionary:
	var owner: String = str(talk.get("owner", ""))
	var level: int = int(talk.get("level", 1))
	var co: String = str(talk.get("co", ""))
	var scene: Dictionary = LoreManager.get_trust_scene(owner, level)
	if scene.is_empty():
		return {}
	var has_jales: bool = owner == "jales"
	for item in scene.get("frames", []) as Array:
		if str((item as Dictionary).get("s", "")) == "jales":
			has_jales = true
	var visible: Array = [owner]
	if owner == "jales":
		if co != "" and co != "jales":
			visible = ["jales", co]
	elif has_jales:
		visible = [owner, "jales"]
	var frames: Array = []
	for item in scene.get("frames", []) as Array:
		var line: Dictionary = item as Dictionary
		var speaker: String = str(line.get("s", owner))
		frames.append({"speaker": speaker, "show": visible.duplicate(), "text": str(line.get("t", ""))})
	var display: String = str(LoreManager.CHARACTER_NAMES.get(owner, owner.capitalize()))
	var narration: Array = [
		"Depois de uma longa conversa, você conhece %s um pouco melhor.",
		"A conversa se estende, e %s abre mais da própria história com você.",
		"Já é noite quando a conversa termina. %s agora trata você como gente da casa."
	]
	return {
		"owner": owner, "level": level, "title": str(scene.get("title", "")), "frames": frames,
		"talk_frames": [{"speaker": "", "narration": true, "dim": 0.72, "text": str(narration[clampi(level - 1, 0, 2)]) % display}],
		"characters": visible
	}


static func _tier_lines(data: Dictionary, tier: String) -> Array:
	var tiers: Dictionary = data.get("tiers", {}) as Dictionary
	if tiers.has(tier) and (tiers[tier] as Array).size() > 0:
		return tiers[tier] as Array
	# Faixa sem fala (ex.: a Roleta so tem bom/ruim): usa a mais proxima disponivel.
	for fallback in ["otimo", "medio", "bom", "fraco", "ruim"]:
		if tiers.has(fallback) and (tiers[fallback] as Array).size() > 0:
			return tiers[fallback] as Array
	return []


static func _pick_line(phase_key: String, slot: String, lines: Array) -> String:
	if lines.is_empty():
		return ""
	var index: int = LoreManager.pick_index("%s:%s" % [phase_key, slot], lines.size())
	return str(lines[index])


static func _characters_in(frames: Array) -> Array:
	var ids: Array = []
	for item in frames:
		var frame: Dictionary = item as Dictionary
		for id in frame.get("show", []) as Array:
			if not ids.has(str(id)):
				ids.append(str(id))
		var speaker: String = str(frame.get("speaker", ""))
		if speaker != "" and not ids.has(speaker):
			ids.append(speaker)
	return ids
