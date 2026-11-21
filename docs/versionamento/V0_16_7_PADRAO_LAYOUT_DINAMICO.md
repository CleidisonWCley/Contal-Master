# V0.16.7 — Padrão único de layout dinâmico (DynamicLayout)

## Motivo
Nos testes, Perseguição e Maleta Certa quebravam o layout com fontes grandes (altura fixa de painéis/botões), e o ajuste do
Show do Bilhão (0.16.6) tinha números de nível escritos dentro do próprio minigame. Agora existe **um padrão só**.

## Como funciona (`scripts/ui/DynamicLayout.gd`)
- O minigame informa suas medidas **originais** (margem, espaçamentos, altura mínima de painéis, ícones, botões).
- Se a coluna principal não cabe na altura da tela, o helper reaplica tudo multiplicado por um fator de 4 níveis
  (1,00 → 0,82 → 0,66 → 0,54) e para no primeiro que cabe. Nível 0 = visual original (nada muda quando já cabe).
- Itens opcionais (dica de atalhos) somem a partir do nível 2.
- Roda ao carregar conteúdo novo, ao trocar a fonte e ao redimensionar a janela (agora + 2 frames, pois o texto/autowrap só
  tem altura final depois do layout).
- Os botões de resposta continuam usando `AnswerLayout.fit_option_buttons`, com altura base × fator (e piso pelo texto).

## Aplicado em
Show do Bilhão (substitui `_fit_layout` da 0.16.6), Perseguição e Maleta Certa.

## Para adotar em outro minigame
Criar `layout_fit = DynamicLayout.new(self, root_margin, main_box, MARGEM)`, registrar gaps/alturas/ícones/opcionais/botões e
chamar `layout_fit.schedule()` quando o conteúdo mudar (ver `ShowDoBilhao._build_scene`).

## Versão
`project.godot` e `BrandText.DEFAULT_VERSION` → **0.16.7**.
