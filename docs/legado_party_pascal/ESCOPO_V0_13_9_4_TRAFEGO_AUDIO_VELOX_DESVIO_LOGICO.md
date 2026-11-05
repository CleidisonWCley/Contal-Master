# Party Pascal V0.13.9.4 — Tráfego justo + presença final do Velox-01

## Objetivo

Refinar o Desvio Lógico após a V0.13.9.3, corrigindo situações injustas de spawn dos carros NPCs e aumentando a presença do áudio do Velox-01 sem alterar a música principal aprovada.

## Ajustes de áudio

- A música principal do Desvio Lógico foi preservada como estava.
- O som de aceleração do Velox-01 foi aumentado para ficar mais perceptível.
- O som de motor em loop também foi aumentado para ser ouvido durante a partida.
- O bus do Velox continua sem filtro, evitando o efeito abafado percebido na versão anterior.

Configuração aplicada:

```text
car_acceleration.ogg = -8 dB
car_engine_loop.ogg  = -10 dB
```

## Correção de tráfego preso em uma faixa

Foi adicionada uma alternância mais rígida por sequência de tráfego:

```text
sequência na esquerda → próxima sequência tende à direita
sequência na direita  → próxima sequência tende à esquerda
```

Isso evita que o jogo fique gerando carros repetidamente em uma única faixa nos modos Fácil, Normal e Difícil.

## Proteção contra carros aparecendo do nada

Foi adicionada uma regra de segurança para impedir que NPCs nasçam perto demais do Velox-01.

A distância mínima considera:

- posição atual do Velox-01;
- faixa atual do jogador;
- dificuldade atual;
- se o NPC nasce na mesma faixa ou na faixa oposta.

A mesma faixa exige maior distância de segurança, reduzindo colisões injustas.

## Abertura mais segura dos desafios

O primeiro spawn real após a aceleração continua sendo único e seguro. A V0.13.9.4 reforça essa lógica com controle de distância em relação ao jogador, especialmente no Normal e no Difícil.

## Rebalanceamento leve do Fácil

O modo Fácil foi acelerado um pouco mais para ficar apenas um nível abaixo do Normal, sem parecer lento demais.

Ajustes aplicados:

```text
world_speed: 540
npc_speed: 255
spawn_base: 2.58
motion_factor: 1.56
```

O Fácil continua mais tolerante porque mantém maior quantidade de colisões permitidas.

## O que não foi alterado

- música principal e perfil sonoro aprovado;
- efeitos da música;
- água;
- postes;
- score;
- pause;
- tutorial;
- chegada natural à bifurcação;
- perguntas;
- sistema de pontuação;
- layout visual atual.

## Critérios de aceite

A atualização está correta quando:

- NPCs alternam melhor entre faixas;
- carros não nascem perto demais do Velox-01;
- início do Normal e Difícil fica mais justo;
- Fácil fica menos lento, mas ainda abaixo do Normal;
- aceleração e motor em loop ficam mais audíveis;
- música principal permanece igual ao perfil aprovado.
