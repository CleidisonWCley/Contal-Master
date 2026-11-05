# V0.8.0 — Cutscenes da História e Ajustes de Fluxo

## Objetivo

Consolidar o fluxo narrativo do Party Pascal no Godot após a migração dos minigames.

## Entregas

- Cutscene inicial refeita com páginas narrativas, Pascal animado, efeito de máquina de escrever, partículas, botão de pular e fade.
- Cutscene de transição entre fases criada para a campanha.
- Cutscene final refeita em atos: fala final do Pascal, pontuação, créditos e tela final.
- Roleta de Risco removida do Modo Livre e mantida apenas como rodada bônus da campanha.
- Tela inicial atualizada para usar `background_main.png`.
- Seleção de modo atualizada para usar `game_modo.png`.
- Configurações mantida usando `game_modo.png`.

## Fluxo esperado da campanha

Menu Principal → Seleção de Modo → Cutscene Inicial → Transição de Fase → Minigame → ... → Cutscene Final.

## Observação

Este patch altera apenas arquivos locais de cenas, scripts e documentação. Não substitui o projeto inteiro.
