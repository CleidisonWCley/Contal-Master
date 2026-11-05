# Party Pascal Godot V0.3.0 — Maleta Certa

## Objetivo

Portar o minigame **Maleta Certa** do projeto Pygame para o Godot, mantendo a estrutura da V0.2.0 e integrando o minigame ao modo campanha e ao modo livre.

## O que foi implementado

- `scenes/minigames/MaletaCerta.gd` deixou de usar o placeholder herdado de `BaseMinigame.gd`.
- Banco de desafios do Pygame migrado para Godot com conjuntos `facil`, `normal` e `dificil`.
- Cada rodada apresenta um problema e três maletas com soluções embaralhadas.
- A solução correta é comparada pelo texto da opção, igual à lógica original do Pygame.
- Pontuação integrada ao `ScoreManager`:
  - Fácil: acerto `+12`, erro `-5`.
  - Normal: acerto `+10`, erro `-12`.
  - Difícil: acerto `+8`, erro `-25`.
- A dificuldade vem de `DifficultyManager.get_rules()` e usa `pergunta_tipo` para escolher o banco de desafios.
- Música `musica_maleta_certa` iniciada ao abrir a fase.
- Efeitos de acerto, erro e conclusão usando `AudioManager`.
- Feedback visual de acerto/erro e destaque da maleta correta.
- Partículas visuais de maletas no fundo.
- Atalhos de teclado: `1`, `2`, `3`, `A`, `B`, `C`.
- Fim da fase com tela de conclusão e retorno correto para campanha ou modo livre via `GameManager.complete_current_stage(0)`.

## Critérios de aceite

- Abrir `Menu → Modo Livre → Maleta Certa` sem erro.
- Abrir `Menu → Campanha` e avançar até Maleta Certa após os minigames anteriores.
- Ao acertar, a pontuação sobe conforme a dificuldade.
- Ao errar, a pontuação cai conforme a dificuldade, podendo ficar negativa como no Pygame.
- Após os 6 desafios, a tela de conclusão aparece.
- No modo livre, ao continuar, retorna para o menu de minigames.
- Na campanha, ao continuar, avança para a próxima fase.

## Fora do escopo desta versão

- Batalha Naval completa.
- Perseguição completa.
- STOP completo.
- Roleta de Risco completa.
- Exportação Android/Play Store.

## Próxima versão sugerida

**V0.4.0 — Perseguição**.

Motivo: reaproveita pontuação, dificuldade, feedback e seleção de respostas, mas adiciona pressão de tempo, preparando o projeto para minigames mais dinâmicos.
