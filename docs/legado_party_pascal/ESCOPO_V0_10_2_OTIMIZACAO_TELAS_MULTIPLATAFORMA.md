# V0.10.2 — Otimização de Telas para Multiplataforma

## Objetivo

Refinar as telas principais do Party Pascal para melhorar a experiência em desktop, notebook, tablet e celulares em orientação paisagem, sem alterar a lógica dos minigames.

## Ajustes aplicados

- Adicionado `ScreenTools.gd` como utilitário central para tamanhos, margens e fontes responsivas.
- Ajustado o `project.godot` para usar `window/stretch/aspect="expand"`.
- Menu principal agora adapta tamanho da logo, botões e espaçamentos conforme a tela.
- Seleção de modo agora adapta painel, margens, fontes e botões em telas compactas.
- Modo livre agora adapta painel, grid, botões e texto em telas compactas.
- Configurações agora adapta painel, margens, sliders, botões e fontes.
- O botão de tela cheia fica oculto em Android/iOS, porque nessas plataformas o comportamento ideal é tela cheia automática/imersiva.
- Cutscene inicial ganhou reposicionamento responsivo de Pascal, botões e caixa de diálogo.
- Cutscene final ganhou reposicionamento responsivo de Pascal, caixa de diálogo e painel de pontuação.
- Transições entre fases tiveram painel, fonte, ícone e textos ajustados para telas compactas.

## Fora do escopo

- Não altera conteúdos de perguntas.
- Não altera pontuação.
- Não altera ordem da campanha.
- Não cria novos minigames.
- Não configura presets finais de exportação Android/Web/Windows.

## Testes recomendados

- 1280x720 no editor.
- 1366x768 em janela.
- Janela menor para simular tablet/celular em paisagem.
- Menu principal, seleção de modo, modo livre, configurações, cutscene inicial, transições e cutscene final.
