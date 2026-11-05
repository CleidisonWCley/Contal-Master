# Desvio Lógico V0.13.8.5 — Correção cirúrgica da colisão do Velox-01

## Objetivo

Corrigir a colisão do Velox-01 depois da atualização em que o carro passou a subir visualmente pela rota e reduzir escala em direção à bifurcação.

A sensação de movimento, avanço de rota e escala do Velox-01 foram preservadas. Esta versão altera apenas a detecção de colisão.

## Problema identificado

A colisão ainda dependia de uma referência de Y fixa próxima à parte inferior da tela. Com o Velox-01 subindo durante os 35 segundos, o carro visual já estava em outra posição, mas a lógica de colisão continuava funcionando bem apenas no início, quando o carro ainda estava embaixo.

## Correção aplicada

- Removida a dependência prática do `collision_y` fixo inferior para causar dano.
- Adicionada função `_npc_can_damage()` para centralizar as regras de dano.
- A colisão agora é calculada por interseção real entre:
  - retângulo visual atual do Velox-01;
  - retângulo visual atual do NPC.
- A hitbox considera posição, pivot e escala atuais do `Control` usando o transform global.
- A margem da hitbox foi ajustada para detectar batidas visíveis sem criar dano fantasma.

## Preservado

- Movimento atual do Velox-01.
- Redução de escala do Velox-01 durante a subida.
- Animação da rota.
- Aceleração inicial.
- Timer após aceleração.
- Tutorial.
- Score e pontuação.
- Pause.
- Postes e pista animada.
- Áudio atual sem alterações.
- Água sem alterações.

## Critério de aceite

A colisão deve funcionar:

- com o Velox-01 na parte inferior;
- com o Velox-01 no meio da subida;
- com o Velox-01 próximo da bifurcação;
- sem quebrar a sensação de movimento já aprovada na V0.13.8.4.
