# Party Pascal — Desvio Lógico V0.13.4.9
## Correção de poste, HUD superior e painel de feedback

### Objetivo
Atualização menor de refinamento visual aplicada sobre a V0.13.4.8, sem alterar o comportamento principal do minigame.

### Ajustes aplicados

#### 1. Poste lateral direito
- Corrigida a ancoragem do poste novo.
- O marker passa a ser tratado como ponto de contato da base inferior com o gramado.
- Removida a oscilação vertical dos postes para evitar aparência de flutuação.
- Recalibrada a escala do poste alto e curvado.
- Ajustado o ponto de brilho da luminária para acompanhar o sprite aprovado.

#### 2. HUD superior de progresso
- O painel `ROTA ATÉ A DECISÃO` foi suavizado.
- O fundo escuro ficou mais transparente.
- A borda foi mantida, mas menos pesada.
- A leitura da barra e do texto permanece preservada.

#### 3. Feedback de rota correta/incorreta
- O painel central de feedback foi deslocado levemente para cima.
- O ajuste evita peso visual excessivo na parte inferior da tela.
- O layout interno do painel foi preservado.

### Itens preservados
- NPCs e balanceamento de tráfego.
- Ciclista lateral esquerdo.
- Placa fixa de bifurcação.
- Água, gramado e efeitos de cenário.
- HUD inferior esquerdo e painel do Velox-01.
- Tempo oficial de 35 segundos.
- Perguntas, decisão A/B e transições.

### Arquivos modificados
- `scenes/minigames/DesvioLogico.gd`
- `docs/ESCOPO_V0_13_4_9_CORRECAO_POSTE_HUD_DESVIO_LOGICO.md`

### Critérios de aceite
- O poste deve parecer plantado no gramado, não flutuando.
- O brilho deve sair da luminária.
- O painel superior deve ficar mais leve e menos intrusivo.
- O painel de feedback deve aparecer um pouco mais alto.
- Nenhum sistema de gameplay deve ser alterado.
