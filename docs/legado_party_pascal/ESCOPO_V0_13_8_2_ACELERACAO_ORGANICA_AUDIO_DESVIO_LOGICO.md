# Desvio Lógico V0.13.8.2 — aceleração orgânica e áudio audível do Velox-01

## Objetivo
Corrigir a sensação de aceleração curta/brusca, reforçar o áudio do Velox-01 e tornar o avanço do carro até a bifurcação mais natural durante os 35 segundos de gameplay real.

## Ajustes aplicados

- A aceleração passa a ter duração por dificuldade:
  - Fácil: 5.0s
  - Normal: 6.0s
  - Difícil: 7.0s
- O timer de 35s continua parado durante toda a aceleração.
- A curva de aceleração foi suavizada para evitar o salto de velocidade no começo.
- O cenário, postes e efeitos prateados da pista passam a acompanhar o fator real de aceleração.
- O Velox-01 agora avança organicamente durante o tempo de rota:
  - começa mais abaixo;
  - sobe aos poucos durante os 35s;
  - chega mais perto da bifurcação antes da decisão;
  - reduz o salto visual no momento da placa.
- O áudio do Velox-01 foi reforçado:
  - `car_acceleration.wav` toca em loop durante a aceleração;
  - `car_engine_loop.wav` entra depois da aceleração;
  - players usam bus Master para evitar dependência de bus inexistente;
  - volume mínimo audível foi reforçado quando SFX não está zerado;
  - os players se auto-reiniciam caso o loop não seja mantido pelo import;
  - os imports foram ajustados com loop e normalização.

## Arquivos alterados/adicionados

- `scenes/minigames/DesvioLogico.gd`
- `assets/sounds/efeitos/car_acceleration.wav`
- `assets/sounds/efeitos/car_acceleration.wav.import`
- `assets/sounds/efeitos/car_engine_loop.wav`
- `assets/sounds/efeitos/car_engine_loop.wav.import`
- `docs/ESCOPO_V0_13_8_2_ACELERACAO_ORGANICA_AUDIO_DESVIO_LOGICO.md`

## Observações
A correção foca em sensação de direção e áudio. O bug dos carros nas fases Entardecer em diante e a animação da água continuam fora desta versão.
