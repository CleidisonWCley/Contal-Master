# V0.9.1 — Hotfix de Cutscenes, Configurações e Animações

## Objetivo

Corrigir os problemas encontrados após os testes da V0.9.0 e aproximar o comportamento das cutscenes e menus da versão Pygame.

## Ajustes aplicados

### Cutscenes

- O avanço das cutscenes agora usa `_input()` em vez de `_unhandled_input()`.
- Clique do mouse agora avança a fala corretamente.
- Toque de celular (`InputEventScreenTouch`) agora também avança a fala.
- Espaço e Enter continuam funcionando.
- Botões Menu/Pular foram reposicionados em uma área fixa no topo direito.
- Botões Menu/Pular deixam de esticar verticalmente.
- Clique em Menu/Pular não avança fala por acidente.
- O som de clique continua restrito a botões explícitos.

### Menu Principal

- Adicionadas partículas animadas leves inspiradas no menu Pygame.
- Logo recebeu pulso visual discreto.
- As animações respeitam a nova opção de configurações.

### Configurações

- Adicionadas partículas animadas leves na tela de configurações.
- Tela cheia agora é aplicada imediatamente ao marcar/desmarcar.
- O texto do botão foi melhorado para:
  - `Tela cheia: ATIVADA`
  - `Tela cheia: DESATIVADA`
- F11 também alterna tela cheia dentro das configurações.
- Adicionada opção `Animações visuais`.

### SettingsManager

- Adicionada configuração persistente:

```json
"animations_enabled": true
```

- Adicionados métodos:
  - `set_animations_enabled(value)`
  - `animations_enabled()`
  - `toggle_fullscreen()`

## Arquivos alterados

```text
scripts/SettingsManager.gd
scenes/menus/main_menu.gd
scenes/menus/Settings.gd
scenes/menus/Settings.tscn
scenes/cutscenes/CutsceneIntro.gd
scenes/cutscenes/StageTransition.gd
scenes/cutscenes/CutsceneFinal.gd
```

## Observação

Esta versão não altera os minigames. O foco é fluxo de cutscene, acessibilidade de clique/toque, configurações e efeitos visuais leves.
