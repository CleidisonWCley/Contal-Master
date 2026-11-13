# Tabela de tamanhos dos personagens (retratos dos tutoriais)

Medido nos PNGs atuais `assets/sprites/personagens/<nome>/<nome>_3.png` (o recorte da cintura para cima usado nos cards de tutorial).
Todos os PNGs têm canvas de **1120 × 1500 px**. "Desenho" é a área realmente visível (pixels com alpha > 24), sem a margem transparente.

## Por que os retratos estavam desproporcionais

O código desenhava o **canvas inteiro** do PNG com a mesma escala para todo mundo, e assumia canvas de 1664 × 2080 (o tamanho antigo). Só que nos sprites novos o desenho ocupa o canvas de formas bem diferentes:
a altura do desenho vai de **76% (Cleiton) a 99% (Priscila)** da altura do PNG, e o topo da cabeça começa entre **0,7% e 20%** do canvas.
Resultado: Cleiton e Aline apareciam pequenos e "afundados" no card, enquanto Priscila, Julios e Tiago apareciam bem maiores que os demais (e a base do desenho flutuava mais ou menos acima da base do card, conforme a margem vazia de cada PNG).

## Como ficou

O retrato agora é dimensionado pelo **desenho visível** (cabeça até o corte da cintura), não pelo canvas:

1. Altura visível base = altura do card + 34 px (card embaixo) ou − 8 px (card no topo).
2. × **altura real do personagem** (`CharacterHeights.bust_scale`, de 0,92 a 1,07, mesma regra de antes).
3. × **`fit`** de cada personagem (ajuste manual, padrão 1.0).
4. A **base do desenho** fica apoiada na base do card e a **borda direita do desenho** alinhada à lateral do card (com a mesma sobra de até 56 px de antes, sem encostar na borda da tela).
5. A área que o texto reserva para o retrato vem da **largura real do desenho** de cada personagem.
6. Se o card estiver tão no topo que o mais alto não cabe, **todos encolhem juntos** (a proporção entre eles se mantém).

## Tabela — sprites `_3` (tutoriais)

Colunas "antes" e "agora" = altura visível do desenho em px, num card de 190 px de altura embaixo da tela (tela 1280×720). Ordenado do mais alto para o mais baixo.

| Personagem | Anfitrião de | Altura (m) | bust_scale | Desenho (L × A px) | Canto (x, y) px | Altura do desenho / canvas | Topo da cabeça | Base do corte | Antes (px) | Agora (px) | Largura agora (px) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Julios | Roleta Risco | 1.85 | 1.057 | 889 × 1395 | 126, 55 | 93.0% | 3.7% | 96.7% | 275 | **237** | 151 |
| Anderson | Batalha Naval | 1.83 | 1.046 | 930 × 1274 | 95, 164 | 84.9% | 10.9% | 95.9% | 249 | **234** | 171 |
| Jales | — (apresenta nas novels) | 1.80 | 1.029 | 895 × 1274 | 98, 164 | 84.9% | 10.9% | 95.9% | 245 | **230** | 162 |
| Cleiton | Stop | 1.77 | 1.011 | 1008 × 1136 | 56, 302 | 75.7% | 20.1% | 95.9% | 214 | **227** | 201 |
| Priscila | Show do Bilhão | 1.75 | 1.000 | 1094 × 1486 | 11, 10 | 99.1% | 0.7% | 99.7% | 277 | **224** | 165 |
| Tiago | Maleta Certa | 1.72 | 0.983 | 1106 × 1437 | 5, 59 | 95.8% | 3.9% | 99.7% | 264 | **220** | 169 |
| Natalia | Desvio Lógico | 1.68 | 0.960 | 994 × 1420 | 79, 76 | 94.7% | 5.1% | 99.7% | 254 | **215** | 151 |
| Ariel | Perseguição | 1.66 | 0.949 | 913 × 1382 | 107, 55 | 92.1% | 3.7% | 95.8% | 245 | **212** | 140 |
| Aline | Força Técnica | 1.62 | 0.926 | 1008 × 1153 | 56, 285 | 76.9% | 19.0% | 95.9% | 199 | **207** | 181 |

Antes, a altura visível variava de **199 a 277 px** (diferença de 1.39×). Agora varia só pelo `bust_scale` (diferença de 1.14×, que é a diferença real de altura entre os personagens).

## Como ajustar um personagem

Em `tutorials/TutorialManager.gd`, constante **`BUST_FRAMES`**:

```gdscript
"cleiton": {"rect": Rect2(0.0500, 0.2013, 0.9000, 0.7573), "fit": 1.0},
```

- **`fit`** — tamanho no card: `1.10` = 10% maior, `0.90` = 10% menor. É o único valor que você precisa mexer no dia a dia.
- **`rect`** — retângulo do desenho em **fração do canvas** (x, y, largura, altura), igual às colunas "Canto" e "Desenho" acima divididas por 1120 e 1500. Só precisa mudar se o **desenho for refeito** (nova arte com outro enquadramento).
- Se **apagar a entrada** de um personagem, o jogo mede o PNG sozinho (área não transparente) na primeira vez que ele aparece. Útil para um personagem novo.
- A diferença de altura entre personagens continua em `scripts/core/CharacterHeights.gd` (`HEIGHTS_M`).

Para remedir um PNG fora do Godot (Python + Pillow):

```python
from PIL import Image
import numpy as np
im = Image.open("assets/sprites/personagens/cleiton/cleiton_3.png").convert("RGBA")
a = np.array(im)[:, :, 3] > 24
ys, xs = np.where(a.any(1))[0], np.where(a.any(0))[0]
x0, y0, x1, y1 = xs[0], ys[0], xs[-1] + 1, ys[-1] + 1
W, H = im.size
print(f'Rect2({x0/W:.4f}, {y0/H:.4f}, {(x1-x0)/W:.4f}, {(y1-y0)/H:.4f})')
```

## Observação sobre os sprites `_1` e `_2`

Medidos só para conferência (não foram alterados). Já estão uniformes entre si (desenho entre 95% e 99% da altura do canvas):

| Personagem | `_1` desenho (L × A px, % do canvas) | `_2` desenho (L × A px, % do canvas) |
|---|---|---|
| Aline | 716 × 1469 (98%) | 681 × 1471 (98%) |
| Anderson | 493 × 1438 (96%) | 568 × 1469 (98%) |
| Ariel | 455 × 1399 (93%) | 657 × 1399 (93%) |
| Cleiton | 489 × 1440 (96%) | 670 × 1428 (95%) |
| Jales | 550 × 1442 (96%) | 558 × 1449 (97%) |
| Julios | 492 × 1458 (97%) | 469 × 1463 (98%) |
| Natalia | 1000 × 1450 (97%) | 526 × 1460 (97%) |
| Priscila | 624 × 1444 (96%) | 335 × 1438 (96%) |
| Tiago | 488 × 1451 (97%) | 623 × 1450 (97%) |

Os valores `size` e `foot_y` registrados em `SPRITE_SETS` (`TutorialManager.gd`) ainda descrevem canvases antigos (1792×2400, 1536×2304, 1664×2080), mas os PNGs atuais são todos 1120×1500. Não mexi nisso porque é usado por novels e cena final, fora do escopo deste ajuste.
