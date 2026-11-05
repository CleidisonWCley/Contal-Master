# V0.9.3 — Hotfix de Loop Infinito das Músicas

## Objetivo

Garantir que as músicas dos menus, cutscenes e minigames fiquem em loop infinito durante a cena.

## Arquivo alterado

```text
scripts/AudioManager.gd
```

## Ajuste aplicado

- `play_music()` agora carrega o áudio como `AudioStream`.
- Antes de tocar, chama `_enable_music_loop(stream)`.
- `_enable_music_loop()` tenta ativar a propriedade `loop` para músicas OGG/MP3.
- Também possui fallback para `loop_mode`, caso algum áudio futuro seja WAV.

## Observação

Esse ajuste afeta apenas músicas tocadas por `AudioManager.play_music()`.
Efeitos sonoros continuam tocando uma vez, como correto.
