# Hotfix V0.8.1 — Backgrounds do Menu e Modo

## Problema
Os arquivos abaixo tinham extensão `.png`, mas o conteúdo interno estava em formato JPEG:

- `assets/background/background_main.png`
- `assets/background/game_modo.png`

Isso fazia o Godot marcar a importação como inválida (`valid=false`) e os fundos não apareciam corretamente nas cenas.

## Correção
Os dois arquivos foram convertidos para PNG real mantendo os mesmos nomes, para não precisar alterar caminhos nas cenas.

## Arquivos alterados

- `assets/background/background_main.png`
- `assets/background/game_modo.png`

## Caso o Godot ainda mostre X vermelho
Feche o Godot e apague estes arquivos do projeto local:

- `assets/background/background_main.png.import`
- `assets/background/game_modo.png.import`

Depois abra o projeto novamente. O Godot vai reimportar os dois backgrounds automaticamente.
