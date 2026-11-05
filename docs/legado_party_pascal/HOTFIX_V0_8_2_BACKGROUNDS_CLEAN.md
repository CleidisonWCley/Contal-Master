# V0.8.2 — Hotfix dos backgrounds main/modo

Este patch evita conflito com imports quebrados dos arquivos antigos `background_main.png` e `game_modo.png`.

## Estratégia

Em vez de reutilizar os nomes antigos, foram criados arquivos novos:

- `assets/background/background_main_clean.png`
- `assets/background/game_modo_clean.png`

As cenas foram atualizadas para apontar para esses novos arquivos:

- `scenes/menus/MainMenu.tscn`
- `scenes/menus/ModeSelect.tscn`
- `scenes/menus/Settings.tscn`

Os PNGs foram reexportados como PNG real e redimensionados para `1536x864`, formato mais seguro para importação no Godot.

## Instalação

Copie as pastas do patch sobre o projeto. Os arquivos antigos podem ficar no projeto, pois não serão mais usados por essas cenas.

Se o Godot ainda mostrar erro visual, feche o Godot e apague a pasta `.godot/imported` para forçar reimportação completa.
