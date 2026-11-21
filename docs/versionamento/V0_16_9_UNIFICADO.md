# V0.16.9 — Documento unificado (0.16.9 a 0.16.9.6)

> Reúne em tópicos os 7 documentos da linha 0.16.9. O número do jogo ficou em **0.16.9** durante toda a linha; os sufixos `.1` a `.6` são entregas internas. O texto de cada entrega foi preservado, só reorganizado por tópico. A linha seguinte é a **0.16.10** (`V0_16_10_DESVIO_FAROIS_E_LIMPEZA.md`).

## Índice

| Entrega | Tópico |
|---|---|
| 0.16.9 | Tutorial: retrato sem invadir texto/botões e corte da cintura da Aline |
| 0.16.9.1 | Hotfix: Perseguição sem perguntas/barra (DynamicLayout) |
| 0.16.9.2 | Desvio Lógico (decisão) e Maleta Certa com fonte Grande/Extra grande |
| 0.16.9.3 | Desvio Lógico: score no card, feedback à frente do HUD, tutorial da Natalia |
| 0.16.9.4 | Laterais do Desvio, botão TELA compacto, tela cheia no celular |
| 0.16.9.5 | Postes por script, luz noturna, cache das trilhas |
| 0.16.9.6 | Postes na calçada, lanternas dos carros e farol do Bionix |

---

## V0.16.9 — Tutorial: retrato sem invadir texto/botões + corte da cintura da Aline

### 1) Retratos invadindo o texto e o botão "Próximo" (todos os personagens)
**Causa:** `TutorialOverlay._layout` reservava a área do retrato com a altura MÍNIMA do card. Com fonte grande (ou texto
longo) o card cresce, o retrato cresce junto (ele é proporcional ao card) e passava da área reservada, cobrindo o fim do texto
e o botão "Próximo". Além disso, perto da borda da tela o retrato é empurrado para dentro (nunca passa de 14 px da borda), e a
reserva ignorava esse recuo.
**Correção:**
- A reserva agora é recalculada com a altura REAL do card, em até 3 passadas (card -> reserva -> largura do texto -> card).
- A reserva usa o deslocamento EFETIVO do retrato (limitado pela borda da tela).
- Card mais largo: 1060 -> 1140 px (o texto quebra em menos linhas, o card fica mais baixo e o retrato menor).
- Mantida a margem de segurança do botão: os botões ficam sempre dentro da área livre, à esquerda do retrato (opção "mais
  largo" escolhida; não foi preciso centralizar os botões).

### 2) Aline — borda da cintura
O desenho dela termina numa curva (cabelo + paletó) que, rente ao card, parecia uma borda solta. Todos os retratos agora ficam
dentro de um recorte (`PortraitClip`) cuja base é a base do card, e `BUST_FRAMES` ganhou o campo opcional **`sink`**
(fração da altura do PNG que o desenho "afunda" sob a base): **só a Aline usa (0.07)**. O trecho curvo some sob o card e o corte
vira uma linha reta rente à borda. Os demais personagens não mudaram (sink = 0, base do desenho = base do recorte).
Para ajustar: `TutorialManager.BUST_FRAMES["aline"]["sink"]` (maior = mais cintura escondida).

### Versão
`project.godot` (mantido `viewport_height=670`) e `BrandText.DEFAULT_VERSION` → **0.16.9**.

---

## V0.16.9.1 — Hotfix: Perseguição "sem perguntas, barra e mecânica" (versão do jogo continua 0.16.9)

### Sintoma
No minigame **Perseguição** só aparecia o fundo (sirenes/alertas) e os botões globais; título, pergunta, ações A/B e barra
de tempo sumiam. O tutorial (Ariel) continuava visível. O fundo NÃO estava por cima do jogo.

### Causa (reproduzida no Godot 4.5)
1. O `DynamicLayout` (V0.16.7) mede a coluna do jogo em vários níveis. No 1º layout, o `hint_label` da Perseguição
   (texto longo com `AUTOWRAP` e sem largura mínima) media altura de "1 letra por linha": a coluna chegava a **~1780–5300 px**.
2. O `SafeArea` (MarginContainer em tela cheia) **crescia junto** (altura ~3947 px) e **não voltava** ao tamanho da tela
   quando o conteúdo encolhia.
3. A coluna é centralizada dentro do SafeArea → o jogo inteiro ficava em y ≈ 1768, **fora da tela** (670 px).
   O tutorial é outra camada, por isso continuava aparecendo.

### Correção
- `scripts/ui/DynamicLayout.gd`: após medir os níveis, `_restore_root_size()` devolve o SafeArea a tela cheia
  (protege **todos** os minigames que usam DynamicLayout).
- `scenes/minigames/perseguicao/Perseguicao.gd`: `hint_label` ganhou largura mínima (420 px), então a medição
  fica correta e o jogo volta ao nível visual completo (nível 0) em vez de esconder elementos.

### Teste
`tools/tests/font_scale_audit.tscn` em 1280×670 — Perseguição, Show do Bilhão e Maleta Certa nos 4 tamanhos de fonte:
0 problemas; Perseguição conferida em print (Pequena/Média/Grande/Extra grande).

---

## V0.16.9.2 — Ajuste: Desvio Lógico e Maleta Certa com fonte Grande/Extra grande (versão do jogo continua 0.16.9)

### Desvio Lógico (fase de decisão)
Problemas vistos no print (Extra grande, 1280×670): a pergunta ficava POR BAIXO dos botões "Tela cheia"/"Pausar" e do placar
(primeira linha cortada), com painel estreito (78% da tela) e várias linhas de altura.
- `DesvioLogico.gd` → novo `_layout_question_panel()`: o painel da pergunta **alarga conforme a fonte** (margem lateral 11% → 3%),
  continua **centralizado**, e com fonte Grande/Extra grande **desce** para abaixo da faixa de Tela cheia/Pausar/Score.
  A altura vem do texto (mín. 13% da tela). Também refaz o layout se a fonte for trocada pelo pause durante a decisão.
- Respostas (ROTA A/B): mais largas com fonte grande (quebram menos linhas), com um **vão central de ~120 px** para o Bionix
  continuar visível, e a camada de respostas agora fica em z=69 (**sempre à frente** dos cards do desafio e do acelerador; o fim de jogo usa 70).

### Maleta Certa
O ícone da maleta nos botões expandia até ~115 px e, com texto de 2+ linhas em Extra grande, sobrepunha "MALETA n" e cortava a resposta.
- `MaletaCerta.gd` → `_fit_buttons_scaled`: ícone com tamanho próprio (`icon_max_width` = 48×k px, k do DynamicLayout), altura do botão
  reserva ícone + texto, e o texto fica **centralizado**.

### Testes (Godot 4.5, 1280×670, 4 tamanhos de fonte)
`tools/tests/font_scale_audit.tscn`: Desvio Lógico forçado na fase de decisão com pergunta/respostas longas e Maleta Certa com respostas de
3 linhas — sem sobreposição em nenhum tamanho. (O ZIP inclui também os arquivos do hotfix V0.16.9.1.)

---

## V0.16.9.3 — Desvio Lógico: score no card, feedback à frente do HUD e tutorial da Natalia (versão do jogo continua 0.16.9)

### Score movido para o card inferior esquerdo
- O quadro "Score: n pts" do topo foi removido. O card de status agora mostra, na primeira linha, **DESVIO LÓGICO | SCORE: n**
  e, abaixo, "Desafio X/6 • Horário" + bolinhas e a dificuldade (`score_value_label`, atualizado por `_refresh_score_label()`).
- O "+10 / -10" que sobe ao pontuar agora nasce ao lado do texto "SCORE: n".
- Com o topo livre, a pergunta fica **centralizada no topo**, logo abaixo dos botões "Tela cheia"/"Pausar" (fonte Grande/Extra grande);
  em Pequena/Média continua na posição de sempre.

### Feedback "ROTA CORRETA / INCORRETA" por cima de tudo
O container do feedback ficava POR TRÁS dos cards do desafio e do acelerador (z 60 contra 64–68 do HUD).
- `feedback_layer` z 60 → **75** (acima do HUD e das respostas, z 69); `finish_layer` 70 → 80.
- Painel do feedback mais opaco (62% → 94%) e fundo escurecido (24% → 42%): o texto não "vaza" mais a pergunta/respostas atrás.

### Tutorial da Natalia (cartões)
- `TutorialOverlay.gd`: com fonte Grande/Extra grande o cartão cresce **para os lados** (largura base × fator da fonte, até 94% da tela):
  o texto quebra em menos linhas e o cartão cresce menos para baixo. Vale para todos os tutoriais.
- `desvio_logico.json` (passo "escolha_rota"): `card_y` 0.42 → 0.54, para o cartão ficar **abaixo** das respostas ROTA A/B em vez de cobri-las.

### Teste (Godot 4.5, 1280×670, 4 tamanhos)
`tools/tests/font_scale_audit.tscn -- only=DesvioLogico [feedback] [tutorial]` (novos: `feedback` abre o feedback, `tutorial` liga os tutoriais).

---

## V0.16.9.4 — Laterais do Desvio Lógico, botão TELA compacto e tela cheia no celular (versão do jogo continua 0.16.9)

### Faixas escuras nas laterais (Desvio Lógico)
Causa: o palco (1280×720) era escalado em modo "conter". Em janelas que não são 16:9 (ex.: 1280×670) sobravam ~45 px de cada lado,
preenchidos por `bg_fill` (arte a 30% de brilho) — as faixas "pretas".
- `_update_stage_transform()`: escala "cobrir" com corte vertical limitado a ~10% da altura do palco. Em 1280×670 o palco preenche a
  largura inteira (sem faixas). Se ainda sobrar espaço (celulares muito largos), o `bg_fill` cobre, agora mais claro (55%) e só aparece se necessário.

### Postes invadindo a pista
As trilhas dos postes (markers `PostLeft*/PostRight*` em `DesvioLogico.tscn`) corriam exatamente sobre a guia do asfalto: a base do poste
ficava na pista. Trilhas empurradas 10–28 px **para fora** (esquerda: 507/292/2 → 497/272/-22; direita: 772/1003/1270 → 782/1021/1298).
O poste próximo sai da tela naturalmente. Ciclista não foi alterado.

### Botão de tela cheia compacto
- Texto `Tela cheia - ON/OFF` → **`TELA: ON` / `TELA: OFF`** (+ ícone; a dica por extenso continua no tooltip). Largura automática (cresce com a fonte).

### Tela cheia em celular/tablet (itch.io)
O navegador mobile já abre o jogo ocupando a tela, mas sem a Fullscreen API, então o botão mostrava OFF.
- Novo estado "efetivo" (JS, `window.__cmFsState` no WebBridge e a mesma regra no botão): API ativa = ON; `display-mode` fullscreen/standalone/PWA = ON;
  aparelho de toque com o jogo ocupando ≥ 92% da largura e ≥ 80% da altura da tela = ON.
- Nesse caso o clique tenta a tela cheia real e nunca vira OFF. O Configurações → "Tela cheia" também passa a refletir o estado.
- NÃO testado em aparelho real (só Godot desktop/xvfb): validar em Android/iPad no itch.io.

### Teste
Godot 4.5, 1280×670, Desvio Lógico em Média e Extra grande, com animações ligadas (postes visíveis): sem faixas laterais, postes fora do asfalto.

---

## V0.16.9.5 — Postes do Desvio Lógico: trilha corrigida, poste por script com luz noturna e menos custo (versão do jogo continua 0.16.9)

### Diagnóstico (por que os postes "invadiam" gramado/água/tela)
Os markers `SidePropMarkers/Post*` **funcionam** (o script os lê). O problema eram cinco defeitos somados:
1. **Âncora errada do PNG.** A haste do poste está a ~87% (direito) / ~12% (esquerdo) da largura da imagem; o código ancorava em 67,5% / 32,5%. O poste era plantado ~15–18 px **para fora**, rumo à água. A V0.16.9.4 compensou empurrando os markers para fora, o que piorou.
2. **Markers fora do centro do gramado** (medido nos 6 fundos): até 40 px de desvio, em direções diferentes.
3. **Tamanho sem perspectiva.** Altura `lerp(72, 212, t)`: 72 px já no horizonte, onde o correto é ~25 px.
4. **Sentinela `-1.0`.** `_side_prop_path_x_at_y` devolvia -1 para "sem trilha", mas x negativo é válido (poste esquerdo próximo sai pela borda). Nesse trecho caía no fallback e o poste "pulava" para dentro da tela.
5. **`PostRightMid` era letra morta** (só o `PostLeftMid` era usado). Por isso mexer nele "não afetava o jogo".

### Mudanças
- **Trilha**: markers `PostLeft*/PostRight*` movidos para o **centro** da faixa de gramado (`L: x = -1,553·y + 934`, `R: x = 1,554·y + 343`; desvio máximo agora 5 px, antes 40). Previews do editor realinhados.
- **Poste por script** (`DLConfig.POST_RENDER_MODE = "script"`, padrão): haste, braço curvo, luminária, plinto e tufos de grama desenhados por código, com a base exatamente na trilha. Paleta por horário.
- **Luz** (`POST_LIGHT_BY_ROUND`): halo, cone e poça de luz no Entardecer (0,55), Anoitecer (0,85) e Noite (1,0), com leve oscilação. Textura radial única, criada uma vez.
- **1 poste por lado** (`POST_DEPTH_SLOTS_LEFT=[0.30]`, `_RIGHT=[0.55]`), escalonados. Voltar a 2: `[0.12, 0.62]`.
- **Perspectiva**: altura ∝ distância ao ponto de fuga (`POST_VANISH_Y/REF_Y/REF_HEIGHT`) e fade-in no início da trilha.
- **Desempenho**: trilha lida uma vez e guardada em cache (`_side_prop_path`). Antes: `get_node_or_null` + formatação de string centenas de vezes por quadro (postes + 24 listras do gramado). Cache invalidado a cada desafio e em `_on_display_changed`. No modo script os PNGs dos postes nem são carregados. Em aparelho fraco (`WebLite.low_end()`) somem o cone de luz e os tufos.
- **Fallback**: `POST_RENDER_MODE = "sprite"` volta aos PNGs antigos, já com âncora e perspectiva corrigidas.
- Listras do gramado (`_draw_road_motion`) agora centralizadas na trilha e usando `NO_PATH_X`.
- Novo `tools/dl_calibrar_postes.py` (`medir`, `auditar`, `preview`): lê markers/constantes do projeto; serve para recalibrar se os fundos mudarem.

### Arquivos
`DLConfig.gd`, `DesvioLogico.gd` (2 pontos), `DesvioLogico.tscn`, `modules/DLSideProps.gd`, `tools/dl_calibrar_postes.py`, este documento, `CRONOGRAMA_VERSOES.md` e `V0_16_9_5_preview_postes.png`.

### Teste
- **Feito aqui**: auditoria de markers contra os 6 fundos (OK) e preview gerado a partir dos arquivos reais do projeto.
- **NÃO executado no Godot** (sem engine no ambiente): rodar o Desvio Lógico em 1280×670 e em tela cheia, nos 6 horários, com animações ligadas; conferir base no gramado, luz só do Entardecer em diante e ausência de warnings no console. Medir FPS no navegador com `?debug=1`.
- Fora do escopo, mas relevante: cada fundo (2816×1584) ocupa ~17,8 MB de VRAM e é recarregado a cada desafio. Reexportar em 1920×1080 tende a ajudar mais o web do que qualquer ajuste nos postes.

---

## V0.16.9.6 — Postes na calçada, lanternas vermelhas nos carros e farol do Bionix (versão do jogo continua 0.16.9)

### Postes na calçada (faixa cinza/roxa), não no gramado
- Medido nos 6 fundos o centro da calçada: `E: x = -1,422·y + 910` e `D: x = 1,436·y + 362` (erro máx. ~7 px). Markers `PostLeft*/PostRight*` movidos para lá (desvio ≤ 1 px na auditoria).
- Tufos de grama da base removidos (a base agora é pedra); sobra o plinto de concreto + sombra de contato.
- As listras decorativas do gramado usavam a trilha dos postes: ganharam `DLConfig.GRASS_LINES_OFFSET_PER_DEPTH` para continuarem no gramado.
- Paleta: chave `grass` removida (não era mais usada).

### Luzes dos carros (novo `modules/DLCarLights.gd`, tudo por código, sem PNG novo)
- **Lanternas vermelhas** (`CAR_TAILLIGHT_BY_ROUND = [0, 0, 0, 0.65, 0.90, 1.0]`): em TODOS os carros (NPCs e Bionix) do Entardecer em diante. Posição medida nas fendas do sprite (x 22,7% e 77,3%; y 61,5%).
- **Farol do Bionix** (`CAR_HEADLIGHT_BY_ROUND = [0, 0, 0, 0, 0.85, 1.0]`): dois feixes em leque à frente do carro + poça de luz no asfalto, só Anoitecer e Noite.
- O nó de luz é **filho do carro**: herda posição, escala, rotação e transparência (perspectiva dos NPCs, fade da saída). No Bionix desenha uma vez; nos NPCs só é criado nos horários com luz (custo zero de dia).
- Aparelho fraco (`WebLite.low_end()`): sem halo/poça/cone dos postes e sem halo/poça dos carros; ficam só os núcleos das lanternas e os feixes.

### Arquivos
`DLConfig.gd`, `DesvioLogico.gd`, `DesvioLogico.tscn`, `modules/DLSideProps.gd`, `modules/DLTraffic.gd`, `modules/DLCarLights.gd` (novo), `tools/dl_calibrar_postes.py` (agora mede a calçada; `gramado` como 2º argumento mede a faixa verde), este documento.
Obs.: o Godot gera o `DLCarLights.gd.uid` ao abrir o projeto.

### Teste
- Feito: auditoria dos markers contra os 6 fundos e prévias em Python (postes e luzes) com os sprites reais.
- **NÃO executado no Godot.** Conferir: poste com a base na calçada nos 6 horários e em tela cheia; lanternas só do Entardecer em diante; farol só no Anoitecer/Noite, atrás da carroceria e sem cortar nas bordas do carro (`car_rect.clip_contents = false`); lanternas alinhadas às fendas também nos sprites de curva (esquerda/direita); sem warnings no console.

---
