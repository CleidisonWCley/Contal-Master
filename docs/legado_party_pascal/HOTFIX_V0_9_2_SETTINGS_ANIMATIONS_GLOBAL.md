# V0.9.2 — Configurações Globais, Animações e UI

Atualização aplicada em cima do arquivo atual enviado pelo usuário.

## Ajustes principais

- Removido o botão `SALVAR` da tela de configurações.
- Música, efeitos, dificuldade, tela cheia e animações agora salvam automaticamente ao alterar.
- `Tela cheia` virou botão ON/OFF.
- `Animações visuais` virou botão ON/OFF.
- O botão de animações agora é global: desliga partículas, brilhos decorativos, flutuações e shakes visuais em menus, cutscenes e minigames.
- Mantidas animações essenciais de gameplay, como o giro da roleta e temporizadores, para não quebrar a mecânica do jogo.
- Adicionadas partículas leves na tela de seleção de modo.
- Adicionadas partículas temáticas no menu do modo livre.
- Subido o painel de texto das cutscenes inicial e final para dar mais respiro no rodapé.

## Arquivos alterados

- `scripts/SettingsManager.gd`
- `scenes/menus/Settings.gd`
- `scenes/menus/Settings.tscn`
- `scenes/menus/ModeSelect.gd`
- `scenes/menus/MenuMinigames.gd`
- `scenes/cutscenes/CutsceneIntro.gd`
- `scenes/cutscenes/CutsceneFinal.gd`
- `scenes/minigames/ShowDoBilhao.gd`
- `scenes/minigames/BatalhaNaval.gd`
- `scenes/minigames/MaletaCerta.gd`
- `scenes/minigames/RoletaRisco.gd`
- `scenes/minigames/Perseguicao.gd`
- `scenes/minigames/Stop.gd`

## Testes recomendados

1. Abrir `Configurações`.
2. Alterar dificuldade e voltar sem apertar salvar.
3. Alternar `Tela cheia: ON/OFF`.
4. Alternar `Animações visuais: ON/OFF`.
5. Verificar se partículas somem no menu, seleção de modo, modo livre, cutscenes e minigames.
6. Testar a campanha completa para garantir que mecânicas essenciais continuam funcionando.
