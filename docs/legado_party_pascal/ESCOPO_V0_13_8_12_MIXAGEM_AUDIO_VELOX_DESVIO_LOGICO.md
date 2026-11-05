# Desvio Lógico V0.13.8.12 — Mixagem final do áudio do Velox-01

## Objetivo

Refinar a mixagem do áudio do Velox-01 para que a música do minigame continue sendo o elemento principal, enquanto o som do carro funcione como camada de sensação de velocidade.

## Problema observado

Após a correção para `.ogg`, os sons do carro passaram a funcionar, mas a aceleração ficou abafando a música do Desvio Lógico. O objetivo desta versão é manter os dois sons coexistindo, com o motor abaixo da trilha.

## Alterações aplicadas

- A música do Desvio Lógico não é mais reduzida durante a direção.
- Removido, na prática, o ducking automático da música para o motor.
- `car_acceleration.ogg` foi reduzido para ficar audível, mas abaixo da música.
- `car_engine_loop.ogg` foi reduzido ainda mais por ser contínuo e poder cansar o jogador.
- O motor continua respeitando o volume global de efeitos do `SettingsManager`.
- Os sons continuam usando players locais do `DesvioLogico.gd`, pois esse caminho foi o que funcionou após a conversão para OGG.
- O `AudioManager.gd` permanece na estrutura estável, sem regras novas de ducking forte.

## Valores de mixagem definidos

```gdscript
car_acceleration.ogg → -12 dB
car_engine_loop.ogg  → -19 dB
```

A aceleração fica um pouco mais presente porque dura pouco. O loop do motor fica mais baixo porque toca durante toda a direção.

## Limpeza recomendada

Os arquivos `.wav` antigos podem ser removidos manualmente do projeto, já que a versão funcional usa `.ogg`:

```text
assets/sounds/efeitos/car_acceleration.wav
assets/sounds/efeitos/car_acceleration.wav.import
assets/sounds/efeitos/car_engine_loop.wav
assets/sounds/efeitos/car_engine_loop.wav.import
```

Manter:

```text
assets/sounds/efeitos/car_acceleration.ogg
assets/sounds/efeitos/car_acceleration.ogg.import
assets/sounds/efeitos/car_engine_loop.ogg
assets/sounds/efeitos/car_engine_loop.ogg.import
```

## O que não foi alterado

- gameplay
- colisão
- água
- postes
- score
- pause visual
- tutorial
- perguntas
- chegada natural à bifurcação

## Critério de aceite

A versão está correta quando:

- a música do Desvio Lógico volta a ser clara;
- a aceleração aparece sem cobrir a música;
- o loop do motor fica perceptível, mas discreto;
- o motor não cansa durante a rodada;
- os demais efeitos sonoros continuam funcionando.
