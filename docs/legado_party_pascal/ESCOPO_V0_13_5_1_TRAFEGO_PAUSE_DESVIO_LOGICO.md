# Desvio Lógico V0.13.5.1 — Tráfego avançado e menu de pause

## Objetivo

Refinar a V0.13.5 corrigindo o padrão de tráfego dinâmico, adicionando uma abertura segura em todos os modos e incluindo um menu de pause funcional para o último minigame da campanha.

## Alterações aplicadas

### 1. Travessia segura inicial

Todos os modos agora começam com uma travessia inicial segura usando apenas 1 carro NPC:

- Fácil: carro inicial mais tranquilo.
- Normal: carro inicial intermediário.
- Difícil: carro inicial mais rápido, mas ainda justo.

Após essa abertura, cada dificuldade entra no seu ritmo próprio de tráfego.

### 2. Correção do loop de faixa única

O gerador de combos agora possui memória da última faixa usada e força alternância dirigida entre esquerda e direita.

Isso evita o problema em que o modo difícil ficava gerando carros repetidamente em apenas uma faixa.

### 3. Padrões por dificuldade

#### Fácil

- Mantém acessibilidade.
- Ganha duplas ocasionais.
- Ganha trios raros.
- Mantém margem de reação maior.

#### Normal

- Tráfego mais dinâmico.
- Duplas mais presentes.
- Trios aparecem algumas vezes por desafio.
- Mantém brechas seguras.

#### Difícil

- Tráfego mais intenso.
- Duplas frequentes.
- Trios mais frequentes.
- Alternância obrigatória de faixa nos combos.
- Mantém espaço de desvio para evitar dano inevitável.

### 4. Regras de segurança

O sistema mantém proteção contra:

- carros colados demais;
- bloqueio simultâneo das duas faixas;
- spawn impossível de reagir;
- repetição infinita na mesma faixa;
- repetição imediata da mesma cor de NPC.

### 5. Menu de pause

Foi adicionado um botão `PAUSE` no canto superior direito.

Ao pausar, um card central exibe:

- Continuar jogo;
- Finalizar minigame;
- Voltar ao menu principal.

### 6. Comportamento dos botões do pause

#### Continuar jogo

Fecha o menu e retoma a gameplay.

#### Finalizar minigame

- No modo campanha: preserva a pontuação acumulada até o momento e chama `GameManager.complete_current_stage(0)`, seguindo para a cutscene final por se tratar do último minigame.
- No modo livre: retorna para a tela de seleção de minigames.

#### Voltar ao menu principal

Retorna para a tela inicial em qualquer modo.

## Arquivos alterados

```text
scenes/minigames/DesvioLogico.gd
docs/ESCOPO_V0_13_5_1_TRAFEGO_PAUSE_DESVIO_LOGICO.md
```

## Critérios de aceite

- O início de cada desafio tem apenas 1 carro seguro.
- O modo difícil não fica preso em apenas uma faixa.
- Os combos alternam entre esquerda e direita.
- O Normal apresenta duplas e trios com frequência moderada.
- O Difícil apresenta tráfego intenso sem fechar brechas de desvio.
- O botão `PAUSE` aparece no canto superior direito.
- O menu de pause pausa timer, NPCs, props e input de gameplay.
- Finalizar minigame preserva os pontos acumulados.
