# Party Pascal — V0.13.2 — Direção Pseudo-3D e Transição Cinemática

## Minigame afetado

- Desvio Lógico

## Objetivo

Refinar o minigame final da campanha para aproximar a experiência de uma corrida arcade retro-futurista, com sensação de avanço, controle de faixas mais confiável, obstáculos em perspectiva e animação cinematográfica na escolha da rota.

## Ajustes implementados

### 1. Controle por faixas mais confiável

O controle agora usa `_input()` para capturar clique/toque antes que camadas de interface possam bloquear a leitura do jogador. Durante a fase de direção:

- clique/toque à esquerda move o carro para a faixa esquerda;
- clique/toque no centro move o carro para a faixa central;
- clique/toque à direita move o carro para a faixa direita.

Também foram mantidos os atalhos de teclado:

- A / seta esquerda: esquerda;
- S / seta baixo / espaço: centro;
- D / seta direita: direita.

### 2. Movimento lateral do carro

O carro agora troca temporariamente para o sprite de curva ao mudar de faixa e retorna ao sprite reto após o deslocamento. Isso reforça visualmente a resposta do controle.

### 3. Sensação de corrida pseudo-3D

O background continua estático, mas a sensação de avanço é reforçada por camadas animadas:

- linhas de pista com movimento;
- marcadores laterais animados;
- vibração/balanço leve do carro;
- água com shimmer/reflexo sutil.

### 4. Obstáculos em perspectiva

Os obstáculos deixam de parecer objetos caindo do céu. Agora eles:

- nascem próximos da região do horizonte da estrada;
- começam menores;
- aumentam conforme se aproximam do carro;
- aceleram visualmente conforme chegam perto;
- seguem o eixo da faixa usando cálculo de perspectiva.

### 5. Aproximação da bifurcação

Ao final do trecho de obstáculos, o carro se aproxima do ponto de decisão em T antes de liberar a escolha entre as rotas A e B.

### 6. Transição cinematográfica de rota

Foram adicionados dois sprites laterais:

- `carro_desvio_lateral_esquerda.png`;
- `carro_desvio_lateral_direita.png`.

Após escolher uma rota:

- o carro faz uma curva inicial;
- troca para o sprite lateral correspondente;
- anda lateralmente pela rota escolhida;
- o cenário escurece suavemente;
- em seguida aparece o feedback pedagógico.

### 7. Ordem dos cenários preservada

A ordem oficial segue:

1. Amanhecer
2. Manhã
3. Tarde
4. Entardecer
5. Anoitecer
6. Noite

## Critérios de aceite

A atualização está correta se:

- o carro responde ao clique/toque nas três faixas;
- o carro desliza visualmente para esquerda, centro e direita;
- os obstáculos surgem em perspectiva e não parecem cair do céu;
- o cenário transmite sensação de avanço mesmo com background estático;
- o carro se aproxima da bifurcação antes da decisão;
- ao escolher A/B, o carro usa a animação lateral da rota escolhida;
- o feedback pedagógico continua funcionando;
- os 6 cenários continuam em ordem.
