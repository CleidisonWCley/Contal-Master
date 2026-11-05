# Party Pascal Godot V0.7.0 — Roleta de Risco

## Objetivo

Portar o último minigame principal do Party Pascal Pygame para Godot: **Roleta de Risco / Rodada Bônus**.

Esta versão fecha a primeira grande etapa da migração dos minigames para Godot.

## Arquivo alterado

```text
scenes/minigames/RoletaRisco.gd
```

A cena `RoletaRisco.tscn` foi mantida com o mesmo caminho e script. O script reconstrói a interface em tempo de execução, seguindo o padrão usado nos minigames anteriores.

## Mecânica portada do Pygame

- Roleta com 8 eventos.
- Giro com desaceleração progressiva.
- Fase curta de tensão antes do resultado.
- Resultado único por rodada bônus.
- Eventos positivos e negativos.
- Pontuação aplicada imediatamente ao cair no evento.
- Integração com modo campanha e modo livre.

## Eventos da roleta

| Evento | Tipo |
|---|---|
| Falha em Servidor | Penalidade baixa |
| Treinamento | Bônus baixo |
| Ransomware | Penalidade alta |
| Auditoria capacitada | Bônus alto |
| Erro Humano | Penalidade baixa |
| Automação de processos | Bônus baixo |
| Comunicação péssima | Penalidade baixa |
| Nova Política | Bônus baixo |

## Pontuação por dificuldade

### Fácil

- Penalidade baixa: `-15`
- Penalidade alta: `-25`
- Bônus baixo: `+25`
- Bônus alto: `+40`

### Normal

- Penalidade baixa: `-30`
- Penalidade alta: `-50`
- Bônus baixo: `+30`
- Bônus alto: `+50`

### Difícil

- Penalidade baixa: `-50`
- Penalidade alta: `-80`
- Bônus baixo: `+60`
- Bônus alto: `+100`

## Melhorias aplicadas no Godot

- Roleta desenhada diretamente com `_draw()`.
- Setor colorido alternando azul e rosa.
- Efeito neon pulsante.
- Partículas orbitando a roleta.
- Partículas diferentes para resultado positivo e negativo.
- Resultado em overlay com título, descrição e impacto.
- Atalhos de teclado:
  - `Espaço` ou `Enter`: girar/continuar;
  - `Esc`: voltar.
- Sem dependência de imagem de seta externa.

## Critérios de teste

Testar:

```text
Menu → Modo Livre → Roleta de Risco
```

Depois testar na campanha:

```text
Show do Bilhão → Batalha Naval → Maleta Certa → Roleta de Risco → Perseguição
```

Também testar as três dificuldades em Configurações:

```text
Fácil / Normal / Difícil
```

## Observação

Esta entrega é um patch local. Não substitui o projeto inteiro.
