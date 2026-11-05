# Party Pascal — V0.13.3.1

## Desvio Lógico: Cenário Vivo e HUD Integrado

### Objetivo

Refinar visualmente o minigame final **Desvio Lógico** após a V0.13.3, corrigindo pontos percebidos em teste:

- as linhas de movimento no centro da pista pareciam artificiais;
- as placas genéricas (`404`, `WARN`, `ERR`) pareciam objetos soltos/HUD;
- a água e as laterais ainda transmitiam pouca sensação de movimento;
- a integridade do veículo estava duplicada no topo e no painel do carro;
- o desenho do HUD de dano precisava conversar melhor com o sprite real do Velox-01;
- havia avisos do Godot ligados a enums de `TextureRect` e nomes genéricos como `size`/`position`.

---

## Alterações aplicadas

### 1. HUD de integridade integrado ao veículo

A informação de integridade saiu do HUD superior e agora fica no painel do veículo:

```text
Integridade do Veículo: XX%
```

O painel inferior direito agora usa o sprite lateral direito do carro:

```text
assets/sprites/desvio_logico/carro_desvio_lateral_direita.png
```

Sobre esse sprite são desenhados danos vermelhos conforme a integridade diminui.

### 2. Carros NPC como obstáculo principal

As placas genéricas deixaram de ser o obstáculo principal.

Agora os obstáculos da pista são os carros NPC já criados na V0.13.3:

```text
assets/sprites/desvio_logico/carro_npc_01.png
assets/sprites/desvio_logico/carro_npc_02.png
```

Os termos técnicos continuam existindo, mas aparecem integrados no vidro/placa dos carros NPC.

### 3. Centro da pista mais limpo

As linhas fortes de movimento no centro da pista foram removidas/reduzidas.

A sensação de velocidade agora vem principalmente de:

- laterais da estrada;
- guardrails;
- regiões de água;
- áreas próximas às árvores;
- carros NPC vindo em perspectiva.

### 4. Água mais perceptível

A camada `WaterShimmer` foi reforçada com:

- mais linhas horizontais de brilho;
- reflexos deslizantes;
- pequenas streaks douradas/ciano;
- movimento lateral sutil.

### 5. Laterais mais vivas

A `LaneOverlay` agora desenha marcadores e streaks nas bordas, em vez de concentrar tudo no centro da pista.

Isso ajuda a vender a sensação de que o cenário está passando sem forçar o carro a alcançar toda a largura do background.

### 6. Micro movimento do background

O background continua sendo a arte-base estática, mas recebeu um micro zoom/pulso durante a fase de direção.

A intenção é dar uma leve sensação de avanço sem distorcer a arte.

### 7. Limpeza de avisos

Foram removidas atribuições numéricas diretas em enums de `TextureRect`, substituindo por constantes oficiais do Godot.

Exemplo:

```gdscript
texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
```

Também foram ajustados nomes de variáveis/parâmetros que sombreavam propriedades do `Control`, como `size` e `position`.

---

## Arquivos modificados

```text
party-pascal-godot/scenes/minigames/DesvioLogico.gd
party-pascal-godot/docs/ESCOPO_V0_13_3_1_CENARIO_VIVO_HUD_INTEGRADO.md
```

---

## Critérios de aceite

A atualização estará correta se:

- a integridade aparecer no painel do veículo, não no topo;
- o HUD usar o sprite lateral direito do Velox-01;
- as placas genéricas não aparecerem mais como obstáculos principais;
- os carros NPC forem os obstáculos visuais predominantes;
- a água tiver movimento mais perceptível;
- as laterais passarem mais sensação de velocidade;
- o centro da pista ficar visualmente mais limpo;
- o minigame continuar encerrando por conclusão dos 6 desafios ou integridade 0;
- os avisos de enum do `TextureRect` forem reduzidos/eliminados.
