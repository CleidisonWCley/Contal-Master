# Party Pascal Godot V0.2.0 — Show do Bilhão

## Objetivo

Portar o primeiro minigame real do Party Pascal em Pygame para Godot, mantendo o Show do Bilhão como fase jogável, integrada ao fluxo de campanha e ao modo livre.

## Entregas desta versão

- Substituição do placeholder do `ShowDoBilhao` por uma versão jogável.
- Banco de perguntas do Pygame migrado para GDScript.
- Seleção automática de perguntas conforme dificuldade atual.
- Embaralhamento das perguntas e alternativas.
- Pontuação fiel ao Pygame:
  - Fácil: acerto +12, erro -5.
  - Normal: acerto +10, erro -12.
  - Difícil: acerto +8, erro -25.
- Feedback visual de acerto e erro.
- Exibição da resposta correta quando o jogador erra.
- Explicação/motivo da resposta correta.
- Efeitos sonoros de acerto, erro e fim da fase.
- Música própria do Show do Bilhão.
- Partículas visuais de dinheiro no fundo.
- Explosão simples de moedas ao escolher uma alternativa.
- Atalhos de teclado A/B/C/D para testar no PC.
- Integração com `GameManager`:
  - no modo campanha, avança para a próxima fase ao concluir;
  - no modo livre, retorna ao menu de minigames ao concluir.
- `ScoreManager` ajustado para permitir pontuação negativa, como no Pygame.

## Fora do escopo desta versão

- Portar Batalha Naval.
- Portar Maleta Certa.
- Portar Roleta de Risco.
- Portar Perseguição.
- Portar STOP.
- Criar ranking, conquistas ou save avançado.
- Configurar exportação final Android/Play Store.

## Critérios de aceite

A versão V0.2.0 é considerada pronta quando:

1. O jogador consegue abrir o Show do Bilhão pela campanha.
2. O jogador consegue abrir o Show do Bilhão pelo modo livre.
3. A fase carrega perguntas da dificuldade selecionada.
4. As alternativas aparecem embaralhadas.
5. Acertos somam pontos conforme dificuldade.
6. Erros removem pontos conforme dificuldade.
7. A pontuação pode ficar negativa, igual ao Pygame.
8. Ao errar, o jogo mostra qual era a resposta certa.
9. Ao terminar todas as perguntas, aparece a tela de fim do Show.
10. Ao clicar em Continuar, o jogo retorna ao fluxo correto.

## Próxima versão recomendada

`V0.3.0 — Maleta Certa`

A Maleta Certa é uma boa próxima etapa porque aproveita a base de pergunta/escolha/feedback criada no Show do Bilhão, mas adiciona uma lógica visual própria de seleção de maletas.
