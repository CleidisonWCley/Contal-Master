# Contal Master — Patch V0.10 · Sistema de Tutoriais dos Minigames

## 1. Resumo
- Todo minigame agora abre com um **tutorial guiado pelo anfitrião** (antes da rodada valer pontos).
- Uma **única UI reutilizável** (`TutorialOverlay`) atende os 8 minigames, na **campanha** e no **modo livre**.
- O tutorial mecânico do **Desvio Lógico** foi migrado para a pasta nova e a **Natalia** narra por cima dele.
- Versão do app: `0.9.2.1` → `0.10.0`.

## 2. Análise funcional (o que foi encontrado)
- Os JSONs de `scripts/data/dialogues/` (Jales + anfitrião, 3 quadros) **não eram lidos por nenhum script**. Continuam intactos: são apresentações, não tutoriais.
- A UI dos minigames é montada em código e guarda cada elemento em variável (`question_panel`, `options_box`, `spin_button`...). O overlay usa esses nomes para **destacar o elemento real**, sem editar nenhuma `.tscn`.
- O ponto comum às duas modalidades é o `_ready()` da cena do minigame (campanha passa por `StageTransition`, livre vem do menu; ambos terminam na mesma cena). Por isso o gancho fica no minigame e funciona nos dois modos.
- O Desvio Lógico já usava módulos (`DLTraffic`, `DLWaterFX`...). O tutorial dele virou o módulo `DLTutorial`, no mesmo padrão.

## 3. Estrutura nova
- `tutorials/TutorialManager.gd` — ponto de entrada (`await TutorialManager.play(self, "<minigame>")`).
- `tutorials/TutorialOverlay.gd` + `TutorialOverlay.tscn` — UI reutilizável.
- `tutorials/data/*.json` — 1 tutorial por minigame (8 arquivos).
- `tutorials/desvio_logico/DLTutorial.gd` — tutorial mecânico migrado + Natalia.
- Não precisa registrar autoload nem alterar o `project.godot`.

## 4. A UI reutilizável (`TutorialOverlay`)
- **Foco (spotlight):** escurece o jogo e abre uma janela sobre o elemento explicado, com borda pulsante, ondas e seta apontando.
- **Dois sprites em tela:** Jales (esquerda) + anfitrião (direita), lidos de `assets/sprites/personagens/`. Quem fala fica iluminado e maior; o outro escurece. A troca é animada.
- **Cartão:** tipo do passo (Jornada, Modo prática, Foco pedagógico, Como jogar, Pontuação, Estratégia, Atenção, Pronto?), nome do falante, texto com efeito de digitação, contador de passos.
- **Controles:** Enter / Espaço / → / clique avançam; ← volta; Esc ou "Pular tutorial" encerra. Durante o tutorial nenhuma tecla vaza para o jogo (letras da Forca, etc.).
- **Dois modos:** `MODAL` (bloqueia o jogo) e `COACH` (dica flutuante que não bloqueia; usado no Desvio Lógico).
- **Responsivo:** layout compacto abaixo de 960×650; retratos escondidos em telas muito estreitas.
- Respeita "Animações visuais" das Configurações (sem animações: texto e transições instantâneos).

## 5. Como cada tutorial é montado (JSON)
- Campos do passo: `kind`, `speaker`, `title`, `text`, `targets` (variáveis do minigame), `target_rect` (área normalizada), `pointer`, `card` / `card_y`, `show`, `modes`, `phase`.
- **Ponte pedagogia ↔ gameplay:** cada tutorial segue a sequência *abertura → foco pedagógico → como jogar → pontuação/regra → estratégia*.
- **Campanha × livre:** o primeiro passo muda (`modes`). Campanha: "Etapa X de 8" (Jales passa a palavra). Livre: "Treino livre".
- **Números reais no texto:** `{correct}`, `{wrong}`, `{difficulty}`, `{threats}`, `{chase_time}`, `{errors}`, `{rounds}`, `{stage}`, `{total}` vêm do `DifficultyManager`/jogo. Se o balanceamento mudar, o tutorial acompanha.
- Falas escritas no tom de cada personagem (Priscila rigorosa, Anderson agitado, Tiago didático, Julios arrogante, Ariel calmo, Aline exigente, Cleiton sério e gentil, Natalia acolhedora).

## 6. Anfitriões e o que cada tutorial destaca
- **Show do Bilhão — Priscila:** enunciado, alternativas A–D, pontuação por tempo.
- **Batalha Naval — Anderson:** tabuleiro 5×5, contador de ameaças, custo de tiro na água.
- **Maleta Certa — Tiago:** cenário, maletas, pontuação por tempo.
- **Roleta de Risco — Julios:** roleta, botão de girar (um giro, sorte pura), resultado.
- **Perseguição — Ariel:** incidente, ações A/B, barra de tempo e pontos por tempo restante.
- **Forca Técnica — Aline:** palavra, teclado, barra de integridade, erros permitidos.
- **STOP — Cleiton:** letra sorteada, categoria e dica, opções (todas começam com a letra).
- **Desvio Lógico — Natalia:** ver seção 7.

## 7. Desvio Lógico (tutorial mecânico + Natalia)
- **Antes:** card desenhado dentro do `DesvioLogico.gd` (~170 linhas de tutorial no arquivo principal).
- **Agora:** `DLTutorial.gd` com o mesmo fluxo e a Natalia por cima:
  - **Intro (modal):** o carro acelera sozinho; o jogador só escolhe o lado; clicar na metade esquerda/direita; a bifurcação é a pergunta (esquerda = Rota A, direita = Rota B); integridade.
  - **Treino esquerda / direita (coach):** o jogador pratica de verdade, com a Natalia e a seta do projeto apontando o lado.
  - **Largada (coach):** comentário enquanto o carro acelera.
  - **1ª bifurcação (coach):** dica na primeira decisão da partida; some ao escolher a rota.
- Pular em qualquer ponto vai direto para a corrida. Continua rodando só na rodada 0, como antes.
- `DesvioLogico.gd` perdeu as variáveis e funções de tutorial (2136 → 1965 linhas) e delega ao módulo.

## 8. Antes da rodada de fato (sem punir o jogador)
- Show do Bilhão, Maleta, STOP: o relógio de resposta só começa **depois** do tutorial.
- Perseguição: a barra de tempo é zerada ao sair do tutorial.
- Batalha Naval, Roleta, Forca: entrada bloqueada durante o tutorial.
- STOP: o tutorial aparece depois da primeira letra sorteada.

## 9. Configurações
- Novo botão **Tutoriais: LIGADO/DESLIGADO** (em Configurações, abaixo de Tela cheia / Animações).
- Desligado: nenhum tutorial aparece (inclusive o mecânico do Desvio Lógico).
- Padrão: ligado, exibido **sempre** que o minigame inicia (com "Pular tutorial"). Para exibir só na primeira vez, é preciso guardar um "já visto" (não incluído neste patch).

## 10. Arquivos modificados
- `scripts/core/Paths.gd` — constantes dos sprites de personagens e dos tutoriais.
- `scripts/autoloads/SettingsManager.gd` — chave `tutorials_enabled`.
- `scripts/autoloads/GameManager.gd` — `APP_VERSION = "0.10.0"`.
- `scenes/menus/Settings.gd` — botão "Tutoriais".
- `scenes/minigames/*` — 7 minigames ganharam o gancho no `_ready()`; `DesvioLogico.gd` refatorado.

## 11. Arquivos novos
- `tutorials/TutorialManager.gd`, `tutorials/TutorialOverlay.gd`, `tutorials/TutorialOverlay.tscn`
- `tutorials/desvio_logico/DLTutorial.gd`
- `tutorials/data/`: `show_do_bilhao`, `batalha_naval`, `maleta_certa`, `roleta_risco`, `perseguicao`, `forca_tecnica`, `stop`, `desvio_logico` (`.json`)

## 12. Como aplicar
- Copie o conteúdo do zip por cima do projeto (mantém os caminhos). Abra o projeto no Godot para ele reimportar e registrar as novas `class_name`.
- Faça backup antes: 12 arquivos existentes foram alterados.

## 13. Como editar ou criar tutoriais
- Texto, ordem e destaques: edite só o JSON em `tutorials/data/`.
- Novo destaque: use no `targets` o nome de uma variável Control do minigame, ou `target_rect` `[x, y, largura, altura]` de 0 a 1.
- Novo minigame: crie o JSON, registre em `Paths.TUTORIAL_DATA` e chame `await TutorialManager.play(self, "chave")` depois de montar a UI.

## 14. Como foi testado
- Godot 4.4.1 headless: todos os scripts e cenas carregam sem erro.
- Execução dos 8 minigames nos dois modos: todos os alvos resolvem, a entrada é liberada ao fim e o botão "Tutoriais: desligado" pula tudo.
- Fluxo completo do Desvio Lógico (intro → esquerda → direita → largada → bifurcação → dica some).
- Capturas de tela renderizadas em 1280×720 e 960×540.
- **Não testado:** toque em celular/Android e áudio. Vale uma passada manual.

## 15. Observações encontradas (não alteradas)
- `ShowDoBilhao.gd`, em `_unhandled_input`, tem `return` duplicado logo no início: os atalhos de teclado A–D nunca funcionam. O tutorial não menciona atalhos por isso.
- `Paths.SPRITE_JALES_RECEPTIVO` aponta para `assets/sprites/jales-receptivo-transparente.png`, que **não está neste patch**. Se o arquivo não existir no seu projeto, a cutscene de intro fica sem o Jales. O tutorial novo usa `personagens/jales/jales.png` e não depende disso.
- O zip não traz `project.godot`; o patch assume o do seu projeto.
- Cada personagem tem **um único sprite**. As expressões dos JSONs de apresentação (`expression`) ainda não têm arte; o destaque do falante é feito por brilho e escala.
