# Contal Master — Patch 0.12.2 (correção de estabilidade e saves)

> **Testado fora do editor**, no Godot 4.5.1 (Compatibilidade, renderização real via Xvfb): importação limpa **sem cache**, carga dos 70 scripts/cenas, instanciação de **todas** as cenas do jogo (menus, 8 minigames, intro, transição, final, tutorial) e teste de saves. Não joguei a campanha inteira: faça o checklist da seção 5 antes de entregar.

## 1. O que aconteceu (causa raiz)
Todos os erros da lista vieram de **uma única linha**: ao mesclar o bloco `CUTSCENE_FLOOR`/`NOVEL_LAYOUT` das duas versões (a V0.12 e a V0.11.1 do colega), sobrou um **`}` solto** em `scripts/core/Paths.gd` (logo depois de `NOVEL_LAYOUT`).

- `Paths` é uma classe usada por quase tudo. Com o parse quebrado, cada script que lê `Paths.XXX` numa constante falhou em cascata: `ScoreManager`, `SettingsManager`, `AudioManager`, `DifficultyManager`, `GameManager`, `AchievementManager`, `NovelStage`, `StageTransition`, `CutsceneIntro/Final`, `MenuMinigames`, módulos do Desvio Lógico (`PROP_SPRITES`, `NPC_SPRITES`), `ForcaTecnica`, `RoletaRisco`…
- Como `ScoreManager` e `SettingsManager` não carregaram, os **saves não carregavam** (nada leu os arquivos). **Não havia falha no código de save em si.**
- `Unrecognized UID: uid://coohboqcvu20l`: o `project.godot` apontava para o UID antigo do ícone; o PNG foi reimportado com outro UID.

## 2. Correções
| Arquivo | Correção |
|---|---|
| `scripts/core/Paths.gd` | Removido o `}` extra após `NOVEL_LAYOUT` (**correção principal**). |
| `project.godot` | `config/icon` agora usa o **caminho** (`res://assets/contalmaster_icon.png`), imune a troca de UID. |
| `scripts/autoloads/ScoreManager.gd` | Save ilegível (JSON quebrado) **não é mais sobrescrito em silêncio**: antes de recriar, guarda cópia em `contal_master_scores.json.corrompido.bak`. |

Mantido sem alteração: a versão do `project.godot`/`APP_VERSION` e todo o trabalho do colega (quadros embaixo, alturas em `CharacterHeights`, sprites `_1/_2/_3`, tutorial da Natalia).

## 3. Estado do que está nos docs 0.12 / 0.11.1 (verificado por renderização)
- **Novels (transições)**: sprites `_1` inteiros, em pé acima do quadro, quadro **sempre embaixo**, fundo desfocado, só nome + fala. ✔
- **Cena final**: escritório → corredor (Natalia `_2`, 2 quadros) → sala (elenco em 2 fileiras) com quadro embaixo; pernas parcialmente cobertas pelo quadro (intencional). ✔
- **Tutorial da Natalia (Desvio Lógico)**: o cartão acompanha o texto, o retrato fica preso ao cartão, avança os 3 passos e inicia a partida. ✔
- **Transição**: título no topo ~5,5 s, sem bola/tremor, música do minigame, partículas sem letras. ✔

## 4. Saves (teste real com pasta de usuário isolada)
| Caso | Resultado |
|---|---|
| Save antigo (`party_pascal_scores.json`) | Migrado para `contal_master_scores.json`, apelido preservado, arquivo antigo removido. |
| Save atual | Carregado normalmente. |
| Save corrompido | Jogo inicia, cópia de segurança `.corrompido.bak` criada. |

## 5. Como aplicar
1. Feche o Godot e use esta pasta **inteira** (o zip não inclui `.godot`, que é cache).
2. Abra o projeto no Godot 4.5.x. A **primeira abertura reimporta** os assets (pode demorar alguns minutos).
3. Se o editor reclamar de cache, apague a pasta `.godot` e abra de novo.
4. Checklist: campanha completa (títulos, novels, tutoriais, os 8 minigames), final até os créditos, modo livre, Configurações (animações ligadas/desligadas), janela pequena.

## 6. Pontos de atenção
- Os avisos de "anchors" em `Perseguicao.gd` (linhas 169/177) já existiam e são inofensivos.
- Para evitar o problema de novo: ao mesclar patches, abra o projeto **antes** de entregar; um erro em `Paths.gd` derruba o jogo inteiro.
