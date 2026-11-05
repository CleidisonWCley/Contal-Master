# Desvio Lógico V0.13.8.7 — Zona segura final + controle de tensão dos NPCs

## Objetivo

Refinar a reta final do Desvio Lógico sem perder a tensão criada pelo avanço do Velox-01.

A V0.13.8.6 deixou a colisão visual funcionando melhor, mas quando o Velox-01 chega muito alto na pista o espaço útil para desviar dos NPCs fica apertado demais. A V0.13.8.7 cria uma curva de avanço mais justa:

```text
início → seguro
meio → tensão crescente
perto do fim → tensão alta
últimos segundos → folga controlada antes da bifurcação
```

## Alterações aplicadas

### 1. Zona segura alta do Velox-01

O Velox-01 agora não sobe de forma totalmente direta até a altura final. A progressão foi dividida em três etapas:

```text
1) sobe da parte inferior até uma altura alta, mas jogável;
2) segura por um tempo nessa zona com pequeno avanço gradual;
3) avança para mais perto da bifurcação apenas na reta final.
```

Isso preserva a sensação de aproximação da bifurcação, mas reduz a chance de o jogador ficar sem espaço real de desvio.

### 2. Tensão por dificuldade preservada

A zona segura começa em momentos diferentes por dificuldade:

```text
Fácil   → zona segura começa mais cedo
Normal  → zona segura intermediária
Difícil → zona segura começa mais tarde
```

Valores usados:

```text
Fácil   → segura a partir de 64% da rota
Normal  → segura a partir de 70% da rota
Difícil → segura a partir de 75% da rota
```

O difícil continua mais tenso, porque o Velox-01 chega na zona alta mais tarde e mantém pressão por mais tempo.

### 3. Avanço final controlado

O avanço final até a bifurcação começa perto do fim:

```text
Fácil   → avanço final a partir de 87%
Normal  → avanço final a partir de 90%
Difícil → avanço final a partir de 92%
```

Assim a chegada na placa continua natural, sem deixar o jogador preso muito cedo em uma região alta demais.

### 4. Bloqueio de novos spawns nos últimos segundos

Novos NPCs deixam de nascer perto do fim da rota.

Critérios aplicados:

```text
Fácil   → bloqueia novos spawns a partir de 88% da rota ou últimos 4.2s
Normal  → bloqueia novos spawns a partir de 90% da rota ou últimos 3.5s
Difícil → bloqueia novos spawns a partir de 92% da rota ou últimos 2.8s
```

Os NPCs já existentes continuam descendo normalmente. A pista esvazia de forma natural, criando folga antes da decisão A/B.

### 5. Escala do Velox acompanha a profundidade visual

A escala do Velox-01 agora acompanha a altura visual real do carro, não apenas o tempo da rota. Isso evita que ele fique pequeno demais enquanto estiver segurando na zona segura.

## Preservado

Não foram alterados:

```text
áudio
água
postes
score
pause
tutorial
pontuação
sprites
HUD
sistema de perguntas
colisão visual da V0.13.8.6
sensação geral de movimento da V0.13.8.6
```

## Critérios de aceite

A versão estará correta quando:

```text
- o Velox-01 não subir alto demais cedo demais;
- o modo difícil continuar transmitindo tensão;
- os últimos segundos antes da bifurcação tiverem folga controlada;
- novos NPCs pararem de nascer perto do final;
- NPCs já presentes continuarem normalmente;
- a chegada na decisão A/B continuar natural;
- o visual e a colisão da versão anterior não forem quebrados.
```
