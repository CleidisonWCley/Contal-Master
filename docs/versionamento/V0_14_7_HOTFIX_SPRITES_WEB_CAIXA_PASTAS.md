# V0.14.7 - Hotfix: sprites de personagens sumindo na web (novels e tutoriais)

Base: contalmaster_patch.zip (0.14.6, Godot 4.5). Godot nao foi executado aqui; a causa foi comprovada lendo o
`build/web/index.pck` enviado. Teste o build web novo antes de publicar.

## Sintoma
Na versao web (itch.io) sumiam os personagens **Cleiton** (Stop), **Ariel** (Perseguicao) e **Natalia** (Desvio Logico)
nos tutoriais e nas novels. Os demais pareciam normais. Desempenho nao foi afetado.

## Causa (comprovada no .pck)
O `index.pck` publicado guarda os remaps dos sprites em pastas **com maiuscula**:

| No .pck exportado | O codigo (Paths.gd) pede |
|---|---|
| `personagens/Ariel/ariel_N.png.import` | `personagens/ariel/ariel_N.png` |
| `personagens/Cleiton/cleiton_N.png.import` | `personagens/cleiton/cleiton_N.png` |
| `personagens/Natalia/natalia_N.png.import` | `personagens/natalia/natalia_N.png` |
| `personagens/Priscilla/priscila_N.png.import` (2 "l") | `personagens/priscila/priscila_N.png` |

O Windows (editor) nao diferencia maiuscula de minuscula, entao tudo funcionava la. O navegador (PCK, estilo Linux)
**diferencia**: `load()` nao acha o arquivo, devolve `null` e `TutorialManager.sprite_texture()` retornava `null`, o
que gera o aviso "sprite nao encontrado" e o personagem simplesmente nao e desenhado (novel e tutorial).
Jales, Tiago, Julios, Aline e Anderson ja estavam em minusculo desde o inicio, por isso nao falharam.
Confirmacao: o hash do `.ctex` no .pck (ex.: `ariel_1.png-527b773f...`) e o md5 do caminho com `Ariel/`; o `.import`
atual do projeto gera o hash do caminho com `ariel/`. Ou seja, as pastas foram renomeadas para minusculo **depois**
do ultimo export (o build do zip e de 10/nov; os sprites e `.import` sao de 12-13/nov).
A Priscila tinha o mesmo problema (grafia "Priscilla"); pode nao ter sido notado.
A arvore atual do projeto esta limpa: 184 referencias `res://` auditadas, nenhuma com caixa errada.

## O que foi alterado
1. `tutorials/TutorialManager.gd` - novo `resolve_sprite_path(id, variante)`: tenta o caminho padrao (minusculo), a
   pasta com 1a letra maiuscula e, para a Priscila, "Priscilla"/"Priscila". Usa `ResourceLoader.exists` (correto em
   export) e guarda em cache. `sprite_texture()` passa a usar isso e avisa no console se nada existir.
   Cobre novels (NovelStage), tutoriais (TutorialOverlay) e cena final (CutsceneFinal), todos usam `sprite_texture`.
2. `scripts/autoloads/GameManager.gd` - a lista de pre-carregamento das transicoes usa o caminho resolvido (antes,
   com caixa errada, o `ResourceLoader.exists` da LoadingScreen descartava o sprite em silencio).
3. `tools/verificar_caixa_build.py` (novo) - confere caixa dos `res://` do codigo e, opcionalmente, do `.pck`.
4. `project.godot` - versao 0.14.7.

## Passo a passo para publicar (obrigatorio: reexportar)
O codigo novo so entra no jogo com um **novo export**; o .pck antigo nao muda.
1. Copie os arquivos deste zip por cima do projeto (mesmos caminhos).
2. Feche o Godot. Confirme no Explorer que as pastas se chamam `ariel`, `cleiton`, `natalia`, `priscila` (minusculo).
   Se renomeou so a caixa no Windows, apague a pasta `.godot/` do projeto (ela guarda o cache com o nome antigo) e abra
   o Godot para reimportar tudo.
3. Exporte para Web (substitua TODOS os arquivos de `build/web`, sobretudo `index.pck`).
4. Rode `python tools/verificar_caixa_build.py build/web/index.pck` (esperado: "OK").
5. Envie ao itch.io e teste com Ctrl+F5 (cache do navegador!): tutorial do Cleiton, Ariel e Natalia + novel de cada um.

## Observacao (nao alterada neste patch)
`TutorialManager.SPRITE_SETS` ainda traz `size` antigos (1792x2400, 1536x2304, 1664x2080) enquanto os PNGs agora sao
todos 1120x1500. As novels (_1) e a cena final (_2) usam esses valores para posicionar; se algum personagem ficar
levemente deslocado, o proximo passo e remedir `head_x/foot_y/top_y` nos PNGs novos. Nao relacionado ao bug dos sprites.
