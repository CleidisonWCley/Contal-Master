# Desvio Lógico V0.13.4.10 — Correção de HUD, poste e listras laterais

## Objetivo

Atualização pequena aplicada sobre a V0.13.4.9 para corrigir os últimos problemas visuais observados em teste e adicionar mais sensação de velocidade nas laterais da pista.

## Correções aplicadas

### 1. Saída irregular do poste

- O poste alto agora recicla antes de atravessar a área dos painéis inferiores.
- A escala máxima foi reduzida para evitar que a haste e a luminária fiquem grandes demais na saída.
- Foi adicionado fade no final do percurso do poste.
- A ancoragem pela base foi mantida, sem oscilação vertical.

### 2. HUD superior sem bloco preto

- O fundo retangular preenchido do painel `ROTA ATÉ A DECISÃO` foi removido.
- O HUD superior agora mantém apenas texto, barra, marcadores e carrinho.
- Foram adicionadas sombras discretas no texto e na barra para preservar legibilidade sem cobrir o cenário.

### 3. Painel de rota correta/incorreta mais compacto

- O painel de feedback foi reduzido verticalmente.
- Margens internas e separações foram ajustadas.
- O texto e botão foram levemente reduzidos para evitar corte visual.

### 4. Novas listras laterais na pista

- Foram adicionadas listras discretas de movimento nas laterais esquerda e direita da pista.
- O efeito complementa a sensação de movimento já existente no lado do ciclista e no gramado.
- As linhas são sutis para não competir com os NPCs, carro do jogador ou placa fixa.

## O que permaneceu intacto

- NPCs e balanceamento de tráfego.
- Ciclista lateral.
- Placa fixa de bifurcação.
- Água e brilhos.
- Gramado com linhas discretas.
- Tempo de 35 segundos.
- Sistema de perguntas e decisão.
- Painéis inferiores.
- Transições de rota.

## Arquivos alterados

- `scenes/minigames/DesvioLogico.gd`
- `docs/ESCOPO_V0_13_4_10_CORRECAO_HUD_POSTE_LISTRAS_DESVIO_LOGICO.md`
