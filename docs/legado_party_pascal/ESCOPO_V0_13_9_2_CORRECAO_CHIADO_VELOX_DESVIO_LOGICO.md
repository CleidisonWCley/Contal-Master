# Party Pascal V0.13.9.2 — Correção do chiado do Velox-01

## Objetivo

Corrigir o chiado/rabisco percebido durante o som de aceleração e o loop do motor do Velox-01, sem desfazer a melhoria sonora geral da V0.13.9.

## Diagnóstico

Após teste da V0.13.9.1, foi identificado que o artefato sonoro não vinha da música principal do Desvio Lógico. O chiado começava quando a aceleração do carro era iniciada e continuava durante o loop do motor.

Causas prováveis tratadas nesta versão:

- ruído agudo já presente nos arquivos do motor;
- volume/pitch do motor puxando frequências altas;
- ausência de tratamento dedicado para os SFX contínuos do Velox-01;
- música tratada indevidamente como origem do problema.

## Ajustes aplicados

### 1. Música principal restaurada

A música do Desvio Lógico recupera presença próxima da V0.13.9:

- offset de música ajustado para `-2 dB`;
- perfil mágico/futurista reativado no bus `DesvioMusic`;
- low-pass, reverb e stereo enhance leves aplicados apenas na música;
- o chiado deixa de ser tratado como problema da trilha principal.

### 2. Bus exclusivo para o Velox-01

Foi criado, em tempo de execução, o bus:

```text
VeloxSFX
```

Esse bus é usado apenas por:

```text
car_acceleration.ogg
car_engine_loop.ogg
```

### 3. Filtro nos SFX do carro

O bus `VeloxSFX` recebe um low-pass leve para cortar parte das frequências agudas que geravam a sensação de rabisco/chiado.

Configuração inicial:

```text
cutoff_hz: 6800
resonance: 0.025
```

Sem reverb, sem stereo enhance e sem efeitos mágicos no motor.

### 4. Pitch do motor mais controlado

O pitch do motor foi suavizado para não elevar demais o ruído agudo:

```text
Engine loop:
Fácil   = 0.95
Normal  = 1.00
Difícil = 1.07

Aceleração:
Fácil   = 0.96
Normal  = 0.99
Difícil = 1.03
```

### 5. Presença do motor preservada

A mixagem mantém o motor perceptível:

```text
Aceleração = -12.5 dB
Motor loop = -14.0 dB
```

## O que não foi alterado

- gameplay;
- colisão;
- postes;
- pista;
- tutorial;
- score;
- pause visual;
- chegada natural à bifurcação;
- perguntas;
- água do cenário.

## Critérios de aceite

A versão estará correta quando:

- a música voltar a soar presente/mágica como na V0.13.9;
- o chiado/rabisco da aceleração reduzir claramente;
- o chiado/rabisco do motor em loop reduzir claramente;
- o motor continuar perceptível durante a corrida;
- a música não for abafada pelo motor;
- nenhum efeito sonoro do Velox vazar ao sair do minigame.
