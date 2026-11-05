# Party Pascal V1.0.2.5 — Ajustes do STOP, pontuação do Desvio Lógico e teste de máscara d’água

## Objetivo

Aplicar uma atualização focada e compacta em três pontos:

1. melhorar o layout e a lógica visual do minigame STOP;
2. garantir o registro de recorde do Desvio Lógico no modo livre;
3. testar uma máscara transparente de água no Desvio Lógico sem substituir o background estático.

## STOP

- O minigame passa a trabalhar com 6 cards de resposta.
- O layout fica equilibrado em 3 + 3.
- Os rótulos visuais A), B), C), D), E) foram removidos dos cards.
- Os termos ficam centralizados.
- Os atalhos numéricos continuam disponíveis internamente.
- Todas as alternativas continuam respeitando a letra sorteada.
- Apenas uma alternativa permanece correta por rodada.

## Desvio Lógico — pontuação no modo livre

Ao finalizar o Desvio Lógico no modo livre, a pontuação final do minigame passa a ser enviada explicitamente ao sistema de recordes locais.

Regra:

- se a pontuação final for maior que o recorde atual, o recorde é atualizado;
- se for menor ou igual, o recorde anterior é preservado.

## Desvio Lógico — máscara transparente de água

Foi adicionada uma camada de teste chamada `WaterMaskShader`, aplicada sobre o background único.

A máscara:

- fica transparente fora das regiões do mar;
- adiciona apenas cintilação/brilho leve dentro da área de água;
- não substitui o desenho estático da água;
- evita aplicar filtro global sobre estrada, HUD e elementos do cenário.

Caso o resultado visual não fique adequado, o efeito pode ser desligado pela constante `WATER_USE_MASK_SHADER` em `DesvioLogico.gd`, retornando ao efeito desenhado por script.

## Arquivos alterados

- `project.godot`
- `scripts/GameManager.gd`
- `scenes/menus/main_menu.gd`
- `scenes/minigames/Stop.gd`
- `scenes/minigames/DesvioLogico.gd`
- `docs/ESCOPO_V1_0_2_5_STOP_DESVIO_MASCARA_AGUA.md`
