# Party Pascal V1.0.1 — Correções de campanha, roleta e distribuição de conteúdo

## Objetivo

Corrigir inconsistências detectadas nos testes da versão V1.0, mantendo o escopo estável do jogo e sem adicionar sistemas grandes novos.

## Correções aplicadas

### 1. Som da Roleta de Risco

O efeito sonoro `roleta` agora fica restrito à cena **Roleta de Risco**. Telas finais de outros minigames usam feedback sonoro comum, evitando que o som da roleta toque ao finalizar desafios normais da campanha.

### 2. Perseguicao

A Perseguicao foi estabilizada com apenas duas opções por incidente:

- AÇÃO A;
- AÇÃO B.

A lógica garante que a resposta correta sempre esteja presente e que apenas uma alternativa incorreta seja usada, evitando quebra lateral em 1280x720.

### 3. Roleta de Risco

A roleta principal foi redesenhada em fatias estilo pizza, com distribuição mais clara e cores inspiradas no cenário da própria roleta:

- magenta;
- azul/violeta;
- roxo;
- roxo escuro.

Também foram reforçados o aro dourado, as divisórias e o centro da roleta.

### 4. Banco de perguntas

O seletor do banco dinâmico passou a considerar também conteúdo recente por dificuldade, reduzindo repetição cruzada entre minigames durante a mesma sessão.

A lógica agora evita, quando possível:

- repetir IDs recentes do mesmo minigame;
- repetir tópicos usados recentemente em outros minigames;
- repetir termos/conceitos centrais usados recentemente.

Quando não há conteúdo suficiente, o sistema relaxa a filtragem para não quebrar a partida.

### 5. Forca Tecnica

A nomenclatura oficial voltou para **Forca Tecnica**, sem cedilha, nos menus e gerenciadores.

### 6. Batalha Naval

A distribuição de ameaças passou a respeitar a configuração por dificuldade:

- Fácil: 8 ameaças no tabuleiro;
- Normal: 6 ameaças;
- Difícil: 5 ameaças.

Isso deixa o modo Fácil com mais chances de acerto e recupera a sensação de tabuleiro menos vazio.

### 7. Transições

A densidade de ícones nas transições foi reduzida. O fundo agora usa menos símbolos, com menor alpha e distribuição mais espaçada, evitando efeito de chuva visual.

## Fora do escopo

- Não foi adicionado pedido de nome ao finalizar campanha.
- Não houve alteração no sistema de pontuação local.
- Não foram adicionados novos minigames.
- Não houve mudança de ordem da campanha.

## Critérios de aprovação

- O som da roleta não toca fora da Roleta de Risco.
- Perseguicao mostra somente duas opções.
- Roleta de Risco fica visualmente mais próxima do cenário de referência.
- Perguntas e assuntos repetidos aparecem com menor frequência entre minigames.
- Forca Tecnica aparece sem cedilha.
- Batalha Naval Fácil tem mais ameaças distribuídas no tabuleiro.
- Transições ficam visualmente mais moderadas.
