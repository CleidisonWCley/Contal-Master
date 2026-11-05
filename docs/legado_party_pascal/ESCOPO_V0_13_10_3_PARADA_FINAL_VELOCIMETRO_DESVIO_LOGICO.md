# Party Pascal V0.13.10.3 — Ajuste da parada final + requadro do velocímetro

## Objetivo

Refinar a chegada do Bionix à bifurcação e ajustar o painel do velocímetro sem alterar áudio, tráfego, perguntas, pontuação, água ou colisão.

## Ajustes aplicados

- Sincronização da parada final: o Bionix agora é fixado no ponto de decisão antes da pergunta aparecer.
- Remoção do avanço aparente com o velocímetro em 0 km/h.
- A etapa de aproximação final agora funciona como uma pausa curta de confirmação, sem tween de avanço do carro.
- Acompanhamento visual do Bionix no fim da rota ficou mais firme para evitar atraso visual durante a desaceleração.
- Remoção do texto superior `BIONIX • VELOCÍMETRO` do painel direito.
- Reenquadramento do velocímetro dentro do painel:
  - arco mais largo;
  - número km/h mais centralizado;
  - texto `km/h` com mais respiro;
  - painel continua no canto inferior direito.

## Preservado

- Áudio e volumes atuais.
- Traffic Director.
- Sistema de perguntas.
- Pontuação.
- Colisão visual.
- Postes.
- Água.
- Tutorial.
- Chegada natural à bifurcação, apenas com correção da parada final.
