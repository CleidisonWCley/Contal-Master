# CM-V0.2 — Quiz: Show do Bilhão e Perseguição

> Faixa **0.2** · múltipla escolha e identificação rápida · `quiz_auditoria.json`

> **Legenda de IDs:** `PP-Vx.y.z` = versão do histórico **Party Pascal** (nome anterior do projeto; arquivos em [`../legado_party_pascal/`](../legado_party_pascal/)). `CM-Vx.y.z` = versão **Contal Master**. A numeração do Party Pascal (que chegou a V1.0.3.2.1) **não** é comparável à do Contal Master (que está em 0.9.2.1): aqui o histórico antigo foi reorganizado nas faixas 0.1 a 0.9.

## 1. Antes (herdado do Party Pascal)

| ID legado | O que entregou |
|---|---|
| [PP-V0.2.0](../legado_party_pascal/ESCOPO_V0_2_0_SHOW_DO_BILHAO.md) | **Show do Bilhão** jogável: banco migrado, perguntas por dificuldade, embaralhamento de perguntas e alternativas, pontuação fiel ao Pygame (Fácil +12/−5; Normal +10/−12). |
| [PP-V0.4.0](../legado_party_pascal/ESCOPO_V0_4_0_PERSEGUICAO.md) | **Perseguição**: incidentes por dificuldade (fácil, normal, difícil), com temporizador e pressão. |
| [PP-V0.4.1](../legado_party_pascal/HOTFIX_V0_4_1_PERSEGUICAO.md) | Hotfix de tipagem (`maxf`, `clampf`, variáveis `float` explícitas) no temporizador e na sirene. |

Evoluções posteriores que tocaram estes minigames: pontuação proporcional ao tempo de resposta ([PP-V1.0.2](../legado_party_pascal/ESCOPO_V1_0_2_BALANCEAMENTO_PONTUACAO_TEMPO_ROLETA.md), recalibrada em [PP-V1.0.2.3](../legado_party_pascal/ESCOPO_V1_0_2_3_RECALIBRACAO_TEMPO_POLIMENTO_VISUAL.md): rápido ≤15 s = 100%, médio 16–34 s = 75%, lento ≥35 s = 55%) e calibração da pressão da Perseguição ([PP-V1.0.2.2](../legado_party_pascal/ESCOPO_V1_0_2_2_ROLETA_EDUCATIVA_PERSEGUICAO.md).

## 2. Agora (Contal Master V0.9.2.1)

- **`quiz_auditoria.json`: 44 perguntas** sobre revisão externa de qualidade pelos pares (NBC PA 11): 15 fáceis, 15 normais, 14 difíceis. Temas: escolha do revisor, plano de ação, carta de recomendações, tipos de relatório, impedimentos, independência, confidencialidade, prazos, composição do CRE, escopo.
- Cada item tem 4 alternativas curtas (≤52 caracteres), resposta, explicação e **referência ao item da norma**.
- Bloco `rapida` em todos os itens: é o que a **Perseguição** usa (frase curta + resposta certa + distratores), porque ali o tempo de resposta é de poucos segundos.
- Pegadinhas deliberadas no nível difícil (ex.: relatório "com deficiências" **não** impede ser revisor; prazo de 2 anos sem auditar, não 3).

## 3. A implementar

- Ampliar para ≥30 perguntas por nível com revisão técnica contábil → **CM-V0.9.6**.
- Recalibrar a pontuação por tempo considerando que os enunciados de auditoria são mais longos → **CM-V0.9.5**.

## Documentos legados desta faixa

- [PP-V0.2.0](../legado_party_pascal/ESCOPO_V0_2_0_SHOW_DO_BILHAO.md) — V0.2.0 — Show do Bilhão
- [PP-V0.4.0](../legado_party_pascal/ESCOPO_V0_4_0_PERSEGUICAO.md) — V0.4.0 — Perseguição
- [PP-V0.4.1](../legado_party_pascal/HOTFIX_V0_4_1_PERSEGUICAO.md) — Hotfix V0.4.1 — Perseguição
