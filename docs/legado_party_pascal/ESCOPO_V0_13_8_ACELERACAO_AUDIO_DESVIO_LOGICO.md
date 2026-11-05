# Desvio Lógico V0.13.8 — Aceleração inicial e áudio do Velox-01

## Objetivo

Adicionar sensação real de partida ao Desvio Lógico: o Velox-01 não começa mais em alta velocidade. Cada desafio entra em uma etapa curta de aceleração antes do timer oficial começar.

## Sons identificados em assets/sounds/efeitos

A versão atual já contém os efeitos do Velox-01 em:

- `assets/sounds/efeitos/car_acceleration.wav`
- `assets/sounds/efeitos/car_engine_loop.wav`

A V0.13.8 adiciona/organiza os arquivos `.import` desses efeitos e usa os sons diretamente no minigame.

## Fluxo atualizado da rodada

1. Tutorial inicial continua antes da gameplay real.
2. Após o tutorial, o Velox-01 começa parado.
3. Entra o estado de aceleração inicial.
4. Cenário, postes, ciclista e efeitos prateados da pista começam quase parados.
5. A velocidade visual aumenta progressivamente.
6. Ao fim da aceleração, o timer de 35 segundos começa.
7. Só depois disso entram os spawns reais de NPCs.

## Regra do timer

O timer de 35 segundos só começa quando a aceleração inicial termina. Isso evita punir o jogador durante a apresentação visual da arrancada.

## Novo estado técnico

Foi adicionado o estado:

```gdscript
const STATE_ACCELERATION := "acceleration"
```

Esse estado fica entre o tutorial e o `STATE_DRIVE`.

## Duração da aceleração por dificuldade

- Fácil: cerca de 2.55s
- Normal: cerca de 2.30s
- Difícil: cerca de 2.05s

O Difícil acelera mais rápido, mas ainda não começa instantaneamente em alta velocidade.

## Áudio

### `car_acceleration.wav`

- Toca uma vez durante a arrancada.
- Volume base: aproximadamente `-13 dB`.
- Pitch por dificuldade:
  - Fácil: `0.96`
  - Normal: `1.00`
  - Difícil: `1.08`

### `car_engine_loop.wav`

- Entra quando a aceleração termina.
- Fica em loop durante a direção real.
- Volume base: aproximadamente `-6 dB`.
- Pitch por dificuldade:
  - Fácil: `0.95`
  - Normal: `1.05`
  - Difícil: `1.15`

## Pause e saída

- Pausar congela o áudio de aceleração ou motor.
- Continuar retoma o áudio.
- Finalizar minigame, voltar ao menu, chegar à decisão ou falhar para os sons do Velox-01.

## Efeitos visuais da estrada

Os elementos prateados da pista agora respeitam a aceleração:

- início: baixa opacidade e pouco movimento;
- meio da aceleração: movimento crescente;
- velocidade máxima: efeitos nítidos e rápidos.

## Segurança de gameplay

Durante a aceleração:

- não há spawn real de NPCs;
- não há combos;
- não há dano inevitável;
- obstáculos do tutorial são limpos antes da direção real.

## Arquivos envolvidos

- `scenes/minigames/DesvioLogico.gd`
- `assets/sounds/efeitos/car_acceleration.wav`
- `assets/sounds/efeitos/car_acceleration.wav.import`
- `assets/sounds/efeitos/car_engine_loop.wav`
- `assets/sounds/efeitos/car_engine_loop.wav.import`
- `docs/ESCOPO_V0_13_8_ACELERACAO_AUDIO_DESVIO_LOGICO.md`
