# Party Pascal — Desvio Lógico V0.13.4.4

## Objetivo

Polimento fino do minigame Desvio Lógico após a consolidação da V0.13.4.3, focando em segurança de spawn dos NPCs, proporção visual dos elementos laterais, ambiência do mar/cidade/céu e ajuste do ritmo geral da fase.

## Atualizações aplicadas

### Tempo oficial
- O tempo oficial do percurso foi reduzido de 45s para **35s**.
- A redução mantém a fase mais direta, mas ainda preserva uma janela de leitura antes da decisão.

### NPCs e tráfego
- NPCs agora nascem mais próximos do horizonte e menores, funcionando primeiro como leitura visual.
- A velocidade real dos NPCs foi reduzida e separada da sensação visual de velocidade.
- A dificuldade passa a afetar mais a sensação do mundo e o ritmo de spawn, não o surgimento injusto.
- O tráfego inicial foi alterado para **2 NPCs no horizonte**, com **3 segundos de intervalo** entre eles.
- Os NPCs iniciais continuam como prévia visual segura, sem colisão ativa imediata.
- Regras de spawn foram reforçadas para evitar fechar as duas faixas em zona de leitura/perigo.
- Hitboxes foram reduzidas para diminuir colisões fantasmas.

### Carro do jogador
- O carro do jogador foi reposicionado um pouco mais acima na tela.
- A posição busca melhorar o campo de leitura e reduzir a sensação de carro colado na borda inferior.

### Coqueiros e arbustos laterais
- As trilhas dos coqueiros foram recalibradas para respeitar melhor a área verde lateral.
- O posicionamento agora usa proporção entre horizonte e base da tela, tentando manter os objetos entre pista e água.
- Os coqueiros ficaram menores e com oscilação reduzida para não parecerem fora de escala.

### Água e mar
- A área de desenho da animação do mar recebeu margem maior para evitar invasão no gramado.
- Brilhos e glints da água foram reforçados.
- A cor dos brilhos varia conforme o horário do cenário.

### Cidade e céu
- Foram adicionadas luzes discretas nos prédios, com maior intensidade em entardecer, anoitecer e noite.
- Nos cenários noturnos, estrelas passam a piscar de forma sutil.

### Estrada
- Foi adicionada uma animação sutil de linha central/estrada andando para reforçar a sensação de movimento.
- O efeito é leve para não competir com o background nem prejudicar a leitura dos carros.

## Arquivos modificados

- `scenes/minigames/DesvioLogico.gd`
- `docs/ESCOPO_V0_13_4_4_POLIMENTO_DESVIO_LOGICO.md`

## Critérios de validação sugeridos

- Testar se o percurso dura 35 segundos antes da decisão.
- Verificar se os 2 NPCs iniciais aparecem separados por cerca de 3 segundos.
- Confirmar que os NPCs não causam colisão imediata no início.
- Verificar se o jogador tem tempo para reagir em Fácil, Normal e Difícil.
- Conferir se coqueiros/arbustos ficam sobre o gramado, sem invadir água/pista.
- Conferir se a animação da água não invade o gramado.
- Testar anoitecer/noite para verificar luzes da cidade e estrelas piscando.
- Confirmar se o carro do jogador ficou um pouco mais acima e com boa leitura.
