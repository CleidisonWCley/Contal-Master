# V0.16.8 — Roleta de 1 giro (reaplicada), retrato do tutorial preso ao card, reforço do DynamicLayout

## 1) Roleta de Risco: 1 giro (V0.16.4 do colega, reaplicada)
**O que aconteceu:** o zip-base das nossas rodadas de ajuste de fonte (0.16.4 a 0.16.7) trazia o `RoletaRisco.gd` da 0.16.2
(N giros). O colega já tinha feito o ajuste de 1 giro (doc `V0_16_4_ROLETA_1_GIRO_LIMITE_DINAMICO_5_MINIGAMES.md`) e
`SettingsManager.gd`, `QuestionSettings.gd` e `roleta_risco.json` dele estavam certos, mas o script da Roleta sobrescrito
voltou a ler `get_current_questions_count()` e ficou com vários giros **sem** o multiplicador de pontos.
**Agora** (`RoletaRisco.gd`): `FIXED_SPINS = 1` (não lê mais a duração), sem multiplicador de pontos por N giros, chip
"GIRO x/N" só existe se `FIXED_SPINS > 1`, botão final "Concluir". Código de vários giros segue dormente.
Os demais arquivos do colega **não foram tocados**.

## 2) Tutorial — retrato preso à base real do card (todos os minigames)
**Causa:** `_needed_card_height` medía o texto com o tamanho de fonte BASE (Média). Com fonte Grande/Extra grande o texto real é
maior, o `PanelContainer` crescia sozinho por baixo e o retrato continuava posicionado pela altura estimada: a cintura do
sprite ficava ~25 px acima da base do card ("flutuando").
**Correção** (`TutorialOverlay.gd`): medição com `FontScale.px(...)` (texto, nome e botões) + rede de segurança com
`_card.get_combined_minimum_size()`; o retrato usa sempre a altura final do card. `PORTRAIT_FOOT_GAP` = 3 px (a borda de
3 px do card continua visível sob o corte da cintura). O card só cresce o que o conteúdo realmente pede.

## 3) DynamicLayout
- Quando a coluna não cabe nem no último nível, passa a alinhar pelo **topo** (antes centralizada cortava título e rodapé).
- Em build de debug imprime `[DynamicLayout] <minigame>: nivel=N cabe=... conteudo=... tela=...` (só quando muda).

## Perseguição (tela vazia)
Causa **não confirmada** (sem Godot aqui). O log acima mostra se o `DynamicLayout` é o responsável; se o problema
persistir, enviar o texto do painel "Saída/Depurador" ao abrir a Perseguição.

## Versão
`project.godot` (mantido `viewport_height=670` do projeto atual) e `BrandText.DEFAULT_VERSION` → **0.16.8**.
