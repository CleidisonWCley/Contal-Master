# Party Pascal V0.13.9 — Refinamento Sonoro do Desvio Lógico

## Objetivo

Refinar a experiência sonora do minigame Desvio Lógico após a consolidação da música nova e dos efeitos do Velox-01 em `.ogg`.

A versão V0.13.9 tem dois focos:

1. deixar o som do motor em loop mais perceptível durante a partida;
2. aplicar um perfil sonoro especial na música principal para reforçar a sensação lo-fi, futurista, mágica e impactante do minigame.

## Ajustes no som do Velox-01

O som de aceleração continua sendo usado na arrancada inicial, mas o motor em loop foi aumentado para ficar mais próximo da aceleração, ainda um pouco mais baixo.

Configuração aplicada no `DesvioLogico.gd`:

```gdscript
const ENGINE_ACCELERATION_VOLUME_DB := -12.0
const ENGINE_LOOP_VOLUME_DB := -14.0
```

Comportamento esperado:

- aceleração audível durante a arrancada;
- motor em loop perceptível durante a direção;
- motor abaixo da música principal, sem dominar a mixagem;
- sons locais do Velox-01 continuam usando `.ogg`.

## Perfil especial da música do Desvio Lógico

Foi criado no `AudioManager.gd` um perfil exclusivo para a música `desvio_logico`.

Quando a música do Desvio Lógico toca, o `AudioManager` cria em tempo de execução um bus chamado:

```text
DesvioMusic
```

Esse bus recebe efeitos leves para melhorar a textura sonora sem afetar os outros minigames.

Efeitos aplicados:

- `AudioEffectLowPassFilter` leve para suavizar agudos agressivos;
- `AudioEffectReverb` discreto para dar profundidade e sensação mágica;
- `AudioEffectStereoEnhance` sutil para ampliar a música.

Também foi aplicado um offset de volume exclusivo da música do Desvio Lógico:

```gdscript
const DESVIO_MUSIC_VOLUME_OFFSET_DB := -3.0
```

## Segurança da implementação

A alteração do bus é feita em tempo de execução, sem alterar `project.godot`.

Quando outra música é tocada, o `AudioManager` volta o player para o bus `Master` e remove o offset de volume do Desvio Lógico.

## Arquivos alterados

```text
scripts/AudioManager.gd
scenes/minigames/DesvioLogico.gd
assets/sounds/musica/desvio_logico.ogg.import
docs/ESCOPO_V0_13_9_REFINAMENTO_SONORO_DESVIO_LOGICO.md
```

## O que não foi alterado

- gameplay;
- colisão;
- NPCs;
- postes;
- água;
- score;
- pause visual;
- tutorial;
- perguntas;
- chegada natural à bifurcação.

## Critérios de aceite

A versão estará correta quando:

- a música do Desvio Lógico continuar clara e marcante;
- a música ganhar textura mais futurista/lo-fi/mágica;
- o motor em loop do Velox-01 for perceptível durante a corrida;
- a aceleração continuar audível na arrancada;
- o som do motor não abafar a música;
- os efeitos do bus não afetarem outros minigames;
- nenhum áudio do Velox vazar ao sair do minigame.
