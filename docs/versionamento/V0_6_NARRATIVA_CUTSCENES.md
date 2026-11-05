# CM-V0.6 — Narrativa e Cutscenes

> Faixa **0.6** · história da campanha, cutscenes e transições

> **Legenda de IDs:** `PP-Vx.y.z` = versão do histórico **Party Pascal** (nome anterior do projeto; arquivos em [`../legado_party_pascal/`](../legado_party_pascal/)). `CM-Vx.y.z` = versão **Contal Master**. A numeração do Party Pascal (que chegou a V1.0.3.2.1) **não** é comparável à do Contal Master (que está em 0.9.2.1): aqui o histórico antigo foi reorganizado nas faixas 0.1 a 0.9.

## 1. Antes (herdado do Party Pascal)

| ID legado | O que entregou |
|---|---|
| [PP-V0.8.0](../legado_party_pascal/ESCOPO_V0_8_0_CUTSCENES.md) | Cutscene inicial com páginas narrativas, mascote animado, máquina de escrever e partículas; cutscene de transição entre fases; cutscene final em atos (fala, pontuação, créditos, tela final). Roleta só como bônus da campanha. |
| [PP-V0.9.0](../legado_party_pascal/ESCOPO_V0_9_0_CUTSCENES_POLISH.md) | Polimento: avanço por clique/Espaço/Enter, botões Menu/Pular menores, som de clique só em ações explícitas. |
| [PP-V0.10.0](../legado_party_pascal/ESCOPO_V0_10_0_JORNADA_SI.md) | **Jornada SI**: conteúdo final da campanha com eixos de TI (algoritmos, banco de dados, engenharia de software, redes, segurança, IHC). |
| [PP-V0.10.1](../legado_party_pascal/HOTFIX_V0_10_1_CUTSCENE_FINAL_MUSICA.md) | Final dividido em atos menores (sem texto cortado) e mapeamento musical por tela. |

O mascote da época se chamava Pascal; hoje é **Jales**.

## 2. Agora (Contal Master V0.9.2.1)

- **Créditos do final** com a marca em duas cores: "CONTAL" em branco e "MASTER" em roxo, versão "Contal Master V0.9.2.1" e agradecimento final.
- **Transição do Show do Bilhão:** a fala de abertura da trilha passa a ser do Jales e fala de revisão pelos pares (independência, sigilo, organização do trabalho).
- Identificadores internos `pascal_*` renomeados para `jales_*` nas cutscenes.

## 3. A implementar

- Reescrever a **história da campanha** (cutscene inicial, falas das fases, final) do tema "Jornada SI" para a **jornada da auditoria / revisão pelos pares** → **CM-V0.9.3**.
- Revisar todos os subtítulos de fase em `StageTransition.gd` (ainda falam de "projeto" e "decisão técnica") → **CM-V0.9.3**.

## Documentos legados desta faixa

- [PP-V0.8.0](../legado_party_pascal/ESCOPO_V0_8_0_CUTSCENES.md) — V0.8.0 — Cutscenes da História e Ajustes de Fluxo
- [PP-V0.9.0](../legado_party_pascal/ESCOPO_V0_9_0_CUTSCENES_POLISH.md) — V0.9.0 — Polimento das Cutscenes e Transições Narrativas
- [PP-V0.10.0](../legado_party_pascal/ESCOPO_V0_10_0_JORNADA_SI.md) — V0.10.0 — Jornada SI: Conteúdo Final da Campanha
- [PP-V0.10.1](../legado_party_pascal/HOTFIX_V0_10_1_CUTSCENE_FINAL_MUSICA.md) — V0.10.1 — Cutscene Final e Música de Navegação
