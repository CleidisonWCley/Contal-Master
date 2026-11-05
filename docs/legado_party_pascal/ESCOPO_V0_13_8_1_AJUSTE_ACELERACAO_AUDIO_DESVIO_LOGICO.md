# Desvio Lógico V0.13.8.1 — Ajuste de aceleração e áudio do Velox-01

## Objetivo

Refinar a atualização V0.13.8 após teste prático, corrigindo a sensação de aceleração muito rápida e aumentando a presença sonora do Velox-01 durante a gameplay.

## Ajustes aplicados

### 1. Aceleração inicial mais longa

A aceleração inicial deixa de durar cerca de 2 segundos e passa a ter pelo menos 5 segundos.

Duração por dificuldade:

- Fácil: 5.80s
- Normal: 5.40s
- Difícil: 5.00s

O timer de 35 segundos continua começando apenas depois da aceleração terminar.

### 2. Som de aceleração em loop durante a arrancada

Como o arquivo `car_acceleration.wav` é menor que a nova duração da aceleração, ele passa a ser usado em loop durante a fase de arrancada.

Quando a aceleração termina:

1. o som de aceleração para;
2. o som de motor contínuo entra;
3. o timer do desafio começa;
4. a gameplay real libera os spawns.

### 3. Motor contínuo mais audível

O volume do som do motor em loop foi aumentado para ficar perceptível mesmo com a música do mundo tocando.

Também foi reforçado o início do loop com `stop()` + `play()`, evitando casos em que o player ficava em estado inconsistente e não reiniciava corretamente.

### 4. Volume da aceleração aumentado

O som de aceleração também teve volume aumentado para acompanhar melhor a arrancada visual.

## Arquivos alterados

- `scenes/minigames/DesvioLogico.gd`
- `assets/sounds/efeitos/car_acceleration.wav.import`
- `docs/ESCOPO_V0_13_8_1_AJUSTE_ACELERACAO_AUDIO_DESVIO_LOGICO.md`

## Critérios de aceite

- A aceleração inicial dura no mínimo 5 segundos.
- O timer continua parado durante a aceleração.
- O som de aceleração permanece tocando durante toda a arrancada.
- Ao fim da aceleração, o som de motor contínuo entra em loop.
- O motor fica audível mesmo com a música do cenário ativa.
- Pause/finalização continuam pausando ou parando os sons do carro.
