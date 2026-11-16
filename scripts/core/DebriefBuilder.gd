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
##     2. UMA novidade de lore, se houver (perfil na 1a conclusao ou trecho liberado, ver LoreManager.next_unseen_item);
##        sem novidade, a dica pratica (quando o desempenho nao foi perfeito).
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
	return {"phase_key": phase_key, "mode": mode, "host": "", "frames": [], "interlude": {}, "characters": [], "has_content": false}


static func build(phase_key: String, mode: String, report: Dictionary, next_phase_key: String = "") -> Dictionary:
	var plan: Dictionary = empty_plan(phase_key, mode)
	var data: Dictionary = load_debrief(phase_key)
	if data.is_empty():
		return plan
	var host: String = str(data.get("host", "")).to_lower()
	plan["host"] = host
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
		var item: Dictionary = LoreManager.next_unseen_item(phase_key)
		if not item.is_empty():
			var owner: String = str(item.get("owner", host)).to_lower()
			var label: String = "Perfil" if str(item.get("kind", "")) == "profile" else "Lore"
			var display: String = str(LoreManager.CHARACTER_NAMES.get(owner, owner.capitalize()))
			var texts: Array = item.get("frames", []) as Array
			for i in range(texts.size()):
				var lore_frame: Dictionary = {
					"speaker": owner,
					"show": [owner] if owner == host else [host, owner],
					"name": "%s · %s" % [display, label],
					"text": str(texts[i])
				}
				if i == 0:
					lore_frame["lore"] = {"kind": str(item.get("kind", "")), "id": str(item.get("id", ""))}
				frames.append(lore_frame)
		elif tip != "":
			frames.append({"speaker": host, "show": [host], "text": tip})

	plan["frames"] = frames
	plan["has_content"] = not frames.is_empty()
	plan["characters"] = _characters_in(frames)
	return plan


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
