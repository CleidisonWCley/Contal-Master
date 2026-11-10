extends RefCounted
class_name UiPalette
## Tokens de design do ContalMaster (paleta definida pela equipe) + helpers de acessibilidade.
## Cores NUNCA devem ser escritas "a mao" nas telas: use UiPalette.X.

# ---- Paleta base -----------------------------------------------------------
const BG := Color("#100B1F")                  # fundo da tela (azul-noite profundo)
const CARD := Color("#211633")                # cartoes e areas secundarias (ameixa escura)
const PRIMARY := Color("#8B3DFF")             # botao principal - Jogar (roxo vibrante)
const HIGHLIGHT := Color("#B66BFF")           # destaque / toque pressionado (lilas claro)
const SECONDARY := Color("#31D6D0")           # botao secundario (ciano tropical)
const ACCENT_ACHIEVEMENTS := Color("#FF4F9A") # acento - Conquistas (rosa neon)
const ACCENT_REWARDS := Color("#FF8A4C")      # acento - Recompensas/Pontuacao (laranja por do sol)
const TEXT_ON_DARK := Color("#FFF9FF")        # texto sobre fundos escuros (branco suave)

# ---- Derivadas -------------------------------------------------------------
const TEXT_ON_BRIGHT := BG                    # texto sobre ciano/laranja/rosa (contraste >= 6:1)
const TEXT_MUTED := Color("#CFC2E8")          # texto secundario sobre CARD (contraste >= 7:1)
const CARD_RAISED := Color("#2D1F46")         # linhas/chips sobre CARD

# ---- Dificuldade (identidade propria, fixa em todas as telas) --------------
const DIFF_EASY := Color("#31D6D0")    # ciano
const DIFF_NORMAL := Color("#FFD23F")  # amarelo
const DIFF_HARD := Color("#FF6B6B")    # vermelho

# ---- Marca (nome do jogo) --------------------------------------------------
const BRAND_CONTAL := Color("#FFFFFF")        # "Contal" - branco
const BRAND_MASTER := PRIMARY                 # "Master" - roxo da equipe (#8B3DFF)
const BRAND_VERSION := TEXT_ON_DARK           # numero da versao
const BRAND_OUTLINE := Color(0.063, 0.043, 0.122, 0.95)  # contorno escuro (= BG) p/ ler sobre o cenario

# Opacidade dos botoes sobre o cenario: 0.86 e o MINIMO que mantem contraste AA no pior caso
# (roxo + branco sobre a parte mais clara do fundo). Abaixo disso o texto perde legibilidade.
const MENU_BUTTON_ALPHA := 0.86

# ---- Escala tipografica (desktop, compacto) --------------------------------
const FONT_TITLE := Vector2i(36, 28)
const FONT_SECTION := Vector2i(24, 20)
const FONT_BODY := Vector2i(18, 16)
const FONT_CAPTION := Vector2i(16, 14)
const FONT_HERO := Vector2i(52, 38)
const FONT_VALUE := Vector2i(30, 24)
const FONT_ROW := Vector2i(22, 18)

# ---- Acessibilidade: contraste WCAG ----------------------------------------
static func _lin(c: float) -> float:
	return c / 12.92 if c <= 0.03928 else pow((c + 0.055) / 1.055, 2.4)

static func luminance(c: Color) -> float:
	return 0.2126 * _lin(c.r) + 0.7152 * _lin(c.g) + 0.0722 * _lin(c.b)

static func contrast(a: Color, b: Color) -> float:
	var la: float = luminance(a)
	var lb: float = luminance(b)
	return (maxf(la, lb) + 0.05) / (minf(la, lb) + 0.05)

## Escolhe automaticamente texto claro ou escuro, o que tiver maior contraste com o fundo.
static func readable_text_on(background: Color) -> Color:
	if contrast(TEXT_ON_DARK, background) >= contrast(TEXT_ON_BRIGHT, background):
		return TEXT_ON_DARK
	return TEXT_ON_BRIGHT

static func with_alpha(c: Color, alpha: float) -> Color:
	return Color(c.r, c.g, c.b, alpha)

## Cor da dificuldade: facil=ciano, normal=amarelo, dificil=vermelho.
static func difficulty_color(key: String) -> Color:
	match key:
		"facil":
			return DIFF_EASY
		"normal":
			return DIFF_NORMAL
		"dificil":
			return DIFF_HARD
		_:
			return HIGHLIGHT

## 1, 2 ou 3 (usado nos pontos indicadores: a dificuldade nunca depende so de cor).
static func difficulty_level(key: String) -> int:
	match key:
		"facil":
			return 1
		"normal":
			return 2
		"dificil":
			return 3
		_:
			return 1

## Escurece a cor ate o texto BRANCO ficar legivel sobre ela (mantem matiz e saturacao).
## Considera a transparencia sobre o trecho mais claro do cenario (pior caso).
static func fill_for_white_text(base: Color, alpha: float = 1.0, min_ratio: float = 4.8) -> Color:
	var backdrop: Color = Color(0.62, 0.52, 0.38)
	var factor: float = 1.0
	while factor > 0.20:
		var candidate: Color = Color.from_hsv(base.h, base.s, base.v * factor)
		var effective: Color = backdrop.lerp(candidate, alpha)
		if contrast(TEXT_ON_DARK, effective) >= min_ratio:
			return candidate
		factor -= 0.02
	return Color.from_hsv(base.h, base.s, base.v * 0.20)
