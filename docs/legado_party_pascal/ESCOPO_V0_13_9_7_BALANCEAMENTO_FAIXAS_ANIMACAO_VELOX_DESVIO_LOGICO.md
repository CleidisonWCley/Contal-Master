# Party Pascal V0.13.9.7 — Balanceamento de faixas + animação lateral do Velox-01

## Objetivo

Refinar o Desvio Lógico após a consolidação do Traffic Director da V0.13.9.6, corrigindo a concentração excessiva de NPCs em uma única faixa e melhorando a sensação visual do Velox-01 ao trocar de faixa.

## Ajustes no Traffic Director

- Adicionado controle de pressão recente por faixa.
- Cada faixa agora possui memória de uso recente.
- Combos de 2 ou 3 carros pesam mais na pressão da faixa utilizada.
- A faixa oposta ganha prioridade quando uma faixa foi usada demais.
- Uma faixa que passou tempo demais sem desafio também ganha prioridade.
- Mantida a lógica de single/double/triple com fila temporal, sem retorno do bug de carros nascendo no céu.
- Mantida a quebra de padrão do Traffic Director, mas sem permitir repetição excessiva na mesma faixa.

## Regras principais

- Se a última sequência veio pela esquerda, a próxima tende à direita.
- Se a última sequência veio pela direita, a próxima tende à esquerda.
- Se uma faixa acumular pressão demais, a outra é forçada quando for seguro.
- Se uma faixa ficar sem NPC por tempo demais, ela passa a ser priorizada.
- A lógica de segurança ainda impede spawns impossíveis ou próximos demais do Velox-01.

## Animação lateral do Velox-01

- A troca de faixa agora usa o sprite reto com inclinação leve do carro.
- O Velox-01 inclina cerca de 5 graus para o lado da troca e retorna suavemente ao centro.
- Isso substitui a sensação de capô virando por uma curva arcade mais orgânica.
- A inclinação é resetada ao finalizar o tutorial, iniciar aceleração e entrar na gameplay real.
- Corrigido o caso em que a animação podia ficar travada após a transição do tutorial.

## Preservado

- Áudio atual.
- Música e volumes ajustados pelo usuário.
- Água.
- Postes.
- Score.
- Pause.
- Perguntas.
- Pontuação.
- Chegada natural à bifurcação.
- Colisão visual.
- Correção de combos da V0.13.9.6.

## Arquivo modificado

- `scenes/minigames/DesvioLogico.gd`
