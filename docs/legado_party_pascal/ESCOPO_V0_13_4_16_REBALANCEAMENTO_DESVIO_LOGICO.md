# Desvio Lógico V0.13.4.16 — Rebalanceamento de Dificuldade e Água Limpa

## Objetivo
Rebalancear o ritmo do minigame para deixar a gameplay mais dinâmica e remover temporariamente a animação da água para preparar um refinamento visual posterior.

## Dificuldade

### Fácil
- Recebe o ritmo que antes era equivalente ao modo Normal.
- Mantém gameplay acessível, mas menos parada.
- Permite aproximadamente 8 colisões em carros antes da integridade zerar.

### Normal
- Recebe a base do antigo Difícil, levemente ampliada.
- Aumenta velocidade e frequência dos carros NPCs.
- Exige mais desvios e menos tempo parado.
- Permite aproximadamente 6 colisões em carros.

### Difícil
- Nova dificuldade realmente tensa.
- Carros NPCs mais rápidos e spawns mais frequentes.
- Exige reação rápida e vários desvios durante os 35 segundos.
- Permite aproximadamente 4 colisões em carros.

## Justiça dos NPCs
- Mantida distância mínima de segurança entre carros.
- Evita dois NPCs ativos na mesma faixa visível.
- Mantém brechas de desvio mesmo no modo difícil.
- Limite de NPCs simultâneos preservado para evitar bloqueio injusto.

## Movimento visual
- Postes, ciclista, listras laterais e sensação de estrada acompanham melhor a dificuldade.
- Fácil: movimento mais controlado.
- Normal: movimento mais dinâmico.
- Difícil: movimento mais acelerado e tenso.

## Água
- Removidas temporariamente as listras e brilhos animados do mar.
- Mantidas luzes/céu/cidade.
- O mar fica limpo até a atualização futura de refinamento visual final.

## Mantido intacto
- HUD superior.
- Cards laterais.
- Placa fixa da bifurcação.
- Transição de decisão.
- Perguntas e lógica A/B.
- Correção do LaneClickLayer.
