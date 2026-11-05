# Party Pascal V0.13.10 — Upgrade Visual do Painel e Pressão de Tráfego

## Objetivo
Atualização focada no Desvio Lógico, consolidando três melhorias finais de apresentação e gameplay:

1. impedir que o jogador fique tempo demais em uma faixa sem desafio real;
2. trocar o painel inferior direito por um painel ciberfuturista com velocímetro;
3. simplificar o painel inferior esquerdo e renomear Velox-01 para Bionix nos textos visíveis.

## Traffic Director
O Traffic Director agora monitora também a faixa atual do jogador. Se o Bionix fica tempo demais sem ameaça na própria faixa, a próxima sequência ganha prioridade para pressionar essa faixa, sempre respeitando as regras de justiça:

- NPC nasce no horizonte válido da estrada;
- não nasce em cima do Bionix;
- não causa colisão instantânea;
- respeita a reta final sem novos spawns;
- mantém o sistema de single/double/triple e quebra de padrão.

Limites aproximados de faixa livre:

- Fácil: cerca de 6,8 segundos;
- Normal: cerca de 4,8 segundos;
- Difícil: cerca de 3,4 segundos.

## Painel inferior esquerdo
Foram removidas informações redundantes de avanço/tempo do painel inferior esquerdo. O avanço continua sendo exibido no HUD superior, de forma animada e mais clara.

O painel inferior esquerdo fica focado em:

- nome do minigame;
- desafio atual;
- dificuldade;
- mensagens contextuais curtas.

## Novo painel inferior direito
O painel inferior direito virou um painel ciberfuturista de corrida:

- velocímetro animado;
- leitura em km/h;
- barra horizontal de integridade;
- visual transparente com ciano/neon e destaque amarelo;
- sem preview do carro no painel.

Velocidade máxima por dificuldade:

- Fácil: 160 km/h;
- Normal: 200 km/h;
- Difícil: 240 km/h.

## Renomeação
Os textos visíveis ao jogador agora usam o nome `Bionix` no lugar de `Velox-01`.

## Preservado
Não foram alterados:

- áudio e volumes testados;
- música principal;
- água;
- postes;
- colisão visual;
- chegada natural à bifurcação;
- score;
- pause;
- perguntas;
- pontuação.
