# Desvio Lógico V0.13.8.11 — restauração do áudio e motor local em OGG

## Objetivo
Corrigir a regressão da V0.13.8.10 em que o áudio do Velox-01 continuou inaudível e a música do Desvio Lógico também deixou de aparecer claramente.

## Diagnóstico aplicado
A V0.13.8.9 alterou o AudioManager para suportar ducking e loops globais. A V0.13.8.10 passou o motor do Velox-01 para players locais, mas ainda deixou o minigame interagindo com o ducking global e usando WAV para loops longos. Isso podia deixar a música muito baixa e ainda não garantir a reprodução do motor.

## Alterações
- AudioManager restaurado para a estrutura estável anterior, preservando música e SFX básicos do projeto.
- Sons do Velox-01 convertidos para OGG:
  - `assets/sounds/efeitos/car_acceleration.ogg`
  - `assets/sounds/efeitos/car_engine_loop.ogg`
- DesvioLogico.gd passa a usar os OGGs locais do Velox-01.
- Ducking da música removido na prática para evitar sumiço da trilha do Desvio Lógico.
- Volume local do Velox-01 elevado para confirmar audibilidade.
- Gameplay, colisão, água, postes, score, pause visual, tutorial, perguntas e chegada natural permanecem preservados.

## Teste recomendado
1. Abrir o Desvio Lógico com a música ativada.
2. Confirmar se a música `desvio_logico.ogg` voltou a tocar.
3. Após o tutorial, confirmar se a arrancada do Velox-01 toca durante a aceleração.
4. Confirmar se o loop do motor entra após a aceleração.
5. Se o motor ficar alto demais, reduzir os offsets de volume no `DesvioLogico.gd` depois de confirmar que o áudio voltou.
