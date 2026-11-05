# Desvio Lógico V0.13.4.13 — Redesenho dos HUDs e ajuste final do poste

## Objetivo

Aplicar uma correção visual estrutural no Desvio Lógico, partindo da V0.13.4.11, para eliminar a sensação de blocos pretos grandes no cenário e ajustar a saída do poste lateral.

## Alterações aplicadas

- Redesenho do `StatusPanel` inferior esquerdo como card compacto com tamanho por offset fixo.
- Redesenho do `DamageHUD` inferior direito como card compacto focado no conteúdo do Velox-01.
- Redução forte do fundo preenchido dos cards, mantendo borda neon e sombras de texto.
- Redução do `Dimmer` geral da tela para preservar melhor o brilho do cenário.
- Recalibração do painel de feedback `ROTA CORRETA / ROTA INCORRETA` com tamanho menor e margem mais estável.
- Ajuste fino do fade do poste para começar quando o poste já está sendo ultrapassado.
- Reciclagem do poste antes de invadir os painéis inferiores.
- Redução leve da escala máxima do poste.
- Correção de avisos do Godot: parâmetro `delta` não usado, parâmetro `side` não usado e variável local `size` sombreando propriedade da classe base.

## O que permanece intacto

- NPCs e balanceamento de tráfego.
- Ciclista lateral.
- Placa fixa da bifurcação.
- Água, listras laterais e gramado.
- Tempo de 35 segundos.
- Lógica de perguntas e decisão.
- Transição de rota.

## Critérios de aceite

- Os painéis inferiores não devem parecer retângulos pretos grandes.
- As bordas dos HUDs devem acompanhar apenas o conteúdo principal.
- O cenário deve aparecer melhor atrás dos cards.
- O poste deve iniciar fade ao ser ultrapassado e não deve atravessar visualmente os painéis inferiores.
- A cena não deve exibir os avisos de script apontados na versão anterior.
