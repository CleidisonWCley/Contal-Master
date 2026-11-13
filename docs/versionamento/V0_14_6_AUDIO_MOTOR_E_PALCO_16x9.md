# V0.14.6 - Audio do motor (web) + palco 16:9 do Desvio Logico

Base: projeto enviado (0.14.4.2, Godot 4.5; build web exportado com 4.5.1, sem threads).
Validacao: scripts carregados e cena do Desvio Logico executada no Godot 4.5 (headless) em 5 tamanhos de janela.
NAO foi possivel testar em navegador real (Edge/Chrome) aqui: teste o build web antes de publicar.

## 1. Som do carro cortado / mudo em aparelhos fracos - causas concretas

O build web usa o modo "Sample" por padrao (audio/general/default_playback_type.web = 1, confirmado no
Godot 4.5). Nesse modo o JavaScript do engine (index.js do seu build) tem estes comportamentos:

1. **Reinicio a cada 250 ms (principal).** `DLEngineAudio._ensure_engine_audio_state()` rodava 4x por segundo
   e fazia `stream_paused = false` mesmo sem estar pausado. No modo Sample isso chama `_unpause()`, que chama
   `_restart()`: o som volta ao inicio e o no antigo e apenas desconectado, nao parado (fica tocando
   "orfao" em loop). Resultado: o motor so tocava os primeiros 250 ms em repeticao (som picotado) e, a cada
   segundo, 4 fontes de audio orfas + copias do buffer inteiro ficavam para o coletor de lixo. Em
   aparelho fraco isso estoura CPU/memoria e o audio some.
2. **Loop emulado.** O Godot web NAO usa `loop` nativo do WebAudio: cada volta do loop depende do evento
   `ended` e recria o buffer inteiro (`getAudioBuffer()` copia tudo). Qualquer travada da pagina vira
   buraco no loop. `loop_offset` tambem e ignorado nesse modo.
3. **Arquivos com silencio na emenda (conteudo).** Medido nos .ogg originais: `car_engine_loop.ogg` comeca com
   ~25 ms de silencio e termina com ~30 ms de fade para zero; `car_acceleration.ogg` tem rampa de ~80 ms
   no inicio e fade de ~40 ms no fim. Como a aceleracao dura 5-7 s e o clipe 2,3 s, havia 2-3 quedas
   a silencio so na aceleracao, e uma a cada 3,96 s no loop - ate no desktop.
4. **Troca aceleracao -> loop** era `stop()` + `play()` (buraco + clique).
5. **Musica no modo Sample** decodifica a faixa inteira: 30 a 118 MB em float32 estereo por faixa
   (desvio_logico.ogg ~ 56 MB; musica_final ~ 118 MB), com ~3 copias durante o registro e mais copias a cada
   reinicio. Em aparelhos com pouca RAM isso derruba a aba ou deixa o audio mudo.

## 2. O que foi alterado (audio)

- `DLEngineAudio.gd`: players do motor em modo **Stream** (loop nativo do engine, sem JavaScript por volta);
  removido `stream_paused=false` e as reescritas de volume/pitch a cada 250 ms (so age se o player parou ou
  se o volume de SFX mudou); `stream_paused` so e escrito quando o valor muda; crossfade de 0,18 s na
  passagem aceleracao -> loop; `loop_offset=0.12` (a introducao toca uma vez, o loop volta para o corpo);
  removidos os handlers `finished` que religavam o som.
- `assets/sounds/efeitos/car_engine_loop.ogg` e `car_acceleration.ogg`: regerados com a emenda final em
  crossfade com o ponto de retorno do loop (sem queda para silencio). Mesmos nomes; o Godot reimporta sozinho.
  Duracoes: 3,96 -> 3,83 s e 2,30 -> 2,19 s.
- `AudioManager.gd`: musica em modo **Stream** (sem decodificar a faixa inteira); escritas de
  `stream_paused` so quando mudam.
- `project.godot`: `audio/driver/output_latency.web=100` (buffer de audio maior para a musica em Stream
  tolerar travadas do Edge; efeitos curtos continuam em Sample, sem latencia extra). Versao 0.14.6.
  (`BrandText.gd`: versao exibida.)

## 3. Cenario e props em resolucoes diferentes - causa e correcao

Causa: o stretch do projeto e `canvas_items` + `expand`, entao a janela logica e **sempre >= 1280x720**
com largura ou altura extra. Os marcadores dos props (SidePropMarkers) e toda a geometria (faixas, profundidade,
spawn, carro) foram feitos em 1280x720, mas o fundo usava `KEEP_ASPECT_COVERED` (escala e corta conforme a
janela). Fora de 16:9 a arte da pista andava em relacao aos postes/faixas/carros; havia ainda um reajuste
parcial por altura (`_canvas_item_global_position`) que errava no eixo X e Y em janelas mais largas
(ex.: 1680x720 ou o Edge com barras). Corrigido:

- `DesvioLogico.gd`: novo **palco** (`Stage`, 1280x720) centralizado e escalado uniformemente na janela.
  Fundo, agua, pista, postes, trafego e carro moram nele; HUD, perguntas e menus continuam na tela cheia.
  Faixa decorativa (mesma arte escurecida) preenche as laterais/topo; some quando a janela e 16:9.
  Atualiza em `NOTIFICATION_RESIZED` e `size_changed` (rotacao, tela cheia, zoom). Toques sao convertidos
  para coordenadas do palco. Previews do editor (BackgroundPreview e postes de exemplo) agora ficam ocultos
  em jogo (eram desenhados por baixo do fundo: overdraw inutil em aparelho fraco).
- `DLSideProps.gd`, `DLTraffic.gd`, `DLWaterFX.gd`, `DLTutorial.gd`: usam o tamanho do palco em vez do da
  janela. A posicao dos marcadores e usada sem reescalonamento.

Resultado medido (headless): janelas 1280x720, 1680x720, 1280x960 e 2400x1080 -> palco em (0,0), (200,0),
(0,120) e (160,0), escala 1.0; geometria identica a 16:9.

## 4. Edge / resolucao interna (web)

- `web/shell.html`: limita `devicePixelRatio` (1,5; 1,25 em aparelhos com <=4 GB/<=4 nucleos). Antes, escala de
  tela 150-200% ou zoom do navegador gerava canvas de ate 4K+ para um jogo em 1280x720, o que aumenta
  fill-rate e o risco de "WebGL context lost". Para testar: `?dpr=1`, `?dpr=1.5` ou `?dpr=2` na URL.

## 5. Como testar

1. Reexporte a web e abra no Edge e no Chrome, com janela estreita, larga e com zoom 125/150%.
2. Desvio Lógico: aceleracao (5-7 s) e Drive por 1-2 min; o motor deve ser continuo, sem picotar.
3. Se a musica perder fidelidade em Stream, o ajuste e uma linha (`music_player.playback_type` no AudioManager).

## Observacoes (nao alteradas)
- As musicas terminam com fade natural; no loop da musica ha uma pausa curta no fim. Posso tratar depois.
- Comentarios do shell/WebLite citam "V0.14.5" enquanto o projeto estava em 0.14.4.2; aqui a versao passa a 0.14.6.
