# V0.15.3 — Rostos certos, capítulos por recorde e conversas de confiança

Copie por cima do projeto mantendo as pastas e abra o Godot uma vez (ele registra as classes novas `FaceAvatar` e `TrustCard`).
Testado com Godot 4.5 (headless): importação limpa, telas abrem sem erro e o teste `tools/tests/trust_smoke.gd` passa.

## 1. Cards dos personagens cortados
- Novo `scripts/ui/FaceAvatar.gd`: usa o sprite **_3** e centraliza o rosto de cada personagem (posição medida em `FACES`; ajuste ali se quiser mais/menos zoom). Sempre quadrado, nada é cortado.
- Usado na grade e na prévia de Perfis da Equipe, na ficha, nas conquistas e no cartão de confiança.

## 2. Capítulos da firma por recordes
- Capítulo abre quando os **pontos de recorde** (melhor campanha de cada dificuldade + melhor marca de cada minigame do Modo Livre em cada dificuldade) passam da meta. Dificuldade maior rende mais pontos.
- Metas (`scripts/data/lore/firma.json`, campo `min_points`): A Ilha 150 · Como nasceu 500 · Por que um jogo 1.400 · O Primeiro Dia 2.800 · Valores 5.000 · A revisão 8.000. Os dois primeiros são baixos e a escala sobe. Ajuste os números no JSON.
- Capítulo aberto nunca fecha de novo; ao abrir aparece o quadro "Capítulo liberado!". A tela bloqueada mostra pontos atuais / meta.

## 3. Confiança por estrelas e conversas do Modo Livre
- Cada estação concluída (campanha ou livre) rende pontos de confiança ao anfitrião (base 10, +5 na 1ª vez, +faixa de desempenho, +dificuldade). Estrelas: 12 / 48 / 105 pontos (`LoreManager.STAR_THRESHOLDS`).
- Ao concluir a estação no **Modo Livre** com estrela pendente: feedback do anfitrião → conversa em que ele conta a própria história (3 a 4 quadros, com o Jales) → tela centralizada "Depois de uma longa conversa, você conhece X um pouco melhor." → quadro de conquista com a nova estrela. Dá para pular (a estrela não se perde).
- 27 cenas novas em `scripts/data/lore/fragments.json` (3 por personagem), escritas na voz de cada um a partir do documento do elenco v2.2.
- **Jales**: participa de todas as conversas, ganha 10 pontos por conversa (+15 ao terminar a campanha); estrelas em 20 / 50 / 90.
- **Julios** não tem minigame no Modo Livre: ele "passa pela sala" depois de qualquer minigame quando tem estrela pendente.
- Sem conversa na rodada, aparece uma faixa curta com o andamento até a próxima estrela. Campanha não muda.
- Saves antigos: estrelas que o jogador já tinha viram estrelas (nada se perde). Os finais secretos usam os ids das cenas (`jales_all2` virou `jales_2`).

## 4. Conquistas
- Nova aba **Arquivos da Equipe** em Conquistas: 6 capítulos e 9 personagens (só o rosto centralizado, estrelas e barra de pontos até a próxima). Não altera o rank Bronze/Prata/Ouro/Platina.

## Arquivos
Novos: `scripts/ui/FaceAvatar.gd`, `scripts/ui/TrustCard.gd`, `tools/tests/trust_smoke.gd`, `tools/tests/trust_cards.{gd,tscn}`.
Modificados: `project.godot`, `LoreManager.gd`, `GameManager.gd`, `AchievementManager.gd`, `DebriefBuilder.gd`, `StageDebrief.gd`, `TeamProfiles.gd`, `ArchiveEntry.gd`, `FirmaArchive.gd`, `AchievementsMenu.gd`, `fragments.json`, `firma.json`, `secret_endings.json`.
