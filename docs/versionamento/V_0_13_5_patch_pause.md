# Patch — Pause padronizado + Configurações (pré-exportação)

Copie os arquivos por cima do projeto, mantendo as pastas. Nenhum asset, cena (.tscn) ou autoload novo.

## O que mudou
- **Removido** o "Finalizar minigame" do pause (atalho de desenvolvedor que pulava para os créditos). Sumiu também o `on_finish` do `MinigamePause` e a função `_on_pause_finish_pressed` do Desvio Lógico.
- **Novo botão "Configurações"** no lugar dele (ordem: Continuar jogo → Configurações → Voltar ao menu principal). Abre dentro do próprio pause, sem trocar de cena, e `Esc` volta ao pause.
- **Opções no pause (campanha, modo livre e gameplay):**
  - Volume de **Música** e de **Efeitos** (sliders com %);
  - **Animações visuais** ligado/desligado;
  - **Tutoriais** ligado/desligado — na campanha de quem joga pela 1ª vez fica travado em LIGADO (mesma regra do botão "Pular");
  - **Novel: Auto / Clique**.
- **Dificuldade:** não há mais como mudar no pause. Aparece só um aviso "Dificuldade: X (não pode ser alterada durante a partida)".

## Novel Auto / Clique
- Novo setting salvo `novel_auto` (padrão: **Clique**, igual ao comportamento anterior).
- **Auto:** cada quadro avança sozinho depois da fala terminar de digitar, com tempo proporcional ao texto (mín. 2,2 s, máx. 7 s). Clique/Espaço/Enter continuam adiantando e o "Pular" segue funcionando.
- Vale para as novels do `NovelStage` (transições antes dos minigames e cutscene final).
- A mesma opção também foi adicionada na tela **Configurações** do menu principal.

## Arquivos modificados
- `scenes/components/MinigamePause.gd`
- `scenes/minigames/desviologico/DesvioLogico.gd`
- `scenes/cutscenes/NovelStage.gd`
- `scenes/menus/Settings.gd`
- `scripts/autoloads/SettingsManager.gd`

## Testes (Godot 4.5 headless)
- Projeto importa sem erros de script.
- Pause aberto em Stop, Show do Bilhão e Desvio Lógico: sem "Finalizar", Configurações abre/volta, sliders e toggles gravam no `SettingsManager`, árvore não fica pausada ao fechar.
- Novel em Auto avançou 2 quadros sozinha (~5 s) e terminou normalmente.
