# Cronograma de versões do ContalMaster

> Faixa **0.x** · índice único de versões. Cada linha aponta para o documento da versão. IDs `PP-Vx.y.z` (histórico do nome anterior, Party Pascal) estão em [`MAPA_LEGADO.md`](MAPA_LEGADO.md).

## Regra de numeração

`MAJOR.MINOR.PATCH[.HOTFIX]` — ex.: `0.13.3`, `0.13.2.1`.

| Parte | Quando sobe |
|---|---|
| `MINOR` (0.**13**) | bloco grande de funcionalidade (ex.: Loading + ícones) |
| `PATCH` (0.13.**3**) | atualização entregue (cena nova, áudio, padronização) |
| `HOTFIX` (0.13.2.**1**) | correção de uma entrega já publicada, sem novidade |

**Onde a versão precisa ser alterada (sempre os três, no mesmo commit):**

1. `project.godot` → `config/version` (fonte da versão; é o que o selo do menu e da cena final mostram).
2. `scripts/ui/BrandText.gd` → `DEFAULT_VERSION` (reserva, igual ao item 1).
3. `export_presets.cfg` → preset Android `version/name` (arquivo local: está no `.gitignore`).

Depois: criar o doc `docs/versionamento/V<versão>_<assunto>.md`, atualizar **esta tabela** e criar a tag `v<versão>`.

**Evitar colisão (aconteceu na 0.13.2):** duas pessoas usaram `0.13.2` ao mesmo tempo (chegada à sala e trilhas). Antes de começar, reserve o número aqui (linha com "em andamento"); quem terminar depois sobe para o próximo.

## Linha do tempo

| Versão | Assunto | Documento |
|---|---|---|
| 0.1 | Fundação e arquitetura | `V0_1_FUNDACAO_ARQUITETURA.md` |
| 0.2 | Quiz Show do Bilhão e Perseguição | `V0_2_QUIZ_SHOW_BILHAO_PERSEGUICAO.md` |
| 0.3 | Dilemas: Maleta e Desvio | `V0_3_DILEMAS_MALETA_DESVIO.md` |
| 0.4 | Dicionário: Stop e Forca | `V0_4_DICIONARIO_STOP_FORCA.md` |
| 0.5 | Matriz de riscos: Naval e Roleta | `V0_5_MATRIZ_RISCOS_NAVAL_ROLETA.md` |
| 0.6 | Narrativa e cutscenes | `V0_6_NARRATIVA_CUTSCENES.md` |
| 0.7 | Interface, áudio e plataforma | `V0_7_INTERFACE_AUDIO_PLATAFORMA.md` |
| 0.8 | Progressão e polimento | `V0_8_PROGRESSAO_POLIMENTO.md` |
| 0.9 | Identidade ContalMaster | `V0_9_IDENTIDADE_CONTAL_MASTER.md` |
| 0.10 | Tutoriais dos minigames | `V0_10_TUTORIAS_MINEGAMES.md` |
| 0.10.1 | Roteiro narrativo | `V0_10_1_ROTEIRO_NARRATIVO.md` |
| 0.10.2 | Ajuste de UI dos tutoriais | `V_0_10_2_ajuste_ui_tutorias.md` |
| 0.11 | Dois dias, cenários numerados, final dourado | `V0_11_DOIS_DIAS_CENARIOS_NUMERADOS_FINALE_DOURADO.md` |
| 0.12 | Novels, sprites e transições | `V0_12_AJUSTES_NOVELS_SPRITES_TRANSICOES.md` |
| 0.12.1 | Ajustes de personagens | `V0_12_1_ajustes_personagens.md` |
| 0.12.2 | Estabilidade e saves | `V0_12_2_CORRECAO_ESTABILIDADE_E_SAVES.md` |
| 0.13 | Tela de Loading + ícones | `V0_13_loading_icons.md` |
| 0.13.1 | Sala de reunião sem cortes solo, logo final, padronização ContalMaster, avisos de sintaxe, leveza web | `V0_13_1_sala_reuniao_logo_padronizacao.md` |
| 0.13.2 / 0.13.2.1 | Cena de chegada à sala (porta, luzes) e conversa Jales/Natalia; hotfix do carregamento da imagem 13 | `V0_13_2_chegada_sala_reuniao.md` |
| 0.13.3 | Trilhas sonoras da nova identidade (correção do `musica_stop` + padronização + compressão) e unificação das linhas 0.13.1 e 0.13.2 | `V0_13_3_trilhas_sonoras_e_unificacao.md` |
| **0.13.4** | **Som da porta na chegada à sala, corredor com 1 quadro, correção dos erros de console (véu da cortina dourada, sirenes da Perseguição e meta `tween` do menu de modo); registra as correções do `preparar_musicas.py`** | `V0_13_4_porta_corredor_correcoes_console.md` |
| 0.14.1 | Otimização para Web (itch.io): WebBridge, AudioManager leve, texturas reduzidas, tráfego por horário | `V0_14_1_OTIMIZACAO_WEB.md` |
| 0.14.2 | Tela de carregamento unificada | `V0_14_2_TELA_CARREGAMENTO_UNIFICADA.md` |
| 0.14.3 | Aparelhos fracos (4 GB), tela cheia/redimensionamento e clique duplo no Continuar | `V0_14_3_OTIMIZACAO_APARELHOS_FRACOS_E_FULLSCREEN.md` |
| **0.14.4** | **Unificação com o patch 0.14.2 do Desvio Lógico: bolinhas de tráfego, ritmo da música por horário, respostas A/B abaixo da pergunta, 2 postes por lado** | `V0_14_4_UNIFICACAO_DESVIO_LOGICO_0_14_2.md` |
| 0.14.4.1 | Hotfix "WebGL context lost" no Desvio Lógico (web): água em densidade reduzida, tela de recarregar no lugar do alert, log de VRAM/desenhos | `V0_14_4_1_HOTFIX_WEBGL_CONTEXT_LOST.md` |
| 0.14.4.2 | STOP: título "STOP - CONTROLE NORMATIVO", 6 opções fixas (3×2) sempre da mesma letra, limpeza do script (conteúdo de TI removido) e termos extras no dicionário | `V0_14_4_2_STOP_TITULO_6_OPCOES_LIMPEZA.md` |
| **0.16.2** | **Limite dinâmico nos 8 minigames (Roleta e Naval), conteúdo sem repetição, feedback didático "Na prática", novels mais enxutas** | `V0_16_2_LIMITE_DINAMICO_8_MINIGAMES_E_FEEDBACK.md` |
| 0.16.3 | Acessibilidade: opção de tamanho da fonte (Pequena · Média · Grande · Extra grande) | `V0_16_3_ACESSIBILIDADE_FONTE.md` |
| 0.16.4 (colega) | Roleta de Risco: 1 giro fixo; limite dinâmico só em 5 minigames | `V0_16_4_ROLETA_1_GIRO_LIMITE_DINAMICO_5_MINIGAMES.md` |
| **0.16.4** | **Ajustes da fonte Extra grande: respostas/feedback crescem para os lados, card do Desvio Lógico enxuto, botão de pausa apagado/aceso, selo de versão mais alto** | `V0_16_4_AJUSTES_FONTE_EXTRA_GRANDE_E_HUD.md` |
| **0.16.5** | **Hotfix: respostas não estouram mais a tela, tutoriais com folga no rodapé, selo do menu mais baixo** | `V0_16_5_HOTFIX_ALTURA_RESPOSTAS_TUTORIAL_E_SELO.md` |
| **0.16.6** | **Show do Bilhão se auto-ajusta à altura da tela; sprites do tutorial não cobrem Tela cheia/Pausar** | `V0_16_6_AUTOAJUSTE_ALTURA_E_SPRITES_TUTORIAL.md` |
| **0.16.7** | **Padrão único de layout dinâmico (`DynamicLayout`) aplicado em Show do Bilhão, Perseguição e Maleta Certa** | `V0_16_7_PADRAO_LAYOUT_DINAMICO.md` |
| **0.16.8** | **Roleta de Risco volta a 1 giro (reaplicada sobre a base atual); retrato do tutorial preso à base real do card em qualquer fonte; DynamicLayout alinha ao topo quando não cabe** | `V0_16_8_ROLETA_1_GIRO_TUTORIAL_RETRATO_BASE.md` |
| **0.16.9** (a 0.16.9.6) | **Linha unificada: tutorial sem invasão de retrato, hotfix da Perseguição, Desvio Lógico (fonte grande, score no card, laterais, postes por script e na calçada, luzes dos carros), botão TELA e tela cheia no celular** | `V0_16_9_UNIFICADO.md` |
| **0.16.10** | **Desvio Lógico: farol do Bionix pequeno e discreto, fundos a 1920 e guia do editor sem custo no jogo (−26 MB de textura), remoção de código morto e constantes sem uso, `.gitignore`/`.gdignore` do `build/`** | `V0_16_10_DESVIO_FAROIS_E_LIMPEZA.md` |
| **0.16.11** (a 0.16.11.1f) | **Desvio Lógico para o web: sem postes por script nas versões antigas, fundo 100% estático, aura de luz do Bionix, postes fixos, ciclista, parada em tempo exato e animação final da bifurcação; pause espaçoso e botão TELA direto na Fullscreen API** | `V_0_16_11_limpeza_web_aureola_fundo_estatico.md` |
| **0.16.12** | **Desvio Lógico: Bionix sobe mais rápido e chega perto da bifurcação, cone do farol mais curto (mesma largura) e água do fundo por shader (GPU) no lugar das linhas desenhadas** | `V_0_16_12_bionix_farol_agua_shader.md` |
| **0.16.13** | **Desvio Lógico: diretor dinâmico de NPCs (ondas de 1 ou 2, faixa sorteada com pesos pelo movimento do jogador, sem seca por faixa, últimos carros saem de vista antes da parada; corrige o spawn que parava na metade) e água com faixas de luz visíveis também em água escura** | `V_0_16_13_trafego_dinamico_e_agua.md` |
| **0.16.14** | **Desvio Lógico: Bionix encolhe de forma contínua ao subir até a bifurcação (0,50), tráfego do Fácil mais ativo com duplas e mais variedade de faixas** | `V_0_16_14_bionix_encolhe_e_facil.md` |

### Observações do histórico

- **Antes da 0.13.1** o `config/version` do `project.godot` ainda marcava `0.9.2.1` (e havia valores diferentes no `GameManager` e em fallbacks). A 0.13.1 unificou tudo em uma fonte só.
- **Etiquetas internas do Desvio Lógico:** comentários em `scenes/minigames/desviologico/` citam `V0.13.9.x` a `V0.13.13.x`. São **iterações internas do módulo**, anteriores a este cronograma, e **não** são versões do projeto. Numericamente `0.13.13.x` "parece" maior que `0.13.3`; por isso, comentários novos devem citar a versão do projeto (ex.: `V0.13.3`).
- **Quer deixar a linha 0.13 "fechada"?** Basta subir para `0.14.0` nos três lugares acima; nada mais depende do número.
