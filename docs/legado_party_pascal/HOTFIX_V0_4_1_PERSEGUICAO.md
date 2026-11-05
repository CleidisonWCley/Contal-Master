# Hotfix V0.4.1 — Perseguição

Correção aplicada no arquivo:

```text
scenes/minigames/Perseguicao.gd
```

## Problema corrigido

O Godot 4 estava tratando warnings como erro em duas inferências de tipo:

- linha do temporizador usando `max(...)` sem tipo explícito;
- linha do efeito de sirene usando `alpha` inferido a partir de cálculo matemático.

## Ajuste realizado

- `remaining` agora é `float` explícito e usa `maxf(...)`.
- `ratio` agora é `float` explícito e usa `clampf(...)`.
- `t`, `alpha` e `color` agora possuem tipos explícitos.

Isso evita falhas quando o projeto está configurado para tratar warnings como erro.
