# V0.14.2 — Tela de carregamento unificada (web)

## Diagnóstico
Hoje o jogador na web passa por **três** telas de carregamento diferentes:

| # | Quem desenha | Visual |
|---|---|---|
| 1 | `web/shell.html` (download do .wasm/.pck) | ícone 160 px + barra pequena em fundo liso |
| 2 | **Boot splash do Godot** (a do print) | ícone quadrado 512 px sobre barras roxas laterais (`#42246C`), cursor do mouse à vista |
| 3 | `LoadingScreen.tscn` | degradê, logo, engrenagem, dicas, barra de 560 px |

A tela do print é a **#2**: `project.godot` tinha `boot_splash/image = contalmaster_icon.png` com
`bg_color` roxo. Como o ícone é quadrado e a janela é 16:9, aparecem as faixas roxas.
O shell não aparece nela, e a `LoadingScreen` só roda depois.

## O que mudou
1. `project.godot`: `boot_splash/show_image=false` e `bg_color` = `#100B1F` (UiPalette.BG).
   O boot splash vira só a cor de fundo, sem a faixa roxa nem o ícone quadrado.
2. `web/shell.html` reescrito para ser **idêntico à LoadingScreen**: mesmo degradê, logo, engrenagem
   girando com núcleo fixo, mesmas dicas, barra branca com preenchimento roxo (560 px) e porcentagem.
   Logo e engrenagem vão embutidos (base64), então aparecem na hora, antes do .wasm.
3. O overlay do shell agora só some quando o jogo avisa que já desenhou a `LoadingScreen`
   (`window.cmShellReady()`, chamado por `LoadingScreen._notify_web_shell()`). Há rede de segurança
   de 4 s: se o aviso não vier, o overlay some sozinho.
4. `LoadingScreen.gd`: só o método `_notify_web_shell()` e a chamada dele.

## Como aplicar
1. Copie o zip por cima do projeto.
2. **Exportar > Web > HTML > Custom HTML Shell = `res://web/shell.html`**.
   Confira mesmo: no `export_presets.cfg` esse campo costuma estar vazio (ver V0.13.3). É o motivo
   mais comum de o shell "não ser chamado". Mantenha Threads desligado.
3. Exporte de novo e **apague o `build/web` antigo** antes (o `index.html` de referência dele é de
   outra versão do shell). Suba para o itch.io.
4. Teste com cache limpo (Ctrl+Shift+R). No itch.io, a moldura "Click to play" e a barra do próprio
   itch.io ficam por fora do jogo e não dá para alterar por código.

## Limite
Não rodei no navegador (sem Godot/rede aqui). A lógica foi conferida lendo o loader do Godot 4.5.
