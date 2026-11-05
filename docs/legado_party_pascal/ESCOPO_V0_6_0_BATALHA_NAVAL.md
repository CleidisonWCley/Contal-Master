# Party Pascal Godot — V0.6.0

## Minigame: Batalha Naval

Esta versão substitui o placeholder da Batalha Naval por uma implementação jogável no Godot.

## O que foi migrado do Pygame

- Grade 5x5.
- Banco de 20 ameaças e controles.
- Quantidade de ameaças por dificuldade:
  - Fácil: 16 ameaças.
  - Normal: 12 ameaças.
  - Difícil: 6 ameaças.
- Ameaças sorteadas aleatoriamente no tabuleiro.
- Clique em célula para revelar risco ou água.
- Acerto: +10 pontos.
- Erro/água: -5 pontos.
- Feedback de ameaça encontrada com controle recomendado.
- Feedback de água.
- Fim de fase quando todas as ameaças são encontradas.
- Integração com campanha e modo livre.

## Melhorias adaptadas para Godot

- Interface construída com `Control`, `GridContainer`, `PanelContainer` e botões grandes para PC/mobile.
- Partículas de água no fundo.
- Splash visual ao clicar em células.
- Células marcadas como risco ou água após clique.
- Música `musica_batalha_naval` integrada ao `AudioManager`.
- Efeitos sonoros de explosão, erro e conclusão.
- Tecla `Esc` para voltar.

## Critérios de teste

1. Abrir `Menu -> Modo Livre -> Batalha Naval`.
2. Clicar em células até encontrar todas as ameaças.
3. Testar dificuldade fácil, normal e difícil em Configurações.
4. Conferir se a quantidade de ameaças muda conforme dificuldade.
5. Rodar campanha e verificar se, após finalizar a Batalha Naval, o jogo segue para Maleta Certa.
