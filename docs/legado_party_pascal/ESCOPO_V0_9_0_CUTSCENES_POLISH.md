# V0.9.0 — Polimento das Cutscenes e Transições Narrativas

## Objetivo

Polir a experiência narrativa do Party Pascal Godot após a conclusão dos minigames principais, mantendo os minigames intactos e focando apenas nas telas de história e transição da campanha.

## Ajustes aplicados

### Cutscene inicial

- Pascal foi reposicionado para ficar mais alto na tela.
- O botão visual `AVANÇAR` foi removido.
- O avanço de fala agora acontece por clique na tela, Espaço ou Enter.
- Os botões `Menu` e `Pular` foram redesenhados em formato menor e horizontal.
- O som de clique foi removido do avanço normal da fala e da finalização automática da cutscene.
- O som de clique ficou apenas para ações explícitas de botão: `Menu` e `Pular`.
- A dica inferior foi atualizada para orientar o clique na tela.

### Transições entre fases

- A transição entre fases foi recriada com efeitos temáticos por minigame.
- A transição não toca mais som de clique ao começar automaticamente ou por clique na tela.
- O clique, Espaço ou Enter ainda podem iniciar a fase depois do pequeno tempo mínimo de leitura.
- Cada fase ganhou identidade visual própria:
  - Show do Bilhão: símbolos `$` e brilho dourado.
  - Batalha Naval: ondas, bolhas e elementos aquáticos.
  - Maleta Certa: símbolos de maleta/decisão e brilho de recompensa.
  - Roleta de Risco: alerta, neon e movimento circular.
  - Perseguição: sirene, perigo e linhas de velocidade.
  - STOP: letras flutuantes e marca visual de categoria/resposta rápida.

### Cutscene final

- Pascal foi reposicionado para ficar mais alto, alinhado com o ajuste da cutscene inicial.
- A dica agora reforça o avanço por clique na tela.
- O painel de diálogo foi levemente ajustado para melhorar composição.
- O fluxo de pontuação, créditos e tela final foi preservado.

## Arquivos alterados

```text
scenes/cutscenes/CutsceneIntro.gd
scenes/cutscenes/StageTransition.gd
scenes/cutscenes/CutsceneFinal.gd
docs/ESCOPO_V0_9_0_CUTSCENES_POLISH.md
```

## Fora do escopo

- Nenhum minigame foi alterado.
- O modo livre não foi alterado nesta versão, pois a Roleta de Risco já estava fora dele no arquivo atual.
- Não foram adicionados novos assets obrigatórios.

## Teste recomendado

```text
Menu Principal
→ Campanha
→ Cutscene Inicial
→ Transição Show do Bilhão
→ Show do Bilhão
→ Transição Batalha Naval
→ Batalha Naval
→ Transição Maleta Certa
→ Maleta Certa
→ Transição Roleta de Risco
→ Roleta de Risco
→ Transição Perseguição
→ Perseguição
→ Transição STOP
→ STOP
→ Cutscene Final
```

Também testar:

```text
Clique na tela para avançar fala
Espaço para avançar fala
Enter para avançar fala
Botão Menu na intro
Botão Pular na intro
Transição automática sem som de clique
```
