# Desvio Lógico V0.13.4.14 — Correção do LaneClickLayer e Safe Area dos Cards

## Objetivo

Corrigir a suspeita principal da faixa/retângulo escuro que permanecia sobre o cenário e ajustar a posição dos cards inferiores após o redesenho da V0.13.4.13.

## Diagnóstico aplicado

Após a inspeção do `DesvioLogico.gd`, o principal suspeito deixou de ser os cards inferiores e passou a ser o `LaneClickLayer`.

O `LaneClickLayer` usa dois botões gigantes invisíveis para captar cliques/toques nas faixas esquerda e direita. Esses botões cobrem a região jogável da tela, de aproximadamente 26% da altura até a base da janela.

O problema estava no estilo visual desses botões: eles usavam `_make_panel_style()` com fundo e borda transparentes, mas essa função adiciona sombra preta por padrão. Na prática, os botões pareciam invisíveis, mas ainda podiam gerar uma sombra/retângulo escuro fantasma sobre o cenário.

## Alterações realizadas

### 1. Botões de faixa 100% invisíveis

Substituído o estilo dos botões do `LaneClickLayer` por `StyleBoxEmpty`.

Estados cobertos:

- `normal`
- `hover`
- `pressed`
- `focus`
- `disabled`
- `hover_pressed`

Também foram zeradas as cores de fonte, por segurança, mesmo os botões estando sem texto.

### 2. Remoção da sombra herdada

Os botões deixaram de usar `_make_panel_style()`, eliminando a sombra preta herdada de `StyleBoxFlat`.

### 3. Safe area inferior

Os dois cards laterais foram levantados:

- `StatusPanel`
- `DamageHUD`

A altura dos cards foi mantida, mas eles ganharam margem inferior maior para não ficarem colados no rodapé da janela.

## O que não foi alterado

- NPCs
- Ciclista
- Postes
- Placa fixa
- HUD superior
- Água
- Gramado
- Listras laterais
- Perguntas
- Tempo de 35 segundos
- Transição da bifurcação
- Lógica de colisão

## Critérios de aceite

A versão será considerada correta se:

- o retângulo/faixa preta fantasma desaparecer ou reduzir drasticamente;
- os botões de clique continuarem funcionando para trocar de faixa/rota;
- os cards inferiores não ficarem mais colados no rodapé;
- o restante do minigame permanecer igual à V0.13.4.13.
