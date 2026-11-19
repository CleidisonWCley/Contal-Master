# V0.16.4 - Roleta de Risco: 1 giro; limite dinâmico só em 5 minigames

## Regra
- **Limite dinâmico (2/4/8/10)** vale APENAS para: Show do Bilhão, Maleta Certa, Perseguição, STOP e Forca Técnica.
- **Roleta de Risco** (mini game bônus): **1 giro, sempre**, independente da configuração de duração. Ela existe SÓ na campanha (bônus de azar); não aparece no Modo Livre (`MenuMinigames` não tem o card).
- Batalha Naval e Desvio Lógico seguem com duração própria (sem mudança).

## Alterações
- `SettingsManager.gd`: `roleta_risco` removida de `QUESTION_BASED_GAMES`; removidos `ROLETA_BASE_SPINS` e o desvio especial em `question_score_scale` (a Roleta volta ao multiplicador 1.0, ou seja, pontos originais do giro único).
- `RoletaRisco.gd`: nova constante `FIXED_SPINS = 1` (não lê mais `get_current_questions_count()`); o multiplicador de pontos por N giros foi removido; o chip "GIRO x/N" só é criado se `FIXED_SPINS > 1`. O botão final continua "Concluir". O código de múltiplos giros ficou dormente (basta alterar `FIXED_SPINS` para reativar).
- `tutorials/data/roleta_risco.json`: texto sem `{rounds}` ("É um giro só...") e removido o quadro `como_jogar_livre` (a Roleta não existe no Modo Livre).
- `QuestionSettings.gd`: nota da tela de duração atualizada para listar os 5 minigames afetados.
- Versão 0.16.3 -> 0.16.4 (`project.godot`, `BrandText.DEFAULT_VERSION`).

## Pontos de atenção
- NÃO testado no editor Godot: abrir o projeto, jogar a Roleta na campanha com duração de campanha 2 e 10 e conferir que só há 1 giro, sem chip de contador e com pontos de bônus/penalidade originais.
- `export_presets.cfg` (Android `version/name`) não veio no zip: atualizar para 0.16.4 localmente.
- Histórico "visto" da Roleta continua sendo registrado (1 evento por partida).
