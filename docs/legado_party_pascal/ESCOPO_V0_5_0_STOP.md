# Party Pascal Godot V0.5.0 — STOP

## Objetivo

Portar o minigame **STOP - Governança de TI** do projeto Pygame para Godot, mantendo a lógica principal do jogo original e integrando ao fluxo de campanha e modo livre.

## Implementado

- `Stop.gd` deixou de ser placeholder.
- Banco de perguntas do Pygame migrado para Godot.
- Perguntas separadas por dificuldade: `facil`, `normal` e `dificil`.
- 6 rodadas por partida.
- Letra sorteada antes de cada rodada.
- Categoria, dica e 5 alternativas por rodada.
- Alternativas embaralhadas.
- Pontuação baseada no mesmo sistema usado nos demais minigames:
  - Fácil: acerto `+12`, erro `-5`.
  - Normal: acerto `+10`, erro `-12`.
  - Difícil: acerto `+8`, erro `-25`.
- Feedback de acerto/erro com resposta correta e tempo de resposta.
- Destaque visual da resposta correta e da resposta errada escolhida.
- Música do STOP.
- Efeitos de roleta, explosão, acerto e erro.
- Partículas de letras no fundo.
- Shake visual ao errar.
- Atalhos de teclado:
  - `1`, `2`, `3`, `4`, `5`.
  - `A`, `B`, `C`, `D`, `E`.
  - `Esc` para voltar.
- Integração com `GameManager` no modo campanha e modo livre.

## Hotfix incorporado

Também foi incorporada a correção da Perseguição:

```gdscript
sin()
```

no lugar de:

```gdscript
sinf()
```

para evitar erro no Godot 4.

## Testes recomendados

1. Abrir o projeto no Godot.
2. Rodar o jogo com `F5`.
3. Testar:
   - `Menu -> Modo Livre -> STOP`.
   - `Menu -> Campanha -> avançar até STOP`.
   - Configurações -> trocar dificuldade -> testar pontuação.
4. Confirmar que a Perseguição ainda abre sem erro.

## Próxima versão sugerida

V0.6.0 — Batalha Naval.
