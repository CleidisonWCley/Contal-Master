# V0.16.0 - Botão global "Tela cheia - ON / OFF"

**Origem:** crítica construtiva de jogadores auditores de contabilidade que não conheciam o jogo: a tela cheia só existia em Configurações (escondida) e o botão nativo do itch.io fica no canto inferior direito.

## O que foi feito
- Botão **persistente** no canto **superior esquerdo** de TODAS as telas (menus, minigames, cutscenes, tutoriais), sempre visível.
- Texto de estado em palavras simples: **"Tela cheia - OFF"** (roxo escuro) e **"Tela cheia - ON"** (lilás cheio), com ícone padronizado (cantos para fora = entrar; cantos para dentro = sair) e dica ao passar o mouse.
- Fica na `CanvasLayer` layer 100 (acima do pause = 90, abaixo da confirmação de saída = 200); funciona com o jogo pausado.
- Sincroniza sozinho se o jogador sair da tela cheia com **ESC / F11 / gesto do celular** (sinal de redimensionamento + checagem 4x por segundo de `DisplayServer.window_get_mode()`).
- Clique mostra o novo estado na hora; se o navegador negar o pedido, o texto volta ao estado real em ~1,5 s.
- O clique passa pelo `SettingsManager.set_fullscreen()` (que chama `DisplayServer.window_set_mode`), então o botão de Configurações fica igual e a escolha é salva no desktop. Sem o SettingsManager o script muda a janela direto.
- Escondido automaticamente onde não funciona: apps Android/iOS e navegadores sem Fullscreen API (iPhone, iframe sem permissão).
- Sem foco de teclado: Enter/Espaço durante a partida nunca acionam o botão.

## Ajustes de layout para o canto esquerdo
- **Desvio Lógico:** o score agora fica **abaixo** do botão (y = 62, margem esquerda 22 px).
- **Tutoriais** (TutorialOverlay): o cartão no topo nunca sobe acima de y = 62 (antes o botão cobria o nome Natalia/Cleiton/Anderson).
- **Pontuação** (ScoreMenu): o título começa à direita do botão.

## Arquivos
- NOVO `scripts/ui/fullscreen_toggle.gd` (script do Button)
- NOVO `scenes/components/FullscreenOverlay.tscn` (CanvasLayer 100 + Button)
- NOVO `assets/icons/ui/icon_fullscreen.svg` e `icon_fullscreen_exit.svg` (+ `.import`)
- `project.godot`: autoload `FullscreenOverlay`, versão 0.16.0
- `scenes/minigames/desviologico/DesvioLogico.gd`, `tutorials/TutorialOverlay.gd`, `scenes/menus/ScoreMenu.gd`

## Para novas telas
HUDs no canto superior esquerdo devem começar abaixo de y = 60 (`HUD_RESERVED_BOTTOM` em `fullscreen_toggle.gd`).

## Teste no itch.io
Abra o jogo na página, clique no botão, aperte ESC e confira que o texto volta para OFF. Em iPhone o botão não aparece (limitação do Safari).
