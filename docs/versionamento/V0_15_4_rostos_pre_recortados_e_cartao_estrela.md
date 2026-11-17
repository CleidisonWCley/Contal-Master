# V0.15.4 — Rostos pré-recortados (web) e cartão de estrela só quando há estrela nova

Copie por cima do projeto mantendo as pastas e abra o Godot uma vez (ele importa os 9 PNGs `*_face.png`).
Godot não foi executado na análise (sem binário no ambiente): a causa do cartão foi comprovada lendo o código; a dos rostos
foi tratada trocando o método de desenho por um que já funciona no projeto (ver abaixo). **Teste no editor e no build web.**

## 1. Rostos dos personagens (quadrados brancos)
- **Sintoma:** grade, prévia, conquistas e cartão de estrela mostravam um quadrado branco no lugar do rosto.
- **Investigação:** os recortes de `FACES` estão certos para os PNGs `_3` atuais (conferido simulando o recorte em Python,
  1120x1500). O problema estava no *método*: `FaceAvatar` desenhava uma região do sprite com `_draw()` +
  `draw_texture_rect_region()`, e o resultado saía como retângulo branco. O teste automático da 0.15.3 roda em modo
  headless (sem renderização), por isso não pegava isso.
- **Web/otimização:** o método antigo carregava os 9 sprites `_3` inteiros (1120x1500 ≈ 6,7 MB de GPU cada, ~60 MB) só
  para avatares de 56–150 px.
- **Correção:** cada personagem ganhou um rosto pré-recortado `assets/sprites/personagens/<id>/<id>_face.png`
  (256x256, ~70–125 KB, ~256 KB de GPU, com mipmaps). `FaceAvatar` agora é um `TextureRect` comum (mesmo caminho das novels,
  que funciona), com cache por personagem. A API continua igual (`FaceAvatar.create(id, lado, bloqueado)`, `backdrop`),
  então nenhuma tela precisou mudar. Silhueta escura de "desconhecido" mantida.
- **Plano B:** se o `_face.png` faltar, usa o recorte do `_3` por `AtlasTexture` (e avisa no console).
- **Ajustar um rosto:** mude o número em `FACES` (FaceAvatar.gd), rode `python tools/gerar_rostos.py` e abra o Godot.
- **Caixa das pastas:** nomes em minúsculo (regra da 0.14.7). Reexporte a web e rode `tools/verificar_caixa_build.py`.

## 2. Cartão de estrela aparecendo sempre no Modo Livre
- **Causa:** em `StageDebrief._play_extras()`, quando não havia conversa, o código mostrava `TrustCard.progress`
  (a faixa "Próxima estrela: X / Y pontos") depois de **todo** minigame, tivesse avanço ou não. `DebriefBuilder` também
  marcava `progress_for` e contava isso como "tem conteúdo".
- **Correção:** a faixa deixou de ser mostrada e `progress_for` foi removido do plano. O cartão **NOVA ESTRELA DE CONFIANÇA**
  só aparece quando `LoreManager.begin_talk()` entrega a estrela de fato (conversa do Modo Livre). Sem estrela nova: só o
  feedback normal do anfitrião (e a dica, se houver). Se não há nada a mostrar, a tela de feedback nem abre.
- **Campanha:** nunca teve conversa nem cartão (inalterada). Pontos, estrelas, capítulos e saves: nada mudou.
- `TrustCard.progress()` continua existindo (sem uso) caso queira reaproveitar em outra tela.

## Arquivos
Novos: `assets/sprites/personagens/<id>/<id>_face.png` (+ `.import`) x9, `tools/gerar_rostos.py`.
Modificados: `scripts/ui/FaceAvatar.gd`, `scenes/cutscenes/StageDebrief.gd`, `scripts/core/DebriefBuilder.gd`,
`tools/tests/trust_smoke.gd`, `project.godot` (0.15.4).

## Como testar
1. Perfis da Equipe e Conquistas > Arquivos da Equipe: rostos visíveis (desconhecidos em silhueta escura).
2. Modo Livre: termine um minigame sem estrela nova → só o feedback, sem cartão. Com estrela → conversa + cartão.
3. `godot --headless --path . -s res://tools/tests/trust_smoke.gd` (checa também a existência dos 9 rostos).
