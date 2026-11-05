# Party Pascal — Desvio Lógico V0.13.5
## Tráfego dinâmico, novas cores de NPC e dificuldade avançada

### Objetivo

A V0.13.5 marca uma evolução maior do minigame Desvio Lógico. A atualização aumenta a variedade visual dos carros NPCs, transforma o tráfego em padrões mais dinâmicos e rebalanceia os modos Normal e Difícil para entregar mais adrenalina sem remover as brechas seguras de desvio.

---

## 1. Novas cores de carros NPC

Foram adicionadas três novas variações de carro NPC:

- `carro_npc_verde.png`
- `carro_npc_laranja_queimado.png`
- `carro_npc_cinza_prata.png`

Com isso, o tráfego passa a usar cinco cores:

- vermelho;
- amarelo;
- verde;
- laranja queimado;
- cinza prata.

O cinza foi definido como cinza prata para manter contraste com a pista e combinar melhor com os seis cenários do minigame.

---

## 2. Regra de variedade visual

A seleção de sprites NPC agora evita repetir imediatamente o mesmo carro.

Exemplos evitados:

- vermelho → vermelho;
- amarelo → amarelo;
- verde → verde;
- laranja queimado → laranja queimado;
- cinza prata → cinza prata.

A intenção é deixar a rodovia mais viva e reduzir a sensação de repetição visual.

---

## 3. Dificuldade Fácil

O modo Fácil foi preservado como estava na V0.13.4.16.

Mantido:

- velocidade aprovada;
- quantidade de spawns aprovada;
- até cerca de 8 colisões;
- gameplay acessível.

---

## 4. Nova dificuldade Normal

O modo Normal passa a assumir a sensação do antigo Difícil, com uma ampliação controlada.

Ajustes:

- velocidade maior dos NPCs;
- spawns mais frequentes;
- até 3 NPCs ativos;
- possibilidade de duplas na mesma faixa;
- brechas obrigatórias para desvio;
- até cerca de 6 colisões.

Objetivo de sensação:

> O jogador precisa prestar atenção e trocar de faixa com frequência.

---

## 5. Nova dificuldade Difícil

O modo Difícil agora é tratado como tráfego intenso e tenso.

Ajustes:

- velocidade bem maior dos NPCs;
- spawn mais frequente;
- até 4 NPCs ativos;
- duplas na mesma faixa com frequência;
- trios na mesma faixa em momentos controlados;
- menos tempo para pensar;
- até cerca de 4 colisões.

Objetivo de sensação:

> O jogador sente adrenalina, mas ainda encontra brechas justas para ultrapassar.

---

## 6. Padrões de tráfego

Foi adicionada uma lógica de padrões de spawn:

### Carro único

Usado em todas as dificuldades.

### Dupla na mesma faixa

Usada no Normal e no Difícil. Dois carros aparecem em sequência, com espaçamento seguro, forçando o jogador a trocar de faixa.

### Trio na mesma faixa

Usado somente no Difícil, de forma controlada. Três carros podem aparecer em sequência na mesma faixa, mas a faixa oposta precisa estar livre para servir como rota de escape.

---

## 7. Regras de segurança

Mesmo com a dificuldade ampliada, o sistema mantém proteções:

- não gera carros colados sem espaço de reação;
- não fecha as duas faixas sem brecha;
- não cria colisão inevitável;
- combos de mesma faixa exigem a faixa oposta livre;
- distância mínima entre NPCs continua ativa.

---

## 8. Cenário acompanhando o ritmo

O ritmo visual continua ligado à dificuldade por meio de:

- velocidade do mundo;
- postes;
- ciclista;
- listras laterais;
- movimento da pista.

A água permanece sem animação, conforme definido na V0.13.4.16, aguardando uma etapa futura de refinamento visual final.

---

## Arquivos alterados/adicionados

- `scenes/minigames/DesvioLogico.gd`
- `assets/sprites/desvio_logico/carro_npc_verde.png`
- `assets/sprites/desvio_logico/carro_npc_verde.png.import`
- `assets/sprites/desvio_logico/carro_npc_laranja_queimado.png`
- `assets/sprites/desvio_logico/carro_npc_laranja_queimado.png.import`
- `assets/sprites/desvio_logico/carro_npc_cinza_prata.png`
- `assets/sprites/desvio_logico/carro_npc_cinza_prata.png.import`
- `docs/ESCOPO_V0_13_5_TRAFEGO_DINAMICO_DESVIO_LOGICO.md`
