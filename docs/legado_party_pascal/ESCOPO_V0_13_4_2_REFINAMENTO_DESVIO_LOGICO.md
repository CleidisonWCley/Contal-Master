# Party Pascal — Desvio Lógico V0.13.4.2

## Objetivo

Refinamento fino da jogabilidade e dos efeitos visuais do minigame **Desvio Lógico**, com foco em corrigir colisões injustas, melhorar a leitura dos NPCs, alinhar elementos laterais ao cenário e dar mais acabamento ao HUD.

## Ajustes aplicados

### Jogabilidade e NPCs

- Mantido o sistema em **2 faixas**: esquerda e direita.
- Carro do jogador continua iniciando na **faixa direita**.
- NPCs ficaram mais lentos e com aproximação mais suave.
- Reduzido o limite de NPCs ativos simultaneamente para evitar tela congestionada.
- Tráfego inicial agora nasce apenas no horizonte, pequeno e distante.
- Tráfego inicial recebeu zona de segurança para evitar colisão imediata.
- Hitboxes do jogador e dos NPCs foram reduzidas para evitar colisões injustas durante troca de faixa.
- Faixas foram afastadas da linha central para dar mais espaço visual.

### Movimento do jogador

- Troca de faixa ficou mais suave e menos brusca.
- Animação de escolha A/B ficou mais controlada.
- Carro se aproxima mais da bifurcação antes da pergunta.
- Animação de saída para Rota A/B agora inclina levemente o carro sem jogar para a água.

### Cenário e efeitos

- Animação da água foi limitada às áreas laterais de mar.
- Traços de movimento não atravessam mais a pista.
- Coqueiros laterais foram realinhados para nascerem e se moverem sobre o gramado.
- Quantidade e velocidade dos coqueiros foram reduzidas para evitar poluição visual.
- Sensação de subida/descida do background foi preservada de forma sutil.

### HUD

- Card inferior esquerdo foi reposicionado um pouco mais para cima, criando respiro visual em relação à borda inferior.
- HUD principal foi preservado: progresso no topo, pergunta na decisão, status à esquerda e painel do veículo à direita.

## Arquivo principal alterado

- `scenes/minigames/DesvioLogico.gd`

## Critérios de aceite

- O início da rodada não deve causar colisão imediata.
- NPCs devem surgir mais visíveis e mais justos no horizonte.
- A troca de faixa deve parecer mais suave.
- O carro não deve sair da pista ao escolher Rota A ou Rota B.
- Água e brilhos não devem atravessar a estrada.
- Coqueiros devem passar pelas áreas verdes laterais.
- O card inferior esquerdo deve ficar com margem inferior confortável.
