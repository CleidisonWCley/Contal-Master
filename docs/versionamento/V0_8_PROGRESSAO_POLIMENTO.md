# CM-V0.8 — Progressão, Pontuação e Polimento

> Faixa **0.8** · campanha, pontuação, conquistas e estabilidade

> **Legenda de IDs:** `PP-Vx.y.z` = versão do histórico **Party Pascal** (nome anterior do projeto; arquivos em [`../legado_party_pascal/`](../legado_party_pascal/)). `CM-Vx.y.z` = versão **Contal Master**. A numeração do Party Pascal (que chegou a V1.0.3.2.1) **não** é comparável à do Contal Master (que está em 0.9.2.1): aqui o histórico antigo foi reorganizado nas faixas 0.1 a 0.9.

## 1. Antes (herdado do Party Pascal)

| ID legado | O que entregou |
|---|---|
| [PP-V1.0](../legado_party_pascal/ESCOPO_V1_0_PRIMEIRA_VERSAO_ESTAVEL.md) | **Primeira versão estável:** fluxo Menu → Modo → Campanha/Livre → Minigames → Pontuação; Modo Livre com 7 minigames; Roleta só na campanha; pontuação local com nickname; configurações funcionais. |
| [PP-V1.0.1](../legado_party_pascal/ESCOPO_V1_0_1_CORRECOES_CAMPANHA_ROLETA_CONTEUDO.md) | Correções de campanha, da roleta e da distribuição de conteúdo (evita repetir IDs recentes). |
| [PP-V1.0.2](../legado_party_pascal/ESCOPO_V1_0_2_BALANCEAMENTO_PONTUACAO_TEMPO_ROLETA.md) | Balanceamento: pontuação por tempo em Show do Bilhão, Maleta, STOP e Perseguição; Forca, Desvio, Naval e Roleta fora da regra de tempo. |
| [PP-V1.0.2.3](../legado_party_pascal/ESCOPO_V1_0_2_3_RECALIBRACAO_TEMPO_POLIMENTO_VISUAL.md) | Recalibração das faixas de tempo e polimento visual dos cards educativos. |
| [PP-V1.0.3](../legado_party_pascal/ESCOPO_V1_0_3_SISTEMA_CONQUISTAS_INTRO.md) → [PP-V1.0.3.2.1](../legado_party_pascal/ESCOPO_V1_0_3_2_1_AJUSTE_LAYOUT_CONQUISTAS.md) | **Sistema de Conquistas** (15 conquistas, ícones próprios, cards bloqueados/desbloqueados, insígnia de progresso X/15) e música da intro. |

## 2. Agora (Contal Master V0.9.2.1)

- **Saves renomeados** para `contal_master_scores.json` e `contal_master_achievements.json`, com **migração automática** do progresso salvo com o nome antigo (copia uma única vez).
- Regras de pontuação, tempo e conquistas **mantidas** (nada foi rebalanceado nesta versão).

## 3. A implementar

- Redesenhar as **15 conquistas** com nomes e requisitos do tema auditoria → **CM-V0.9.7**.
- Remover as constantes `LEGACY_*` e a função de migração quando não houver mais save antigo → **CM-V0.9.4**.

## Documentos legados desta faixa

- [PP-V1.0](../legado_party_pascal/ESCOPO_V1_0_PRIMEIRA_VERSAO_ESTAVEL.md) — V1.0 — Primeira Versão Estável
- [PP-V1.0.1](../legado_party_pascal/ESCOPO_V1_0_1_CORRECOES_CAMPANHA_ROLETA_CONTEUDO.md) — V1.0.1 — Correções de campanha, roleta e distribuição de conteúdo
- [PP-V1.0.2](../legado_party_pascal/ESCOPO_V1_0_2_BALANCEAMENTO_PONTUACAO_TEMPO_ROLETA.md) — V1.0.2 — Balanceamento de pontuação, tempo de resposta e Roleta de Risco
- [PP-V1.0.2.3](../legado_party_pascal/ESCOPO_V1_0_2_3_RECALIBRACAO_TEMPO_POLIMENTO_VISUAL.md) — V1.0.2.3 — Recalibração de tempo e polimento visual dos minigames
- [PP-V1.0.3](../legado_party_pascal/ESCOPO_V1_0_3_SISTEMA_CONQUISTAS_INTRO.md) — V1.0.3 — Sistema de Conquistas e música da intro
- [PP-V1.0.3.1](../legado_party_pascal/ESCOPO_V1_0_3_1_REFINAMENTO_CONQUISTAS.md) — V1.0.3.1 — Refinamento visual da área de Conquistas
- [PP-V1.0.3.2](../legado_party_pascal/ESCOPO_V1_0_3_2_REFINAMENTO_CARDS_CONQUISTAS_ICONES.md) — V1.0.3.2 — Refinamento dos cards de conquistas e ícones por desafio
- [PP-V1.0.3.2.1](../legado_party_pascal/ESCOPO_V1_0_3_2_1_AJUSTE_LAYOUT_CONQUISTAS.md) — V1.0.3.2.1 — Ajuste de layout da tela de Conquistas
