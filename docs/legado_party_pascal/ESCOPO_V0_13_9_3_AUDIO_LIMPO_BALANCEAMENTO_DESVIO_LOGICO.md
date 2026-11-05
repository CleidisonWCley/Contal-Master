# Party Pascal V0.13.9.3 — Áudio limpo do Velox + balanceamento inicial de gameplay

## Objetivo

Refinar o áudio do carro após a V0.13.9.2 e corrigir dois pontos de gameplay observados no Desvio Lógico:

- o som do Velox-01 ficou abafado demais por causa do filtro aplicado no bus do carro;
- o início do Normal/Difícil ainda podia abrir com colisões injustas;
- o modo Fácil estava lento demais em comparação com o Normal.

## Ajustes sonoros

### Música principal

A música do Desvio Lógico foi preservada como estava na V0.13.9.2, pois o resultado foi aprovado.

Não foram alterados:

- volume da música;
- perfil `DesvioMusic`;
- efeitos da música;
- arquivo de música.

### Som do Velox-01

O bus `VeloxSFX` foi mantido, mas o filtro low-pass aplicado na V0.13.9.2 foi removido/neutralizado.

O áudio do carro agora volta a ser limpo, sem tratamento que abafe o motor.

Volumes ajustados:

- aceleração do Velox-01: `-10 dB`;
- motor em loop: `-12.5 dB`.

Pitch ajustado:

- Fácil: `0.96` no loop;
- Normal: `1.00` no loop;
- Difícil: `1.05` no loop.

A aceleração também recebeu pitch mais natural para evitar distorção.

## Ajustes de gameplay

### Abertura segura após aceleração

A primeira ameaça real de cada desafio agora é sempre um carro único, evitando que Normal/Difícil comecem com duplas ou trios injustos logo após a aceleração.

Depois desse carro inicial seguro, o tráfego normal da dificuldade é liberado.

Também foi adicionado um intervalo pós-abertura para dar mais leitura antes dos padrões intensos voltarem.

### Modo Fácil mais ativo

O Fácil foi acelerado para ficar apenas um nível abaixo do Normal, sem parecer parado demais.

Ajustes principais:

- aumento do `world_speed`;
- aumento do `npc_speed`;
- redução leve do `spawn_base`;
- aumento do fator visual de movimento.

O Fácil continua mais tolerante por causa da maior quantidade de colisões permitidas e menor punição.

## O que não foi alterado

Esta atualização não altera:

- música principal;
- água;
- postes;
- colisão geral;
- score;
- pause;
- tutorial;
- perguntas;
- chegada natural à bifurcação;
- assets de áudio.

## Critérios de aceite

A versão está correta quando:

- a música continua com a presença aprovada na V0.13.9.2;
- o som de aceleração volta a ser audível;
- o motor em loop fica perceptível durante a corrida;
- o carro não fica abafado;
- Normal/Difícil não abrem com colisões injustas;
- Fácil fica mais rápido, mas ainda abaixo do Normal.
