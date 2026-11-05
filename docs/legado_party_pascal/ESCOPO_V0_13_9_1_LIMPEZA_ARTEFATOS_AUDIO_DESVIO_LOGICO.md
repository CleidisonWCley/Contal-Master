# Party Pascal V0.13.9.1 — Limpeza dos artefatos sonoros do Desvio Lógico

## Objetivo

Manter o refinamento sonoro aplicado na V0.13.9, mas remover os artefatos agudos percebidos como rabiscos/chiados no fundo da música do minigame Desvio Lógico.

## Problema observado

A V0.13.9 melhorou a presença sonora do minigame, porém alguns efeitos aplicados no bus exclusivo da música geraram ruídos finos/agudos que não pertenciam à faixa original.

## Correções aplicadas

- Mantido o bus exclusivo `DesvioMusic`.
- Mantido o perfil sonoro especial da música do Desvio Lógico.
- Removido o efeito `AudioEffectStereoEnhance`, provável origem dos rabiscos agudos.
- Reduzido o reverb para um valor mínimo.
- Ajustada a configuração do low-pass para continuar suavizando a música sem gerar ressonância perceptível.
- Mantidos os volumes da V0.13.9 para música e motor do Velox-01.

## Configuração final

- Música do Desvio Lógico: permanece no bus `DesvioMusic`.
- Low-pass: leve e com baixa ressonância.
- Reverb: mínimo, apenas para profundidade discreta.
- StereoEnhance: removido.

## O que foi preservado

- Música nova do Desvio Lógico.
- Motor do Velox-01 perceptível.
- Som de aceleração.
- Mixagem base da V0.13.9.
- Gameplay.
- Água.
- Postes.
- Score.
- Tutorial.
- Perguntas.
- Chegada natural à bifurcação.

## Critério de aceite

A atualização estará correta quando a música continuar mágica/futurista, mas sem os rabiscos/chiados agudos no fundo.
