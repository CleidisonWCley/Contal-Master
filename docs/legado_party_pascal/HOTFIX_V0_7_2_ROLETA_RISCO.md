# V0.7.2 — Hotfix visual da Roleta de Risco

## Arquivo alterado

- `scenes/minigames/RoletaRisco.gd`

## Correções

- Corrigido desenho da roleta invisível.
- A roleta agora é desenhada diretamente no `WheelCanvas` usando o sinal `draw` do próprio nó.
- Reduzido tamanho/posição da roleta para caber melhor na tela 1280x720.
- Reposicionados os nomes dos setores para acompanhar a roleta visível.
- Resultado recebeu prioridade visual maior (`z_index = 200`) para cobrir os nomes/fundo.
- Botões `GIRAR!` e `Voltar` foram reduzidos e puxados para cima.
- Removido o espaçador expansivo que empurrava os botões para a borda inferior.

## Observação

Este patch contém apenas o arquivo local da Roleta de Risco. Aplique por cima da base atual substituindo o arquivo indicado.
