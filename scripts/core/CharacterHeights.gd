extends RefCounted
class_name CharacterHeights
## Alturas dos personagens UNICA fonte de verdade: mude aqui e novels, cena final e tutoriais acompanham.
##
## Valores em METROS (altura "de desenho": inclui o cabelo, o bone e o salto, como aparecem no sprite).
## Novels (_1) e cena final (_2) desenham o corpo inteiro com a MESMA escala em metros; os tutoriais (_3, da
## cintura para cima) usam bust_scale(), uma versao suavizada da mesma diferenca de altura.

const HEIGHTS_M := {
	"julios": 1.85,
	"anderson": 1.83,
	"jales": 1.80,
	"cleiton": 1.77,
	"priscila": 1.75,
	"tiago": 1.72,
	"natalia": 1.68,
	"ariel": 1.66,
	"aline": 1.62
}

const DEFAULT_M := 1.75
## Referencia dos retratos _3 (todos os PNGs _3 ja vem enquadrados parecido; so a diferenca de altura e aplicada).
const BUST_REFERENCE_M := 1.75
const BUST_MIN := 0.92
const BUST_MAX := 1.07


static func meters(character_id: String) -> float:
	return float(HEIGHTS_M.get(character_id, DEFAULT_M))


## Fator de escala do retrato _3 (1.0 = altura de referencia).
static func bust_scale(character_id: String) -> float:
	return clampf(meters(character_id) / BUST_REFERENCE_M, BUST_MIN, BUST_MAX)


static func tallest_m() -> float:
	var best: float = DEFAULT_M
	for value in HEIGHTS_M.values():
		best = maxf(best, float(value))
	return best
