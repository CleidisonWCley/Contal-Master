# V0.15.6 — Rolagem por toque (celular / tablet)

Copie por cima do projeto mantendo as pastas. **Uma classe nova (`TouchScroll`)**: abra o projeto no Godot uma vez
(ou use Projeto > Recarregar projeto atual) para ele registrar a classe antes de exportar.

## Problema
Nas telas novas (Perfis da Equipe, Arquivos da Firma, Conquistas) arrastar o dedo não rolava a tela. Os cartões são
`PanelContainer`/`Button` com `mouse_filter = STOP` e "engolem" o toque antes do `ScrollContainer`. Só a barra fina
de rolagem funcionava, e ninguém acerta ela com o dedo.

## Solução
`scripts/ui/TouchScroll.gd` — helper de uma linha: `TouchScroll.attach(scroll_container)`.
- Escuta o toque cru (`InputEventScreenTouch/Drag`) em `_input`, antes dos botões, então não depende de `mouse_filter`.
- Toque curto continua sendo clique normal. Arrastar além de 12 px rola o conteúdo, com inércia ao soltar.
- Arrastar **cancela** o clique do botão sob o dedo (rolar não abre ficha nem troca de personagem sem querer).
- Mouse de PC não muda (roda e barra nativas).

## Arquivos
- novo: `scripts/ui/TouchScroll.gd` (+ `.gd.uid`)
- alterados (1 linha cada): `scenes/menus/TeamProfiles.gd`, `FirmaArchive.gd`, `TeamArchive.gd`, `ArchiveEntry.gd`, `AchievementsMenu.gd`
- teste: `tools/tests/touch_scroll_test.gd`

## Como foi testado (Godot 4.5 headless, toque simulado, tela 1280x592 = celular deitado)
Antes: Perfis 0 → 0 (não rolava). Depois: Perfis 0 → 182, Conquistas 0 → 304, Firma 0 → 82; Arquivos da Equipe e
Ficha rolam em tela baixa (1280x380). Cliques disparados durante o arraste: 0. Toque curto em botão: 1 clique.
Rodar de novo: `godot --headless --path . -s tools/tests/touch_scroll_test.gd -- res://scenes/menus/TeamProfiles.tscn 1280 592`

## Não testado (precisa de aparelho real)
Inércia e "sensação" do dedo no navegador do celular/tablet; só dá para validar no build web.
