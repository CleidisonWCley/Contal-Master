# V0.10.1 — Cutscene Final e Música de Navegação

## Objetivo

Corrigir a leitura da cutscene final e padronizar a música das telas de navegação.

## Alterações

- A cutscene final foi dividida em atos menores para evitar texto cortado ou excesso de conteúdo em uma única tela.
- O painel de diálogo final foi reposicionado mais acima e recebeu texto um pouco menor.
- O avanço por clique, toque, Espaço e Enter foi mantido.
- A cutscene inicial continua usando `loop_start.ogg`, reforçando o clima de abertura da Jornada SI.
- A seleção de modos agora usa `music_menu.ogg`, como o menu principal, configurações e modo livre.

## Mapeamento musical

- Menu principal: `music_menu.ogg`
- Seleção de modo: `music_menu.ogg`
- Modo livre: `music_menu.ogg`
- Configurações: `music_menu.ogg`
- Cutscene inicial: `loop_start.ogg`
- Cutscene final: `musica_final.ogg`

## Arquivos alterados

- `scenes/cutscenes/CutsceneFinal.gd`
- `scenes/menus/ModeSelect.gd`
