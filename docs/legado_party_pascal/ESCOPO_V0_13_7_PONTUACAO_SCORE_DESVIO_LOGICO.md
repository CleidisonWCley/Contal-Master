# Desvio Lógico V0.13.7 — Sistema inteligente de pontuação e correções

## Objetivo

Esta versão adiciona pontuação inteligente ao Desvio Lógico, exibe o score acumulado do jogador durante o minigame, mostra feedback visual animado de pontos ganhos/perdidos e reforça a correção dos spawns iniciais injustos.

## Pontuação

### Rota correta ou incorreta

- Fácil: rota correta +30, rota errada -25.
- Normal: rota correta +40, rota errada -35.
- Difícil: rota correta +50, rota errada -45.

### Chegada à bifurcação

- Fácil: chegou +5, perdeu antes da bifurcação -20.
- Normal: chegou +10, perdeu antes da bifurcação -40.
- Difícil: chegou +15, perdeu antes da bifurcação -60.

A pontuação é aplicada diretamente ao ScoreManager para preservar o acumulado real do jogador durante a campanha ou modo livre.

## HUD de score

Foi adicionado um card translúcido no canto superior esquerdo mostrando o score acumulado atual do jogador.

Quando há alteração de pontos, aparece um feedback animado ao lado do score, como +30 ou -25, com leve subida e fade.

## Correção dos carros iniciais injustos

A transição entre tutorial e gameplay real agora limpa explicitamente os obstáculos antes de iniciar o timer real. O primeiro spawn real volta a ser uma abertura segura controlada, impedindo combos ou carros residuais logo no início.

## Postes no lado esquerdo

Foi adicionado um sprite de poste esquerdo espelhado. Os postes esquerdos usam a trilha lateral esquerda e possuem controle para não aparecerem ao mesmo tempo que o ciclista.

## Pause

O botão de pause agora usa o texto oficial: `⏸ Pause`.

O card de pause ficou mais translúcido, preservando leitura sem pesar visualmente.

## Arquivos alterados/adicionados

- `scenes/minigames/DesvioLogico.gd`
- `assets/sprites/desvio_logico/props/poste_lateral_esquerdo.png`
- `assets/sprites/desvio_logico/props/poste_lateral_esquerdo.png.import`
- `docs/ESCOPO_V0_13_7_PONTUACAO_SCORE_DESVIO_LOGICO.md`
