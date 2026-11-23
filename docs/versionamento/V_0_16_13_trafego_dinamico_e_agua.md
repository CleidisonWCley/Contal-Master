# V0.16.13 — Desvio Lógico: tráfego dinâmico de NPCs e água visível em todos os fundos

Base: 0.16.12. Copie por cima do projeto mantendo as pastas e reexporte o web. Testado no Godot 4.5 (simulação sem render do jogo real + prints; GPU por software). **Não testado:** navegador, celular, FPS.

## 1) Por que os NPCs paravam de nascer na metade do percurso (erro da 0.16.12)
A regra antiga de "folga do jogador" exigia que o ponto de nascimento ficasse **0,22 da tela acima do Bionix**. Na 0.16.12 o carro passou a subir mais; medido: a partir de **~38% do percurso** (centro do carro em y≈420→360 px) nenhum ponto de nascimento passava na regra e o tráfego parava até a parada. A regra era por distância, então só funcionava com o carro baixo.

## 2) Diretor dinâmico de tráfego (`DLTraffic.gd` reescrito, constantes `DIRECTOR_*` e `SPAWN_*` no `DLConfig.gd`)
Substitui as ondas fixas por sacolas de padrões (`TRAFFIC_COUNT_TEMPLATES`) e a regra de 3 carros.
- **Ondas de 1 ou 2 carros. Nunca 3.** Chance de dupla por horário (`DIRECTOR_PAIR_CHANCE_BY_ROUND`, 18% → 55%) × dificuldade; só depois de 20% do percurso. O 2º carro da dupla nasce quando o 1º já andou o espaçamento mínimo (antes a dupla muitas vezes era recusada e sumia), na faixa oposta (55%) ou na mesma, em sequência.
- **Mais frequentes:** intervalo médio entre ondas Fácil 1,80 s · Normal 1,38 s · Difícil 1,10 s, encolhendo a cada horário e sorteado entre 0,78× e 1,30× (sem ritmo fixo). Espaçamentos mínimos entre carros reduzidos ~10%.
- **Sem padrão decorável:** a faixa é **sorteada com pesos**, sem sequência pré-definida. Peso extra para a faixa onde o jogador está e mais ainda quanto mais tempo ele fica parado nela (`PLAYER_LANE_BIAS`, `DWELL_BIAS`) → quem fica parado recebe carro; quem troca de faixa é acompanhado. A faixa sorteada **espera a vez** até nascer (senão o espaçamento fazia as faixas alternarem sempre: E D E D…).
- **Os dois lados sempre têm carro:** nenhuma faixa passa `DIRECTOR_MAX_LANE_GAP` (Fácil 5,8 s · Normal 4,2 s · Difícil 3,6 s) sem receber, e no máximo `DIRECTOR_MAX_SAME_LANE_STREAK` = 2 carros seguidos na mesma faixa.
- **Folga por tempo, não por distância** (`SPAWN_MIN_REACTION_SECONDS`: Fácil 1,10 s · Normal 0,90 s · Difícil 0,66 s até o centro do Bionix; na faixa oposta ×0,8). Funciona com o carro alto na pista. Os valores foram calibrados com o tempo real de viagem do NPC no Godot (ex.: Normal, 105 px = 1,05 s).
- **Últimos carros saem de vista antes da parada:** antes de nascer, cada NPC é **simulado** com a desaceleração final: ele precisa passar do Bionix antes da centralização e sair da tela pelo menos `DIRECTOR_EXIT_MARGIN_SECONDS` (0,5 s) antes de a pergunta abrir. O prazo é calculado, não fixo (último nascimento medido: ~14–17 s de 22 s). A desaceleração/parada do carro **não mudou**.
- **Abertura:** os dois primeiros carros continuam lentos e seguros, mas a ordem de faixa agora é sorteada (antes sempre direita → esquerda).

### Simulação (jogo real sem render, passo fixo de 60 fps, 6–8 partidas por linha)
| Cenário | Carros/partida | 1º nascimento | Último nascimento | Último NPC visível | NPCs vivos na parada | Maior seca numa faixa | Colisões (bot que desvia) |
|---|---|---|---|---|---|---|---|
| Fácil, horário 2 | 7,6 | 0,8 s | 14,0 s | 18,5 s | 0 | 6,1 s | 0 |
| Normal, horário 4 | 11,0 | 0,6 s | 15,3 s | 18,9 s | 0 | 6,3 s | 0 |
| Normal, horário 6 | 11,5 | 0,5 s | 15,4 s | 19,1 s | 0 | 5,4 s | — |
| Difícil, horário 2 | 15,5 | 0,7 s | 16,9 s | 19,7 s | 0 | 4,2 s | 0,9 |
| Difícil, horário 6 | 17,4 | 0,5 s | 17,1 s | 19,8 s | 0 | 4,5 s | 3,0 |
Observações honestas: (a) a "maior seca" inclui o início da partida e vale para o pior caso das partidas; a média fica em ~4 s; (b) o bot desvia sem tempo de reação humano; (c) repetição na mesma faixa em ondas seguidas fica em ~20–30% (mais que isso exigiria afrouxar o espaçamento entre carros); (d) no Fácil raramente há duplas, porque o limite de 3 carros ao mesmo tempo ocupa os "slots".

## 3) Água: efeito visível também em água escura (`dl_water.gdshader`, `DLConfig.gd`)
Diagnóstico: o shader só deslocava os pixels do próprio fundo; em água escura e lisa (ex.: lado esquerdo do Entardecer) o deslocamento não aparece, e o brilho só ocorria onde o fundo já era claro (lado do sol). Resultado: um lado parecia parado e o outro, cheio de elementos.
- **Faixas suaves de luz/sombra** (`wave_band`) que vêm em direção à câmera, aplicadas em **toda** a água, com ganho maior na água escura. É o que anima as áreas lisas.
- **Brilhos pontuais mais fracos** (teto 0,55 → 0,32; `WATER_SPARKLE` 0,35 → 0,26) e deslocamento menor (`WATER_WAVE_AMPLITUDE` 1,8 → 1,4) para o lado do sol não "poluir".
- Aparelho fraco (`WebLite.low_end()`): só uma faixa suave, sem brilhos.
- Teste: comparação com e sem o overlay no mesmo instante, nos 6 horários, em áreas do mar de cada lado: esquerda e direita ficam na mesma faixa de intensidade (diferença média entre lados de até ~27% (antes até ~39%); a intensidade em si varia por horário, porque depende da cor do fundo).

## Código removido
Sacolas/ondas fixas e `TRAFFIC_COUNT_TEMPLATES`, `TRAFFIC_MIN_INTERVAL_MULT`, `SPAWN_HORIZON_SAFETY_*`, regra de 3 carros e ordem fixa da abertura.

## Arquivos
`project.godot`, `scripts/ui/BrandText.gd`, `assets/shaders/dl_water.gdshader`, `scenes/minigames/desviologico/DLConfig.gd`, `DesvioLogico.gd`, `modules/DLTraffic.gd`, docs (`CRONOGRAMA_VERSOES.md`, este arquivo).

## Para conferir jogando
Sensação de frequência/dificuldade em cada nível; se o limite de 2 carros seguidos na mesma faixa basta; brilho da água em celular fraco. Ajustes rápidos no `DLConfig`: `DIRECTOR_INTERVAL`, `DIRECTOR_PAIR_CHANCE_BY_ROUND`, `DIRECTOR_MAX_LANE_GAP`, `SPAWN_MIN_REACTION_SECONDS`, `WATER_*`.
