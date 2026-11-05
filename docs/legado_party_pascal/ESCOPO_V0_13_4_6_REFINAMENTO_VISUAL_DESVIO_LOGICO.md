# Desvio Lógico V0.13.4.6 — Refinamento visual com props laterais

## Objetivo
Substituir os coqueiros por objetos laterais mais coerentes com o cenário costeiro/futurista do Desvio Lógico, mantendo a edição visual por Marker2D no Godot.

## Decisões consolidadas
- Coqueiros removidos da lógica visual.
- Postes/balizadores aparecem apenas no lado direito.
- Ciclistas aparecem apenas no lado esquerdo.
- Placas de bifurcação em Y aparecem raramente nos dois lados.
- A água deixa de usar linhas fortes; ficam apenas brilhos e micro listras sutis.
- O gramado ganha linhas discretas de movimento usando as trilhas dos markers.
- Os objetos laterais não causam colisão e servem apenas como sensação de ultrapassagem/movimento.

## Assets adicionados
- `assets/sprites/desvio_logico/props/poste_lateral.png`
- `assets/sprites/desvio_logico/props/placa_bifurcacao_y.png`
- `assets/sprites/desvio_logico/props/ciclista_lateral.png`

## Markers editáveis no Godot
A cena `DesvioLogico.tscn` agora possui:

```text
DesvioLogico
├── BackgroundPreview
└── SidePropMarkers
    ├── PostRightStart
    ├── PostRightEnd
    ├── CyclistLeftStart
    ├── CyclistLeftEnd
    ├── SignLeftStart
    ├── SignLeftEnd
    ├── SignRightStart
    └── SignRightEnd
```

## Como ajustar visualmente
Abra `scenes/minigames/DesvioLogico.tscn`.

- Para postes: mova `PostRightStart` e `PostRightEnd` sobre o gramado direito.
- Para ciclistas: mova `CyclistLeftStart` e `CyclistLeftEnd` sobre a lateral esquerda, fora da pista.
- Para placas: mova `SignLeftStart`, `SignLeftEnd`, `SignRightStart` e `SignRightEnd`.

Os objetos são animados pelo script entre o ponto `Start` e o ponto `End`.

## Regras visuais
- Postes: frequentes, pequenos e discretos.
- Ciclistas: ocasionais, com leve oscilação para não parecerem parados.
- Placas: raras, alternadas entre os lados, reforçando o tema de bifurcação.
- Água: brilho e micro detalhes, sem linhas longas atravessando o mar.
- Gramado: linhas discretas acompanhando a perspectiva dos markers.

## Arquivos alterados/adicionados
- `scenes/minigames/DesvioLogico.gd`
- `scenes/minigames/DesvioLogico.tscn`
- `assets/sprites/desvio_logico/props/poste_lateral.png`
- `assets/sprites/desvio_logico/props/poste_lateral.png.import`
- `assets/sprites/desvio_logico/props/placa_bifurcacao_y.png`
- `assets/sprites/desvio_logico/props/placa_bifurcacao_y.png.import`
- `assets/sprites/desvio_logico/props/ciclista_lateral.png`
- `assets/sprites/desvio_logico/props/ciclista_lateral.png.import`

## Critérios de aceite
- Os postes aparecem somente no lado direito.
- Os ciclistas aparecem somente no lado esquerdo.
- As placas aparecem nos dois lados de forma rara.
- Os objetos seguem os markers editáveis no Godot.
- A água fica mais limpa, com brilho e micro listras.
- As linhas de movimento do gramado reforçam velocidade sem poluir o cenário.
