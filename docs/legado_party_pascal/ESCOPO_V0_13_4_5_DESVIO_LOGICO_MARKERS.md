# Party Pascal — Desvio Lógico V0.13.4.5

## Foco da atualização

Esta versão torna o posicionamento dos coqueiros editável visualmente no Godot sem abandonar a animação via script.

## Arquivos alterados

- `scenes/minigames/DesvioLogico.gd`
- `scenes/minigames/DesvioLogico.tscn`

## O que foi adicionado

A cena `DesvioLogico.tscn` agora contém:

- `BackgroundPreview` para enxergar o cenário dentro do editor;
- `SidePropMarkers/PalmLeftStart`;
- `SidePropMarkers/PalmLeftEnd`;
- `SidePropMarkers/PalmRightStart`;
- `SidePropMarkers/PalmRightEnd`.

Esses markers podem ser arrastados visualmente no editor. O script usa esses pontos para animar os coqueiros em linha reta entre início e fim de cada lado.

## Ajustes de gameplay também aplicados

- NPCs passam a nascer mais dentro da estrada.
- Faixas no horizonte ficam menos abertas.
- Ritmo de spawn foi aumentado para funcionar melhor em 35 segundos.
- Velocidade real dos NPCs foi calibrada para mais ultrapassagens sem spawn instantâneo.
- Coqueiros ficaram menores e mais discretos.
- A margem da animação de água foi ampliada para reduzir invasão no gramado.
- O brilho da água foi reforçado.

## Como ajustar os coqueiros no Godot

1. Abra `scenes/minigames/DesvioLogico.tscn`.
2. Use o `BackgroundPreview` como referência visual.
3. Arraste os markers do grupo `SidePropMarkers` para cima da faixa verde do gramado.
4. Rode o minigame e observe o caminho dos coqueiros.
5. Ajuste novamente os markers se necessário.

Os markers não aparecem no jogo final; eles servem como pontos de controle para o script.
