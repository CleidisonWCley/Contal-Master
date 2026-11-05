# Desvio Lógico V0.13.8.3 — Colisão e avanço orgânico do Velox-01

## Objetivo

Esta atualização refina o comportamento do Velox-01 durante a subida gradual até a bifurcação, sem mexer no áudio. O foco é corrigir colisões que não estavam sendo detectadas durante o avanço, reduzir o salto final até a placa e impedir que o carro do jogador pareça crescer conforme sobe na estrada.

## Ajustes aplicados

### 1. Colisão acompanhando a posição real do Velox-01

A detecção de colisão agora considera a posição visual atual do Velox-01 durante o avanço da rota.

Antes, o NPC dependia de uma zona fixa de colisão mais baixa na tela. Isso fazia o carro do jogador não receber dano em alguns momentos enquanto estava mais acima na estrada.

Agora:

- a faixa vertical de colisão acompanha o centro atual do Velox-01;
- a hitbox do jogador usa a posição visual atual;
- o NPC só causa dano quando entra na área real do carro;
- o alcance foi ampliado com cuidado para registrar colisões visíveis sem criar dano fantasma.

### 2. Avanço maior até a bifurcação

O ponto final da subida do Velox-01 durante os 35 segundos foi ajustado para ficar mais próximo da bifurcação.

Resultado esperado:

- menos salto visual ao entrar na fase de decisão;
- avanço mais orgânico;
- sensação mais clara de que o carro realmente percorreu a estrada.

### 3. Escala proporcional do Velox-01 durante a subida

O Velox-01 não deve crescer enquanto avança para a bifurcação.

Agora ele reduz levemente de tamanho conforme sobe na estrada, evitando a sensação de ficar gigante em relação aos NPCs e à perspectiva da pista.

A regra ficou:

- na parte baixa da tela, mantém o tamanho base;
- ao avançar para a bifurcação, reduz de forma leve e progressiva;
- no momento da aproximação, não recebe tween de escala para crescer;
- a saída pela rota A/B continua usando redução visual própria da animação final.

### 4. Áudio preservado

Nenhum ajuste de áudio foi feito nesta versão.

A investigação do som do Velox-01 fica registrada para uma próxima atualização separada.

## Arquivo modificado

- `scenes/minigames/DesvioLogico.gd`

## Critérios de aceite

A versão está correta quando:

- o Velox-01 recebe dano normalmente durante a subida;
- colisões visíveis com NPCs são registradas;
- o carro avança mais perto da bifurcação antes da decisão;
- o salto final até a placa fica menor;
- o Velox-01 não cresce visualmente durante o avanço;
- áudio, tutorial, score, pause, postes, pista e demais sistemas continuam como na V0.13.8.2.
