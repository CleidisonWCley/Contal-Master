# CM-V0.5 — Matriz de Riscos: Batalha Naval e Roleta de Risco

> Faixa **0.5** · ameaças, controles e práticas · `matriz_riscos.json`

> **Legenda de IDs:** `PP-Vx.y.z` = versão do histórico **Party Pascal** (nome anterior do projeto; arquivos em [`../legado_party_pascal/`](../legado_party_pascal/)). `CM-Vx.y.z` = versão **Contal Master**. A numeração do Party Pascal (que chegou a V1.0.3.2.1) **não** é comparável à do Contal Master (que está em 0.9.2.1): aqui o histórico antigo foi reorganizado nas faixas 0.1 a 0.9.

## 1. Antes (herdado do Party Pascal)

| ID legado | O que entregou |
|---|---|
| [PP-V0.6.0](../legado_party_pascal/ESCOPO_V0_6_0_BATALHA_NAVAL.md) | **Batalha Naval**: grade 5×5, banco de 20 ameaças e controles, ameaças sorteadas no tabuleiro (16/12/6 por dificuldade; depois 14/10/6 em PP-V1.0.2). |
| [PP-V0.6.1](../legado_party_pascal/HOTFIX_V0_6_1_BATALHA_NAVAL_UI.md) | Hotfix de UI: margens, ícones, painel do tabuleiro (560→450 px) e células (96→78 px). |
| [PP-V0.7.0](../legado_party_pascal/ESCOPO_V0_7_0_ROLETA_RISCO.md) | **Roleta de Risco**: 8 eventos, desaceleração progressiva, fase de tensão, rodada bônus da campanha. |
| [PP-V0.7.1](../legado_party_pascal/HOTFIX_V0_7_1_ROLETA_RISCO.md) / [PP-V0.7.2](../legado_party_pascal/HOTFIX_V0_7_2_ROLETA_RISCO.md) | Hotfixes de roleta invisível (camada `WheelCanvas`) e de layout em 1280×720. |
| [PP-V1.0.2.2](../legado_party_pascal/ESCOPO_V1_0_2_2_ROLETA_EDUCATIVA_PERSEGUICAO.md) | Roleta educativa: fatias com **nomes** de práticas (sem pontos), cores por tipo, card final com explicação e aprendizado, 16 eventos por rodada. |

Conteúdo antigo: ameaças e práticas de TI (backup, deploy sem teste, senhas), fixas dentro da cena da roleta.

## 2. Agora (Contal Master V0.9.2.1)

- **`matriz_riscos.json`: 45 não conformidades** para a Batalha Naval (15 por nível), cada uma com `ameaca`, `controle` (o que fazer), `consequencia` (efeito previsto na norma: impedimento, nova revisão, comunicação ao CFC/CVM, infração disciplinar do item 60) e explicação. A Naval pede até 14 itens por rodada, daí o mínimo de 14 por nível.
- **37 eventos** para a Roleta (18 boas e 19 péssimas práticas; a cena precisa de ≥8 de cada): "Sigilo preservado", "Revisão recíproca", "Cliente captado" etc., cada um com descrição e aprendizado.
- **Roleta atualizada:** lê o JSON; a lista antiga de TI virou apenas fallback.

## 3. A implementar

- Validar em tela o texto do card final da roleta com as descrições novas → **CM-V0.9.5**.
- Incluir matriz com probabilidade/impacto (base das Instruções do CRE sobre risco inerente) → **CM-V0.9.6**.

## Documentos legados desta faixa

- [PP-V0.6.0](../legado_party_pascal/ESCOPO_V0_6_0_BATALHA_NAVAL.md) — V0.6.0
- [PP-V0.6.1](../legado_party_pascal/HOTFIX_V0_6_1_BATALHA_NAVAL_UI.md) — HOTFIX V0.6.1 — Batalha Naval UI
- [PP-V0.7.0](../legado_party_pascal/ESCOPO_V0_7_0_ROLETA_RISCO.md) — V0.7.0 — Roleta de Risco
- [PP-V0.7.1](../legado_party_pascal/HOTFIX_V0_7_1_ROLETA_RISCO.md) — V0.7.1 — Hotfix Roleta de Risco
- [PP-V0.7.2](../legado_party_pascal/HOTFIX_V0_7_2_ROLETA_RISCO.md) — V0.7.2 — Hotfix visual da Roleta de Risco
- [PP-V1.0.2.2](../legado_party_pascal/ESCOPO_V1_0_2_2_ROLETA_EDUCATIVA_PERSEGUICAO.md) — V1.0.2.2 — Roleta educativa e pressão calibrada da Perseguição
