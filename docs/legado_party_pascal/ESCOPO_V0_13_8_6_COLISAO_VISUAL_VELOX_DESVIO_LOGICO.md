# Desvio Lógico V0.13.8.6 — Colisão visual real do Velox-01

## Objetivo
Corrigir a colisão dos NPCs com o Velox-01 depois que o carro do jogador sobe visualmente em direção à bifurcação.

## Problema identificado
Na V0.13.8.5, a colisão funcionava melhor no início da pista, quando o Velox-01 ainda estava na parte inferior. Conforme o carro subia, os NPCs passavam visualmente pelo carro sem causar dano.

A causa provável era dupla:

- o tempo de `grace` dos NPCs ainda estava longo demais para a nova posição do Velox;
- a colisão podia perder o cruzamento entre frames quando o NPC descia rápido e o Velox estava mais alto.

## Correções aplicadas

### 1. Redução do grace dos NPCs reais
O grace deixou de funcionar como uma proteção longa e passou a ser apenas uma proteção curta contra spawn instantâneo.

Novos valores:

- NPC comum: `0.18s`
- primeiro NPC seguro: `0.48s`

Carros do tutorial continuam sem causar dano.

### 2. Colisão por retângulo visual atual
A hitbox do Velox-01 continua sendo calculada pela posição e escala visual reais do sprite.

### 3. Colisão por varredura vertical dos NPCs
Agora o NPC considera a área entre a posição do frame anterior e a posição atual. Isso evita que um NPC rápido atravesse o Velox entre dois frames sem registrar dano.

### 4. Sem mudança visual
Esta versão não altera:

- movimento do Velox-01;
- escala visual;
- sensação de velocidade;
- pista;
- postes;
- tutorial;
- score;
- pause;
- áudio;
- água.

## Resultado esperado

- colisão funcionando na parte inferior;
- colisão funcionando no meio da subida;
- colisão funcionando perto da bifurcação;
- NPC encostou visualmente no Velox → dano;
- NPC passou longe → sem dano fantasma.
