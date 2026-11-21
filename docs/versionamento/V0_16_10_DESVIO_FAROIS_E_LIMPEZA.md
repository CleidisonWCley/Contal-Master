# V0.16.10 — Desvio Lógico: farol discreto, memória de vídeo menor e limpeza de código

> Linha anterior (0.16.9 a 0.16.9.6) unificada em [`V0_16_9_UNIFICADO.md`](V0_16_9_UNIFICADO.md).
> Base: `contalmaster_ajustes_0_16_9.zip`. Godot **4.5-stable** (GL Compatibility).

## 1) Farol do Bionix mais discreto (`DLCarLights.gd` + `DLConfig.gd`)
**Antes:** dois feixes altos e largos (≈1,4 × a altura do carro, meia-largura 8% → 15%, opacidade 0,38) + poça grande no asfalto. Parecia "dois refletores" cortando a pista.
**Agora:** dois feixes curtos e finos, um pontinho de luz na saída de cada farol e uma poça bem fraca (só em aparelho forte).

| Constante (`DLConfig`) | Antes | Agora |
|---|---|---|
| `CAR_HEADLIGHT_BY_ROUND` (Anoitecer / Noite) | 0,85 / 1,00 | **0,55 / 0,70** |
| comprimento do feixe (`HEADLIGHT_BEAM_LENGTH`, em alturas do sprite) | 1,39 | **0,55** |
| meia-largura na saída / na ponta | 0,08 / 0,15 | **0,028 / 0,060** |
| opacidade do feixe (`HEADLIGHT_BEAM_ALPHA`) | 0,38 | **0,26** (× intensidade do horário) |
| ponto de luz (`HEADLIGHT_SPOT_RADIUS`) | não tinha | **0,035** |
| poça no asfalto (`HEADLIGHT_POOL_ALPHA`) | 0,22 | **0,10** |
| altura da saída (`HEADLIGHT_ORIGIN_Y`) | 0,34 | **0,14** (acima do teto, para o ponto aparecer) |

Tudo é ajustável só em `DLConfig.gd` (bloco `HEADLIGHT_*`), sem mexer no módulo. Para ficar ainda menor: baixe `HEADLIGHT_BEAM_LENGTH` e `HEADLIGHT_BEAM_ALPHA`. As lanternas vermelhas (traseiras) **não mudaram**. Aparelho fraco (`WebLite.low_end()`) continua sem a poça.

## 1b) Destino da bifurcação que "se aproxima" (`DesvioLogico.gd` + `DLConfig.gd`)
O fundo é uma imagem única e estática; só a placa e os postes tinham perspectiva. Agora **só a faixa do horizonte** (céu + cidade, acima da linha de árvores, y ≤ 230 do palco) cresce durante o trajeto:
- Uma cópia dessa faixa (mesma textura, **sem VRAM extra**, recortada por `clip_contents`) é filha do fundo e escala com pivô na linha de árvores. A linha do horizonte não se mexe, então a emenda com o resto do fundo fica invisível; pista, mar e postes **não mudam**.
- Escala hiperbólica (1/distância): cresce devagar no início e mais rápido perto da decisão. Vai de 1,00 (início do desafio) a **1,14** (decisão) e **mantém o tamanho** na decisão/feedback; volta a 1,00 no desafio seguinte (o fade preto cobre a troca).
- Compõe com o micro zoom/ondulação que o fundo já tinha (a faixa é filha do fundo).
- Ajuste em `DLConfig`: `SKYLINE_APPROACH_ENABLED` (liga/desliga), `SKYLINE_ZOOM_END` (1.10 sutil, 1.20 forte), `SKYLINE_HORIZON_Y`, `SKYLINE_PIVOT_X`.
- Testado no Godot 4.5 com prints em 0%, 50% e 100% (Entardecer e Noite): emenda limpa. Não medido em navegador/aparelho fraco; o custo é um recorte de ~1280×230 por quadro.

## 2) Verificação dos itens de limpeza (cada um conferido por busca em todo o projeto)
| # | Item | Resultado | Ação nesta versão |
|---|---|---|---|
| 1 | `build/web` (~110 MB: `index.pck` + `index.wasm`, desatualizados) | Confirmado; só pesa na pasta, não no jogo | `.gitignore` (ignora `build/`) e `build/.gdignore` (o editor não escaneia). **Apague a pasta `build/web` do projeto** (ou mova para fora): o zip deste patch não consegue apagar arquivos. |
| 2 | `BackgroundPreview` carregava o fundo 2816×1584 no jogo | Confirmado | **Feito:** virou o `modules/DLEditorGuide.gd` (`@tool`), que desenha o fundo da Manhã a 55% **só no editor**. No jogo/web nenhuma textura é carregada. Você mantém a referência visual para posicionar os markers. |
| 3 | 6 fundos 2816×1584 recarregados a cada desafio | Confirmado (o Amanhecer já estava limitado a 1920; os outros 5 não) | **Feito sem tocar nos PNGs:** `process/size_limit=1920` no `.import` dos 5 fundos restantes (o Godot reduz na importação; o PNG original fica intacto para o futuro). Resultado 1920×1080, mesma proporção 16:9, então markers e calibração dos postes continuam valendo. |
| 4 | `poste_lateral*.png` + modo `"sprite"` + `LeftPostPreview`/`RightPostPreview` | Confirmado: só servem de fallback e de preview | **Não removido**: depende da sua aprovação dos postes por script. Quando aprovar, dá para apagar os 2 PNGs (~192 KB), o modo `sprite` e os dois previews. |
| 5 | Código morto do Desvio Lógico | Confirmado: nenhuma chamada (nem por string) | **Removido** (ver lista abaixo) |
| 6 | 10 constantes sem uso do `DLConfig` | Confirmado | **Removidas** (ver lista abaixo) |

### Removido (item 5) — ~120 linhas
- `DLWaterFX`: `_create_water_mask_shader_material` (com o shader embutido), `_update_water_mask_shader`, `_draw_water_broken_wave`, e também `_draw_water_poly_wave` e a variável `water_mask_shader_layer`, que só existiam para essas funções.
- `DesvioLogico`: `_resume_game`, `_lane_x`, `_fit_rect_into`.
- `DLSideProps`: `_left_post_spacing_conflict`, `_left_side_visual_conflict`.
- `DLTraffic`: `_active_obstacle_count`.

### Removido (item 6)
`PLAYER_CAR_DISPLAY_NAME`, `WATER_USE_MASK_SHADER`, `ENGINE_ACCELERATION_SFX_KEY`, `ENGINE_LOOP_SFX_KEY`, `VELOX_SFX_BUS`, `VELOX_SFX_BUS_SEND`, `NPC_DAMAGE_GRACE_SECONDS`, `LANE_COUNT`, `INITIAL_TRAFFIC_COUNT`, `SIDE_PROP_COUNT`.
Ficou órfã com a limpeza do item 5 e também saiu: `LEFT_POST_VISIBLE_MAX_T`. Rastreio final: nenhuma outra constante do `DLConfig` está sem uso.

## 3) Testes (executados no Godot 4.5, Xvfb + OpenGL/GL Compatibility, 1280×670)
- Projeto importa sem erros; cena do Desvio Lógico carrega todos os módulos sem erro de script; o modo editor (`--headless --editor`) carrega o `DLEditorGuide` sem erro.
- Prints do Anoitecer e da Noite antes/depois (farol e, com NPCs, lanternas vermelhas): farol discreto, lanternas inalteradas, postes e fundo no lugar.
- **Memória de textura do Desvio Lógico em jogo (Anoitecer): 47,7 MB → 21,6 MB (−26,1 MB)**, medida com `RenderingServer.get_rendering_info(RENDERING_INFO_TEXTURE_MEM_USED)` na base 0.16.9 contra esta versão.
- **Não testado:** navegador/itch.io e aparelho real (nem FPS). Conferir no web: tamanho do `.pck` e o visual do fundo a 1920 em telas grandes.
- O GPU deste teste é software (llvmpipe): serve para o visual e para memória, não para desempenho.

## 4) Arquivos alterados
`project.godot` e `scripts/ui/BrandText.gd` (versão), `scenes/minigames/desviologico/`: `DLConfig.gd`, `DesvioLogico.gd`, `DesvioLogico.tscn`, `modules/DLCarLights.gd`, `modules/DLEditorGuide.gd` (novo), `modules/DLSideProps.gd`, `modules/DLTraffic.gd`, `modules/DLWaterFX.gd`; os 5 `.import` dos fundos (`background_dl_{manha,tarde,entardecer,anoitecer,noite}.png.import`); `.gitignore`, `build/.gdignore`; docs.
O Godot gera o `DLEditorGuide.gd.uid` ao abrir o projeto.

## 5) Apagar do projeto (o zip não apaga arquivos)
- A pasta `build/web/` inteira.
- Os 7 documentos soltos da 0.16.9, já reunidos no unificado: `V0_16_9_TUTORIAL_RETRATO_SEM_INVASAO_E_ALINE.md`, `V0_16_9_1_…`, `V0_16_9_2_…`, `V0_16_9_3_…`, `V0_16_9_4_…`, `V0_16_9_5_POSTES_…`, `V0_16_9_6_…` (e, se quiser, `V0_16_9_5_preview_postes.png`).
