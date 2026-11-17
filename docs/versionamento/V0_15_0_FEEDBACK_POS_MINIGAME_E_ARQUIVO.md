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

---
# V0.15.1 - Arquivos da Equipe como 3º modo + fichas dos personagens + estrada no Desvio Lógico

## Mudanças
1. **Desvio Lógico**: TODO o feedback depois do minigame (Natalia, corte da reunião e narração) acontece no cenário da **estrada à noite** (`14_estrada.png`), a ponte para os créditos. Sem a imagem, gradiente noturno de reserva. Vale na campanha e no Modo Livre. Configurável em `scripts/data/debrief/desvio_logico.json > background`.
2. **Arquivos da Equipe virou o 3º modo** em "Modo de jogo" (cartão próprio, ícone `icon_archive.svg`, degradê âmbar → rosa → roxo). O botão escondido do Modo Livre foi removido (`MenuMinigames.gd` voltou ao original).
   Motivo: descoberta (é onde o jogador já escolhe o que fazer), layout próprio e rolável no celular, e a lore deixa de depender de um menu de minigames.
3. **Hub** (`TeamArchive`): "A Firma" (6 capítulos: ilha, como nasceu, por que jogar, Primeiro Dia, valores, revisão) + "A Equipe" em grade **3 x 3**.
4. **Ficha** (`ArchiveEntry`) ao tocar num personagem: nome, cargo, confiança e abas **Perfil** (nome completo, idade e nascimento, altura, naturalidade, formação, traços, hobbies), **Gostos e forças**, **Origem e motivação**, **Relações**, **Momento marcante**, **Lembranças** (trechos de lore já ouvidos no Modo Livre). **Sem medidas do corpo.**
5. Conteúdo vindo de `contalmaster_elenco.docx` (v2.2): `scripts/data/lore/dossiers.json` e `firma.json`. Perfis e trechos de lore dos novels do Modo Livre foram **realinhados ao canon** do documento (ex.: Cleiton é auditor sênior, não "estagiário"; Natalia/Ariel/Aline/Julios/Anderson com as origens do doc).

## Trava por progresso (a calibrar)
Abas: Perfil e Gostos = nível 1 · Origem e Relações = nível 2 · Momento marcante = nível 3. Nível do Jales: 3 estações concluídas / 5 na Prata / 8 na Prata (`LoreManager.JALES_LEVEL_RULES`). Capítulos da firma abrem por estações concluídas (`firma.json > min_stations`).

## Novos arquivos
`scenes/menus/ArchiveEntry.(gd|tscn)`, `assets/icons/ui/icon_archive.svg(.import)`, `scripts/data/lore/{dossiers,firma}.json`.
Alterados: `ModeSelect.gd`, `TeamArchive.gd`, `LoreManager.gd`, `GameManager.gd`, `Paths.gd`, `StageDebrief.gd`, `DebriefBuilder.gd`, `profiles.json`, `fragments.json`, `secret_endings.json`, `desvio_logico.json`.
