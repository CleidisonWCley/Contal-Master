# Desvio Lógico V0.13.8.4 — Reversão da rota quebrada + escala correta do Velox-01

## Objetivo

Corrigir o refinamento da V0.13.8.3 que acabou quebrando o layout da animação de rota, mantendo o comportamento visual que estava melhor na V0.13.8.2 e aplicando apenas a correção necessária de perspectiva do Velox-01.

## Alterações aplicadas

- Restaurada a rota visual da V0.13.8.2:
  - `CAR_DRIVE_END_Y_RATIO` voltou para `0.515`.
  - `CAR_APPROACH_Y_RATIO` voltou para `0.425`.
  - animação de aproximação da bifurcação voltou a usar o timing anterior.
  - animação de saída A/B voltou a usar a escala/timing anterior.
- Removido o comportamento da V0.13.8.3 que forçava o Velox-01 a tamanho fixo durante a aproximação.
- Adicionada escala progressiva do Velox-01 durante a rota:
  - início da rota: escala `1.0`.
  - fim da rota: escala aproximada `0.70`.
- A escala reduz conforme o Velox-01 sobe na estrada, simulando profundidade.
- A lógica dos NPCs continua igual: eles nascem menores e crescem enquanto descem.
- A lógica do Velox-01 agora segue a leitura contrária: ele sobe e reduz tamanho.
- A hitbox do Velox-01 agora considera a escala visual atual, sem alterar a regra original de colisão por faixa/profundidade.

## O que foi preservado

- Aceleração inicial da V0.13.8.2.
- Timer começando apenas depois da aceleração.
- Tutorial.
- Pause.
- Score.
- Sistema de pontuação.
- Postes e efeitos da pista.
- Áudio atual, sem investigação nesta versão.
- Água, sem alteração.
- Bug dos carros do Entardecer em diante, reservado para investigação posterior.

## Critério de aceite

A V0.13.8.4 estará correta quando:

- a animação de rota voltar a se comportar como na V0.13.8.2;
- o Velox-01 não ficar gigante ao subir em direção à bifurcação;
- o Velox-01 reduzir tamanho de forma suave durante os 35 segundos;
- a transição para a bifurcação não gerar o salto/layout quebrado da V0.13.8.3;
- colisões continuarem funcionando considerando a posição e a escala visual atual do carro.
