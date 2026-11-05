# Desvio Lógico V0.13.6 — Tutorial jogável + correção dos spawns

## Objetivo
Adicionar um tutorial inicial ao Desvio Lógico e corrigir a base do sistema de spawn para remover carros iniciais injustos, reforçar duplas/trios e impedir padrões presos em uma única faixa nos 6 cenários.

## Alterações aplicadas

### 1. Remoção dos carros iniciais injustos
- A lógica antiga de carros iniciais automáticos foi desativada.
- Os carros que surgiam do nada no início da gameplay não interferem mais no início do desafio.
- O timer dos 35 segundos não depende mais dessa abertura antiga.

### 2. Tutorial inicial antes da gameplay real
- Novo fluxo de tutorial antes da primeira rodada:
  - tela introdutória por cerca de 2 segundos;
  - instrução visual para clicar à esquerda e à direita;
  - tutorial prático com um carro vindo pela direita para o jogador clicar à esquerda;
  - tutorial prático com um carro vindo pela esquerda para o jogador clicar à direita.
- O tempo oficial de 35 segundos só começa após o tutorial.
- Os carros do tutorial são seguros e não causam dano.

### 3. Setas visuais animadas
- Adicionados sprites de seta para o tutorial:
  - `tutorial_seta_esquerda.png`
  - `tutorial_seta_direita.png`
- As setas são exibidas pelo script com animação de pulso/deslocamento.

### 4. Correção do bug de rota única
- O gerador de combos foi ajustado para evitar loops presos em uma única faixa.
- Se a faixa alternada não estiver segura para combo, o combo não é forçado para a outra faixa de forma artificial.
- A próxima tentativa aguarda uma brecha real, preservando a alternância entre esquerda/direita.

### 5. Refinamento de duplas e trios
- Duplas e trios agora aparecem próximos o suficiente para serem lidos como sequência.
- Ainda existe distância mínima para evitar carros colados.
- A frequência planejada vale para todos os 6 desafios/cenários.

### 6. Regras preservadas
- Mantém as 5 cores de NPCs da V0.13.5.
- Mantém o pause da V0.13.5.1.
- Mantém HUD superior, cards laterais, placa fixa, postes, ciclista, água sem animação, transição da bifurcação e decisão A/B.

## Arquivos alterados/adicionados
- `scenes/minigames/DesvioLogico.gd`
- `assets/sprites/desvio_logico/tutorial_seta_esquerda.png`
- `assets/sprites/desvio_logico/tutorial_seta_esquerda.png.import`
- `assets/sprites/desvio_logico/tutorial_seta_direita.png`
- `assets/sprites/desvio_logico/tutorial_seta_direita.png.import`
- `docs/ESCOPO_V0_13_6_TUTORIAL_SPAWN_DESVIO_LOGICO.md`

## Critérios de aceite
- O tutorial aparece antes da gameplay real.
- O jogador aprende a clicar para esquerda e direita com dois carros seguros.
- O timer de 35 segundos começa somente após o tutorial.
- Não existem mais carros iniciais injustos surgindo do nada.
- Duplas e trios aparecem nos 6 cenários respeitando frequência e brechas.
- O bug de rota única é reduzido/evitado pela alternância controlada.
