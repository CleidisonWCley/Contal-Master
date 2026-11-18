# V0.15.6 — Otimização de plataforma (web / celular / tablet)

Só ajustes de plataforma; a mecânica do jogo não muda. **Abra o projeto no editor uma vez antes de exportar**
(o Godot registra as novas classes `StarsRow` e o autoload `TouchScroll`).

## 1. Rolagem por toque (celular/tablet)
- Novo autoload `scripts/autoloads/TouchScroll.gd`: toda `ScrollContainer` do jogo (Arquivo da Equipe, Conquistas, Pontuação,
  Configurações, Pause...) agora rola arrastando o dedo, **inclusive quando o toque começa em cima de um cartão/botão**
  (antes o cartão "engolia" o toque). Tem inércia ao soltar. Toque curto continua sendo clique; ao arrastar, o clique é cancelado.
- Mouse e roda do mouse não mudam.

## 2. Estrelas e setas sem símbolos (ícones que sumiam na build)
- A fonte da build web não tem ★ ☆ ← →. Agora as **estrelas são desenhadas em código** (`scripts/ui/StarsRow.gd`) no Arquivo da
  Equipe, nos cartões de Conquistas, na ficha e no aviso de conquista. Nenhum texto/glifo envolvido.
- Desvio Lógico: as setas das opções "ROTA A / ROTA B" viraram **ícones** (seta para a esquerda e seta espelhada para a direita).
- Textos com setas/símbolos raros trocados por palavras ou ASCII (dica da Perseguição, botões "< Anterior / Próximo >").

## 3. Somente na horizontal
- `web/shell.html`: em **tela em pé (retrato)** o canvas é ocultado e aparece "Gire o aparelho" (celular, tablet e PC).
  Ao deitar o aparelho o jogo volta sozinho, no mesmo ponto. Botão "Tela cheia na horizontal" no aviso.
- Ao entrar em tela cheia o shell tenta `screen.orientation.lock('landscape')` (Android/Chrome gira sozinho); ao sair, destrava.
  iPhone/iPad (Safari) não permitem tela cheia nem trava: ali o aviso pede para girar o aparelho.
- `WebBridge`: enquanto estiver em pé, **pausa o minigame e silencia a música**; retoma ao voltar para horizontal.
- `project.godot`: `display/window/handheld/orientation = sensor_landscape` (builds nativas).
- No export web, em Preset > Progressive Web App (se usar), defina Orientation = Landscape.

## 4. Som de conquista nas estrelas
- O aviso de estrela de confiança (`TrustCard`) agora toca o mesmo som `conquista` das conquistas de capítulo.

## 5. Áudio travando / engasgando
Causas encontradas e corrigidas:
- **Gravação em disco a cada tique do slider de volume** (na web `user://` é IndexedDB e trava a página, e junto o áudio).
  Agora `SettingsManager` grava com atraso (0,6 s após a última mudança) e força a gravação ao esconder a aba/fechar. Valores
  iguais não regravam nem emitem sinal.
- **Clique de prévia a cada tique** do slider de efeitos: limitado a ~5 por segundo (Configurações e Pause).
- **Primeiro som carregava o arquivo na hora**: os efeitos são pré-carregados um por quadro logo após abrir o jogo.
- **Rajadas do mesmo efeito** (evento duplicado) são unificadas (intervalo mínimo de 35 ms por efeito).
- **Troca de música lia/decodificava o arquivo de novo**: cache das 3 últimas músicas.
- Mantidos: música em modo Stream, 1 player de música + pool de efeitos, latência web de 100 ms, watchdog.

## Arquivos
`project.godot`, `web/shell.html`, `scripts/autoloads/{TouchScroll,SettingsManager,WebBridge,AudioManager}.gd`,
`scripts/ui/{StarsRow,ArchiveArt,TrustCard,UiIcons}.gd`, `scenes/menus/{TeamProfiles,ArchiveEntry,AchievementsMenu,FirmaArchive,Settings}.gd`,
`scenes/components/MinigamePause.gd`, `scenes/minigames/desviologico/DesvioLogico.gd`, `scenes/minigames/perseguicao/Perseguicao.gd`.
