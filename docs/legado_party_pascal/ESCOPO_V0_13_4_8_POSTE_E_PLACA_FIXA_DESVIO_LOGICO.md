# Desvio Lógico V0.13.4.8 — Poste Oficial e Placa Fixa de Distância

## Objetivo
Consolidar o refinamento visual lateral do minigame Desvio Lógico sem alterar o núcleo de gameplay aprovado na V0.13.4.7.

Esta versão troca o poste lateral pelo sprite oficial curvado aprovado e transforma a placa de bifurcação em um elemento fixo de cenário, usado como referência visual de distância até a decisão.

## Mantido intacto
- Tempo oficial de 35 segundos por rota.
- HUD superior de avanço.
- Painel inferior esquerdo do desafio.
- Painel inferior direito do Velox-01.
- Ciclista no lado esquerdo com 2 aparições por rodada.
- Balanceamento dos carros NPCs da V0.13.4.7.
- Água com brilho e micro detalhes.
- Linhas discretas no gramado.
- Transição de aproximação e escolha A/B.

## Alterações aplicadas

### 1. Poste oficial novo
O arquivo `assets/sprites/desvio_logico/props/poste_lateral.png` foi substituído pelo poste curvado aprovado.

Tratamento aplicado ao sprite:
- remoção do fundo quadriculado;
- transparência real em PNG;
- corte inteligente da base inferior;
- proporção vertical adequada para encaixe visual no gramado;
- luminária voltada para dentro da pista, adequada ao lado direito do cenário.

### 2. Ajuste visual dos postes no script
Os postes continuam sendo props laterais no lado direito, mas agora usam escala maior para casar com o sprite novo.

Também foi ajustado o ponto de brilho da luminária para a cabeça do novo poste.

### 3. Placa de bifurcação fixa
A placa de bifurcação deixou de ser objeto lateral em movimento.

Ela agora é desenhada como elemento fixo, sempre presente no cenário, usando o marker:

```text
FixedSceneMarkers/BifurcationSignAnchor
```

Esse marker pode ser posicionado manualmente no Godot no ponto da divisa das pistas.

### 4. Animação de distância da placa
A placa não se desloca mais pela lateral. Em vez disso, ela muda visualmente conforme o avanço da rota:

- no início, fica menor e pouco visível;
- no meio, fica mais perceptível;
- perto da decisão, fica maior e totalmente visível.

Isso transforma a placa em um marcador visual de aproximação da bifurcação.

### 5. Compatibilidade com markers anteriores
Os markers antigos de placa lateral foram mantidos como referência/legado, mas o script passou a usar apenas o novo anchor fixo.

## Arquivos modificados

```text
scenes/minigames/DesvioLogico.gd
scenes/minigames/DesvioLogico.tscn
assets/sprites/desvio_logico/props/poste_lateral.png
assets/sprites/desvio_logico/props/poste_lateral.png.import
docs/ESCOPO_V0_13_4_8_POSTE_E_PLACA_FIXA_DESVIO_LOGICO.md
```

## Critérios de aceite
- O poste novo aparece sem fundo quadriculado.
- O poste fica maior e melhor encaixado no gramado direito.
- A base do poste não parece pesada nem solta.
- A luminária aponta para dentro da pista.
- A placa de bifurcação fica fixa no ponto definido pelo marker.
- A placa fica mais visível conforme a rota avança.
- NPCs, ciclista, HUD, água e transições continuam funcionando como antes.
