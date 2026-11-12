# V0.14.4 — Unificação com o patch 0.14.2 do Desvio Lógico

Base preservada: **contalmasterVatual (0.14.3)**. O patch `patch_web_v0_14_2` foi feito sobre uma linha anterior (0.14.1),
sem os módulos (`modules/DL*.gd`), sem `WebLite` e sem `WebBridge.display_refit`. Só os 3 arquivos dele foram comparados com a base atual:
`AudioManager.gd` e `DLConfig.gd` diferiam **apenas** pelas linhas do patch; `DesvioLogico.gd` aplicou sem conflito.

## O que veio do patch 0.14.2
| Melhoria | Onde |
|---|---|
| Texto "Tráfego X" some; 6 bolinhas na linha do "Desafio X/6 • Horário" (1–2 azul, 3–4 amarelo, 5–6 vermelho; acesas até o atual, a atual pulsa, futuras apagadas) | `DesvioLogico.gd` (`_on_traffic_dots_draw`), `DLConfig.traffic_dot_color()` |
| Ritmo da música sobe de 1.00 a 1.12 (+0.024 por horário, transição de 2,5 s); volta a 1.0 ao sair/trocar de música | `AudioManager.set_music_tempo()`, `DLConfig.MUSIC_TEMPO_STEP` |
| Respostas A/B numa linha centralizada **abaixo** do painel da pergunta, largura cresce com o texto (até ~46 % cada), mesma altura | `DesvioLogico.gd` (`answers_box`, `_layout_decision_answers`) |
| 2 postes por lado (eram 3): `POST_DEPTH_SLOTS = [0.12, 0.62]` | `DLConfig.gd` (consumido por `modules/DLSideProps.gd`) |

## Padrões identificados (por que cada coisa foi encaixada onde foi)
- **Constantes e regras do minigame ficam em `DLConfig`** (cores, passos, slots) → o patch já seguia isso; mantido.
- **Estado de áudio global fica no `AudioManager`** (1 player de música, sem criar bus em runtime, regra da 0.14.1) → o ritmo usa só `pitch_scale` + `move_toward` no `_process`, sem `AudioServer`.
- **Desenho caro é limitado por `WebLite`** (0.14.3) → o patch redesenhava as bolinhas a ~15×/s sempre.
- **Layout reage a `WebBridge.display_refit`** (0.14.3) → o patch media as respostas só uma vez, ao entrar na decisão.

## Adaptações feitas à arquitetura atual (além do patch)
1. **Bolinhas**: intervalo de redesenho 0,066 s (desktop) / 0,10 s (web) / 0,20 s (aparelho fraco) via `WebLite`. Helper `draw_circle_on` virou `_dot`.
2. **Respostas A/B**: refaz o layout em tela cheia/rotação/barra de endereço (`viewport.size_changed` + `WebBridge.display_refit`). Rotina com *token* (sem duas simultâneas) e guardas `is_inside_tree()`/`state` após cada `await` (evita erro se o jogador sair no meio). Largura com `clamp` seguro (o do patch invertia min/max em viewport estreita).
3. **Tutorial do Desvio Lógico** (`tutorials/data/desvio_logico.json`): cartão do passo "Escolha a rota" desceu de `card_y 0.34` para `0.42`, para não cobrir a nova linha de respostas.
4. Comentário de `DLSideProps.gd` atualizado (2 postes).
5. **Versão**: `project.godot` → `0.14.4`; `BrandText.DEFAULT_VERSION` estava em `0.13.4` (defasado) → `0.14.4`. Tabela do cronograma ganhou as linhas 0.14.1–0.14.4.

## Arquivos alterados
`scenes/minigames/desviologico/DesvioLogico.gd`, `DLConfig.gd`, `modules/DLSideProps.gd`,
`scripts/autoloads/AudioManager.gd`, `tutorials/data/desvio_logico.json`, `scripts/ui/BrandText.gd`, `project.godot`,
`docs/versionamento/CRONOGRAMA_VERSOES.md`, este documento.

## Como aplicar
Copie o conteúdo do zip por cima do projeto (mesmas pastas) e abra no Godot 4.5. Não há arquivos novos de código nem reimportação.

## Limites (leia)
- **Não foi executado**: não há Godot neste ambiente. Revisado por leitura e comparação com a base (indentação em tabs, balanceamento igual ao original), mas **precisa de teste no editor e no navegador**. Se aparecer erro de parse, me envie a mensagem.
- Na web o Godot 4.5 pode tocar música em modo "sample"; se o `pitch_scale` não surtir efeito lá, o ritmo só ficará fixo (sem quebrar nada). Confirme no itch.
- As bolinhas azul/amarelo/vermelho lembram as cores de dificuldade (ciano/amarelo/vermelho); o patch pedia assim, mas vale conferir se não confunde.
- O cartão do coach (0.42) e a altura das respostas dependem do tamanho do texto da pergunta: teste com a pergunta mais longa do banco.

## Como testar
1. Desvio Lógico, 6 horários: bolinhas acendem e a atual pulsa; "Tráfego X" não aparece.
2. Música: perceptivelmente mais animada a cada horário; ao sair para o menu volta ao normal.
3. Decisão: A/B abaixo da pergunta, sem sobreposição, mesma altura; teste com pergunta longa e redimensionando a janela/tela cheia.
4. Postes: 2 por lado; ciclista igual.
5. Tutorial (1ª partida): dica "Escolha a rota" sem cobrir os botões.
