# V0.16.4 — Ajustes da fonte Extra grande, card do Desvio Lógico, botão de pausa e selo do menu

Continuação direta da 0.16.3 (acessibilidade de fonte). Foco: remover cortes de texto na fonte **Extra grande** e
padronizar o HUD. Sem mudança de regras, pontuação ou conteúdo.

## 1) Respostas e feedback crescendo para os lados (todas as fontes)
- Novo **`scripts/ui/AnswerLayout.gd`** (`class_name AnswerLayout`), usado por todos os minigames:
  - **Feedback**: o painel agora **alarga conforme a fonte** (Pequena ×1,10 · Média ×1,20 · Grande ×1,36 · Extra grande ×1,55,
    limitado pela largura da tela). O texto fica **alinhado à esquerda** (leitura corrida) dentro de uma rolagem vertical:
    se ainda for maior que a tela, **título e botão "Continuar" ficam sempre visíveis** e só o texto rola.
  - **Respostas (botões A/B/C/D)**: texto à esquerda, quebra de linha e **altura calculada pelo texto** (antes: altura fixa
    cortava). Reajusta ao trocar a fonte (pause) e ao redimensionar a janela/tela cheia.
- Aplicado no feedback de: Show do Bilhão, Perseguição, Maleta Certa, STOP, Forca Técnica, Batalha Naval, Desvio Lógico e
  resultado da Roleta do Risco. Nos botões de resposta de: Show do Bilhão, Perseguição e Maleta Certa.

## 2) Desvio Lógico — card padronizado e pequeno
- Removido o texto de narração ("Bionix em velocidade de rota…"). O `status_label` continua existindo, porém oculto
  (o jogo e o tutorial ainda gravam nele, sem risco de erro).
- Card agora mostra só: **nome do minigame · Desafio X/Y • cenário · bolinhas de tráfego · dificuldade**.
  Altura vem do conteúdo (cresce para cima) e o chip de dificuldade tem só o tamanho do texto.

## 3) Botão de pausa
- Mesmo tratamento do botão **Tela cheia**: fica **apagado (42%) no canto, ainda visível**, e **acende** (100%) com mouse,
  toque ou foco de teclado. Ao fechar o pause, volta ao estado correto (aceso se o mouse ainda estiver sobre ele).
  (`scenes/components/MinigamePause.gd`)

## 4) Menu — selo de versão
- O selo "ContalMaster V0.16.x" **subiu** (~52 px do rodapé) e cresce para cima, evitando corte por barras do sistema
  e janelas maiores que a tela. (`scenes/menus/main_menu.gd`)

## Versão
`project.godot` (`config/version`) e `BrandText.DEFAULT_VERSION` → **0.16.4**.

## Pontos para testar (não rodei o Godot neste ambiente)
1. Extra grande em Show do Bilhão: feedback de resposta errada longa → painel largo, "Continuar" visível.
2. Perseguição/Maleta em Extra grande: texto das respostas sem corte.
3. Trocar a fonte no pause com o feedback/respostas na tela.
4. Desvio Lógico: card pequeno; pause apagado e acendendo.
5. Menu em tela cheia e janela pequena: selo visível.
