# V0.13.1 — Refino de Movimento do Desvio Lógico

## Objetivo

Refinar a sensação de avanço do minigame **Desvio Lógico**, deixando o carro, os obstáculos e o cenário mais sincronizados visualmente antes da bifurcação.

## Ajustes aplicados

### 1. Ordem dos cenários

A sequência dos 6 desafios foi consolidada nesta ordem:

1. Amanhecer
2. Manhã
3. Tarde
4. Entardecer
5. Anoitecer
6. Noite

O HUD agora também mostra o nome do cenário atual junto da dificuldade e do número do desafio.

### 2. Sensação de avanço do carro

O carro continua andando automaticamente, mas agora o cenário ganhou efeitos de movimento:

- linhas de pista animadas;
- pequenos traços de velocidade;
- oscilação leve no carro durante a direção;
- transição de aproximação antes da bifurcação.

Isso cria a sensação de que o carro está avançando pelo cenário, mesmo com o background estático.

### 3. Obstáculos com perspectiva

Os obstáculos deixaram de nascer fora da tela como se estivessem caindo do céu.

Agora eles:

- aparecem próximos da região do horizonte/estrada;
- começam menores;
- crescem conforme se aproximam do carro;
- seguem a posição da faixa usando perspectiva;
- ficam mais coerentes com a estrada do background.

### 4. Aproximação da bifurcação

Antes da decisão A/B, o carro agora se desloca para uma posição mais próxima da bifurcação.

Fluxo atualizado:

1. trecho de direção com obstáculos;
2. carro se aproxima do ponto de decisão;
3. opções A e B aparecem;
4. jogador escolhe esquerda ou direita;
5. carro usa sprite de curva e dobra para a rota escolhida;
6. feedback pedagógico aparece.

## Arquivos alterados

- `scenes/minigames/DesvioLogico.gd`
- `docs/ESCOPO_V0_13_1_REFINO_DESVIO_LOGICO.md`
