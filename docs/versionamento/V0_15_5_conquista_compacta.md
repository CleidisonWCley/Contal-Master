# V0.15.5 — Aviso de conquista compacto

Copie por cima do projeto mantendo as pastas. Nenhuma classe nova (nada para reimportar).

## O que mudou
- O cartão grande de "Nova estrela de confiança" (fundo escurecido + botão "Clique para continuar") foi **substituído por um aviso pequeno no canto superior direito**: rosto do personagem, texto **"Conquista desbloqueada"**, nome e estrelas. Sem barra de progresso e sem elementos pesados.
- O jogador **não precisa mais clicar em continuar**: o aviso entra com fade, fica parado e **some sozinho em ~3,5 s** (`SHOW_SECONDS` em `TrustCard.gd`, ajuste entre 3 e 4 se quiser).
- Ele **não bloqueia mouse/teclado**: a novel continua normalmente por baixo.
- Momento: aparece **no início da fala final** ("Depois de uma longa conversa, você conhece X um pouco melhor"), e não mais depois dela. Quem pula a conversa ainda vê o aviso (a estrela já foi entregue).
- Animações desligadas nas configurações: o aviso só aparece e some, sem fade.

## Arquivos alterados
- `scripts/ui/TrustCard.gd` (reescrito; `TrustCard.star()` e `TrustCard.progress()` mantêm a mesma assinatura)
- `scenes/cutscenes/StageDebrief.gd` (dispara o aviso junto da fala final, sem `await`)
- `project.godot` (versão 0.15.5)

## Ajuste 2 — Aba "Lembranças" (Arquivo da Equipe)
- **Bug corrigido:** as falas apareciam como `{ "s": "jales", "t": "..." }`. A aba convertia o quadro inteiro (dicionário) em texto. Agora lê `s` (quem fala) e `t` (texto) e mostra **"Nome: fala"**.
- Só essa aba tinha o problema (as demais abas, os capítulos da firma e a novel leem os dados corretamente).
- **Cores dos nomes:** cada nome vem na cor principal do minigame do personagem (Priscila amarelo · Anderson azul · Tiago laranja · Julios magenta · Ariel vermelho · Aline verde-água · Cleiton verde · Natália ciano · Jales dourado). Ficam em `LoreManager.CHARACTER_COLORS` (ajuste lá).

Arquivos: `scenes/menus/ArchiveEntry.gd`, `scripts/autoloads/LoreManager.gd`.
