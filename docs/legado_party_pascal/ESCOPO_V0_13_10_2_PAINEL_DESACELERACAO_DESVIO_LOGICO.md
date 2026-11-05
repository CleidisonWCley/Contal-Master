# Party Pascal V0.13.10.2 — Ajuste fino do painel + desaceleração final

## Objetivo

Refinar a apresentação final do minigame Desvio Lógico sem mexer em áudio, água, perguntas, pontuação, colisão ou Traffic Director.

A versão concentra-se em dois pontos:

1. dar mais espaço interno ao painel do Bionix/velocímetro;
2. fazer a chegada à bifurcação acontecer com desaceleração natural antes da pergunta aparecer.

## Ajustes no painel do Bionix

- O painel permanece no canto inferior direito.
- O card foi levemente ampliado para dar mais respiro ao velocímetro.
- O arco do velocímetro foi reduzido e reposicionado.
- O número de km/h e o texto `km/h` foram reenquadrados.
- A barra de integridade foi realinhada dentro do painel.
- O estilo ciberfuturista/transparente foi preservado.

## Desaceleração final

Quando os novos NPCs deixam de nascer na reta final:

1. o Bionix continua avançando naturalmente para a bifurcação;
2. o velocímetro começa a cair gradualmente;
3. o cenário acompanha a desaceleração;
4. a velocidade chega em `0 km/h`;
5. o mundo fica parado;
6. o Bionix fica centralizado próximo da placa;
7. só então a pergunta e as opções A/B aparecem.

## Regras mantidas

- Spawns continuam bloqueados na reta final.
- O Traffic Director não foi alterado.
- O áudio e os volumes atuais foram preservados.
- O sistema de colisão não foi alterado.
- A chegada natural à bifurcação foi preservada, apenas suavizada com parada final.

## Arquivos alterados

- `scenes/minigames/DesvioLogico.gd`
- `docs/ESCOPO_V0_13_10_2_PAINEL_DESACELERACAO_DESVIO_LOGICO.md`
