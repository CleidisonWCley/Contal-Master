# V0.14.4.2 — STOP: novo título, 6 opções fixas e limpeza

Aplique por cima da 0.14.4.1.

## Problemas encontrados
1. **Título herdado de outro jogo:** a tela mostrava "STOP - GOVERNANÇA DE TI".
2. **Nem sempre 6 opções:** o dicionário só tinha 4 a 8 termos por inicial (D, E, F, L, O, P e S tinham 4; A, I e R tinham 5). Como todas as opções precisam começar com a letra sorteada, o jogo não conseguia montar 6 botões. O banco de perguntas ainda gerava só 5 opções por rodada.
3. **Script com conteúdo morto:** `Stop.gd` carregava ~280 linhas de conteúdo antigo de TI (perguntas `ALL_QUESTIONS`, explicações `STOP_EXPLANATIONS`, lista `STOP_TECH_TERMS_BY_INITIAL`) e uma segunda lógica de distratores que duplicava a do banco. O `Stop.tscn` tinha nós de teste ("Placeholder funcional") que o script apagava ao abrir.

## Título
Escolhido pela narrativa do **Cleiton** (Auditor Sênior & Especialista em Controle Normativo; estação "O Controle", Selo do Controle, "vocabulário normativo na ponta da língua"):

**STOP - CONTROLE NORMATIVO** (mesmo comprimento do título antigo; cabe na barra superior).
Para trocar depois: constante `STOP_TITLE` no topo de `Stop.gd`.

## O que mudou
| Arquivo | Mudança |
|---|---|
| `scenes/minigames/stop/Stop.gd` | 891 → ~700 linhas. Grade fixa de **6 botões (3 em cima, 3 embaixo)** criada uma vez e reaproveitada a cada rodada (sem recriar nós). Conteúdo de TI e lógica duplicada de opções removidos; as opções vêm só do `question_bank.gd`. Textos longos quebram em duas linhas em vez de serem cortados. Ícone STOP carregado uma vez; estilos compartilhados entre os botões. Atalhos 1–6 / A–F continuam. |
| `scenes/minigames/stop/Stop.tscn` | Só o nó raiz + script (os nós de teste foram removidos). |
| `scripts/core/question_bank.gd` | `STOP_OPTIONS_PER_ITEM` 5 → 6; lê `distratores_stop`; avisa no log se alguma inicial tiver menos de 6 termos. |
| `scripts/core/data/dicionario.json` | Nova chave `distratores_stop`: termos de contabilidade/auditoria por inicial (A, C, D, E, F, I, L, O, P, R, S), usados **só como opções erradas** (não viram palavra da Forca). Agora toda inicial tem 9+ termos. |
| `project.godot`, `BrandText.gd` | Versão 0.14.4.2. |

Nomes que o tutorial do Cleiton usa (`category_label`, `tip_label`, `options_grid`, `score_label`, `difficulty_label`) foram mantidos.

## Como testar
1. Abra o STOP em Fácil, Normal e Difícil: em **toda** rodada devem aparecer 6 botões, 3 + 3, todos começando com a letra sorteada.
2. Confira o título e o tutorial do Cleiton (o destaque da grade deve cobrir os 6 botões).
3. Teste teclas 1–6 e clique; confira acerto, erro (verde/vermelho) e a tela de fim.
4. Na web, abra com `?debug=1` e veja se há aviso `[STOP] Letra X tem so N opcoes` no console (não deve haver).

## Limites
- **Não rodei no Godot nem no navegador** (sem Godot neste ambiente): a lógica de dados foi validada por script (todas as iniciais com 6+ termos, nenhum distrator repetido), mas o código GDScript precisa de um teste seu.
- Ao adicionar termos novos ao dicionário com uma inicial nova, ela precisa de 6+ termos (termos + `distratores_stop`).
- Os distratores novos foram escolhidos para **não** servir como resposta de nenhuma dica existente; revise se criar dicas novas.
- Título no menu de minigames e nome da fase continuam "STOP" (marca do jogo); só o título dentro da tela do jogo mudou.
