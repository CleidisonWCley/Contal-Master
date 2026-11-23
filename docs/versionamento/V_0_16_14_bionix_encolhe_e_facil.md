# V0.16.14 — Bionix encolhe ao subir, tráfego do Fácil e variedade de faixas

Base: 0.16.13. Copie por cima do projeto e reexporte o web. Testado no Godot 4.5 (prints + simulação do jogo real sem render). **Não testado:** navegador/celular.

## 1) Tamanho do Bionix acompanha a subida (`DLConfig.gd`, `DesvioLogico.gd`)
**Diagnóstico:** a escala ia de 1,0 a só 0,70 e **parava de encolher** na altura 0.515 (metade da subida); depois só fazia um pulo para 0,66 na parada. Com o carro subindo até 0.425, ele ficava grande demais em relação à pista e aos NPCs.
**Agora:** a escala é **contínua do início até a parada**: `PLAYER_CAR_FAR_ROUTE_SCALE` 0,70 → **0,50** e `PLAYER_CAR_DECISION_SCALE` 0,66 → **0,50** (iguais: sem pulo). O progresso de profundidade passou a usar a altura da parada (`_car_decision_stop_y_ratio`) em vez de `CAR_DRIVE_END_Y_RATIO` (removida). 0,50 acompanha o tamanho dos NPCs na mesma altura. Para encolher menos: 0,60; mais: 0,45.
Efeito na jogabilidade: o retângulo de colisão é o visual, então o carro menor desvia com mais folga. Se quiser compensar, suba `PLAYER_CAR_FAR_ROUTE_SCALE`.

## 2) Fácil e variedade de faixas (`DLConfig.gd`, `DLTraffic.gd`)
Causas no Fácil: (a) o espaçamento mínimo entre carros era grande para a velocidade lenta e **forçava revezar as faixas** (E D E D); (b) as vagas de onda contavam **carros que já passaram do Bionix**, então duplas quase nunca cabiam.
- **Vagas:** `_active_threat_count()` agora conta só quem ainda não passou do Bionix; carros saindo da tela não ocupam vaga. Novo teto de segurança de desempenho: `DIRECTOR_MAX_VISIBLE_NPCS` = 6.
- **Fácil mais ativo:** intervalo 1,80 → **1,50 s**; espaçamento mesma faixa 0,185 → 0,165 e entre faixas 0,215 → 0,185; chance de dupla ×0,80 → ×0,90; limite de seca 5,8 → **5,4 s**.
- **Variedade:** o 2º carro da dupla vai para a faixa oposta em 40% das vezes (antes 55%), então mais duplas na mesma faixa em sequência.

Simulação (8 partidas por linha, jogador parado/aleatório/que desvia):
| | Antes (0.16.13) | Agora |
|---|---|---|
| Fácil: duplas por partida | 0 | 1,5 a 2,1 |
| Fácil: carros seguidos na mesma faixa | 2% (revezava sempre) | 27% a 41% |
| Fácil: carros por partida | 7 a 9 | 8,5 a 9 |
| Normal / Difícil: mesma faixa seguida | 25–29% | 27–31% |
| NPCs vivos na parada | 0 | 0 |
| Fácil: maior seca numa faixa | 4,5 s | 5,5 a 7 s (pior caso) |
Trade-off honesto: no Fácil a seca de uma faixa pode chegar a ~7 s no pior caso (os carros são lentos e o limite de segurança é maior). Baixar `DIRECTOR_MAX_LANE_GAP` do Fácil de 5,4 para 4,8 foi testado: reduz pouco a seca e volta a revezar as faixas (mesma faixa seguida cai para 16–30%), então foi revertido.

## Arquivos
`project.godot`, `scripts/ui/BrandText.gd` (0.16.14), `scenes/minigames/desviologico/DLConfig.gd`, `DesvioLogico.gd`, `modules/DLTraffic.gd`, `docs/versionamento/CRONOGRAMA_VERSOES.md` e este arquivo.
