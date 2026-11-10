# CM-V0.13.4 — Som da porta, corredor com 1 quadro e correção dos erros de console

> Faixa **0.13** · cutscene final, áudio e estabilidade. Base: projeto **0.13.3**. Veja o índice em [`CRONOGRAMA_VERSOES.md`](CRONOGRAMA_VERSOES.md).

## 1. O que mudou

| # | Mudança | Onde |
|---|---|---|
| 1 | **Som da porta** volta na abertura da porta da cena de chegada (cutscene da Natalia) | `ArrivalScene.gd`, `AudioManager.gd`, `Paths.gd`, `assets/sounds/efeitos/porta_abrindo.ogg` |
| 2 | **Corredor com 1 quadro** (eram 2): a Natalia resume a narrativa numa fala só | `scripts/data/dialogues/final.json` (`corridor`) |
| 3 | Erro `Invalid polygon data, triangulation failed` na cena final | `CutsceneFinal.gd` (`_on_finale_veil_draw`) |
| 4 | Erro `_set_size` na Perseguição | `Perseguicao.gd` (`_build_scene`, sirenes) |
| 5 | Erro `The object does not have any 'meta' values with the key 'tween'` ao passar o mouse/foco nos cartões do menu de modo | `ModeSelect.gd` (`_animate_card`) |
| 6 | Versão `0.13.3` → `0.13.4` | `project.godot`, `BrandText.DEFAULT_VERSION` |
| 7 | Registro das correções do `preparar_musicas.py` (já no código desde antes, sem doc) | seção 5 |

## 2. Som da porta

A V0.13.2.1 removeu o rangido gerado por código e **não havia nenhum `.ogg` de porta** no projeto. O som novo foi **sintetizado** (sem samples de terceiros, sem questão de direitos) por `tools/audio/gerar_som_porta.py`:

| Trecho | O que soa |
|---|---|
| 0,00 s | trava destravando (dois estalos) |
| 0,05–1,95 s | madeira deslizando + rangido, com a intensidade seguindo a **velocidade** da porta (curva cúbica in/out de `DOOR_OPEN_SECONDS = 1,9 s`) |
| ~1,92 s | batida suave das folhas no batente |

Formato: Ogg Vorbis 44,1 kHz estéreo, 2,5 s, 36 KB, **-19 LUFS**, pico -2,8 dBFS (os efeitos atuais ficam entre -10 e -18 LUFS; a porta fica abaixo para não cobrir a música final).

O som toca em `ArrivalScene.play()` no instante em que a porta começa a abrir (`AudioManager.play_sfx("porta")`). Com **animações desligadas** a porta já nasce aberta e o som **não** toca (coerente com a cena sem animação).

**Para ajustar:** `python tools/audio/gerar_som_porta.py --lufs -17` (mais alto), `--seed 7` (outra variação do rangido), `--door-open 2.2` (se mudar `DOOR_OPEN_SECONDS`). Pode também trocar o arquivo por um `.ogg` próprio com o mesmo nome. O `.import` é gerado pelo Godot na primeira abertura.

> `gerar_som_porta.py` exige `numpy` e `scipy` além do ffmpeg. `preparar_musicas.py` **não** toca nos efeitos, então não mexe nesse arquivo.

## 3. Corredor com 1 quadro

`corridor` tinha 2 quadros; agora tem 1, com o resumo da narrativa (ontem aprendendo a norma → hoje decisões éticas → errar virou lição → rigor, cuidado e coragem → sala logo à frente):

> Enquanto caminhamos, respire fundo e olhe para trás: ontem você começou aprendendo a norma e hoje termina tomando decisões éticas. Cada erro virou lição, e o que você leva daqui é rigor, cuidado e coragem. A sala de reunião é logo ali!

Nada no código dependia da quantidade de quadros: `_play_block(_frames_of("corridor"), …)` lê o que estiver no JSON, e a saída andando da Natalia para a porta (`exit_slide`) continua a mesma. Para voltar a 2 quadros, restaure o bloco do `final.json` da 0.13.3.

## 4. Erros de console

### 4.1 `Invalid polygon data, triangulation failed` (`CutsceneFinal.gd:1097`)

O véu escuro da cortina dourada é um paralelogramo cuja borda esquerda anda com a cortina. No **fim da varredura** (`front >= largura + skew/2`) a borda esquerda ultrapassa a direita, o polígono fica invertido e o Godot recusa triangular — **uma mensagem por quadro** até o véu desligar. Só acontecia em tela **larga** (16:9, 2560×1080…); em retrato o polígono nunca inverte. Correção: quando a cortina já passou da tela inteira, não há mais véu e a função retorna sem desenhar. Conferido numericamente: ~2,5% dos quadros da varredura eram inválidos em 1920×1080, 1280×720 e 1366×768 (4,2% em 2560×1080); agora 0.

### 4.2 `_set_size` (`Perseguicao.gd:177`, e o equivalente da faixa de cima)

As sirenes (`TopSiren` e `BottomSiren`) tinham âncoras `*_WIDE` (esquerda≠direita) e recebiam `.size = …` antes de entrar na árvore. O Godot avisa que o tamanho será sobrescrito. A altura (34 px) passa a vir dos **offsets** (`offset_top/offset_bottom`), sem atribuir `.size`.

> **Atenção visual:** a faixa de **baixo** provavelmente ficava fora da tela (altura vinda só do mínimo, crescendo para baixo da âncora). Agora fica colada na borda inferior, como a de cima. Se preferir só a faixa de cima, ajuste com cuidado: o pulso (`Perseguicao.gd`, ~linha 720) só roda se as duas existirem.

### 4.3 `The object does not have any 'meta' values with the key 'tween'` (`ModeSelect.gd:273`)

`button.get_meta("tween", null)`: no Godot 4.5, passar `null` como padrão é o mesmo que **não passar padrão**, então, na primeira animação de cada cartão (que ainda não tem a meta `tween`), o Godot registra o erro. Era inofensivo (o fluxo seguia), mas poluía o console. Correção: checar `has_meta("tween")` antes de ler. Varredura do projeto: não há outro `get_meta(..., null)`.

## 5. Correções do `preparar_musicas.py` (registro)

Já estavam no código (cabeçalho citava "V0.13.4") sem doc: ffmpeg/ffprobe fora do PATH com mensagem clara; marca "já processado" lida também do metadado do **stream** (antes toda rodada reencodava tudo); arquivo travado com novas tentativas e erro legível; sobras `*.tmp.ogg` ignoradas/limpas; código de saída 1 se algum arquivo falhar.

## 6. Verificação e limites

Verificado: JSON válido (1 quadro em `corridor`); `porta_abrindo.ogg` decodifica por inteiro (Vorbis, 44,1 kHz, 2 canais, 2,5 s); geometria do véu testada em 6 resoluções; trilhas continuam byte a byte iguais às da 0.13.3.

**Não verificado:** não havia Godot nem fones neste ambiente. Os scripts foram editados e **não rodados**; o som da porta foi conferido por espectrograma, **não ouvido**.

## 7. Checklist de teste

1. Abrir no Godot 4.5: `porta_abrindo.ogg` importa sem erro.
1b. Menu de modo de jogo: passar o mouse/focar nos cartões anima normalmente e **sem** erro de `meta 'tween'`.
2. Jogar a **Perseguição**: sem `_set_size` no painel; faixas de cima **e** de baixo coladas nas bordas.
3. Cena final até o fim em janela larga: sem `Invalid polygon data` quando a cortina dourada termina; o véu escuro ainda "revela" a imagem normalmente.
4. Corredor: **uma** fala da Natalia, texto cabe na caixa, ela sai andando e a tela escurece.
5. Chegada: a porta abre **junto** com o som (estalo → deslizar → batida) e o volume fica confortável sobre a música. Se estiver alto/baixo: `--lufs`.
6. Animações desligadas nas configurações: porta já aberta, sem som, fluxo não trava.
7. Selo de versão: **ContalMaster V0.13.4**.

## 8. Commit (Feature Branch)

```bash
git checkout -b feat/v0.13.4-porta-corredor-console
git add assets/sounds/efeitos/porta_abrindo.ogg tools
git commit -m "feat(audio): som da porta (sintetizado) para a cena de chegada + gerador em tools/audio"
git add -A
git commit -m "fix: V0.13.4 corredor com 1 quadro, veu da cortina dourada e sirenes da Perseguicao sem erro de console"
git tag v0.13.4
git push origin feat/v0.13.4-porta-corredor-console --tags
```

`export_presets.cfg` (arquivo local, no `.gitignore`) **não veio no zip**: altere o `version/name` do preset Android para `0.13.4` na sua máquina, conforme o cronograma.
