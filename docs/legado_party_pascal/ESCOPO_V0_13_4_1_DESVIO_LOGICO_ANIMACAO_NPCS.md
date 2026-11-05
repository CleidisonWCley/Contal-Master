# V0.13.4.1 — Desvio Lógico: Direção em 2 Faixas, NPCs e Animação

## Objetivo
Refinar o minigame **Desvio Lógico** para combinar melhor com os novos cenários costeiros em pixel art, melhorando o controle do carro, a leitura dos NPCs, a sensação de velocidade e os efeitos visuais de movimento.

## Alterações principais

- Movimento do jogador migrado de **3 faixas** para **2 faixas**: esquerda e direita.
- O carro do jogador agora inicia na **faixa direita**.
- A faixa central deixa de ser posição jogável e passa a funcionar como referência visual da pista.
- NPCs foram rebalanceados para surgirem mais cedo, maiores e mais lentos.
- Adicionados sprites de NPCs baseados no design do Velox-01:
  - `carro_npc_vermelho.png`
  - `carro_npc_amarelo.png`
- Adicionado tráfego inicial ao começo da rodada para criar sensação de ultrapassagem.
- A animação de escolha entre Rota A e Rota B foi reduzida para uma inclinação curta, evitando que o carro saia da pista ou vá para a água.
- A sensação de subida/descida foi reforçada com micro zoom e deslocamento vertical do background.
- Adicionados coqueiros laterais desenhados pelo Godot em loop nas áreas verdes, sem colisão, para reforçar velocidade e passagem pelo cenário.
- A animação de água permanece ativa nos 6 cenários com brilhos e linhas sutis.

## Critérios de aceite

- O carro alterna apenas entre esquerda e direita.
- O carro não sai da pista na animação de escolha da rota.
- NPCs são identificáveis no horizonte antes de alcançar o jogador.
- NPCs usam visual mais fiel ao carro do jogador.
- Há sensação de aceleração com carros já presentes no início.
- Coqueiros passam nas laterais verdes sem interferir na pista.
- O minigame mantém o HUD e fluxo da V0.13.4.
