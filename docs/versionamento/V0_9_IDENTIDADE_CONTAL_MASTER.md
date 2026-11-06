# CM-V0.9 — Identidade Contal Master (transição)

> Faixa **0.9** · renomeação, versão e documentação

> **Legenda de IDs:** `PP-Vx.y.z` = versão do histórico **Party Pascal** (nome anterior do projeto; arquivos em [`../legado_party_pascal/`](../legado_party_pascal/)). `CM-Vx.y.z` = versão **Contal Master**. A numeração do Party Pascal (que chegou a V1.0.3.2.1) **não** é comparável à do Contal Master (que está em 0.9.2.1): aqui o histórico antigo foi reorganizado nas faixas 0.1 a 0.9.

## (herdado do Party Pascal)

| ID | O que era |
|---|---|
| Rótulo "v0.9.1" | Última versão exibida no jogo sob o nome anterior (`GameManager.APP_VERSION`). A documentação, porém, já estava em PP-V1.0.3.2.1: os dois números nunca foram alinhados. |
| Sufixo "0.9.5" em `build/version.txt` e `docs/version.txt` | Em `docs/index.html` aparece como "Pygbag Version : 0.9.5": é a versão da ferramenta do build web do Pygame, **não** do jogo. |

## Entregue nesta versão
**Conteúdo (banco de auditoria, base NBC PA 11 R1)**
- `question_bank.gd` + 4 JSONs: quiz (44), dilemas (24), dicionário (51 termos), matriz de riscos (45 ameaças + 37 eventos de roleta).
- Ferramentas: `validar_banco.py`, `selftest_question_bank.gd`, `aplicar_integracao.py`.
- Integração nas cenas, STOP e Roleta lendo os JSONs, `*.json` incluído no export.

**Marca e versão**
- Versão `0.9.2.1` unificada; nome do projeto, APK e artefato de CI renomeados.
- Selo no menu e créditos do final com "Contal" branco + "Master" roxo (`BrandText.gd`, tokens `BRAND_*`).
- Remoção do nome anterior de código, textos e saves (com migração do save antigo).
- `verificar_marca.py` confere ausência do nome anterior e consistência da versão.

**Documentação**
- Versionamento reorganizado em faixas 0.1–0.9 (Antes · Agora · A implementar), mapa do legado e roadmap até 1.0.0.

## Decisões sobre as fontes (banco de auditoria)
- **Guarda de documentos:** 7 anos desde a emissão do relatório (NBC PA 11, item 28g); o Anexo 2 das Instruções do CRE diverge, e a norma prevaleceu.
- **Auditoria recente do revisor:** 2 anos (item 26i).
- **Carta de recomendações:** obrigatória (item 45), embora a base do jogo diga "quando necessário".
- **Investimento em cliente do revisado:** permitido, mas o membro não revisa aquele cliente (item 23).
- **Relatório "com deficiências"** não impede atuar como revisor (item 26b).
- **Datas anuais do CRE** não entram no banco (mudam a cada ciclo). A Instrução CVM 308/99 citada nas Instruções de 2020 foi substituída pela Resolução CVM 23/2021.
- Conteúdo específico de Susep/Previc ficou de fora: as provas de apoio vieram sem gabarito.

## Fora do escopo (vai para o roadmap)
História/cutscenes ainda no tema anterior · fallbacks de TI nas cenas · conquistas · identidade visual (logo/ícone) · expansão do banco · validação dentro do Godot.

# CM-V0.9.2.2 — Contal Master  padronização UI Pause + merge (transição)

- Paths.gd: saves novos + LEGACY_ + migrate_legacy_saves() + constantes do banco de perguntas
  + os meus icones/Jales.
- UiPalette.gd: seus tokens BRAND_* (Contal branco / Master roxo) + as cores de dificuldade.
- 8 minigames: voltam a usar res://scripts/core/question_bank.gd (suas mudancas, incl. distratores
  do STOP e roleta pelo JSON) + o pause padronizado.
- CutsceneIntro/Final: seus nomes (jales_sprite/JALES_PATH) + o layout com Jales a direita e zoom.
- StageTransition e AchievementManager: suas mudancas + meus icones no lugar de emojis.
- MainMenu.tscn: removidos 2 UIDs invalidos (so silencia avisos).
Arquivos SEUS mantidos sem alteracao: ScoreManager.gd, GameManager.gd, main_menu.gd, BrandText.gd,
project.godot, export_presets.cfg, workflow, question_bank.gd e os 4 JSONs.

# CM-V0.9.2.3 — Atualização de UI/UX dos menus.

## Novidades
- **Modo de jogo**: os dois cartões gigantes viraram **relatórios contábeis** de tamanho médio (papel claro, faixa de título colorida, colunas DISCRIMINAÇÃO / VALOR com linhas pontilhadas e TOTAL com linha dupla). Campanha = "Balanço da Jornada"; Modo Livre = "Demonstrativo de Recordes". Os valores vêm do jogo (desafios, dificuldade, melhor campanha/recorde).
- **Modo livre**: minigames centralizados por linha (4 em cima, 3 embaixo centralizados); em janelas menores a grade se reorganiza mantendo cada linha centralizada.
- **Conquistas**: contêiner da insígnia/progresso agora transparente e menor, com mais espaço para o botão Voltar.
- **Conquistas — animação de rank**: ao abrir a tela, a barra e o contador sobem até o progresso atual; a cada troca de rank (Bronze → Prata → Ouro → Platina) a insígnia dá um "pop" com brilho e o nome troca com fade. Respeita a opção "Animações visuais" (desligada = mostra direto).
- Arquivos novos/alterados: `ModeSelect.gd`, `MenuMinigames.gd`, `AchievementsMenu.gd`, `AchievementManager.gd` (novo `get_insignia_name_for_count`, sem mudar o comportamento anterior).

## Telas atualizadas
- **Tela inicial**: letras e ícones sempre em branco; os fundos dos botões (roxo, ciano, laranja, rosa) são escurecidos só o necessário para o branco ter contraste, mantendo a leve transparência.
- **Modo de jogo** (`ModeSelect`): título "MODO DE JOGO", chip de dificuldade, dois cartões grandes (Campanha roxo / Modo Livre ciano) com ícone, descrição e contagem ("8 desafios em sequência", "7 minigames", lidas do jogo).
- **Modo livre** (`MenuMinigames`): grade 4+3 de cartões com selo de ícone, descrição e "Recorde" da dificuldade atual; nomes com acento (Força Técnica).
- **Configurações**: painel com seções ÁUDIO / JOGO / TELA; sliders com valor em %; dificuldade em 3 botões (cor + 1/2/3 pontos); interruptores "LIGADO/DESLIGADO".
- **Conquistas**: painel de progresso com insígnia e barra; cartões desbloqueados com borda rosa, bloqueados sóbrios com cadeado branco; barra de rolagem fina.
- **Pontuação**: cores de dificuldade fixas (ciano/amarelo/vermelho), abre com o primeiro minigame selecionado, botão Voltar padrão.
- **Pause padronizado**: já estava aplicado, não foi alterado.

## Padronização
- Todos os emojis dos menus foram trocados por ícones brancos (`UiIcons`).
- Botão **Voltar** único (seta + texto) em todas as telas: `UiKit.back_button()`.
- Todas as telas usam o mesmo fundo (`UiBackdrop`: cenário escurecido + partículas, respeita "Animações visuais").
- Esc volta ao menu anterior nas telas atualizadas.
- Layout responsivo: cartões empilham e a tela rola em janelas pequenas.

## Arquivos
- Reescritos: `ModeSelect.gd/.tscn`, `MenuMinigames.gd/.tscn`, `Settings.gd/.tscn`, `AchievementsMenu.gd` (interface agora montada por código, como a ScoreMenu).
- Ajustados: `ScoreMenu.gd`, `ButtonStyles.gd` (variantes `menu_*` com texto branco, `mode_card_*`, `ui_card`, `ui_toggle_on`), `UiKit.gd` (novos helpers: `screen_title`, `back_button`, `icon_badge`, `pill`, `format_points`; `difficulty_chip` com tamanho opcional).