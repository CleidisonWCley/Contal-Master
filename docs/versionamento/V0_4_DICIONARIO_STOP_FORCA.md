# CM-V0.4 — Dicionário: STOP e Forca Técnica

> Faixa **0.4** · termos, dicas e categorias · `dicionario.json`

> **Legenda de IDs:** `PP-Vx.y.z` = versão do histórico **Party Pascal** (nome anterior do projeto; arquivos em [`../legado_party_pascal/`](../legado_party_pascal/)). `CM-Vx.y.z` = versão **Contal Master**. A numeração do Party Pascal (que chegou a V1.0.3.2.1) **não** é comparável à do Contal Master (que está em 0.9.2.1): aqui o histórico antigo foi reorganizado nas faixas 0.1 a 0.9.

## 1. Antes (herdado do Party Pascal)

| ID legado | O que entregou |
|---|---|
| [PP-V0.5.0](../legado_party_pascal/ESCOPO_V0_5_0_STOP.md) | **STOP**: 6 rodadas, letra sorteada, categoria, dica e 5 alternativas embaralhadas. |
| [PP-V0.11.0](../legado_party_pascal/ESCOPO_V0_11_0_FORCA_TECNICA.md) | **Forca Técnica**: 1 termo oculto por rodada, com área e dica; teclado físico ou botões; erro reduz a "integridade do sistema". |
| [PP-V0.11.1](../legado_party_pascal/HOTFIX_V0_11_1_FEEDBACK_MANUAL.md) | Feedback manual ("Entendi, continuar") e painéis mais translúcidos. |
| [PP-V0.11.2](../legado_party_pascal/ESCOPO_V0_11_2_FEEDBACK_PEDAGOGICO.md) | Limite de erros por dificuldade (14/10/6), integridade proporcional e explicação curta no fim da rodada. |
| [PP-V1.0.2.5](../legado_party_pascal/ESCOPO_V1_0_2_5_STOP_DESVIO_MASCARA_AGUA.md) | STOP com 6 cards (3+3), sem rótulos A–E, termos centralizados; recorde do Desvio Lógico no modo livre. |

Limitação herdada: os distratores do STOP vinham de uma **lista fixa de termos de TI** dentro da própria cena.

## 2. Agora (Contal Master V0.9.2.1)

- **`dicionario.json`: 51 termos** (17 por nível) com `termo`, `categoria`, `dica`, `definicao` e `referencia`. Categorias: órgãos (CRE, CFC, CVM, Susep, Previc, Ibracon), papéis, documentos, princípios, ameaças à independência, relatórios, prazos e procedimentos.
- **Um único arquivo alimenta dois minigames:** a Forca usa termo/dica/categoria/definição; o STOP deriva a letra da inicial do termo.
- **STOP atualizado:** os distratores agora vêm do próprio dicionário, agrupados pela inicial (11 letras, ≥4 termos cada). A lista antiga de TI deixou de ser usada.
- Regra do validador: a dica **não pode conter o próprio termo**.

## 3. A implementar

- Testar termos compostos e com hífen na Forca (ex.: "Auditor-revisor", "Carta de recomendações") → **CM-V0.9.5**.
- Expandir o dicionário (mais letras e mais termos de auditoria) → **CM-V0.9.6**.

## Documentos legados desta faixa

- [PP-V0.5.0](../legado_party_pascal/ESCOPO_V0_5_0_STOP.md) — V0.5.0 — STOP
- [PP-V0.11.0](../legado_party_pascal/ESCOPO_V0_11_0_FORCA_TECNICA.md) — V0.11.0 — Forca Técnica
- [PP-V0.11.1](../legado_party_pascal/HOTFIX_V0_11_1_FEEDBACK_MANUAL.md) — Hotfix V0.11.1 — Feedback Manual e Legibilidade da Forca Técnica
- [PP-V0.11.2](../legado_party_pascal/ESCOPO_V0_11_2_FEEDBACK_PEDAGOGICO.md) — V0.11.2 — Feedback Pedagógico e Balanceamento da Forca Técnica
- [PP-V1.0.2.5](../legado_party_pascal/ESCOPO_V1_0_2_5_STOP_DESVIO_MASCARA_AGUA.md) — V1.0.2.5 — Ajustes do STOP, pontuação do Desvio Lógico e teste de máscara d’água
