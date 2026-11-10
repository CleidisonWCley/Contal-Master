# V0.12 — Ajustes: sprites _2/_3, corredor, transições e novels limpas

> **Status:** compilado e renderizado no Godot 4.5.1 (Compatibilidade) fora do editor; **falta testar o fluxo completo da campanha dentro do jogo** (checklist no fim).

## 1. O que mudou

| # | Pedido | Como ficou |
|---|---|---|
| 1 | Sprites `_3` nas novels/tutoriais, **sem cortar detalhes** | Usados **inteiros** (imagem 1664×2080), sem recorte por código. Base do recorte encostada na base da tela. `TutorialManager.SPRITE_SETS` guarda as medidas. |
| 2 | Sprites `_2` na cena final | Corpo inteiro (1536×2304), com os **pés na linha do chão** de cada cenário + sombra de contato. Quem fala **não levanta mais** (só brilha e cresce 4% a partir dos pés). |
| 3 | Personagens flutuando | Chão por cenário em `Paths.CUTSCENE_FLOOR`. Elenco em 2 fileiras em perspectiva (fundo no chão mais alto e menor). Caixa de dialogo foi para o **topo** nas cenas com personagens em pé. |
| 4 | Fundo 12 (corredor) | Cena nova entre o escritório e a sala: **Natalia (`natalia_2`)** conversa com o jogador em novel, **2 quadros** (`final.json > corridor`). |
| 5 | Sem bola/tremor nas transições | Removidos o círculo pulsante, a escala do título e a rotação do ícone. |
| 6 | Títulos 5–6 s, no topo | `TITLE_SECONDS = 5.5`, painel centralizado no **topo**. Clique só adianta após 1,6 s. |
| 7 | Partículas | Reconstruídas (`TransitionFX.gd`, CPUParticles2D): brilhos, bolhas e riscos de luz. **Sem letras/siglas de TI.** |
| 8 | Fundo das novels desfocado | Shader `assets/shaders/novel_blur.gdshader` + `NovelBlur.gd` (24 amostras, funciona na Compatibilidade). Força em `NovelBlur.DEFAULT_RADIUS`. |
| 9 | Som da transição | Toca a **música do próprio minigame** (`AudioManager.PHASE_MUSIC`) e segue sem corte quando o minigame começa. |
| 10 | Sem títulos de apoio ao lado do nome | Novels e tutoriais: **nome** e, embaixo, a **fala**. Removidos também a etiqueta (ESTRATÉGIA, COMO JOGAR…). O contador "1/2" continua à direita. |

## 2. Arquivos

**Novos:** `assets/shaders/novel_blur.gdshader`, `scripts/ui/NovelBlur.gd`, `scenes/cutscenes/TransitionFX.gd`, este documento.
**Alterados:** `Paths.gd`, `AudioManager.gd`, `GameManager.gd` (versão 0.12.0), `TutorialManager.gd`, `TutorialOverlay.gd`, `NovelStage.gd`, `StageTransition.gd`, `CutsceneFinal.gd`, `final.json`.

## 3. Pontos de atenção

- O arquivo do corredor se chama `012_corredor.png` (3 dígitos); o código usa esse nome. Se renomear, mude só `Paths.BG_CUT_12_CORREDOR`.
- O campo `title` dos JSONs deixou de ser exibido; pode ficar como anotação.
- "Reduzir para 2 quadros" foi aplicado à **mensagem de apoio da Natalia** (antes 3 narrações). As apresentações dos minigames continuam com 3 quadros.
- A **introdução** (`CutsceneIntro`) não recebeu o desfoque nem mudou de sprite (continua com o Jales original). As partículas de letras do **Forca Técnica** (`TECH_SYMBOLS`) são do minigame, não da transição, e não foram tocadas.
- Zoom lento do cenário na transição: `BACKGROUND_DRIFT_PER_SECOND = 0` deixa o cenário parado.
- Abra o projeto no editor uma vez (gera os `.import` dos novos arquivos).

## 4. Checklist de testes

1. Campanha: título no topo ~5,5 s, sem bola nem tremor; música do minigame já tocando.
2. Novel de cada minigame: sprites `_3` inteiros, fundo desfocado, só nome + fala.
3. Tutoriais: cartão sem etiqueta/título; retrato `_3` completo.
4. Final: escritório → corredor (Natalia, 2 quadros) → sala (elenco com pés no chão) → score → créditos.
5. Configurações > Animações desligadas: sem partículas, sem erros.
6. Janela pequena/celular: caixa no topo não cobre cabeças.
