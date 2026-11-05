# Desvio Lógico V0.13.8.10 — Áudio local direto do Velox-01

## Objetivo
Corrigir o caso em que os sons do Velox-01 não ficam audíveis dentro do minigame Desvio Lógico, mesmo após a integração com o AudioManager na V0.13.8.9.

## Diagnóstico
A V0.13.8.9 registrou os sons no AudioManager e tentou controlar aceleração e motor por efeitos em loop globais. Na prática, o som continuou sem aparecer no gameplay. A causa mais provável é a dependência do loop do AudioManager ou das regras globais de SFX/música.

## Correção aplicada
O Desvio Lógico volta a criar players locais próprios e obrigatórios:

- `VeloxAccelerationPlayer`
- `VeloxEngineLoopPlayer`

Esses players ficam dentro do próprio `DesvioLogico.gd`, usam o bus `Master` e não dependem mais do AudioManager para tocar o motor.

## Comportamento novo

- A aceleração toca localmente durante o estado de aceleração.
- O loop do motor toca localmente durante `STATE_DRIVE` e `STATE_APPROACH`.
- O AudioManager é usado apenas para reduzir temporariamente a música, quando o método existir.
- Loops antigos criados pela V0.13.8.9 são encerrados por segurança.
- Pause pausa os players locais.
- Continuar retoma os players locais.
- Finalizar, sair, falhar ou entrar na decisão para os sons do Velox-01.

## Audibilidade
Foram ajustados os volumes para o motor do Velox-01 ficar acima da música do mundo:

- aceleração com volume reforçado;
- loop do motor com volume reforçado;
- ducking da música mais forte durante a direção;
- piso mínimo de audibilidade se o SFX não estiver zerado.

## Arquivos alterados

- `scenes/minigames/DesvioLogico.gd`
- `docs/ESCOPO_V0_13_8_10_AUDIO_LOCAL_VELOX_DESVIO_LOGICO.md`

## O que não foi alterado

- gameplay;
- colisão;
- água;
- postes;
- score;
- pause visual;
- tutorial;
- chegada natural à bifurcação;
- perguntas.
