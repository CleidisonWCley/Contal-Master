# Party Pascal V1.0.2 — Balanceamento de pontuação, tempo de resposta e Roleta de Risco

## Objetivo

A V1.0.2 consolida ajustes de balanceamento identificados nos testes da campanha estável V1.0.1, com foco em textos finais, pontuação por dificuldade, pontuação proporcional ao tempo de resposta e maior tensão na Roleta de Risco.

## Correções e decisões

- Textos finais da campanha deixam de citar Jornada SI e passam a usar Party Pascal.
- Batalha Naval passa a usar 14 ameaças no Fácil, 10 no Normal e 6 no Difícil.
- Batalha Naval fica fora da pontuação por tempo, pois sua lógica é de tabuleiro, risco, estratégia e adivinhação.
- Show do Bilhão, Maleta Certa, STOP e Perseguição recebem pontuação proporcional ao tempo de resposta.
- Forca Tecnica, Desvio Lógico, Batalha Naval e Roleta de Risco ficam fora da regra de tempo.
- Roleta de Risco passa a sortear mais desafios, deixando as fatias da roleta mais estreitas e tensas.

## Faixas gerais de tempo

Aplicadas em Show do Bilhão, Maleta Certa e STOP:

- Rápido: até 30 segundos — 100% dos pontos.
- Médio: de 31 até 60 segundos — 75% dos pontos.
- Lento: acima de 60 segundos — 55% dos pontos.

## Perseguição

A Perseguição usa a própria barra de tempo:

- Verde ou quase amarelo: rápido — 100% dos pontos.
- Amarelo: médio — 75% dos pontos.
- Vermelho: lento — 55% dos pontos.

## Segurança de perda

Nos minigames recalibrados, erros aplicam perda controlada e não reduzem a pontuação abaixo de zero em uma única penalidade.

## Minigames recalibrados

- Show do Bilhão.
- Batalha Naval.
- Maleta Certa.
- Perseguição.
- STOP.

## Roleta de Risco

- A roleta usa 12 eventos por rodada quando houver banco disponível.
- Eventos positivos e negativos são reorganizados de forma alternada para criar mais tensão visual.
- Opções negativas usam perda controlada.
- Setores exibem impacto direto de pontos, evitando texto largo dentro de fatias estreitas.
