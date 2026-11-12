# V0.14.3 — Aparelhos fracos (4 GB) + tela cheia/redimensionamento (web)

## Diagnóstico do botão "Continuar" (fim de game)
Ao clicar, `GameManager.complete_current_stage()` salvava, trocava de cena e **tudo acontecia no mesmo quadro**,
com a tela ainda mostrando o botão pressionado. Causas encontradas lendo o código:

| # | Causa | Efeito em aparelho de 4 GB |
|---|---|---|
| 1 | A `LoadingScreen` só carregava o `.tscn` (poucos bytes). As imagens grandes (cenário 1920×1080, sprites ~1120×1500) e a música eram carregadas no `_ready()` da cena nova, **depois** da barra chegar a 100 % | congelava 1–3 s logo após o Continuar |
| 2 | `play_music("loop_start")` na hora do clique (ogg de 2,8 MB) e, em seguida, outra música no `StageTransition` | duas cargas/decodificações de áudio |
| 3 | `TransitionFX` simulava 10 s de partículas de uma vez (`preprocess`) + zoom lento do cenário inteiro a cada quadro | pico de CPU ao abrir a transição |
| 4 | `complete_current_stage()` podia rodar **duas vezes**: com a tela congelada o jogador toca de novo. Resultado: `campaign_index += 2` (pulava uma fase) e pontos gravados em dobro | bug de progresso, não só lentidão |
| 5 | Dezenas de `Label` animados como partículas decorativas em 5 minigames | quadros lentos durante o jogo |

## O que mudou
| Arquivo | Mudança |
|---|---|
| `GameManager.gd` | `complete_current_stage()` só vale **1×** por fase (`_stage_open`). Ao clicar: cobre a tela com uma cortina (`ExitShield`), desliga e esconde a fase, espera 2 quadros e só então salva/troca de cena. Se a troca falhar, restaura a fase (nada de tela preta). Passa à `LoadingScreen` a lista de recursos pesados de cada cena (`_warm_for_*`). Na web não carrega mais `loop_start` no clique. |
| `SceneLoader.gd` | `change_scene(tree, path, warm_paths)`: recursos "aquecidos" ficam retidos até a próxima troca de cena e depois são liberados. |
| `LoadingScreen.gd` | Fila: **um recurso por quadro** (cenário, sprites, música) e por último a cena. A barra anda de verdade e o navegador desenha entre as cargas. Recurso opcional que falhar é ignorado; falha da cena mostra "Tentar novamente" como antes. |
| `WebLite.gd` | Novo perfil **aparelho fraco** (`low_end()`): liga sozinho com `navigator.deviceMemory ≤ 4` ou `hardwareConcurrency ≤ 4`, ou quando o FPS medido cai. `?low=1` força, `?low=0` desliga a detecção. Helpers `fx_scale()`, `scaled_count()`, `preprocess_seconds()`. |
| `TransitionFX.gd`, `StageTransition.gd` | Menos partículas, pré-aquecimento de 1,5 s (era 10 s) e cenário parado no perfil fraco. |
| `Stop`, `ForcaTecnica`, `ShowDoBilhao`, `BatalhaNaval`, `MaletaCerta` | Só a contagem de partículas decorativas passa por `WebLite.scaled_count()` (desktop: igual a antes; web: −25 %; fraco: −60 %). Jogabilidade intacta. |
| `WebBridge.gd` | Ver "Tela cheia" abaixo + medidor de FPS: abaixo de ~36 FPS por 8 s seguidos liga o perfil fraco e limita o motor a 30 FPS. |

## Tela cheia / redimensionamento
- **Sair da tela cheia, girar o aparelho, mexer na barra de endereços, voltar de outra aba/janela**: o `WebBridge` re-mede a tela em 0, 120, 350, 800 e 1600 ms (os navegadores atualizam `innerWidth/innerHeight` *depois* do evento), manda o motor reler o tamanho, força os Controls a recalcularem se o canvas já mudou e emite `WebBridge.display_refit(size)`.
- **Opção "Tela cheia" desalinhada**: antes, o jogo abria com "LIGADA" salva (o navegador não deixa entrar em tela cheia sem toque) e, ao sair com Esc, o botão continuava "LIGADO" — o primeiro clique parecia não fazer nada. Agora na web a opção começa desligada e acompanha o estado real (`SettingsManager.sync_fullscreen_state`); a tela de Configurações atualiza o botão sozinha.
- **Aba escondida durante um minigame** (trocar de aba/app): abre o **Pause** sozinho. Ao voltar, o jogo está parado, sem tempo "pulando".

## Como aplicar
1. Copie o conteúdo do zip por cima do projeto (mesmas pastas) e abra no Godot 4.5.
2. Exporte para Web (Threads desligado, shell `res://web/shell.html` como antes). `web/shell.html` **não** mudou.
3. Suba o build e teste com cache limpo (Ctrl+Shift+R).

## Como testar
- `?debug=1` na URL: o log `[CM-DEBUG]` agora mostra `web/lite/low_end`. Se o medidor ligar o perfil fraco aparece `[CM-PERF]`.
- `?low=1`: simula o aparelho fraco em PC forte. No editor: `-- --low`.
- Teste do clique duplo: no fim de um game, toque 3× rápido em Continuar — a campanha deve avançar **uma** fase só.
- Tela cheia: Configurações → Tela cheia → Esc → o botão deve voltar para DESLIGADO e o jogo ocupar a janela inteira. Repita girando o celular.

## Limites (leia)
- **Não foi executado**: não há Godot nem navegador neste ambiente. O código foi revisado por leitura (indentação, nomes de constantes/métodos, balanceamento) e comparado com os originais, mas **precisa de um teste real no editor e no navegador**. Se aparecer erro de parse no Godot, me envie a mensagem.
- Na web sem threads, `load_threaded_request` ainda decodifica cada imagem de forma síncrona; o ganho é **fatiar** o trabalho em vários quadros (e deixar a tela de loading respirar), não eliminá-lo.
- O medidor de FPS e a detecção por `deviceMemory` são heurísticas: o Safari não expõe `deviceMemory`; lá vale o medidor e o `?low=1`.
- Próximo passo possível (não feito, pois exige reimportar assets): texturas com compressão VRAM só para backgrounds. Em desktop o navegador costuma não ter ETC2/ASTC, então precisa ser testado nos dois tipos de aparelho antes.
