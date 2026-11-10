# ContalMaster — V0.13.2: cena de chegada à sala de reunião + conversa Jales/Natalia

Atualização extra de teste da dinâmica de cutscenes. Feita por cima do `contalmaster_1.zip` (V0.13.1). Extraia o zip **por cima** do projeto (pasta `contalmaster/`) e abra no Godot: ele reimporta a imagem nova na primeira abertura.

> **Nome da imagem:** o arquivo enviado se chama `13_entrada_sala_reuniao.png` (não `13_salao_reuniao`). O código usa o nome real.

## 1. Novo fluxo da cutscene final

1. **Despedida do Jales** (inalterada).
2. **Conversa Jales ↔ Natalia no escritório (3 quadros, nova):** Jales fica na **esquerda** e a Natalia na **direita** (antes o Jales ficava no centro). Natalia avisa que a equipe está reunida → Jales responde que está **indo na frente** e pede que ela **guie o revisor** → o Jales sai andando pela esquerda e a Natalia chama o jogador.
3. **Corredor:** Natalia segue com os 2 quadros de apoio (o último ganhou uma frase de ligação: "a sala é logo ali à frente") e sai andando para a porta.
4. **Cena de chegada (nova, `ArrivalScene`):**
   - tela escura → surge uma **porta fechada** → a porta **abre** (duas folhas, brilho pela fresta);
   - as **luzes sobem**: a cena clareia, uma faixa de luz sobe pela tela e as 3 luminárias acendem em sequência;
   - **partículas de brilho** flutuam o tempo todo (dourado, branco, roxo e ciano da marca);
   - o **card pequeno e transparente** da Natalia surge suavemente (a cena inteira continua visível) e a frase é digitada;
   - **sem botão de continuar**: 1º clique/Espaço/Enter **acelera** a digitação, 2º clique termina a frase; com a frase completa, um clique encurta a leitura;
   - o **card some primeiro**; depois a cena **escurece**.
5. **Sala de reunião:** clareia e o **Jales entra andando pela esquerda** para falar com o jogador ("Aí está você! Pessoal, nosso revisor chegou!...") e segue a sequência de agradecimentos, placar, fala final e créditos como antes.

Frase da Natalia na chegada (editável): *"Chegamos! Essa é a sala de reunião e, veja só, estão todos aqui, haha! Fique à vontade, revisor. Estou ansiosa para ver a sua pontuação depois de todos os desafios!"* (combina com a imagem: ela rindo de olhos fechados, mão estendida convidando).

## 2. Onde retirar / desligar a cena

| Quero... | Faça |
|---|---|
| **Desligar a cena de chegada** (volta ao corte direto corredor → sala) | `scenes/cutscenes/CutsceneFinal.gd` → `const ARRIVAL_ENABLED := false` |
| Remover de vez | apague `scenes/cutscenes/ArrivalScene.gd` (+ `.uid`), a chave `arrival` e `backgrounds.arrival` do `final.json`, as funções `_play_arrival()`/`_enter_room_from_arrival()` e o bloco `if ARRIVAL_ENABLED` do `_run_story()`; a constante `BG_CUT_13_ENTRADA_SALA` e a linha `"entrada_sala"` do `Paths.gd` |
| Voltar o Jales ao centro na conversa do escritório | `CutsceneFinal.gd` → `MEETING_SLOT_JALES` (0.24) e `MEETING_SLOT_NATALIA` (0.76); `0.52` era o valor antigo do Jales |
| Voltar à conversa antiga | em `final.json`, `meeting_call` tinha 2 quadros (use o `.zip` anterior como referência) |

Se a imagem ou a frase faltarem, a cena é **ignorada com aviso** no painel e o fluxo segue como antes (não trava).

## 3. Onde ajustar

| O que | Onde |
|---|---|
| Frase da Natalia na chegada | `final.json > arrival.text` |
| Diálogo Jales/Natalia | `final.json > meeting_call` (3 quadros; `slide` = quem anda pela lateral) |
| Fala do Jales ao entrar | `final.json > cast_thanks[0]` |
| Ritmo da porta/luzes | `ArrivalScene.gd`: `DOOR_OPEN_SECONDS`, `LIGHTS_SECONDS`, `LIGHTS_START_RATIO`, `DOOR_PAUSE_SECONDS` |
| Velocidade da digitação / aceleração | `TYPE_CHARS_PER_SECOND` (34), `TYPE_FAST_MULTIPLIER` (5) |
| Tempo de leitura depois da frase | `HOLD_MIN_SECONDS`, `HOLD_MAX_SECONDS`, `HOLD_PER_CHAR` |
| Card (transparência, largura, posição) | `CARD_BG_ALPHA` (0.42), `CARD_WIDTH_RATIO`/`MIN`/`MAX`, `CARD_BOTTOM_MARGIN` |
| Brilhos | `SPARKLE_COUNT` (58), `SPARKLE_COLORS` |
| Luminárias (pontos de luz) | `LAMP_POINTS` (fração x,y da imagem), `LAMP_RADIUS_RATIO` |
| Escurecimento inicial | `DIM_START` |
| Cor/tom da porta | `DOOR_WOOD_DARK`, `DOOR_WOOD_LIGHT` |

## 4. Arquivos alterados / novos

- **Novos:** `scenes/cutscenes/ArrivalScene.gd` (+ `.uid`) e este documento. O `.import` da imagem 13 **não** vai mais no pacote: o Godot gera o dele ao abrir. Para deixá-la leve na web, no dock Importar escolha *Lossy* (qualidade 0,9) e *Process > Size Limit* 1920.
- **Alterados:** `CutsceneFinal.gd`, `final.json` (versão 4 → 5), `Paths.gd` (+`BG_CUT_13_ENTRADA_SALA`, `"entrada_sala"`), `project.godot` e `BrandText.gd` (versão **0.13.2**; para manter 0.13.1, volte esses dois).

## 5. Observações

- **Sem som de porta** (V0.13.2.1): o rangido gerado por código foi removido; a cena abre em silêncio, com a música do final. Para usar um `.ogg` depois, toque-o com `AudioManager.play_sfx()` no início da abertura em `ArrivalScene.play()`.
- **Animações desligadas:** a porta já aparece aberta, a cena acesa e o card pronto (sem partículas); o fluxo não trava.
- **Esc** durante a cena volta ao menu, como no resto da cutscene.
- **Botão "Pular" do novel:** pula só o bloco atual; a cena de chegada não tem "Pular" (é curta, ~14 s), mas o clique acelera a frase.
- **Testes feitos:** abri o projeto no Godot 4.5 (importação sem erros), rodei a cutscene final inteira com cliques simulados (animações ligadas e desligadas, e Esc na chegada) sem erros de script, e renderizei capturas da conversa, da porta, das luzes e do card. **Não ouvi o áudio nem joguei com mouse/toque reais:** vale uma passada sua.

## 6. Checklist de teste

1. Campanha até o fim → despedida do Jales → conversa: **Jales à esquerda, Natalia à direita**; Jales diz que vai na frente e sai pela esquerda.
2. Corredor (2 quadros) → Natalia sai andando → **tela escura** → porta fechada → **abre** com luz (sem som).
3. Luzes sobem, brilhos aparecem, **card pequeno** surge e a frase é digitada **sem botão**.
4. Clicar durante a digitação **acelera**; clicar de novo termina; depois um clique encurta a leitura.
5. O **card some antes** de a cena escurecer; a sala de reunião clareia e o **Jales entra andando**.
6. Resto do final (agradecimentos, placar, fala final, créditos) igual a antes.
7. Com animações desligadas e com `ARRIVAL_ENABLED := false`, o fluxo completa sem travar.
8. Redimensionar a janela durante a chegada: card, porta e luminárias acompanham.

## 7. Correção V0.13.2.1: erro "Unable to open file ... 13_entrada_sala_reuniao...ctex"

Causa: o `.import` do pacote anterior apontava para um cache (`.godot/imported/...ctex`) que não existia no seu projeto. Correção: o `.import` saiu do pacote e o carregamento passou a ser seguro (`CutsceneFinal._load_texture_safe`): se o cache faltar, lê o PNG direto do disco (no editor) sem erro; se nada funcionar, avisa e pula a cena. **Se o erro persistir:** apague `assets/background/cutcines/13_entrada_sala_reuniao.png.import` (se existir), reabra o projeto no Godot e, no dock Importar, clique em *Reimportar* na imagem.
