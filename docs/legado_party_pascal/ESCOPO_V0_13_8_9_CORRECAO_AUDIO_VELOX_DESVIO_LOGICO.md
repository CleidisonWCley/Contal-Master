# Desvio Lógico V0.13.8.9 — Correção do áudio do Velox-01

## Objetivo

Corrigir o problema em que os efeitos do Velox-01 não ficavam audíveis durante o minigame Desvio Lógico, especialmente com a música do cenário tocando.

## Diagnóstico aplicado

Os arquivos de áudio existem no projeto:

```text
assets/sounds/efeitos/car_acceleration.wav
assets/sounds/efeitos/car_engine_loop.wav
```

O problema estava mais relacionado à integração dos sons do Velox-01 com o sistema global de áudio do projeto. O `AudioManager.gd` só reconhecia efeitos curtos tradicionais, como clique, correto, errado, explosão e roleta. O motor do Velox-01 precisava de suporte a SFX em loop, controle de pausa/retomada e redução temporária da música para abrir espaço no mix.

## Alterações realizadas

### AudioManager.gd

- Registrados os efeitos:
  - `car_acceleration`
  - `car_engine_loop`
- Criado suporte a efeitos sonoros em loop.
- Adicionadas funções para:
  - tocar SFX contínuo;
  - parar SFX contínuo;
  - pausar/retomar SFX contínuo;
  - alterar pitch;
  - alterar volume;
  - aplicar ducking na música.
- O áudio em loop usa o bus `Master` de forma segura, evitando dependência de um bus `SFX` inexistente no projeto atual.
- A música pode ser reduzida temporariamente por `set_music_duck()` e restaurada com `clear_music_duck()`.

### DesvioLogico.gd

- O áudio do Velox-01 passou a usar o `AudioManager` quando ele está disponível.
- Os players locais foram mantidos apenas como fallback.
- Durante a aceleração:
  - `car_acceleration` toca em loop;
  - a música do minigame recebe ducking.
- Após a aceleração:
  - o som de aceleração para;
  - `car_engine_loop` entra em loop;
  - a música continua levemente reduzida para o motor ficar audível.
- Ao pausar:
  - o motor é pausado;
  - a música volta temporariamente ao volume normal.
- Ao continuar:
  - o motor é retomado;
  - o ducking volta a ser aplicado.
- Ao sair, finalizar, falhar ou voltar ao menu:
  - todos os loops do Velox-01 são interrompidos;
  - o volume da música é restaurado.

## Arquivos alterados

```text
scripts/AudioManager.gd
scenes/minigames/DesvioLogico.gd
```

## Arquivo adicionado

```text
docs/ESCOPO_V0_13_8_9_CORRECAO_AUDIO_VELOX_DESVIO_LOGICO.md
```

## Observação de teste

É recomendado testar dentro do Godot com a música do Desvio Lógico ativa. O comportamento esperado é:

1. tutorial termina;
2. aceleração inicia com som audível;
3. música baixa um pouco;
4. loop do motor entra após a aceleração;
5. pause pausa o motor;
6. sair do minigame para todo som do Velox-01.
