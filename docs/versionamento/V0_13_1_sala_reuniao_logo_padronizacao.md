# ContalMaster — V0.13.1: sala de reunião, logo final, padronização e leveza web

Feito **por cima da V0.13** (tela de Loading + ícones, `contalmaster_1.zip`). Ordem de aplicação, na raiz do projeto (onde está o `project.godot`):

```bash
patch -p1 < contalmaster_v0.13.1.patch                # funcional + padronização + avisos + este doc
patch -p1 < contalmaster_v0.13.1_otimizacao_web.patch # OPCIONAL: só arquivos .import
```

Os dois são independentes. O segundo mexe só em `*.import` (para desfazer: `patch -R -p1`). O Godot reimporta as imagens na primeira abertura.

> **Não testado no editor.** Não havia Godot no ambiente onde o patch foi preparado. Os patches aplicam limpo sobre o `contalmaster_1.zip`
> (testado com `patch -p1`) e os scripts passaram em checagens estáticas, mas **a cena final precisa ser jogada uma vez** (checklist no fim).

---

## 0. Compatibilidade com a V0.13 (loading + ícones)

Comparei o `contalmaster_1.zip` com a base anterior (V0.12). A V0.13 alterou apenas: `project.godot` (main scene → `LoadingScreen`, boot splash),
`GameManager._change_scene()` (agora `SceneLoader.change_scene`), `Paths.gd` (+`SCENE_LOADING`, −`ICON_PLAY`), `StageTransition.gd` (ícone do Desvio Lógico),
os arquivos novos (`SceneLoader`, `scenes/loading/*`, `web/shell.html`, `icon_loading*.png`) e os ícones otimizados/removidos.
`CutsceneFinal.gd`, `NovelStage.gd` e `CutsceneIntro.gd` **não foram tocados**, então as mudanças deste patch entram sem conflito.

- **Cutscenes passam pela Loading** (`SceneLoader.HEAVY_PREFIXES` inclui `res://scenes/cutscenes/`). Nada a mudar: a cena final abre pela Loading e, ao fim, "Voltar ao menu" é troca direta.
- O logo da cena final é carregado com `load()` (120 KB), dentro da própria cena já carregada: não pesa na Loading.
- Itens da V0.13 que este patch **não alterou**: boot splash, ícones, `icon_loading*`, `SceneLoader`, lógica da `LoadingScreen`.
  Só corrigi o **nome** nos textos/comentários deles (ver seção 1).

## 1. Padronização de versão e nome

**Versão única: `0.13.1`** (a V0.13 já existe; a atualização tem que ser posterior a ela. O `0.12.2.2` combinado antes ficaria *abaixo* da versão atual).
Havia 4 valores diferentes no código (`0.9.2.1` no `project.godot`, `0.12.0` no `GameManager`, fallbacks `0.9.2.1` e `0.12.1`).

**Nome único: `ContalMaster`** (junto). A marca colorida continua "Contal" branco + "Master" roxo, agora **sem espaço**.

| Onde | O que mudou |
|---|---|
| `project.godot` | `config/version="0.13.1"` (fonte da versão) |
| `scripts/ui/BrandText.gd` | `BRAND_NAME`, `DEFAULT_VERSION`, `app_version()` (lê o `project.godot`, com reserva); `brand_bbcode()` sem espaço; `version_bbcode()`/`version_plain()` sem argumento usam a versão atual |
| `scripts/autoloads/GameManager.gd` | `APP_NAME`/`APP_VERSION` vêm do `BrandText` |
| `main_menu.gd`, `CutsceneFinal.gd` | removidos os fallbacks com versão fixa |
| `CutsceneIntro.gd`, `final.json` | "Contal Master"/"CONTAL MASTER" → ContalMaster/CONTALMASTER |
| `LoadingScreen.gd`, `web/shell.html` | nome em comentário, `alt` do logo e aviso de JavaScript desativado |
| comentários | `UiPalette`, `ButtonStyles`, `question_bank` |

**Deixado de propósito:** `user://contal_master_scores.json` e `..._achievements.json` (`Paths.gd`): renomear apagaria recordes/progresso salvos; e os `.md` históricos em `docs/`.

> **Ao subir de versão:** altere `config/version` no `project.godot` **e** `DEFAULT_VERSION` em `BrandText.gd`. Se preferir outro número (ex.: `0.13.0.1`), são só esses dois lugares.

## 2. Cena final após os créditos: logo

**Decisão: usar `assets/contalmaster_logo.png`** (816×306, transparente, "Contal" branco + "Master" roxo) dentro da cortina dourada que já existia: é a identidade oficial e tem bom contraste sobre a imagem escurecida. O logo "respira" (escala 0 a 2,2%, onda lenta) enquanto está na tela, além do fade/zoom de entrada.

- Se a imagem não carregar, cai no texto `CONTALMASTER` colorido.
- Ajustes em `CutsceneFinal.gd`: `LOGO_SIZE`, `LOGO_SIZE_COMPACT`, `LOGO_BREATH_SCALE` (`0.0` desliga a respiração). Caminho: `Paths.LOGO_CONTALMASTER`.

## 3. Sala de reunião sem cortes solo

### Fluxo (`CutsceneFinal._run_story`)
1. Um único corte (fade) para entrar na sala.
2. **Agradecimentos em janela de 3:** entra quem fala (sobe do chão); com 3 em cena, o **mais antigo sai andando pela lateral** e o novo ocupa o lugar dele (esquerda, meio, direita, repetindo). Ficam os 3 últimos (Cleiton, Natália, Jales).
3. **Todos saem** andando pela lateral; sala vazia por um instante.
4. **Jales volta pela esquerda e Ariel pela direita**, mesma cena, sem corte, e conversam para apresentar a pontuação.
5. A **pontuação sobe** (igual a antes).
6. **Jales centralizado**, mesma sala, sem corte: "Antes que você vá, quero lhe dizer algo..." + fala final por desempenho.
7. Créditos, cena final, Game Over (inalterados).

Removidos os cortes pretos solo do Ariel e do Jales. **Tamanho:** a sala usa os mesmos valores do escritório (antes do corredor): `Paths.CUTSCENE_FLOOR["sala_reuniao"] = {"front": 1.05, "back": 1.05, "ppm": 0.55, "row_ppm": 0.55}` (era `0.76 / 0.68 / 0.30 / 0.265`).

### Quantidade de caixas
- Agradecimentos: **mesmas 10 caixas**. Fala final do Jales: **mesmas caixas** (a abertura "Antes que você vá..." é colada na 1ª fala; `closing_intro` no `final.json`, `""` desliga).
- Placar: era 1 caixa (Ariel), agora **2** (fala curta do Jales + a do Ariel): única caixa nova, necessária ao diálogo. Texto em `final.json > score_dialogue.jales`; vazio = volta a 1 caixa.

### Locais de manutenção

| O que ajustar | Onde |
|---|---|
| Personagens juntos na sala | `CutsceneFinal.CAST_WINDOW` |
| Posição dos 3 lugares (0 a 1) | `CutsceneFinal.CAST_SLOTS` |
| Jales/Ariel no placar | `SCORE_SLOT_JALES`, `SCORE_SLOT_ARIEL` |
| Pausa com a sala vazia | `EMPTY_ROOM_SECONDS` |
| Jales na fala final | `CLOSING_SLOT_JALES` |
| Ordem/texto dos agradecimentos | `final.json > cast_thanks` (a janela se adapta) |
| Fala do Jales antes do placar | `final.json > score_dialogue.jales` |
| Fala do Ariel | `final.json > tiers[].ariel` |
| Abertura da fala final | `final.json > closing_intro` |
| Tamanho/chão | `Paths.CUTSCENE_FLOOR["sala_reuniao"]` |
| Lado de saída do lugar do meio | `CutsceneFinal._door_side()` |

### Novo no `NovelStage.gd`
- Chaves de quadro: `slide: {id: "left"|"right"}` (anda pela lateral ao entrar/sair) e `slots: {id: 0..1}` (posição a partir deste quadro).
- Opções de layout: `exit_slide`, `exit_dirs`, `exit_wait`. Constantes: `SLIDE_ENTER_SECONDS`, `SLIDE_EXIT_SECONDS`, `SLIDE_DISTANCE`.
- Correção junto: o destaque de quem fala brigava com o fade de entrada (ambos animavam `modulate`); agora o destaque anima só RGB. Quem está saindo não é reposicionado.
- O suporte a `row_ids` (fileira) permanece no `NovelStage`, mas nenhuma cena usa mais (`CAST_ROW` foi removida).

## 4. Natália saindo do escritório

No fim do bloco `meeting_call`, a Natália **sai andando pela lateral** rumo ao corredor e o fade para o corredor começa **no meio** da caminhada. Ajustes em `CutsceneFinal.gd`: `NATALIA_EXIT_SIDE` (`"right"`/`"left"`, o lado da porta) e `NATALIA_EXIT_WAIT` (0 = fade junto; 1 = espera ela sair).

## 5. Avisos de sintaxe

| Aviso | Correção |
|---|---|
| `SHADOWED_VARIABLE_BASE_CLASS` (`position`) | `CutsceneIntro` (→ `point`/`pos`), `main_menu`, `RoletaRisco` (→ `spot`), `CutsceneFinal` |
| idem (`theme`, `size`) | `TransitionFX._build()` → `fx_theme`, `fx_size` |
| `INT_AS_ENUM_WITHOUT_CAST/MATCH` | `expand_mode = 1` → `TextureRect.EXPAND_IGNORE_SIZE`; `stretch_mode = 5/6` → `STRETCH_KEEP_ASPECT_CENTERED/_COVERED` (`CutsceneIntro`, 7 minigames, `AchievementManager`) |
| `UNUSED_PARAMETER` | `bg_color`/`border_color` removidos de `_create_cutscene_button()` e dos 2 chamadores; prefixo `_` em `_elapsed_seconds`, `_remaining_ratio`, `_reserve`, `_compact` |

Varredura em **todo** o projeto (inclui os arquivos novos da V0.13: `SceneLoader` e `LoadingScreen` estão limpos nessas famílias). Outras famílias (`INTEGER_DIVISION`, `NARROWING_CONVERSION`) **não foram verificadas**; se aparecerem no painel, me mande a lista.

## 6. Leveza para a web

### O que a V0.13 já resolveu (não repetido aqui)
Ícones coloridos grandes (`trofeu`, `mala`, `cadeado`, `perigo`, `naval`, `money`) já estão em 256 px; `icon_loading` em 512 px; `play/exit/settings.png` pretos, as `.webp` das insígnias e o `DynamicQuestionBank.gd` (código morto de 7 mil linhas) já foram removidos.

### Ainda pesado
~100 MB de imagens em `compress/mode=0` e **resolução cheia**: sprites de 1536×2304 e 1792×2400 exibidos com ~700 a 1100 px de altura; insígnias 1920×1920 exibidas com ~56 px; ícone do app 1920×1920; um fundo 3000×2000. Pesa no download (`.pck`) e na memória de vídeo. Os personagens são posicionados pelas medidas gravadas em `TutorialManager.SPRITE_SETS` e desenhados com `EXPAND_IGNORE_SIZE`, então reduzir a resolução importada **não muda posição nem escala**.

### Patch opcional (60 arquivos `.import`)
| Grupo | Mudança |
|---|---|
| Sprites `_1`/`_2` | `size_limit = 1536` |
| Sprites `_3` (tutoriais) | `size_limit = 1152` |
| Insígnias PNG | `size_limit = 640` |
| Ícone do app | `size_limit = 512` |
| Fundos opacos | `size_limit = 1920` + compressão lossy qualidade 0,9 |

Estimativa (recodificação em WebP, como o Godot faz): imagens afetadas **~56 → ~22 MB no `.pck`** e **~655 → ~350 MB** de memória de vídeo se tudo estivesse carregado junto. Os números reais saem no seu export. Fundos com transparência ficam sem perda. Se alguma imagem ficar "mole" em tela cheia, suba o `process/size_limit` só dela (ou volte o fundo para `compress/mode=0`).

### Recomendações não aplicadas
1. **Export Web → Resources → Filters to exclude:** `docs/*` (e `web/*` se o shell não precisar entrar no pacote).
2. **Áudio:** ✅ trilhas tratadas na **V0.13.3** (ver `V0_13_3_trilhas_sonoras_e_unificacao.md`). Resta apenas `efeitos/roleta.wav` (2,5 MB), que poderia virar `.ogg`.
3. **Hospedagem:** Brotli/gzip para `.wasm`/`.pck` é o maior ganho de download.
4. **Export:** *Thread Support* desligado (salvo COOP/COEP no host); como a V0.13 notou, sem threads a barra da Loading pode saltar (a suavização cobre).
5. Os `_process` têm guardas e, numa varredura simples, não encontrei `load()` dentro de `_process`/`_draw`/`_update_*`.

## 7. Arquivos alterados (patch principal)

`project.godot`, `NovelStage.gd`, `CutsceneFinal.gd`, `CutsceneIntro.gd`, `TransitionFX.gd`, `main_menu.gd`, 7 minigames (só enums/parâmetros), `AchievementManager.gd`, `GameManager.gd`, `Paths.gd`, `question_bank.gd`, `final.json` (versão 3 → 4: removidas `backgrounds.ariel_intro`/`jales_closing` e o bloco `ariel_intro`; adicionados `score_dialogue` e `closing_intro`), `BrandText.gd`, `ButtonStyles.gd`, `UiPalette.gd`, `TutorialOverlay.gd`, `LoadingScreen.gd`, `web/shell.html` e este documento.

## 8. Checklist de teste

1. Primeira abertura: Loading (com o nome ContalMaster nas dicas/título) → menu; selo **ContalMaster V0.13.1**.
2. Campanha até o fim: a cena final abre pela Loading. No escritório, a Natália **sai andando** e o corredor entra com ela ainda saindo.
3. Sala: entram Jales, Priscila, Anderson; com o Tiago o Jales **sai pela esquerda**; segue até ficarem Cleiton, Natália e Jales.
4. Todos saem; sala vazia; **Jales pela esquerda e Ariel pela direita**; placar sobe; Jales **centralizado** sem tela preta com "Antes que você vá...".
5. Créditos (mesmo selo de versão) e **logo** com brilho dourado + "Obrigado por jogar!"; Game Over → menu direto (sem Loading).
6. Com **animações desligadas**: fluxo completo sem travar (sem deslizar, só aparece/some).
7. Redimensionar a janela na sala não desloca ninguém.
8. Se aplicou a otimização: conferir um fundo, um personagem e as insígnias em tela cheia.
9. Painel de erros: avisos da lista original devem ter sumido.

Olho de designer: **(a)** com `ppm 0.55` os personagens ficam grandes, então os 3 lugares (0,20 / 0,50 / 0,80) podem pedir ajuste em `CAST_SLOTS`; **(b)** os textos `score_dialogue` e `closing_intro` são sugestão de redação.
