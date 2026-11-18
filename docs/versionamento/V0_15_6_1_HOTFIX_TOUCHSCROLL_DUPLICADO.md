# V0.15.6.1 — Hotfix: `TouchScroll` duplicado (classe x autoload)

Só correção de erro de projeto; nenhuma mecânica muda. Copie por cima mantendo as pastas e abra o projeto no Godot
uma vez (ou Projeto > Recarregar projeto atual) para ele atualizar o cache de classes.

## Erro

```
SCRIPT ERROR: Parse Error: Class "TouchScroll" hides an autoload singleton.
          at: GDScript::reload (res://scripts/ui/TouchScroll.gd:2)
ERROR: Failed to load script "res://scripts/ui/TouchScroll.gd" with error "Parse error".
```

Efeito real: além do erro no console, `scenes/menus/TeamArchive.gd` **não compilava**
("Failed to compile depended scripts"), então a tela **Arquivos da Equipe** quebrava.

## Causa

Dois patches diferentes receberam o mesmo número **0.15.6** e criaram um `TouchScroll` cada um. Ao mesclar, os dois ficaram no projeto:

| Arquivo | Origem | Como existe no Godot |
|---|---|---|
| `scripts/ui/TouchScroll.gd` | patch "scroll por toque" (`V0_15_6_scroll_por_toque.md`) | `class_name TouchScroll`, usado com `TouchScroll.attach(scroll)` |
| `scripts/autoloads/TouchScroll.gd` | patch "otimização web" (`V0_15_6_otimizacao_web.md`) | autoload `TouchScroll` registrado no `project.godot` |

O Godot 4 não aceita uma `class_name` com o mesmo nome de um autoload (o autoload já é um singleton global com aquele nome).
O patch da web foi o que **substituiu** o do scroll: o autoload registra sozinho toda `ScrollContainer` (inclusive Pause, Configurações,
Pontuação), então as chamadas `TouchScroll.attach(...)` deixaram de ser necessárias e foram removidas dos menus que esse pacote reescreveu
(`TeamProfiles`, `FirmaArchive`, `AchievementsMenu`, `ArchiveEntry`, `Settings`).
**`TeamArchive.gd` não estava nesse pacote**, então ficou com a chamada antiga, que não existe mais no autoload.

## Correção

- **Mantido:** o autoload `scripts/autoloads/TouchScroll.gd` (é o que o `project.godot` registra e o que cobre todas as telas).
- `scenes/menus/TeamArchive.gd`: removida a linha `TouchScroll.attach(scroll)` (a rolagem continua funcionando, agora pelo autoload).
- `scripts/ui/TouchScroll.gd`: **sem `class_name`**, virou uma casca vazia marcada como obsoleta. Assim copiar o patch por cima resolve o erro
  mesmo sem apagar nada. **Pode apagar** `scripts/ui/TouchScroll.gd` e `scripts/ui/TouchScroll.gd.uid` quando quiser; nada referencia o uid.
- `V0_15_6_scroll_por_toque.md`: aviso no topo de que a solução foi substituída.

## Arquivos
- alterado: `scenes/menus/TeamArchive.gd` (1 linha)
- alterado: `scripts/ui/TouchScroll.gd` (sem `class_name`, obsoleto)
- docs: este arquivo e aviso em `V0_15_6_scroll_por_toque.md`

## Como foi testado (Godot 4.5 stable, headless)
- **Reproduzido** o erro exato no projeto original antes de mexer (inclusive o `TeamArchive.gd` falhando ao compilar).
- Varredura de todos os `.gd`/`.tscn` (95 arquivos): **2 erros antes, 0 depois**; nenhum outro erro de parse no projeto.
- `tools/tests/touch_scroll_test.gd` com toque simulado (celular deitado 1280x592):
  Perfis da Equipe 0 → 182, Conquistas 0 → 308, Firma 0 → 82; em tela baixa (1280x380) Arquivos da Equipe 0 → 109 e Ficha 0 → 67.
  Cliques disparados durante o arraste: 0. Toque curto em botão: 1 clique.
- Reproduzir: `godot --headless --path . -s tools/tests/touch_scroll_test.gd -- res://scenes/menus/TeamArchive.tscn 1280 380`

## Não testado (precisa de aparelho real)
Inércia e "sensação" do dedo no navegador do celular/tablet (o teste usa toque simulado).

## Para não repetir
Antes de começar um patch, reserve o número da versão no `CRONOGRAMA_VERSOES.md` (linha "em andamento"), como já indicado lá desde a 0.13.2.
Dois patches 0.15.6 simultâneos foram a origem deste problema. Observação: o cronograma está parado na 0.14.4.2; as versões 0.14.6 a 0.15.6
só existem como arquivos soltos em `docs/versionamento`.
