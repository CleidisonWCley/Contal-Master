# Party Pascal V0.13.9.5 — Áudio limpo + Traffic Director do Desvio Lógico

## Objetivo

Esta versão estabiliza o Desvio Lógico após a fase de refinamento sonoro e recria a lógica de spawn dos carros NPCs para reduzir conflitos acumulados nas versões anteriores.

## 1. Limpeza dos filtros de áudio

A música e os sons do Velox-01 passam a trabalhar por volume puro, sem filtros aplicados por código.

Foram neutralizados/removidos do perfil do Desvio Lógico:

- low-pass criado em runtime na música;
- reverb criado em runtime na música;
- stereo enhance criado em runtime na música;
- efeitos no bus `DesvioMusic`;
- filtros no bus `VeloxSFX`.

Os volumes definidos no `DesvioLogico.gd` foram preservados conforme a versão enviada pelo usuário:

```gdscript
const DESVIO_MUSIC_VOLUME_DB := -1.0
const ENGINE_ACCELERATION_VOLUME_DB := -4.0
const ENGINE_LOOP_VOLUME_DB := -7.0
```

A música continua usando o perfil do minigame, mas o bus fica limpo e com bypass de efeitos. O áudio do carro também continua em bus próprio, porém sem filtros.

## 2. Recriação da lógica de tráfego

A lógica antiga de spawn recebeu muitas correções ao longo das versões e estava acumulando conflito, especialmente com:

- carros presos em uma única faixa;
- combos surgindo perto demais do Velox-01;
- duplas/trios criando sensação de spawn injusto;
- dificuldade de prever qual regra antiga estava causando o problema.

A V0.13.9.5 substitui a decisão principal de spawn por um `Traffic Director` consolidado.

## 3. Traffic Director

O `Traffic Director` controla os pacotes de tráfego com base em:

- dificuldade atual;
- progresso da rota;
- histórico de faixa usada;
- quantidade de colisões recentes;
- tempo sem dano;
- confiança/desempenho do jogador;
- reta final sem novos spawns.

O fluxo agora é:

1. abertura segura com um único NPC;
2. padrões simples para o jogador ler o ritmo;
3. aumento gradual da confiança interna quando o jogador fica sem dano;
4. quebra de padrão com dupla/trio quando houver espaço e justiça;
5. pequeno respiro após pressão ou colisão;
6. bloqueio de novos spawns na reta final já existente.

## 4. Quebra de padrão controlada

A ideia de “trolar” o jogador foi implementada como quebra de padrão justa.

O jogo pode entregar um padrão por alguns spawns e, quando o jogador estiver indo bem, inserir uma variação mais forte:

- Fácil: quebra leve, geralmente dupla e trio raro;
- Normal: quebra com trio quando o jogador estiver confortável;
- Difícil: quebra mais cedo e com menos respiro, mantendo justiça.

O sistema nunca deve roubar do jogador. A quebra só ocorre se houver distância, faixa e progresso adequados.

## 5. Correção dos combos aparecendo do nada

A lógica antiga criava duplas/trios colocando os próximos carros mais abaixo na tela, o que podia fazer o segundo ou terceiro NPC nascer perto demais do Velox-01.

Agora os combos entram como fila vindo do fundo:

```text
carro 1 no horizonte
carro 2 um pouco atrás/acima
carro 3 um pouco atrás/acima
```

Isso preserva a leitura de sequência sem gerar colisões instantâneas.

## 6. Alternância de faixa

O Traffic Director tenta sempre a faixa planejada e, se ela estiver insegura, tenta a faixa oposta. A sequência registra a faixa usada para impedir que o tráfego fique preso indefinidamente em apenas um lado.

## 7. Correção de warning

Foi corrigido o warning:

```text
SHADOWED_GLOBAL_IDENTIFIER: The variable "sign" has the same name as a built-in function.
```

A variável foi renomeada para `direction_sign`.

## 8. Preservado

Não foram alterados:

- volumes definidos pelo usuário;
- música escolhida;
- gameplay principal;
- colisão visual do Velox;
- chegada natural à bifurcação;
- tutorial;
- score;
- pause;
- postes;
- água;
- perguntas;
- pontuação.

## Arquivos alterados

```text
scenes/minigames/DesvioLogico.gd
scripts/AudioManager.gd
docs/ESCOPO_V0_13_9_5_AUDIO_LIMPO_TRAFEGO_RECRIADO_DESVIO_LOGICO.md
```
