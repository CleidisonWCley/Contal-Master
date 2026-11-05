# Party Pascal — V0.13.4.3
## Desvio Lógico — Consolidação de Tráfego, Distância Segura e Transição de Rotas

Esta atualização consolida o núcleo jogável do minigame **Desvio Lógico** após a introdução dos novos cenários finais.

## Ajustes implementados

### 1. NPCs com distância segura
- NPCs deixam de virar ameaça imediatamente ao surgir.
- O surgimento agora prioriza leitura visual no horizonte.
- A colisão só passa a ser considerada em uma zona mais baixa da tela.
- O tráfego inicial passou a ser apenas prévia visual segura, sem colisão ativa.

### 2. Dificuldade mais justa
- A dificuldade agora separa sensação visual de velocidade e velocidade real dos NPCs.
- Fácil: menos NPCs e maior janela de reação.
- Normal: até 2 NPCs, com velocidade moderada.
- Difícil: sensação visual mais rápida e NPCs mais frequentes, mas ainda legíveis.

### 3. Controle e colisão
- Troca de faixa suavizada.
- Entrada de nova troca bloqueada enquanto a animação anterior ainda está em andamento.
- Faixas foram afastadas da linha central para dar mais respiro visual.
- Hitbox reduzida continua preservada para evitar colisões fantasmas.

### 4. Coqueiros refeitos do zero
- A lógica de trilha dos coqueiros foi refeita.
- Eles agora seguem a diagonal do gramado lateral.
- A intenção é evitar coqueiros sobre a água ou sobre a pista.
- O número de coqueiros foi reduzido para diminuir poluição visual.

### 5. Água mais perceptível
- Brilhos da água tiveram alpha e quantidade reforçados.
- A área de desenho foi recalibrada a partir da posição real do gramado.
- O efeito continua limitado às laterais de mar.

### 6. Continuidade após escolha A/B
- Após escolher a rota, o carro segue em direção ao horizonte.
- O carro reduz escala e desaparece gradualmente.
- A tela escurece antes do feedback/próximo desafio, reforçando continuidade visual.

### 7. Limpeza de peso morto
- Removidos restos de obstáculo textual antigo (`BUG`, `404`, `ERR`, etc.).
- Removida função antiga de obstáculo técnico que não era mais usada.

## Arquivos alterados

- `scenes/minigames/DesvioLogico.gd`
- `docs/ESCOPO_V0_13_4_3_CONSOLIDACAO_DESVIO_LOGICO.md`

## Critérios de aceite

- NPCs não devem causar colisão inevitável logo no início.
- O jogador deve conseguir ler o NPC no horizonte antes da zona de perigo.
- A velocidade visual pode variar por dificuldade, mas a aproximação real dos NPCs deve continuar justa.
- Coqueiros devem parecer presos ao gramado lateral.
- Água deve ficar mais perceptível sem atravessar a pista.
- Após escolher A/B, o carro deve seguir para o horizonte antes da transição.
