# V0.15.0 - Feedback pós-minigame, corte do Desvio Lógico e Arquivo da Equipe

Base: ContalMaster v0.14.7 · Design: `ContalMaster_Fase2_Design.docx` (versão enxuta, decidida no chat).

## O que muda
**Campanha** (a narrativa continua a mesma; só ganha o "depois" do minigame)
1. Minigame termina → painel de números → **Continuar** → pontos somados/salvos (igual a antes).
2. NOVO `StageDebrief`: o anfitrião comenta o desempenho (perfeito / ótimo / médio / fraco; Roleta: bom / ruim), com dica opcional.
3. O **Jales** fecha chamando para a próxima estação (depois do STOP: "amanhã cedo, Desvio Lógico").
4. **Desvio Lógico (última)**: Natalia comenta, faz o **corte** (reunião no escritório; "vou me trocar e me arrumar", o que justifica a roupa formal na cena final) e roda o **interlúdio da estrada à noite** antes da cena final.

**Modo Livre**: feedback de 1 quadro do anfitrião + **uma novidade de lore** por conclusão (perfil na 1ª vez; depois trechos liberados), marcada como "Nome · Perfil" ou "Nome · Lore". Sem novidade, mostra a dica.

**Arquivo da Equipe** (botão no Modo Livre): 9 personagens, confiança 0-3, perfis e trechos já vistos, e a lista de **finais secretos** (só dados; as cenas virão depois).

## Interlúdio da estrada
Caminho preparado: `assets/background/14_estrada.png` (também aceita `assets/background/cutcines/14_estrada.png`).
Sem arquivo, usa gradiente noturno (`Paths.INTERLUDE_FALLBACK`). Ao colocar a imagem, entra sozinha. Texto da narração: `scripts/data/debrief/desvio_logico.json > interlude`.

## Arquivos
Novos: `scripts/autoloads/LoreManager.gd` (autoload), `scripts/core/DebriefBuilder.gd`, `scenes/cutscenes/StageDebrief.(gd|tscn)`, `scenes/menus/TeamArchive.(gd|tscn)`, `scripts/data/debrief/*.json` (8), `scripts/data/lore/{profiles,fragments,secret_endings}.json`.
Alterados (poucas linhas, marcadas V0.15): `GameManager.gd`, `Paths.gd`, `project.godot` (autoload + versão), `MenuMinigames.gd`, e uma linha `GameManager.report_stage({...})` em cada um dos 8 minigames.
Save novo e separado: `user://contal_master_lore.json` (recordes e conquistas intocados).

## Regras fixas respeitadas
Pontuação e recordes inalterados (o feedback roda DEPOIS de salvar); trava `_stage_open` mantida; Web: cenário e sprites aquecidos pela LoadingScreen (`_warm_for_debrief`); "Pular"/Esc em todo feedback; `GameManager.DEBRIEF_ENABLED := false` volta ao fluxo antigo.

## Confiança (a calibrar: `LoreManager.GOALS`)
Nível 1 = concluir; 2 = Prata (bom desempenho em Normal/Difícil **ou** 3 conclusões); 3 = Ouro. Roleta usa nº de conclusões (2 e 4).

## Pendências / decisões suas
- **Canon**: todos os perfis e trechos de lore são PROPOSTA (do docx). Edite em `scripts/data/lore/*.json`.
- **Roleta fora do Modo Livre**: trechos do Julios só liberam jogando a campanha (e leem-se no Arquivo).
- **Textos antigos** (limpeza de linguagem neutra, "revisor", Malfoid: V0.14.5 do docx) NÃO foram tocados; os textos novos já são neutros.
- Finais secretos: só liberam em dados (`LoreManager.get_unlocked_secret_endings()`); falta produzir as cenas.
- Testado em Godot 4.5 headless (lógica, feedback até o interlúdio, Arquivo e menu livre). Falta passada visual no editor e na exportação Web.
