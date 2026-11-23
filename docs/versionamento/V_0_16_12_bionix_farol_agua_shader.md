# V0.16.12 — Desvio Lógico: Bionix sobe mais, cone do farol curto e água por shader

Base: `contalmaster_ajustes.zip` (0.16.11.1f). Copie os arquivos por cima do projeto mantendo as pastas e reabra o Godot (ele cria o `.uid` do shader). **Exporte o build web de novo.**
Testado no Godot 4.5-stable (Xvfb + GL Compatibility, GPU por software): carrega sem erros, prints e valores conferidos. **Não testado:** navegador real, celular e FPS (o GPU do teste é software).

## 1) Bionix sobe mais rápido e chega perto da bifurcação (`DLConfig.gd`)
**Diagnóstico (medido):** o carro subia de 0.78 até ~0.575 da altura da tela e **ficava parado por volta de 0.57–0.56 entre 35% e 85% do percurso**; só nos últimos ~2 s ia até a parada (0.425). Por isso parecia que ele "andava até a metade da pista".
**Agora** (só constantes; a curva em `_player_car_y_ratio_for_progress` não mudou):
- `CAR_ROUTE_SAFE_HOLD_Y_RATIO` 0.575 → **0.52** (altura que ele alcança na subida).
- `CAR_ROUTE_HOLD_START_BY_DIFFICULTY` 0.64/0.70/0.75 → **0.46/0.52/0.58** (chega lá bem antes).
- `CAR_ROUTE_SAFE_HOLD_DRIFT` 0.018 → **0.025** (segue avançando devagar até a freada final).
- Altura do carro (Normal): 5% → 0.77 · 25% → 0.64 · 50% → 0.52 · 75% → 0.50 · 92% → 0.48 · fim → 0.425.
- **Parada preservada:** freada final, aproximação da placa (`CAR_SIGN_APPROACH_SECONDS`), centralização, velocímetro em 0, pausa de 0,7 s e perguntas continuam como na 0.16.11.1f (parada em 0.425 exatamente aos 22 s).
- **Efeito na jogabilidade (medido):** com o carro mais alto, o NPC leva menos tempo do nascimento até ele: em 0.52 são ~20% a menos que em 0.575 (ex.: NPC de velocidade 180: 2,31 s → 1,84 s). Se ficar difícil, suba `CAR_ROUTE_SAFE_HOLD_Y_RATIO` (0.54, 0.55) ou reduza a velocidade dos NPCs. Se quiser ainda mais perto da bifurcação, desça para 0.50.

## 2) Farol: cone mais curto, mesma largura (`DLConfig.gd`)
- `AURA_CONE_LENGTH` 0.42 → **0.24**. Larguras (`AURA_CONE_NEAR_HALF_W` 0.26 / `FAR_HALF_W` 0.48) **iguais**.
- `AURA_POOL_Y` -0.36 → **-0.16**: a poça acompanha o fim do cone mais curto (senão ficava solta à frente).

## 3) Água por shader no lugar das linhas desenhadas (`DLWaterFX.gd`, `dl_water.gdshader`, `DesvioLogico.gd`, `DLConfig.gd`)
**Antes:** a camada `WaterSurfaceOverlay` desenhava, por redesenho, centenas de `draw_line`/`draw_rect` na CPU, só dentro de uma máscara irregular que cobria **uma parte** do mar (sobrava mar parado). **Agora:** um `ColorRect` com shader na GPU (nenhum comando de desenho por quadro; a CPU só atualiza o tempo).
- O shader **re-amostra a própria textura do fundo** na área do mar: cada linha ondula para o lado em passos de 1 px (visual pixel art, sem borrar), com faixas mais finas perto do horizonte (perspectiva). Brilhos aparecem **só onde o fundo já é claro** (reflexo do sol, da lua e das luzes da cidade) e se concentram na coluna do sol/lua de cada horário. Sem `hint_screen_texture` (instável no WebGL, como o `WebLite` já avisava).
- **Máscara:** é matemática dentro do shader (nada de textura nem asset): o mar é o que está acima/ao lado da reta da grama. Medido nos 6 fundos: a borda grama/mar é a mesma reta (`x = 550 − 1,68·(y − 243)` no palco 1280×720, espelhada à direita). Folga de 9 px até a grama: no teste de diferença entre quadros, nada mudou na grama, mureta ou pista. O mar todo anima (antes só parte).
- **Aparelho fraco** (`WebLite.low_end()`): 1 onda só, amplitude menor e sem brilhos. **Animações desligadas** ou `WATER_EFFECT_QUALITY = 0`: o overlay some e o fundo fica estático.
- Constantes em `DLConfig.gd`: `WATER_WAVE_AMPLITUDE` (1.8; 1.0 sutil, 3.0 forte), `WATER_WAVE_SPEED`, `WATER_SPARKLE` (0 desliga), `WATER_TOP_Y`, `WATER_BOTTOM_Y`, `WATER_EDGE_X0`, `WATER_EDGE_SLOPE`, `WATER_EDGE_MARGIN`. Se a arte do fundo mudar de geometria, ajuste a reta (`EDGE_*`).
- Memória: **nenhuma textura nova**; o shader usa a mesma textura do fundo.
- **Removido:** ~300 linhas de desenho de água em `DLWaterFX.gd` (399 → 114 linhas), `DLConfig.WATER_REDRAW_INTERVAL` e `DEBUG_WATER_POINTS`, e `WebLite.water_density()` / `water_interval()` (não tinham mais uso).

## Versão
`project.godot` (`config/version`) e `BrandText.gd`: **0.16.12**.

## Arquivos modificados
- `project.godot`, `scripts/ui/BrandText.gd`, `scripts/core/WebLite.gd`
- `assets/shaders/dl_water.gdshader` (novo)
- `scenes/minigames/desviologico/DLConfig.gd`, `DesvioLogico.gd`
- `scenes/minigames/desviologico/modules/DLWaterFX.gd`
- `docs/versionamento/CRONOGRAMA_VERSOES.md`, `V_0_16_12_bionix_farol_agua_shader.md`

## Para conferir no navegador
FPS e tamanho do `.pck` no itch.io; água em celular fraco; se o brilho ficou forte demais (`WATER_SPARKLE`); sensação de dificuldade com o carro mais alto na pista.
