# V0.13.0 — Desvio Lógico

## Objetivo

Adicionar o minigame final da campanha: **Desvio Lógico**, um jogo de direção em estilo arcade/pixel art onde o jogador controla o carro Velox-01, desvia de obstáculos e escolhe entre duas rotas técnicas.

## Regras principais

- Minigame final do modo campanha.
- Também disponível no Modo Livre.
- 6 desafios por partida.
- Cada desafio usa um background diferente, simulando avanço da jornada: amanhecer, manhã/meio-dia, tarde, entardecer, anoitecer e noite.
- O jogador controla o carro por clique/toque em 3 faixas: esquerda, centro e direita.
- Antes da bifurcação, obstáculos aparecem na estrada.
- A cada desafio, a intensidade dos obstáculos aumenta.
- A dificuldade geral altera velocidade, tamanho e frequência dos obstáculos.
- No final do trecho, o jogador escolhe uma rota em T:
  - esquerda = alternativa A;
  - direita = alternativa B.
- Após a escolha, o carro anima a curva usando sprite específico.
- O feedback pedagógico explica a decisão correta ou incorreta.

## Recursos adicionados

- Cena: `scenes/minigames/DesvioLogico.tscn`
- Script: `scenes/minigames/DesvioLogico.gd`
- Sprites:
  - `assets/sprites/desvio_logico/carro_desvio_reto.png`
  - `assets/sprites/desvio_logico/carro_desvio_esquerda.png`
  - `assets/sprites/desvio_logico/carro_desvio_direita.png`
- Música mapeada: `assets/sounds/musica/desvio_logico.ogg`
- Banco dinâmico: `desvio_logico` com 30 perguntas por dificuldade.

## Integrações

- `GameManager.gd`: adiciona Desvio Lógico como última fase da campanha e no modo livre.
- `AudioManager.gd`: mapeia a música `desvio_logico`.
- `MenuMinigames.gd` e `MenuMinigames.tscn`: adiciona botão no Modo Livre.
- `StageTransition.gd`: adiciona estilo, subtítulo e partículas temáticas da transição.
- `DynamicQuestionBank.gd`: adiciona banco próprio para decisões A/B.

## Critérios de aceite

- O minigame aparece no modo livre.
- O minigame entra depois do STOP na campanha.
- A música `desvio_logico.ogg` toca no minigame.
- Os 6 backgrounds são usados em sequência.
- O carro muda de faixa por clique/toque.
- Os obstáculos reduzem a integridade ao colidir.
- A bifurcação permite escolher A ou B.
- O carro usa sprite de curva para esquerda/direita.
- O feedback mostra explicação pedagógica objetiva.
- Ao final dos 6 desafios, o jogo conclui a fase e segue o fluxo normal.
