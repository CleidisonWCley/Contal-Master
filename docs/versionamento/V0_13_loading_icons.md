# Contal Master – Patch 0.13: Tela de Loading + ícones

Feito em cima do `contalmaster.zip` (v0.12). Extraia **por cima** da pasta do projeto (mesmos caminhos) e abra no Godot 4.5 para reimportar.

## O que entrou (arquivos novos)
- `scripts/core/SceneLoader.gd` – decide quando passar pela tela de loading. Edite só `HEAVY_PREFIXES` para mudar o que é "pesado".
- `scenes/loading/LoadingScreen.tscn` + `.gd` – a tela de loading (fundo roxo/azul em degradê, logo, engrenagem, dica, barra, porcentagem).
- `assets/icons/ui/icon_loading_core.png` – o miolo (cifrão) da engrenagem, separado para ficar parado enquanto a engrenagem gira.
- `web/shell.html` – entrada estilizada para o export web (substitui a tela cinza padrão).

## O que mudou (edições mínimas em arquivos existentes)
- `project.godot`: `run/main_scene` → `res://scenes/loading/LoadingScreen.tscn` (o jogo abre na loading e ela abre o MainMenu).
- `scripts/autoloads/GameManager.gd`, em `_change_scene()`: `get_tree().change_scene_to_file(scene_path)` → `SceneLoader.change_scene(get_tree(), scene_path)`.
- `scripts/core/Paths.gd`: + `const SCENE_LOADING := "res://scenes/loading/LoadingScreen.tscn"`; − `ICON_PLAY` (não é mais usado).
- `scenes/cutscenes/StageTransition.gd`: `"desvio_logico": Paths.ICON_PLAY` → `Paths.ICONS_UI_DIR + "icon_car.svg"`.
- Se o seu projeto já divergiu, aplique só essas linhas à mão em vez de substituir os arquivos inteiros.

## Como funciona
- **Primeira abertura (nativo e web):** LoadingScreen → carrega o MainMenu com barra → abre.
- **Menus** trocam direto (sem piscar a loading). **Minigames e cutscenes** passam pela loading, exceto se a cena já estiver em cache.
- Barra: trilho **branco**, preenchimento **roxo #8B3DFF** (UiPalette.PRIMARY), porcentagem de quanto já carregou.
- A barra é suavizada (`BAR_SPEED`) e a tela fica no mínimo `MIN_SHOW_SECONDS` (0.55 s) para não piscar.
- Engrenagem gira (respeita a opção "Animações visuais"); o cifrão fica parado.
- Dicas trocam a cada 2,6 s. Edite `LOADING_TIPS` no `LoadingScreen.gd`.
- Se o carregamento falhar (ex.: web sem rede): mensagem + **Tentar novamente** / **Voltar ao menu**.
- A tela funciona mesmo com o jogo pausado (`PROCESS_MODE_ALWAYS`).

## Web (entrada estilizada)
1. Project → Export → Web → **HTML → Custom HTML Shell** = `res://web/shell.html`.
2. Exporte. A barra da web (branca/roxa, mesma engrenagem) mostra o download do `.wasm`/`.pck`; depois a LoadingScreen do Godot assume.
3. Se o servidor não informar o tamanho, a barra vira "indeterminada" (vai e volta) em vez de travar em 0%.
4. O shell foi escrito a partir da estrutura do shell padrão do Godot 4.x (placeholders `$GODOT_*`). **Não consegui rodar um export web real aqui**; teste no navegador e, se algo estranho aparecer, compare com o `index.html` gerado pelo shell padrão.

## Ícones – varredura
**Pode apagar (sem nenhuma referência no código):**
- `assets/icons/exit.png`, `assets/icons/settings.png` (pretos; as versões brancas já são `ui/icon_exit.png` e `ui/icon_settings.png`)
- `assets/icons/play.png` (preto; era usado só na transição do Desvio Lógico, já trocado pelo `icon_car.svg` branco)
- `assets/icons/ui/icon_cursor.svg`
- Apague também os `.import` correspondentes.

**Otimizados (mesmos nomes, mesma proporção, 256 px):** `trofeu`, `mala`, `cadeado`, `perigo`, `naval`, `money` → de ~9,1 MB para ~230 KB. Eles aparecem em 26–76 px no jogo, então não perde qualidade visível, e o download da web cai bastante.

**`icon_loading.png`:** substituído por versão 512 px recentralizada (era 1254 px, ~370 KB).

**Pendências (decisão de vocês, não mexi):**
- Os 6 ícones coloridos acima ainda são arte colorida nos minigames (não são pretos). Se quiserem tudo em branco, dá para migrar para os SVGs brancos de `UiIcons`.
- `perseguicao` e `forca_tecnica` usam o cadeado como ícone na transição (parece provisório).

## Testado / não testado
- Testado (Godot 4.5, headless + captura de tela): importação sem erros; boot → MainMenu; Desvio Lógico via loading; estado de erro.
- Não testado: export web real, navegador, celular.

## Pontos de atenção
- Na web **sem suporte a threads**, o carregamento de cena pode não reportar progresso intermediário (a barra salta); a suavização cobre isso. Confira no seu export.
- Confira com a equipe as referências normativas das dicas (ex.: "NBC PA 11") antes de publicar.
- Opcional: alinhar `application/boot_splash/bg_color` com o topo do degradê (#100B1F) para a transição splash → loading ficar contínua.
