# V0.9.4 — Padronização dos Botões por Script

## Objetivo

Padronizar os botões principais do Party Pascal Godot sem depender de edição manual em cada cena.

## Arquivo central criado

- `scripts/ui/ButtonStyles.gd`

Esse script define estilos reutilizáveis para:

- botão principal;
- botão secundário;
- botão de perigo/sair/pular;
- botão discreto/voltar/menu;
- botão ON/OFF;
- botão de opção.

## Arquivos atualizados

- `scenes/menus/main_menu.gd`
- `scenes/menus/ModeSelect.gd`
- `scenes/menus/MenuMinigames.gd`
- `scenes/menus/Settings.gd`
- `scenes/cutscenes/CutsceneIntro.gd`
- `scenes/cutscenes/CutsceneFinal.gd`

## Resultado esperado

- Botões do menu principal deixam de usar aparência padrão do Godot.
- Botões de seleção de modo ficam padronizados.
- Botões do modo livre ficam padronizados.
- Botões ON/OFF das configurações mantêm a lógica da V0.9.2, mas agora usam estilo centralizado.
- Botões Menu/Pular das cutscenes usam o mesmo padrão visual do restante do jogo.
- Botão final de voltar ao menu também segue o padrão.

## Observação

Esta atualização não altera a lógica dos minigames nem o fluxo da campanha. É uma atualização visual baseada em script.
