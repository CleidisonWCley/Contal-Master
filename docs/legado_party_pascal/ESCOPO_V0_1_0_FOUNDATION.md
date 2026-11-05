# Party Pascal Godot — V0.1.0 Fundação da Migração

Esta atualização transforma o projeto Godot em uma base navegável para receber a migração fiel da versão Pygame.

## Entregue nesta versão

- `project.godot` atualizado com autoloads globais:
  - `ScoreManager`
  - `SettingsManager`
  - `AudioManager`
  - `DifficultyManager`
  - `GameManager`
- Menu principal corrigido.
- Seleção de modo funcional.
- Tela de configurações criada.
- Menu de minigames criado.
- Cutscene inicial criada.
- Cutscene final criada.
- Fluxo de campanha criado na ordem oficial:
  1. Show do Bilhão
  2. Batalha Naval
  3. Maleta Certa
  4. Roleta de Risco
  5. Perseguição
  6. STOP
  7. Cutscene Final
- Todos os minigames foram transformados em placeholders funcionais.
- Pontuação global funcionando no fluxo de teste.
- Dificuldade salva/carregada via `user://settings.json`.
- Volumes de música e efeitos salvos/carregados via `user://settings.json`.
- Áudio centralizado por chave em `AudioManager.gd`.

## O que ainda não foi portado

Esta versão ainda não porta a mecânica completa dos minigames. O objetivo foi criar o chassi da migração para evitar retrabalho.

A próxima versão recomendada é a V0.2.0, focada no port completo do Show do Bilhão.

## Caminho de teste manual

1. Abrir o projeto no Godot.
2. Rodar a cena principal.
3. Testar: Menu Principal → Iniciar Jogo → Campanha.
4. Avançar pela cutscene inicial.
5. Clicar em “Concluir fase teste” em cada minigame.
6. Confirmar que a campanha chega à cutscene final.
7. Testar: Menu Principal → Iniciar Jogo → Modo Livre.
8. Abrir cada minigame e voltar ao menu de minigames.
9. Testar configurações de volume e dificuldade.
