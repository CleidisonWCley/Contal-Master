# V0.16.2 - Limite dinâmico, feedback didático e novels enxutas

## 1. Limite dinâmico (6 minigames) + regras próprias de Batalha Naval e Desvio Lógico
- `SettingsManager.QUESTION_BASED_GAMES`: Show do Bilhão, Perseguição, Maleta Certa, STOP, Forca Técnica e **Roleta do Risco** (N giros: 2/4/8/10; roda nova a cada giro, contador "GIRO x/N", botão "Concluir" no último). Máximo de pontos preservado (Roleta: 1/N).
- **Batalha Naval — FORA do limite dinâmico**, inalterada: ameaças fixas por dificuldade, agora **16 (Fácil), 12 (Normal) e 8 (Difícil)** (`DifficultyManager.naval_qtd`; antes 14/10/6).
- **Desvio Lógico — FORA do limite dinâmico**: sempre **6 desafios** (1 por horário do dia, tráfego crescente). Para ficar mais ágil, o percurso até a bifurcação ficou mais curto: `DLConfig.DRIVE_DURATION_SECONDS` 35 s → **22 s** e aceleração 5/6/7 s → **3,2/3,8/4,4 s** (Fácil/Normal/Difícil).
- **Conteúdo variado (`question_bank.gd`):**
  - Histórico de itens vistos por FAMÍLIA de banco (quiz, dilemas, dicionário, naval, roleta), salvo em `user://contal_master_question_history.json`: não repete entre minigames da mesma campanha nem ao reabrir o jogo.
  - Novos: `mark_seen`, `get_seen_ids`, `clear_history`; `pick_rounds(..., record=true)`.
  - Banco de dilemas (Desvio Lógico + Maleta Certa): 24 -> 48 itens (16 por nível), resolvendo o limite de 10 questões.

## 2. Explicações de acertos e erros
- Novo `scripts/core/FeedbackText.gd` (formato único): explicação enxuta + linha **"Na prática:"**; no erro, **"Por que não:"** com o motivo da opção escolhida.
- Dados: quiz (44) com `porque_erradas` por alternativa + `na_pratica`; dilemas (48) e dicionário (51) com `na_pratica`; STOP mostra o significado do termo errado escolhido; Perseguição reaproveita o motivo quando o distrator casa com uma alternativa.
- Telas ajustadas: Show do Bilhão, Perseguição, Maleta Certa, STOP, Forca Técnica, Desvio Lógico.

## 3. Novels mais enxutas
- Falas das 8 apresentações, intro e final.json reduzidas (maior fala 264 -> ~145 caracteres; meta: até ~140), mantendo personalidade e informações de enredo. Fallback da CutsceneIntro e 2 tutoriais encurtados.
- Tutoriais da Roleta e da Naval atualizados ({rounds}/{threats}).

## Pontos de atenção
- NÃO testado no editor Godot: abrir o projeto e conferir o console (incl. `class_name FeedbackText` novo).
- Naval: com mais ameaças (16/12/8) o máximo de pontos sobe (pontos por acerto não foram recalibrados). Banco naval tem 15 ameaças/nível; no Fácil (16) 1 vem de outro nível.
- Desvio: tempos novos precisam de teste manual (tráfego, desaceleração final e fim do spawn dentro de 22 s).
- O fallback em código da Roleta, da Naval e do Show do Bilhão ainda tem conteúdo de TI (só é usado se o JSON falhar).
- Revisar com a equipe técnica os textos novos de "Na prática" antes de publicar.
