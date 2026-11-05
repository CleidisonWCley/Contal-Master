# Desvio Lógico V0.13.4.15 — Safe Area e Balanceamento por Dificuldade

## Objetivo

Refinar a versão V0.13.4.14 mantendo o restante do minigame intacto. Esta versão foca em três pontos:

1. subir os cards laterais para evitar contato visual com o rodapé;
2. remover o fade artificial dos postes, fazendo-os sair naturalmente como os NPCs/ciclista;
3. rebalancear velocidade, spawn e sensação visual por dificuldade.

## Alterações aplicadas

### 1. Cards laterais

- `StatusPanel` foi elevado mais alguns pixels.
- `DamageHUD` também foi elevado.
- O layout compacto da V0.13.4.13/V0.13.4.14 foi mantido.

### 2. Postes laterais

- Removido o fade artificial do poste.
- O poste agora segue o mesmo tratamento visual dos demais elementos móveis: aproxima, cresce com a perspectiva e recicla apenas após sair da área visual.
- A saída do poste ficou mais natural, sem desaparecimento antecipado.
- A velocidade de reciclagem dos postes agora varia por dificuldade.

### 3. Balanceamento dos NPCs por dificuldade

#### Fácil
- Mantém velocidade próxima da atual.
- Menos spawns.
- Maior tempo de reação.
- `max_npcs` permanece 1.

#### Normal
- NPCs mais rápidos.
- Intervalo de spawn menor.
- Ritmo mais desafiador, mas ainda com brechas de desvio.
- `max_npcs` permanece 2.

#### Difícil
- NPCs bem mais rápidos.
- Spawn mais frequente.
- Sensação de gameplay tensa.
- Mantém limites para não empilhar carros na mesma faixa nem fechar a rota do jogador de forma injusta.

### 4. Distância mínima de segurança

- A regra de distância mínima foi separada entre:
  - mesma faixa;
  - faixa oposta.
- No difícil, a distância é menor para aumentar o ritmo, mas ainda existe uma brecha segura.
- O script continua bloqueando spawn quando outro NPC já está na zona de perigo do jogador.

### 5. Cenário acompanhando a dificuldade

- `world_speed` foi ajustado por dificuldade.
- Postes e ciclista passam a usar fator de movimento por dificuldade.
- Listras laterais e estrada acompanham a sensação de velocidade pela própria função `_world_speed()`.

## O que não foi alterado

- HUD superior.
- Perguntas.
- Placa fixa de bifurcação.
- Água.
- Gramado.
- Ciclista: continua com 2 aparições.
- Transição de decisão.
- Lógica geral de conclusão do minigame.
- Assets.

## Critérios de aceite

A versão estará correta quando:

- os cards laterais não ficarem colados no rodapé;
- o poste não sumir em fade, saindo naturalmente como objeto ultrapassado;
- o modo fácil continuar acessível;
- o modo normal ficar mais dinâmico;
- o modo difícil ficar rápido e tenso, mas ainda justo;
- não houver carros empilhados na mesma faixa;
- sempre existir brecha mínima de desvio.
