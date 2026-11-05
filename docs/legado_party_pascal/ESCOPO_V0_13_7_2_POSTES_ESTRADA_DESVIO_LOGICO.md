# Desvio Lógico V0.13.7.2 — Recalibração dos postes + animação visual da pista

## Objetivo

Refinar o cenário do minigame Desvio Lógico sem mexer na lógica principal dos carros NPCs, na pontuação, no pause, na água ou na decisão A/B.

Esta versão organiza os postes laterais como parte fixa do cenário em profundidade e reforça a sensação de movimento da pista.

---

## 1. Animação da pista mais perceptível

A pista recebeu elementos prateados animados por cima do asfalto para reforçar a sensação de velocidade.

A animação agora cobre visualmente o trecho entre:

- o ponto onde os carros NPCs nascem no horizonte;
- o meio da estrada;
- a zona próxima ao Velox-01.

Foram reforçados:

- linha central animada;
- rastros internos por faixa;
- listras laterais;
- pequenas placas/traços prateados sobre a pista.

O efeito continua sendo apenas visual e não interfere na colisão dos NPCs.

---

## 2. Novo padrão dos postes laterais

Os postes deixaram de funcionar como spawns aleatórios e passam a seguir um padrão fixo de 3 profundidades por lado:

1. poste distante, próximo ao nascimento dos NPCs;
2. poste intermediário, no meio do mapa;
3. poste próximo, perto de ser ultrapassado.

Esse padrão é aplicado nos dois lados:

- lado esquerdo;
- lado direito.

---

## 3. Proporção entre postes esquerdo e direito

Os postes laterais agora são posicionados em pares proporcionais:

- poste esquerdo distante com poste direito distante;
- poste esquerdo médio com poste direito médio;
- poste esquerdo próximo com poste direito próximo.

A velocidade dos postes também foi estabilizada para manter o alinhamento entre os dois lados.

Quando um poste próximo sai da tela, ele volta para o fundo, mantendo o ciclo contínuo de 3 postes.

---

## 4. Markers editáveis no Godot

A cena recebeu markers editáveis para ajustar os pontos diretamente no editor:

- `PostLeftStart`
- `PostLeftMid`
- `PostLeftEnd`
- `PostRightStart`
- `PostRightMid`
- `PostRightEnd`

Também foram mantidos/adicionados previews 2D no `.tscn`, usando sprites já existentes, sem criação de imagens novas:

- `LeftPostPreview`
- `RightPostPreview`

Esses previews servem apenas como referência visual para editar o posicionamento no Godot.

---

## 5. Relação com o ciclista

O ciclista não bloqueia mais a existência do poste esquerdo.

A nova regra visual é:

- poste fica atrás;
- ciclista passa na frente.

Isso é feito pela ordem de desenho: postes são desenhados primeiro, ciclista depois.

---

## 6. Tutorial sem postes laterais

Os postes e o ciclista não aparecem durante o tutorial inicial.

O tutorial fica mais limpo para o jogador focar em:

- setas;
- instrução de clique;
- carros tutorial.

Depois que o tutorial termina, os postes entram normalmente na gameplay real.

---

## Arquivos modificados

- `scenes/minigames/DesvioLogico.gd`
- `scenes/minigames/DesvioLogico.tscn`
- `docs/ESCOPO_V0_13_7_2_POSTES_ESTRADA_DESVIO_LOGICO.md`

---

## Fora do escopo desta versão

Não foram alterados nesta versão:

- bug dos carros nas fases de Entardecer em diante;
- animação da água;
- sistema de pontuação;
- pause;
- tutorial;
- perguntas;
- decisão A/B.
