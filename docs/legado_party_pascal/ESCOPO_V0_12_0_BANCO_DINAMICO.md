# V0.12.0 — Banco Dinâmico de Questões

## Objetivo
Transformar os minigames em uma experiência de estudo mais variada, evitando que o jogador veja sempre as mesmas perguntas ou o mesmo assunto repetido em sequência.

## Regras implementadas

- Cada minigame passa a usar banco por dificuldade.
- Cada dificuldade possui 30 itens no banco: fácil, normal e difícil.
- Cada partida usa 6 itens sorteados.
- O sorteio prioriza diversidade de tópicos dentro da partida.
- O jogo evita repetir os mesmos IDs em partidas consecutivas da mesma sessão, enquanto houver banco disponível.
- As dificuldades variam pela complexidade do conteúdo, não apenas pela pontuação ou tempo.

## Temas ampliados

A atualização inclui conteúdos de UX, EX/experiência, cibersegurança, DevOps, POO, desenvolvimento web, ciência de dados, análise de dados, BI, mineração de dados, Data Warehouse, governança de TI, LGPD, arquitetura, qualidade e assuntos comuns em concursos de tecnologia.

## Observação por minigame

- Show do Bilhão, Maleta Certa, Perseguição, Batalha Naval, STOP e Forca Técnica agora sorteiam 6 itens a partir do banco dinâmico.
- Roleta de Risco usa o mesmo banco dinâmico por dificuldade para formar 6 setores de evento por partida.
- Batalha Naval foi ajustada para 6 ameaças por partida, mantendo a busca no tabuleiro.
