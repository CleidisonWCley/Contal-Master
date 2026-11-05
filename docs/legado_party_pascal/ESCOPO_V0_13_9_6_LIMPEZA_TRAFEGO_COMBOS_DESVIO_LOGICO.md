# Party Pascal V0.13.9.6 — Limpeza técnica + correção de combos do Traffic Director

## Objetivo

Estabilizar o Desvio Lógico após a recriação do Traffic Director, corrigindo o bug em que carros de duplas/trios nasciam acima da estrada, além de limpar sobras técnicas de áudio/spawn antigo.

## Alterações aplicadas

- Duplas e trios deixaram de usar deslocamento vertical negativo para simular fila.
- O primeiro carro do combo nasce no horizonte válido da estrada.
- Os carros seguintes do combo entram por agendamento temporal, também no horizonte válido da pista.
- Isso impede NPCs de nascerem no céu, na cidade ou fora da estrada.
- O Traffic Director continua controlando single/double/triple, alternância de faixas, quebra de padrão e respiro após pressão/colisão.
- A lógica antiga de carros iniciais foi removida do script para evitar confusão de manutenção.
- Funções antigas de padrão/combo que não eram mais fonte oficial do tráfego foram removidas.
- A música do Desvio Lógico voltou ao Master limpo, sem usar filtros ou bus especial.
- Qualquer efeito residual no antigo bus DesvioMusic é removido quando existir.
- O som do Velox permanece sem filtros e com os volumes definidos pelo usuário no DesvioLogico.gd.
- Mantida a correção do warning da variável `sign`, usando nomes não conflitantes.

## Não alterado

- Movimento do Velox-01.
- Colisão visual atual.
- Chegada natural à bifurcação.
- Pontuação, score, pause, tutorial, postes, água e questões.
- Música escolhida e volumes testados pelo usuário.
