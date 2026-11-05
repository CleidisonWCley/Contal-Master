# Desvio Lógico V0.13.8.8 — Chegada natural à bifurcação

## Objetivo

Refinar a reta final do Desvio Lógico para que o Velox-01 não dê sensação de salto/“boom” ao chegar na placa da bifurcação.

A partir desta versão, quando os spawns de NPCs são bloqueados perto do fim do desafio, o Velox-01 começa a avançar progressivamente para o centro da bifurcação. Ao terminar a rota, o carro já está praticamente alinhado ao meio da placa e apenas faz uma parada curta antes das opções A/B aparecerem.

## Regras aplicadas

- Mantém a zona segura final da V0.13.8.7.
- Mantém o bloqueio de novos NPCs nos últimos segundos da rota.
- Durante essa reta final, o Velox-01 avança verticalmente até a zona da decisão.
- Durante essa reta final, o Velox-01 centraliza horizontalmente de forma gradual.
- A escala do Velox-01 também chega de forma progressiva ao tamanho da decisão.
- A animação de aproximação final foi encurtada e suavizada para funcionar apenas como parada natural.

## O que foi preservado

- Áudio atual do carro.
- Água sem refinamento novo.
- Postes laterais.
- Score e animações de pontuação.
- Pause.
- Tutorial.
- Pontuação.
- Sistema de perguntas.
- Spawns principais dos NPCs.
- Colisão visual da V0.13.8.6/V0.13.8.7.

## Critérios de aceite

- O Velox-01 não deve saltar para a placa no fim do desafio.
- O carro deve chegar ao centro da bifurcação de forma gradual.
- As opções A/B só aparecem depois da parada natural.
- A sensação de tensão da rota final continua, mas a chegada fica mais limpa.
