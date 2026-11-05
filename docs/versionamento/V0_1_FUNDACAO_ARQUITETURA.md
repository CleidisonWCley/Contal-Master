# CM-V0.1 — Fundação e Arquitetura

> Faixa **0.1** · chassi do jogo, dados e fluxo

> **Legenda de IDs:** `PP-Vx.y.z` = versão do histórico **Party Pascal** (nome anterior do projeto; arquivos em [`../legado_party_pascal/`](../legado_party_pascal/)). `CM-Vx.y.z` = versão **Contal Master**. A numeração do Party Pascal (que chegou a V1.0.3.2.1) **não** é comparável à do Contal Master (que está em 0.9.2.1): aqui o histórico antigo foi reorganizado nas faixas 0.1 a 0.9.

## 1. Antes (herdado do Party Pascal)

Chassi da migração Pygame → Godot e a arquitetura de dados.

| ID legado | O que entregou |
|---|---|
| [PP-V0.1.0](../legado_party_pascal/ESCOPO_V0_1_0_FOUNDATION.md) | Autoloads (`ScoreManager`, `SettingsManager`, `AudioManager`, `DifficultyManager`, `GameManager`), menu, seleção de modo, configurações, campanha na ordem oficial, minigames como placeholders, dificuldade e volumes salvos em `user://settings.json`. |
| [PP-V0.12.0](../legado_party_pascal/ESCOPO_V0_12_0_BANCO_DINAMICO.md) | **Banco dinâmico:** cada minigame com banco por dificuldade (30 itens por nível), 6 itens sorteados por partida, prioridade de diversidade de tópicos e não repetição de IDs em partidas consecutivas. |
| [PP-V0.12.1](../legado_party_pascal/ESCOPO_V0_12_1_REFINAMENTO_PEDAGOGICO.md) | Refinamento pedagógico: alternativas curtas, explicação ensina (resposta e explicação não repetem a mesma frase), siglas por extenso. |

Conteúdo do banco antigo: tema TI/Sistemas de Informação, embutido num único script GDScript gigante.

## 2. Agora (Contal Master V0.9.2.1)

- **Novo loader** `scripts/core/question_bank.gd`: lê 4 JSONs e entrega cada item **no formato que cada minigame já esperava** (mesma API `pick_rounds`), preservando diversidade de tópicos e memória de IDs recentes.
- **4 bancos fragmentados** em `scripts/core/data/` (um por mecânica: quiz, dilemas, dicionário, matriz de riscos). O banco antigo (`DynamicQuestionBank.gd`, ~7 mil linhas) deixa de ser usado.
- **Integração mínima nas cenas:** `_ferramentas/aplicar_integracao.py` (idempotente, com backup) + `Paths.gd` com as constantes dos novos arquivos + `include_filter="*.json"` no export (os JSONs precisam ir no APK).
- **Qualidade:** `validar_banco.py` (campos, IDs únicos, limites de texto da UI, cobertura por nível) e `selftest_question_bank.gd` (roda no Godot em modo headless).
- **Regras de fonte:** conteúdo ancorado na NBC PA 11 (R1); divergências entre fontes resolvidas a favor da norma (ver "Decisões sobre as fontes" em [ESCOPO_CM_V0_9_2_1_INCLUSAO_CONTAL_MASTER](ESCOPO_CM_V0_9_2_1_INCLUSAO_CONTAL_MASTER.md)).

## 3. A implementar

- Rodar o autoteste e jogar todos os minigames nas 3 dificuldades dentro do Godot (o loader novo ainda não foi executado na engine) → **CM-V0.9.5**.
- Remover o banco antigo, o `ContaLMaster_Banco_Final.json` e os fallbacks de TI embutidos nas cenas → **CM-V0.9.4**.

## Documentos legados desta faixa

- [PP-V0.1.0](../legado_party_pascal/ESCOPO_V0_1_0_FOUNDATION.md) — V0.1.0 Fundação da Migração
- [PP-V0.12.0](../legado_party_pascal/ESCOPO_V0_12_0_BANCO_DINAMICO.md) — V0.12.0 — Banco Dinâmico de Questões
- [PP-V0.12.1](../legado_party_pascal/ESCOPO_V0_12_1_REFINAMENTO_PEDAGOGICO.md) — V0.12.1 — Refinamento Pedagógico do Banco Dinâmico
