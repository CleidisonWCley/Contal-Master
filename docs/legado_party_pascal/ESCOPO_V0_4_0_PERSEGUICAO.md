# Party Pascal Godot V0.4.0 — Perseguição

## Objetivo

Portar o minigame **Perseguição** do projeto Pygame para o Godot, deixando a fase jogável e integrada ao fluxo já existente de campanha e modo livre.

## Base de referência

A lógica foi baseada no arquivo original do Pygame:

```text
src/minigames/perseguicao.py
```

## Entregas da versão

- `Perseguicao.gd` deixou de ser placeholder.
- Banco de incidentes migrado para Godot.
- Incidentes separados por dificuldade:
  - `facil`
  - `normal`
  - `dificil`
- Cada rodada apresenta 1 incidente e 2 decisões possíveis.
- Ordem dos incidentes embaralhada a cada execução.
- Ordem das opções embaralhada a cada incidente.
- Temporizador por incidente respeitando a dificuldade.
- Penalidade automática quando o tempo acaba.
- Feedback de acerto, erro e tempo esgotado.
- Destaque da ação correta após cada decisão.
- Pontuação integrada ao `ScoreManager`.
- Música `musica_perseguicao` integrada ao `AudioManager`.
- Efeitos sonoros de acerto, erro e conclusão.
- Atalhos de teclado:
  - `1`, `A` ou seta esquerda para a primeira ação.
  - `2`, `B` ou seta direita para a segunda ação.
  - `Esc` para voltar.
- Visual com sirene vermelha/azul, linhas de estrada e shake em erro.
- Integração com campanha e modo livre.

## Regras de pontuação

As regras usam o `DifficultyManager` já consolidado:

| Dificuldade | Tempo por incidente | Acerto | Erro / tempo esgotado |
|---|---:|---:|---:|
| Fácil | 4.0s | +12 | -5 |
| Normal | 2.5s | +10 | -12 |
| Difícil | 1.0s | +8 | -25 |

## Critérios de aceite

A versão é considerada pronta quando:

1. A Perseguição abre pelo modo livre.
2. A Perseguição abre corretamente na campanha após a Roleta de Risco placeholder.
3. Os 6 incidentes aparecem em sequência.
4. Cada incidente tem 2 opções.
5. A escolha correta soma pontos.
6. A escolha errada remove pontos.
7. Tempo esgotado remove pontos.
8. Ao finalizar os 6 incidentes, aparece o relatório da fase.
9. O botão Continuar retorna ao menu livre ou avança a campanha.
10. O jogo não quebra quando a pontuação fica negativa.

## Fora do escopo

Ainda não foram portados nesta versão:

- Batalha Naval completa.
- Roleta de Risco completa.
- STOP completo.
- Exportação Android/Play Store.
- Ranking ou conquistas.

## Próxima versão recomendada

```text
V0.5.0 — STOP
```

Motivo: o STOP é o próximo minigame que ainda pode reaproveitar a arquitetura de perguntas, tempo, escolha, feedback e pontuação antes de partirmos para os minigames mais visuais.
