# Desvio Lógico V0.13.4.11 — Painéis translúcidos e fade de ultrapassagem do poste

## Objetivo

Esta atualização é um refinamento visual aplicado sobre a versão atual do Desvio Lógico, mantendo a gameplay, NPCs, ciclista, placa fixa, água, gramado, HUD superior e transições intactos.

## Ajustes aplicados

### 1. Painéis inferiores mais translúcidos

O painel inferior esquerdo (`StatusPanel`) e o painel inferior direito (`DamageHUD`) estavam visualmente pesados, criando a sensação de um grande bloco preto na tela.

Ajustes:
- `StatusPanel` teve o fundo reduzido de alpha alto para alpha mais leve.
- `DamageHUD` teve o fundo reduzido para ficar mais transparente.
- As bordas neon foram mantidas para preservar a identidade visual e a leitura.
- A barra interna do painel do Velox-01 também teve fundo suavizado.

### 2. Dimmer geral mais discreto

O escurecimento geral da cena foi reduzido para deixar os cenários mais vivos e menos apagados.

### 3. Painel de feedback com mais folga

O painel de `ROTA CORRETA` / `ROTA INCORRETA` foi ajustado para reduzir a sensação de corte visual.

Ajustes:
- painel levemente menor;
- margens internas mais compactas;
- corpo do texto ajustado;
- botão `Continuar` um pouco mais compacto;
- overlay levemente menos escuro.

### 4. Fade do poste após ultrapassagem

O poste lateral agora começa a desaparecer quando já existe a sensação de que o jogador passou por ele, em vez de permanecer inteiro até a região dos painéis inferiores.

Ajustes:
- fade baseado na posição vertical do poste na tela;
- reciclagem antes de invadir os painéis inferiores;
- escala máxima levemente reduzida;
- saída mais natural, evitando o efeito de dobra ou corte brusco.

## Mantido sem alteração

- velocidade e spawn dos carros NPCs;
- ciclista lateral;
- placa fixa de bifurcação;
- água e brilhos;
- listras de movimento da pista e gramado;
- tempo de 35 segundos;
- HUD superior de progresso;
- lógica de decisão e perguntas;
- transições entre cenários.
