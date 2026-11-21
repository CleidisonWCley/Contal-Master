# V0.16.5 — Hotfix da 0.16.4: respostas cortadas fora da tela, folga dos tutoriais e selo do menu

## Problema
Na 0.16.4 o cálculo de altura dos botões de resposta (`AnswerLayout`) somava folgas (+8 px e espaçamento de linha) mesmo
para respostas de **uma linha**. Com a fonte grande, 4 respostas ficaram ~13 px mais altas cada e a alternativa D saiu da
tela (Show do Bilhão). Configuração de tela do projeto (`canvas_items` + `expand`, 1280×720) está correta e não mudou.

## Correções
- `scripts/ui/AnswerLayout.gd`: resposta de uma linha volta à altura mínima original; folga/espaçamento só entram em
  respostas de várias linhas (espaçamento **entre** linhas, +4%).
- `ShowDoBilhao.gd`: painel da pergunta com altura mínima 120 (era 150) — sobra espaço para as 4 respostas.
- `tutorials/TutorialOverlay.gd`: o cartão do tutorial não encosta mais na borda inferior (folga 56 px; 40 px em tela
  compacta), vale também para passos com `card_y` fixo; retratos ficam a 14 px da borda lateral (antes 4 px).
- `scenes/menus/main_menu.gd`: selo de versão desceu (≈34 px do rodapé; na 0.16.4 estava ≈52 px).

## Versão
`project.godot` e `BrandText.DEFAULT_VERSION` → **0.16.5**.
