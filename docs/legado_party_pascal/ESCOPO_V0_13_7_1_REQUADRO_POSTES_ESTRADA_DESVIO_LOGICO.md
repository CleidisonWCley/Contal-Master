# Desvio Lógico V0.13.7.1 — Requadro dos postes esquerdos + trilhas visuais da estrada

## Objetivo

Refinar o visual lateral do minigame sem alterar a estrutura principal da gameplay. A versão concentra as mudanças nos postes do lado esquerdo e no efeito de movimento da estrada.

## Alterações aplicadas

### 1. Postes esquerdos editáveis no Godot

A cena `DesvioLogico.tscn` recebeu novos markers para o caminho do poste esquerdo:

- `SidePropMarkers/PostLeftStart`
- `SidePropMarkers/PostLeftMid`
- `SidePropMarkers/PostLeftEnd`

O script agora lê esses pontos antes de usar qualquer fallback. Com isso, o enquadramento do poste esquerdo pode ser ajustado diretamente no editor do Godot, sem precisar editar valores no script.

### 2. Modelos 2D de preview

Foi adicionado o grupo:

- `SidePropMarkers/LeftPostPreview`

Com três sprites de referência:

- `PostLeftPreviewFar`
- `PostLeftPreviewMid`
- `PostLeftPreviewNear`

Esses previews servem apenas como guia visual para posicionar os markers do poste esquerdo no editor.

### 3. Menos postes esquerdos colados

A lógica de spawn do poste esquerdo foi reforçada:

- poste esquerdo tem intervalo de reciclagem maior que o poste direito;
- o script evita ativar um poste esquerdo enquanto outro ainda está visível;
- o spawn esquerdo usa retry próprio quando há conflito visual;
- o poste esquerdo continua evitando conflito com o ciclista.

### 4. Alternância visual com ciclista

O lado esquerdo passou a alternar melhor entre poste e ciclista. Os horários iniciais foram espaçados e ainda passam por validação no script antes da ativação.

### 5. Efeito animado da estrada refinado

A animação da estrada agora cobre melhor o caminho entre a área de spawn dos NPCs e a zona onde o carro do jogador está andando.

Foram adicionados/refinados:

- linha central animada mais coerente com a perspectiva;
- rastros internos por faixa;
- listras laterais distribuídas da área de spawn até o Velox-01;
- linhas discretas no gramado usando os markers editáveis.

## O que foi preservado

- Sistema de score da V0.13.7;
- animação +pontos/-pontos;
- pause `⏸ Pause`;
- tutorial inicial;
- NPCs coloridos;
- cards laterais;
- HUD superior;
- água sem animação;
- bifurcação e decisão A/B;
- bug dos carros nos cenários Entardecer em diante foi mantido para investigação posterior.

## Arquivos alterados/adicionados

- `scenes/minigames/DesvioLogico.gd`
- `scenes/minigames/DesvioLogico.tscn`
- `docs/ESCOPO_V0_13_7_1_REQUADRO_POSTES_ESTRADA_DESVIO_LOGICO.md`
