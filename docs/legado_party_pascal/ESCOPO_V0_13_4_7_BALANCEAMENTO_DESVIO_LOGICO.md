# Desvio Lógico V0.13.4.7 — Balanceamento de NPCs e Refinamento dos Props Laterais

## Objetivo

Refinar o comportamento visual e jogável do minigame Desvio Lógico sem alterar a estrutura principal já aprovada: HUD, cenário, transição de decisão, água, gramado, tempo de 35 segundos e lógica das perguntas permanecem intactos.

## NPCs de tráfego

- A velocidade dos carros NPCs foi aumentada para deixar a gameplay mais desafiadora.
- Os NPCs iniciais deixam de sumir no meio da pista: agora continuam o percurso até sair da área inferior da tela.
- O tráfego inicial mantém uma zona de segurança por tempo curto, mas passa a se comportar como tráfego real durante a rodada.
- A distância mínima entre NPCs foi reforçada.
- O spawn evita carros colados na mesma faixa ou muito próximos em faixas opostas.
- A regra de no máximo duas ameaças simultâneas permanece para evitar bloqueios injustos.

## Ciclista lateral

- O ciclista aparece somente no lado esquerdo.
- Existem exatamente duas aparições por rodada.
- As aparições são controladas por tempo, não por reciclagem infinita.
- O movimento continua discreto para não parecer estático, mas foi desacelerado para leitura mais natural.

## Placa de bifurcação em Y

- A placa aparece somente no lado direito.
- Há apenas uma aparição por rodada.
- Ela surge perto da aproximação da decisão, por volta de 28 segundos da rodada.
- O objetivo é sinalizar visualmente que a bifurcação está chegando.

## Postes / balizadores

- Os postes aparecem somente no lado direito.
- A fase inicia com dois postes visíveis:
  - um próximo da bifurcação;
  - outro na parte inferior direita, para ser ultrapassado logo no começo.
- A frequência de reaparição foi reduzida.
- A velocidade dos postes foi reduzida para ficar mais natural.
- O tamanho visual dos postes foi aumentado.
- O sprite do poste foi recortado com menos margem transparente para melhorar a leitura quando escalado no Godot.

## Markers editáveis

O arquivo `DesvioLogico.tscn` agora preserva os markers já posicionados manualmente e adiciona os pontos finais necessários para as trilhas:

```text
SidePropMarkers
├── PostRightStart
├── PostRightEnd
├── CyclistLeftStart
├── CyclistLeftEnd
├── SignLeftStart        # legado visual, ignorado pelo script
├── SignRightStart
└── SignRightEnd
```

## Arquivos alterados

```text
scenes/minigames/DesvioLogico.gd
scenes/minigames/DesvioLogico.tscn
assets/sprites/desvio_logico/props/poste_lateral.png
docs/ESCOPO_V0_13_4_7_BALANCEAMENTO_DESVIO_LOGICO.md
```
