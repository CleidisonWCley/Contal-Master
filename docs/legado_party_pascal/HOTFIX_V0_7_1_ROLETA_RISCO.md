# V0.7.1 — Hotfix Roleta de Risco

## Objetivo
Corrigir os primeiros ajustes visuais e de ritmo do minigame Roleta de Risco.

## Ajustes aplicados

- Corrigida a roleta invisível.
  - O desenho saiu do `_draw()` do nó principal e foi movido para uma camada própria `WheelCanvas`.
  - A roleta agora fica acima do fundo/dimmer e abaixo da UI.

- Reforçado o desenho da roleta.
  - Borda dourada.
  - Base escura.
  - Setores com contraste maior.
  - Divisórias douradas.
  - Sombra da roleta.

- Corrigido vazamento dos nomes no overlay de resultado.
  - Os textos dos setores são escondidos quando aparece o resultado.
  - O overlay ficou mais escuro para cobrir o fundo claro.

- Giro ajustado para ficar mais tenso.
  - Velocidade inicial maior.
  - Desaceleração geral mais lenta.
  - Nova etapa de tensão com parada devagar antes do resultado.

## Arquivo alterado

- `scenes/minigames/RoletaRisco.gd`
