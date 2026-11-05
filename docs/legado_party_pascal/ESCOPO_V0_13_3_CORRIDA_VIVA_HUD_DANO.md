# Party Pascal — V0.13.3

## Desvio Lógico: Corrida Viva e HUD de Dano

### Objetivo

Refinar o minigame final **Desvio Lógico** para reforçar a sensação de corrida arcade, mantendo os backgrounds estáticos como arte-base e usando camadas animadas em script para simular avanço, tráfego e profundidade.

### Decisões principais

- Manter 3 faixas jogáveis reais: esquerda, centro e direita.
- Não expandir o jogador para toda a largura visual da estrada.
- Ocupar laterais e áreas excedentes com movimento, marcadores e carros NPC.
- Usar o cenário estático como base visual e criar a sensação de movimento por overlays.
- Encerrar o minigame se a integridade do veículo chegar a 0.

### Ajustes implementados

- Tempo de direção aumentado por dificuldade:
  - Fácil: 60 segundos por desafio.
  - Normal: 75 segundos por desafio.
  - Difícil: 90 segundos por desafio.
- HUD passou a exibir progresso/tempo restante da rota.
- Cards de feedback e finalização ficaram mais translúcidos para preservar a leitura do cenário.
- Controle por clique/toque reforçado com uma camada de 3 áreas invisíveis.
- Alcance visual das faixas laterais foi levemente ampliado.
- Linhas de pista, marcadores laterais, raios de velocidade e água animada reforçam a ilusão de movimento.
- Obstáculos seguem a lógica de pseudo-3D:
  - nascem perto do horizonte;
  - começam menores;
  - crescem ao se aproximar;
  - ficam mais opacos perto do carro;
  - aceleram visualmente com a profundidade.
- Carros NPC foram adicionados como obstáculos orgânicos/tráfego:
  - `carro_npc_01.png`
  - `carro_npc_02.png`
- Os carros NPC podem receber rótulos técnicos como BUG, 404, WARN, ERR, NULL e LAG.
- HUD de dano foi adicionado no canto inferior direito:
  - mostra um mini carro;
  - partes ficam vermelhas conforme a integridade cai;
  - estado crítico pisca e exibe aviso.
- Condição de falha crítica:
  - se a integridade chegar a 0, o minigame termina imediatamente;
  - a tela final informa que o veículo entrou em falha crítica.
- Animação lateral da decisão foi alongada e mantida dentro de uma área mais segura do cenário.

### Critérios de aceite

A atualização está correta se:

- O carro continua usando 3 faixas reais.
- O jogador consegue clicar/tocar nas faixas esquerda, centro e direita.
- O trecho de direção dura mais tempo e exibe progresso.
- O cenário parece mais vivo por causa dos overlays animados.
- Os obstáculos não parecem cair do céu.
- Carros NPC aparecem na pista como tráfego/obstáculo.
- O HUD de dano aparece no canto inferior direito.
- O HUD de dano muda conforme a integridade diminui.
- O minigame encerra quando a integridade chega a 0.
- Cards continuam legíveis, mas deixam o cenário aparecer melhor.
- A transição lateral após escolher A/B fica mais longa e natural.
