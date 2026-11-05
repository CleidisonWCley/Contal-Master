# HOTFIX V0.6.1 — Batalha Naval UI

## Objetivo

Corrigir o corte visual da área inferior da Batalha Naval em telas menores, causado pelo conjunto de título grande, ícones, painel do tabuleiro e texto de ajuda.

## Alterações aplicadas

Arquivo alterado:

```text
scenes/minigames/BatalhaNaval.gd
```

Ajustes principais:

- Redução das margens verticais da área segura.
- Redução do espaçamento geral do layout.
- Redução dos ícones do título de `62x62` para `44x44`.
- Redução da fonte do título de `54` para `40`.
- Redução do painel do tabuleiro de `560x560` para `450x450`.
- Redução das células do grid de `96x96` para `78x78`.
- Redução dos espaçamentos internos do grid.
- Texto de ajuda encurtado para ocupar menos altura.
- Botão Voltar reduzido levemente.

## Resultado esperado

A grade/tabela da Batalha Naval deve caber melhor na tela, evitando corte na parte inferior em resoluções menores ou janelas reduzidas.
