# CM-V0.13.3 — Trilhas sonoras da nova identidade + unificação das linhas 0.13.1 e 0.13.2

> Faixa **0.13** · áudio, versionamento e unificação. Base: projeto **0.13.2.1** (`contal-master_atual_.zip`). Veja o índice em [`CRONOGRAMA_VERSOES.md`](CRONOGRAMA_VERSOES.md).

## 1. Unificação (o que foi preservado e o que foi somado)

Três frentes foram feitas em paralelo sobre a base 0.13 e chegaram juntas:

| Frente | Versão | Estado nesta entrega |
|---|---|---|
| Sala de reunião sem cortes solo (janela de 3, saída lateral), logo final, padronização ContalMaster, avisos de sintaxe, leveza web | 0.13.1 | **preservada** (já estava no projeto) |
| Cena de chegada à sala (`ArrivalScene`), conversa Jales/Natalia, imagem `13_entrada_sala_reuniao.png`, ajustes nas novels | 0.13.2 / 0.13.2.1 | **preservada sem alteração de lógica** (`CutsceneFinal.gd`, `final.json`, `Paths.gd` e `ArrivalScene.gd` intactos) |
| Trilhas sonoras | (era 0.13.2) | **somada**, agora como **0.13.3** |

As duas últimas usaram o número `0.13.2`; a numeração foi reorganizada (ver `CRONOGRAMA_VERSOES.md`) e esta entrega é a **0.13.3**, uma acima da `0.13.2.1` que estava no projeto.

Ajustes pontuais feitos na unificação (todos pequenos e sem mudar comportamento):

| Onde | O que |
|---|---|
| `ArrivalScene.gd` (`_additive_material`) | variável local `material` sombreava `Control.material` (aviso `SHADOWED_VARIABLE_BASE_CLASS`); renomeada para `additive` |
| `.gitignore` | a regra `*.html` **ignorava `web/shell.html`** (o shell do V0.13 não era versionado e os outros membros não o recebiam). Adicionada a exceção `!web/shell.html` |
| `README.MD`, `.gitignore` | "Contal Master" → **ContalMaster**; estrutura do repositório passa a citar `tools/` e `web/` |
| `export_presets.cfg` | preset Android com `version/name="0.9.2.1"` → `0.13.3` (arquivo local, está no `.gitignore`) |
| Versão | `0.13.2.1` → **`0.13.3`** em `project.godot` e `BrandText.DEFAULT_VERSION` |

> **Ponto de atenção (não alterado):** no preset **Web** do `export_presets.cfg`, `html/custom_html_shell` está **vazio**; o doc da V0.13 manda usar `res://web/shell.html`. Se o export web ainda mostra a tela cinza padrão, é isso.

## 2. Causa do erro de importação das trilhas

```
ERROR: Ogg Vorbis decoding failed. Check that your data is a valid Ogg Vorbis audio stream.
ERROR: Error importing 'res://assets/sounds/musica/musica_stop.ogg'.
```

`assets/sounds/musica/musica_stop.ogg` **não era Ogg Vorbis: era um MP3** (primeiros bytes `FF FB`, 112 kbps) com a extensão trocada para `.ogg`. O Godot escolhe o importador pela **extensão**, tentou decodificar como Vorbis e falhou (`.import` com `valid=false`; o minigame Stop ficava sem música). Renomear um arquivo **não** converte o formato.

Os outros 11 eram Vorbis legítimos, mas havia mais inconsistências:

| Problema | Antes |
|---|---|
| Formato real | 1 MP3 disfarçado de `.ogg` (`musica_stop`) |
| Taxa de amostragem | mistura de 44,1 kHz e **48 kHz** (`intro_jornada`, `musica_show_do_bilhao`) |
| Volume (LUFS integrado) | de **-7,8 a -16,9** (9 dB entre faixas) |
| Peso | 38,9 MB, tudo em ~160 kbps |

> A pasta chama-se `assets/sounds/musica` (singular). Nenhum caminho de `Paths.gd` mudou: **nenhum script do jogo foi alterado para o áudio**.

## 3. Padrão aplicado às 12 trilhas

| Item | Valor |
|---|---|
| Formato | Ogg Vorbis real (libvorbis), 2 canais |
| Taxa | **44,1 kHz** (a do mixer do Godot: sem reamostragem em tempo real) |
| Qualidade | `-q 1.5` (~88 kbps, VBR) |
| Volume | **-14 LUFS** integrado (só ganho + limitador de pico em -1,5 dBFS; não comprime a dinâmica) |
| Metadados | removidos; marca interna `contalmaster-audio-v1` (evita reprocessar) |
| `.import` | `loop=true` em todas (o `AudioManager` já forçava o loop por código) e `valid=true` |

| Faixa | Antes | Depois | LUFS antes → depois |
|---|---|---|---|
| desvio_logico | 2,55 MB | 1,38 MB | -9,0 → -14,0 |
| forca_tecnica | 3,06 MB | 1,65 MB | -11,1 → -14,1 |
| intro_jornada | 4,18 MB (48 kHz) | 2,41 MB | -10,1 → -14,0 |
| loop_start | 4,81 MB | 2,69 MB | -16,9 → -14,3 |
| music_menu | 3,73 MB | 2,13 MB | -15,7 → -14,4 |
| musica_batalha_naval | 1,48 MB | 0,80 MB | -11,9 → -14,0 |
| musica_final | 5,49 MB | 2,76 MB | -10,5 → -14,0 |
| musica_maleta_certa | 2,82 MB | 1,50 MB | -9,0 → -14,0 |
| musica_perseguicao | 2,96 MB | 1,55 MB | -13,0 → -14,1 |
| musica_rodada_bonus | 4,62 MB | 2,26 MB | -7,8 → -14,0 |
| musica_show_do_bilhao | 1,83 MB (48 kHz) | 1,00 MB | -9,8 → -14,1 |
| musica_stop | 1,40 MB (**MP3**) | 1,05 MB | -13,3 → -14,1 |
| **Total** | **38,9 MB** | **21,2 MB (-45%)** | todas dentro de ±0,4 do alvo |

**Efeitos sonoros (`assets/sounds/efeitos`): intocados.** Por que -14 LUFS: a música já tem volume padrão 0,5 e os efeitos 1,0, então as trilhas ficam abaixo dos efeitos; o alvo derruba as faixas mais altas (-7,8 e -9) e sobe levemente as mais baixas.

## 4. Verificação (e limites)

Verificado: as 12 trilhas decodificam por inteiro; a estrutura Ogg de cada uma foi conferida página a página (CRC, numeração, granule crescente, início/fim de stream); a duração bate com a original; o script roda em `--check` sem pendências; os arquivos de efeitos são idênticos aos de antes.

**Não verificado:** não havia Godot nem fones neste ambiente. **Ouça as trilhas** (principalmente `desvio_logico`, `musica_rodada_bonus`, `musica_perseguicao`) e confirme que a importação termina sem erros. Se alguma soar chiada, reprocesse só ela com `--quality 2` a partir do original. O ffmpeg pode imprimir `non monotonically increasing dts` ao ler esses `.ogg`: é um aviso de estimativa de tempo do próprio ffmpeg (ocorre até num re-encode simples); o arquivo está íntegro.

## 5. Ferramenta: `tools/audio/preparar_musicas.py`

Requisitos: Python 3 + ffmpeg no PATH (Windows: `winget install Gyan.FFmpeg`). Na raiz do projeto:

```powershell
python tools/audio/preparar_musicas.py --check   # só confere formato real e volume; não altera nada
python tools/audio/preparar_musicas.py           # converte/nivela o que ainda não foi processado
python tools/audio/preparar_musicas.py --force --quality 2 --target-lufs -15   # reprocessa (use o ORIGINAL)
```

A pasta `tools/` tem `.gdignore`: o Godot não a enxerga e ela não entra no export.

**Regra para quem entrega trilha:** exportar como *Ogg Vorbis* (Audacity: Arquivo → Exportar → Ogg Vorbis), nunca MP3 renomeado; rodar `--check` antes de commitar.

## 6. Checklist de teste

1. Abrir no Godot 4.5 e esperar a reimportação: **sem** `Ogg Vorbis decoding failed`; `musica_stop.ogg` sem ícone de erro.
2. Minigame **Stop**: a música agora toca.
3. Menu → intro → cada minigame → cena final: volumes parecidos entre as trilhas.
4. Efeitos (clique, certo/errado, explosão, roleta, conquista) iguais aos de antes.
5. Fim de uma faixa curta (`musica_batalha_naval`, 80 s): a emenda do loop soa bem.
6. Cena final completa: conversa Jales/Natalia → corredor → **chegada** (porta/luzes) → sala → placar → créditos/logo, sem erros no painel.
7. Selo de versão: **ContalMaster V0.13.3**.
8. Export Web: o `.pck` deve diminuir ~17,7 MB só com as trilhas.

## 7. Commit (o repositório já tem histórico; fluxo da equipe: Feature Branch)

O working tree reúne mudanças ainda **não commitadas** (0.13.1, 0.13.2/0.13.2.1 e 0.13.3). Sugestão em **três commits**, em uma branch:

```bash
git checkout -b feat/v0.13.3-unificacao

# 1) áudio + ferramenta
git add assets/sounds tools
git commit -m "fix(audio): converte musica_stop (MP3 disfarcado) e padroniza as 12 trilhas em Ogg Vorbis 44,1 kHz, -14 LUFS (-45% de peso)"

# 2) importação / imagens
git add -- "*.import" assets/insignias assets/background/cutcines/13_entrada_sala_reuniao.png
git commit -m "chore(assets): size limit e compressao nos .import, insignias e imagem 13 da chegada a sala"

# 3) código, dados, docs e versão
git add -A
git commit -m "feat: V0.13.3 unifica sala de reuniao (0.13.1), chegada (0.13.2.1) e trilhas; padroniza ContalMaster; cronograma de versoes"

git tag v0.13.3
git push origin feat/v0.13.3-unificacao --tags
```

**Alternativa em um único commit:**

```bash
git add -A
git commit -m "feat: V0.13.3 unificacao (sala de reuniao + chegada + trilhas)" -m "musica_stop.ogg era MP3 com extensao .ogg. 12 trilhas em Ogg Vorbis 44,1 kHz, q1.5, -14 LUFS (38,9 -> 21,2 MB). Preserva ArrivalScene e novels. ContalMaster padronizado, shell.html versionado, CRONOGRAMA_VERSOES.md."
git tag v0.13.3
```

> `export_presets.cfg` está no `.gitignore`: a mudança de versão dele fica só na sua máquina. Confira `git status` antes do commit 3 para não incluir nada que não queira (`.godot/` já é ignorado).
