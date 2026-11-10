# Contal Master — Patch V0.10.2 · Padrão de sprites, tutoriais enxutos e ajustes de UI

## 1. Resumo
- Verificação dos sprites dos personagens e **padrão único de tamanho** aplicado em tutoriais e novels.
- Tutoriais reduzidos para **3 quadros (4 nos mais complexos)**, sem repetir o que a transição já diz.
- **Desvio Lógico:** a Natalia agora fecha o tutorial **antes** de o carro acelerar.
- **Batalha Naval:** seta apontando para **D3** piscando em vermelho e tabuleiro com **25 células idênticas**, maiores e mais largas.
- **Cutscene final:** elenco em **duas fileiras e menor**, sem ninguém colado.
- Versão: `0.10.1` → `0.10.2`.

## 2. Verificação dos sprites (resultado)
- Proporção dos PNGs: **todos 3:4** (✔ padrão).
- Tamanho do canvas: **não é idêntico** — 1792×2400 (Jales, Ariel, Cleiton, Anderson), 1632×2176 (Natalia, Julios, Tiago) e 1529×2048 (Priscila, Aline).
- Altura do corpo em relação ao canvas (referência Jales = 96,2%): Ariel 96,2 · Natalia 96,3 · Cleiton 96,0 · Anderson 96,0 · Julios 97,7 · Tiago 97,4 · Aline 98,0 · **Priscila 99,0**.
- Se os PNGs fossem desenhados direto pelo canvas, a Priscila sairia ~2,9% maior que o Jales, a Aline ~1,9%, o Julios ~1,6% e o Tiago ~1,3%.
- **Atenção na Priscila:** o topo do rabo de cavalo encosta na borda superior (24 px na linha 0), então está levemente cortado. Vale reexportar com ~46 px de margem como o Jales.
- **Solução no código:** o tamanho na tela passa a ser normalizado pela **altura real do corpo** (medida em cada PNG), usando o Jales como referência. Todos saem com a mesma altura e a **cabeça no mesmo nível**, mesmo com canvas diferentes.
- As medidas (área do corpo e centro da cabeça de cada personagem) ficam em `tutorials/TutorialManager.gd` (`CHARACTERS`). Se reexportar algum PNG, só é preciso atualizar essa linha.

## 3. Layout dos tutoriais e novels
- **Retrato do tutorial:** recorte padronizado (mesma escala para todos): da cabeça até o peito, centrado no rosto. Antes o recorte variava com a largura da pose.
- **Novel (transição e final):** altura de corpo igual para todos e **rosto alinhado ao centro do slot**. Natalia (pose larga) e Jales ficam na mesma escala e linha de cabeça.
- Cartão do tutorial mais baixo (190 px; 166 px na dica do Desvio Lógico), porque o texto ficou menor.
- A intro do Jales passou a usar o sprite padrão: os PNGs antigos `jales-receptivo/confiante` saíram de `assets/sprites` e a intro ficaria sem o Jales.

## 4. Tutoriais enxutos
- **Campanha:** 3 quadros (Batalha Naval e Forca Técnica: 4). **Modo livre:** mesma quantidade, com o primeiro quadro trazendo a apresentação curta do anfitrião e o recorde.
- Estrutura: *como jogar* → *pontuação/tempo* → *estratégia*.
- **Tempo:** sem explicar faixas de segundos; cada personagem diz em uma fala que o relógio corre e que responder rápido rende mais pontos (e demorar custa pontos). Ex.: Ariel avisa que quem demora perde pontos.
- Textos com no máximo ~150 caracteres.

## 5. Diálogos duplicados (análise entre transição e tutorial)
- **Havia repetição direta** nos 7 minigames: o quadro 2 da novel e o "foco pedagógico" do tutorial diziam quase a mesma coisa (Julios, Ariel, Aline, Cleiton e Natalia, praticamente idênticos; Priscila, Anderson e Tiago, parecidos).
- **Decisão:** a **pedagogia e a personalidade ficam só na novel**; o tutorial fica só com a **mecânica**. Removi o "foco pedagógico" dos tutoriais.
- O quadro 3 de cinco novels (Batalha Naval, Maleta Certa, Roleta, Forca e STOP) descrevia a mecânica ("você dispara no grid...", "gire..."). Reescrevi para falar do **propósito na história** e do selo, deixando o "como" para o tutorial.

## 6. Desvio Lógico (Natalia)
- Fluxo: 3 quadros de introdução → treino esquerda → treino direita → **quadro de largada (parado)** → o jogador aperta **Continuar** → o carro acelera.
- O quadro de largada agora acontece **antes** do jogo iniciar (o carro fica parado). O texto virou um aviso de começo ("vamos acelerar!!!") e não mais "o carro está acelerando".
- Se o jogador **pular**, o jogo inicia depois de tudo (o "Pular" só aparece quando permitido; na primeira campanha só existe "Continuar").
- Entradas durante essa tela não mexem no carro.
- Mantido: dica na 1ª bifurcação com botão **Continuar**.

## 7. Batalha Naval
- **Tutorial:** a seta aponta para a célula **D3** (meio do tabuleiro) e a área pisca em vermelho com anel pulsante. Recurso novo e reutilizável: `pointer_target` e `pointer_color` no JSON do passo.
- **Tabuleiro:** as células mudavam de tamanho porque as reveladas (ícone empilhado e "~ ÁGUA" em duas linhas) cresciam. Agora:
  - todas têm tamanho **fixo e igual** (medido: 25 células com o mesmo tamanho);
  - ficam **maiores e mais largas** (≈117×84 em 1280×720) e proporcionais à tela;
  - ícone do "RISCO" ao lado do texto e "ÁGUA" em uma linha.

## 8. Cutscene final: elenco sem ficar colado
- Escolhi um **meio-termo (opção 3)**: sprites **menores** (opção 1) em **duas fileiras**, com a de trás mais alta e a da frente mais baixa, e o rosto de cada um alinhado ao seu lugar. Ninguém sai da tela (Natalia, de pose larga, era cortada).
- Cada personagem continua **subindo** quando fala; quem fala ganha destaque e leve elevação.
- A opção 2 (cada um sair da cena indo para a reunião) ficou de fora para não alterar a narrativa; dá para somar depois.

## 9. Arquivos modificados (22)
- `tutorials/`: `TutorialManager.gd`, `TutorialOverlay.gd`, `desvio_logico/DLTutorial.gd` e os 8 `data/*.json`.
- `scenes/cutscenes/`: `NovelStage.gd`, `CutsceneIntro.gd`.
- `scenes/minigames/batalhanaval/BatalhaNaval.gd`.
- `scripts/autoloads/GameManager.gd` (versão).
- `scripts/data/dialogues/`: `batalha_naval`, `maleta_certa`, `roleta_risco`, `forca`, `stop` (quadro 3).
- `docs/versionamento/V0_10_1_ROTEIRO_NARRATIVO.md` (textos atualizados).

## 10. Como aplicar
- Copie o conteúdo de `patch-cm-V0.10.2` por cima do projeto e abra no Godot. Faça backup antes.

## 11. Como foi testado
- Godot 4.4.1 headless: scripts e cenas carregam sem erro; o jogo abre sem erros de script.
- Os 8 minigames nos dois modos: alvos do tutorial resolvem, a entrada é liberada ao fim, e o número de quadros está correto (3 ou 4).
- Fluxo completo do Desvio Lógico: intro → esquerda → direita → tela de largada com carro parado → Continuar → acelera.
- Tabuleiro da Batalha Naval com células reveladas (todas do mesmo tamanho) e capturas de tela de tutorial, novel, cutscene final e intro.
- **Não testado:** toque em celular/Android, áudio e telas muito pequenas (menos de 960×540).

## 12. Observações
- No tutorial da Batalha Naval o cartão cobre parte da primeira linha do tabuleiro (a seta e o D3 ficam visíveis). Se preferir, é possível reduzir a altura só desse passo.
- Na primeira campanha a regra "não pode pular" continua valendo, inclusive no quadro de largada do Desvio Lógico (só "Continuar").
