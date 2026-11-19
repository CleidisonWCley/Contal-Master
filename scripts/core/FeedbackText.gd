class_name FeedbackText
extends RefCounted
## V0.16.2 - Pecas de texto do feedback pos-resposta, iguais em todos os minigames.
##
## Formato (enxuto, mas completo para o auditor-revisor):
##   acerto: <explicacao> + "Na pratica: <dica>"
##   erro:   "Por que nao: <motivo da opcao escolhida>" + resposta certa + <explicacao> + "Na pratica: <dica>"
## Todas as funcoes devolvem "" quando nao ha conteudo, para o texto nunca ficar com linha vazia sobrando.

const PRACTICE_LABEL := "Na prática: "
const WHY_NOT_LABEL := "Por que não: "


## "\nNa prática: ..." (ou "" se a dica estiver vazia). Pronto para concatenar apos a explicacao.
static func practice_line(practice_text: String) -> String:
	var text: String = practice_text.strip_edges()
	if text == "":
		return ""
	return "\n" + PRACTICE_LABEL + text


## "Por que não: ..." usando o motivo especifico da opcao; sem motivo, usa o texto reserva do minigame.
static func why_not_line(reason: String, fallback: String) -> String:
	var text: String = reason.strip_edges()
	if text == "":
		return fallback
	return WHY_NOT_LABEL + text


## Encurta um texto longo (ex.: definicao de dicionario) sem cortar palavra no meio.
static func shorten(text: String, max_chars: int = 120) -> String:
	var clean: String = text.strip_edges()
	if clean.length() <= max_chars:
		return clean
	var cut: String = clean.substr(0, max_chars)
	var last_space: int = cut.rfind(" ")
	if last_space > max_chars / 2:
		cut = cut.substr(0, last_space)
	return cut.rstrip(" ,;:.") + "…"


## Motivo de uma opcao errada guardado por TEXTO da opcao (Maleta Certa e STOP).
static func reason_for_text(reasons_by_text: Variant, option_text: String) -> String:
	if reasons_by_text is Dictionary:
		return str((reasons_by_text as Dictionary).get(option_text, ""))
	return ""
