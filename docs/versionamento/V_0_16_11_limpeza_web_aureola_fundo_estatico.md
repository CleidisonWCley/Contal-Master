# Patch V0.16.11 — Limpeza para o build web (sem postes, sem farol, fundo estático)

Copie os arquivos por cima do projeto, mantendo as pastas. Nenhum asset novo. Depois de copiar, feche e reabra o Godot (ele reconstrói o cache de UIDs).

## O que mudou (Desvio Lógico)
- **Postes removidos de vez.** Saíram o desenho por script, a luz noturna, os PNGs referenciados (`poste_lateral*.png`, que nem existiam mais no projeto), os sprites de pré-visualização da cena e as constantes `POST_*`.
- **Farol removido.** No lugar entra uma **aureola de luz branca suave** à frente do Bionix, só no Anoitecer e na Noite (`DLCarLights.KIND_HEAD`). Forma: cone suave que abre à frente do carro + poça no asfalto. Todos os controles ficam juntos no bloco "LUZ A FRENTE DO BIONIX" do `DLConfig.gd` (`CAR_HEADLIGHT_BY_ROUND`, `AURA_CONE_*`, `AURA_POOL_*`). Aparelho fraco (`WebLite.low_end()`) desenha 1 camada em vez de 2. As lanternas vermelhas continuam.
- **Fundo 100% estático.** Removidos o zoom/ondulação do fundo (`_update_background_motion_fx`) e a faixa do horizonte que crescia (`SkylineApproach`). Sai uma cópia da textura do fundo por partida e um update por quadro.
- **Markers da cena mantidos:** `PostLeft*` / `PostRight*` continuam em `SidePropMarkers`, mas agora só guiam as listras decorativas do gramado (`PROP_TRAIL_LEFT/RIGHT`). A perspectiva delas usa `DLConfig.GRASS_VANISH_Y` (era `POST_VANISH_Y`, mesmo valor).

## Erros do console corrigidos
- `DesvioLogico.tscn`: `invalid UID` + `Resource file not found` de `poste_lateral*.png` (ext_resources e 6 sprites de preview removidos).
- `Paths.gd`: `DL_PROP_POST` / `DL_PROP_POST_LEFT` removidos do dicionário de sprites.
- `ForcaTecnica.tscn`: UID do script estava desatualizado (mesmo warning `invalid UID`).
- `DesvioLogico.tscn`: o script `DLEditorGuide.gd` ganhou o UID correto.

## Versão
- `project.godot` e `BrandText.gd`: 0.16.10 → 0.16.11.

## Arquivos modificados
- `project.godot`
- `scripts/ui/BrandText.gd`
- `scripts/core/Paths.gd`
- `scenes/minigames/desviologico/DesvioLogico.gd`
- `scenes/minigames/desviologico/DesvioLogico.tscn`
- `scenes/minigames/desviologico/DLConfig.gd`
- `scenes/minigames/desviologico/modules/DLSideProps.gd`
- `scenes/minigames/desviologico/modules/DLCarLights.gd`
- `scenes/minigames/forca/ForcaTecnica.tscn`

## Observação
- `tools/dl_calibrar_postes.py` ficou obsoleto (calibrava os postes). Pode ser apagado; não afeta o jogo.
- Rode `python tools/verificar_caixa_build.py build/web/index.pck` antes de publicar.

---

# Tópico V0.16.11.1 — Pause espaçoso, tela cheia no celular, postes fixos, ciclista, parada em 18 s e faróis mínimos

Copie os arquivos por cima do projeto, mantendo as pastas. Nenhum asset novo. Depois de copiar, feche e reabra o Godot. **Exporte o build web de novo** (o `WebBridge.gd` mudou).

## 1. Menu de pause mais largo e espaçoso (`MinigamePause.gd`)
- Painel de 460 → **640 px**; margens e espaçamentos maiores.
- Botões do menu 380×54 → **564×64**; toggles (Animações/Tutoriais) 380×50 → **564×60**; Auto/Clique e seletor de fonte com **60/58 px** de altura.
- Botão "Pausar" do canto: 126×46 → **158×54**.

## 2. Botão TELA: ON/OFF no celular (`WebBridge.gd`, `fullscreen_toggle.gd`, `SettingsManager.gd`)
- **Causa**: o Godot guarda um estado próprio de tela cheia. Quem saía pelo gesto do aparelho/Esc ficava com o Godot achando que ainda estava em tela cheia, e o pedido para voltar era ignorado. Além disso, o palpite por **tamanho de tela** (V0.16.9.4) marcava ON no celular mesmo fora da tela cheia.
- **Correção**: o pedido agora vai **direto para a Fullscreen API** do navegador (`window.__cmSetFs`), armado no toque e executado no próprio gesto (`__cmArmFs`), como o celular exige. O estado do botão vem só do navegador (API ou app instalado/PWA). O palpite por tamanho foi removido.
- A tela de Configurações usa o mesmo caminho (`SettingsManager.apply_window_settings`).
- Teste no aparelho: entrar → sair pelo gesto do celular → tocar de novo no botão deve voltar à tela cheia.

## 3. Postes fixos por script (`DLSideProps.gd`, `DLConfig.gd`, `DesvioLogico.tscn`)
- **6 postes**: 3 por lado, **parados** (não nascem, não se movem), sobre a calçada, nos markers `PostLeftStart/Mid/End` (perto da placa / meio / canto inferior). O lado direito é o **espelho** do esquerdo (mesma distância).
- O poste do canto inferior fica um pouco para dentro da tela (`POLE_NEAR_INSET`), ainda sobre a linha da calçada; é o único que o Bionix "ultrapassa".
- Os postes são desenhados **antes** de placa, ciclista e carros: nada fica atrás de poste.
- **Luz**: do Entardecer à Noite aparece só uma **bolinha branca** alinhada com a lâmpada (`POLE_LIGHT_BY_ROUND`), sem luz grande no chão.
- Ajustes rápidos em `DLConfig.gd`: `POLE_HEIGHT_FAR/MID/NEAR`, `POLE_NEAR_INSET`, `POLE_ARM_RATIO`.

## 4. Ciclista
- Os markers `CyclistLeftStart/End` saíram da calçada para a **linha lateral da pista** (560,268 → -13,715).
- Continua aparecendo **2 vezes**, agora em 12% e 46% do percurso (2,2 s e 8,3 s): antes o 2º estava em 27 s, depois do fim dos 18 s, e nunca aparecia.
- Desenhado por cima dos postes.

## 5. Tempo de gameplay (18 s) e parada do carro (`DesvioLogico.gd`, `DLConfig.gd`)
- A freada do carro e a desaceleração do cenário começam juntas e terminam juntas **exatamente em 18,0 s** (`progress = 1.0`). Velocidade do cenário = (1−t)², posição do carro = 1−(1−t)³, sem a "cauda" longa que fazia tudo parecer parado ~1 s antes.
- O carro para no meio da pista em `DLConfig.CAR_DECISION_STOP_Y_RATIO = 0.48` (antes ~0.40, colado na placa).

## 6. Faróis minúsculos (`DLConfig.gd`, `DLCarLights.gd`)
- `AURA_CONE_LENGTH` 0.42 → **0.13**; meia-largura 0.26/0.48 → **0.07/0.13**; poça 0.75×0.12 → **0.26×0.05**.

## Versão
- `BrandText.gd`: 0.16.11 → **0.16.11.1**. **Atenção:** o `project.godot` não veio no zip enviado; altere nele `config/version` para `0.16.11.1` (a fonte única da versão).

## Arquivos modificados
- `scenes/components/MinigamePause.gd`
- `scripts/autoloads/WebBridge.gd`
- `scripts/autoloads/SettingsManager.gd`
- `scripts/ui/fullscreen_toggle.gd`
- `scripts/ui/BrandText.gd`
- `scenes/minigames/desviologico/DesvioLogico.gd`
- `scenes/minigames/desviologico/DesvioLogico.tscn`
- `scenes/minigames/desviologico/DLConfig.gd`
- `scenes/minigames/desviologico/modules/DLSideProps.gd`
- `scenes/minigames/desviologico/modules/DLCarLights.gd`
- `docs/versionamento/V_0_16_11_limpeza_web_aureola_fundo_estatico.md`

## Não testado no Godot
Feito sem abrir o editor. Conferir: posição/altura dos postes (constantes `POLE_*`), ponto de parada do carro (`CAR_DECISION_STOP_Y_RATIO`) e o botão TELA em celular real.


## Ajuste pós-teste (V0.16.11.1b)
- Postes ~40% menores (`POLE_HEIGHT_FAR/MID/NEAR` = 46 / 120 / 215).
- Poste do canto bem mais embaixo (`POLE_NEAR_Y = 705`): o Bionix nasce perto dele e o deixa para trás.
- Aproximação final da placa: o carro freia até o meio da pista (`CAR_PRE_STOP_Y_RATIO`) e só nos últimos 1,6 s (`CAR_SIGN_APPROACH_SECONDS`) chega perto da placa (`CAR_DECISION_STOP_Y_RATIO = 0.425`), terminando junto com os 18 s.

## Ajuste pós-teste 2 (V0.16.11.1c)
- Percurso volta a **22 s** (`DRIVE_DURATION_SECONDS`); a aproximação final da placa continua nos últimos 1,6 s.
- **Postes do canto dinâmicos**: começam sobre a calçada (`POLE_NEAR_START_Y`), descem pela linha da calçada com a velocidade do cenário e somem pela borda (`POLE_NEAR_EXIT_Y`); não atravessam mais a pista. Postes do meio e distantes seguem fixos.
- **Faróis**: dois feixes pequenos, um por farol, que passam da frente do sprite (antes ficavam escondidos atrás do carro). `AURA_CONE_*` e intensidade do Anoitecer 0.5 → 0.8. Só aparecem de Anoitecer em diante.

## Ajuste pós-teste 3 (V0.16.11.1d)
- **Poste dinâmico do canto inferior removido.** Ficam 4 postes fixos (2 por lado: perto da placa e meio).
- **Farol**: volta a ser UM cone só (como na V0.16.11), com densidade menor (`AURA_CONE_ALPHA` 0.15, poça 0.09); intensidade do Anoitecer de volta a 0.5.
- **Menu de pause**: painel de 900 px e Configurações em **2 colunas** (esquerda: Áudio e Jogo; direita: Novel e Acessibilidade), botões sem largura mínima fixa, menos rolagem.
- **Pause (e)**: painel de 1080 px (cresce para os lados) para as Configurações caberem sem rolar; a rolagem só aparece com fonte Grande/Extra grande.

## Animação final da bifurcação (V0.16.11.1f)
Sequência: o Bionix **vai para o meio** da pista (centraliza de −2,6 s a −0,6 s do fim) → **chega perto da placa** (aproximação de 2 s, `CAR_SIGN_APPROACH_SECONDS`) → **para** com o velocímetro em 0 → **pausa de 0,7 s** com o carro parado (`DECISION_STOP_HOLD_SECONDS`, sem clique nas respostas) → aparecem a pergunta e as rotas A/B. Com animações desligadas não há pausa. Constantes em `DLConfig.gd`: `CENTER_BLEND_LEAD_SECONDS`, `CENTER_DONE_BEFORE_END_SECONDS`, `DECISION_STOP_HOLD_SECONDS`.
