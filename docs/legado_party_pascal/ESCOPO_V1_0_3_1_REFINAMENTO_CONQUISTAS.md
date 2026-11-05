# Party Pascal V1.0.3.1 — Refinamento visual da área de Conquistas

## Objetivo
Refinar a tela de Conquistas para priorizar progresso, mistério e leitura visual, usando as novas insígnias do Party Pascal.

## Ajustes aplicados

### Área superior
- Removido o conceito visual de `Rank atual`.
- Adicionada insígnia de progresso baseada no total de conquistas desbloqueadas.
- Mantido texto de progresso `X/15` com barra visual.
- Quando todas as conquistas forem desbloqueadas, exibir:

```text
🏆 Parabéns, todas conquistas foram desbloqueadas!
15/15 conquistas desbloqueadas
```

### Insígnias
Assets usados:

```text
assets/insignias/bronze_pascal.png
assets/insignias/prata_pascal.png
assets/insignias/ouro_pascal.png
assets/insignias/platina_pascal.png
```

Progressão:

```text
0/15  → Sem insígnia
1–4   → Bronze
5–8   → Prata
9–14  → Ouro
15/15 → Platina
```

### Conquistas bloqueadas
- Título e requisito reais ficam ocultos.
- Card mostra apenas:

```text
Bloqueado
Continue jogando para revelar esta conquista.
```

### Conquistas desbloqueadas
- Mantêm nome real.
- Mantêm descrição/requisito concluído.
- Recebem destaque dourado e ícone visual.

### Responsividade
- Desktop: grade com 3 cards por linha.
- Telas médias: 2 cards por linha.
- Telas pequenas: 1 card por linha.
- Estrutura inspirada na tela de Pontuação para evitar que os cards quebrem o layout.

## Fora do escopo
- Novas conquistas.
- Alterações nos requisitos das conquistas.
- Mudanças nos minigames.
- Novos sons.
- Ranking online.
