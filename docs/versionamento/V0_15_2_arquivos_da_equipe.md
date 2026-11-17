# V0.15.2 — Arquivos da Equipe reorganizado

Copie os arquivos por cima do projeto, mantendo as pastas. Abra o projeto no Godot uma vez para ele importar o novo ícone `icon_team.svg`.

## O que mudou
- **Modo Livre:** removido o botão "Arquivo da Equipe" (redundante com a tela "Modo de jogo").
- **Arquivos da Equipe virou um hub** com 2 cartões (mesmo visual da tela "Modo de jogo"):
  - esquerda: **Arquivos da Firma** (capítulos da ilha, origem e valores);
  - direita: **Perfis da Equipe** (os 9 personagens).
  Cada cartão mostra o progresso (capítulos abertos / pessoas conhecidas).
- **Arquivos da Firma** (`FirmaArchive`): padrão da tela de Pontuação — lista de capítulos à esquerda (com cadeado e dica), leitura à direita, botões Anterior / Próximo e barra de progresso nos capítulos bloqueados.
- **Perfis da Equipe** (`TeamProfiles`): grade 3×3 à esquerda; à direita um cartão de prévia com o **cenário cortado do minigame** do personagem (Jales usa o escritório), cargo, confiança, minigame, progresso da ficha e "Abrir ficha completa".
- **Ficha completa** (`ArchiveEntry`): ganhou o cenário do minigame no topo; ao voltar, retorna a Perfis já com o personagem selecionado.
- Alternador "Arquivos da Firma | Perfis da Equipe" no topo das duas telas, para trocar sem passar pelo hub.
- **Responsivo:** ≥ 980 px lado a lado; abaixo disso empilhado (celular: prévia no topo e grade embaixo; ao escolher alguém a tela sobe sozinha; capítulos em 2 colunas).
- Versão: **0.15.2** (`project.godot`).

## Arquivos
Novos: `scenes/menus/FirmaArchive.{gd,tscn}`, `scenes/menus/TeamProfiles.{gd,tscn}`, `scripts/ui/ArchiveArt.gd`, `scripts/ui/SceneBanner.gd`, `assets/icons/ui/icon_team.svg`.
Modificados: `project.godot`, `scripts/core/Paths.gd`, `scripts/autoloads/GameManager.gd`, `scripts/autoloads/LoreManager.gd`, `scenes/menus/TeamArchive.gd`, `scenes/menus/ArchiveEntry.gd`, `scenes/menus/MenuMinigames.gd`.

## Observações
- Nenhum save muda. `open_archive_entry("firma:<id>")` continua funcionando (redireciona para a nova tela).
- Os cenários usam `Paths.CUTSCENE_BG_BY_PHASE`; só a imagem do minigame aberto é carregada.
