# V0.16.15 — Forca Técnica: teclado filtrado, chute rápido, pistas da Aline e nova interface

Base: 0.16.14. Copie por cima do projeto. **Não testado no Godot** (sem o editor no ambiente de geração): o script passou no analisador de sintaxe do GDScript, mas abra a cena `ForcaTecnica` e jogue uma rodada em cada dificuldade antes de exportar.

## 1) Melhorias técnicas
- **Teclado filtrado:** só as letras do termo + 3 a 6 distratoras (12 a 15 teclas). Distratoras nunca são K, W, Y, Z, J, Q, X (só aparecem se o termo as tiver). Termo com 13+ letras diferentes chega a 16 teclas, porque as letras certas têm prioridade. Teclado físico: letra que não está na tela é ignorada, sem punição.
- **Já sei o termo!:** libera com 40% das letras reveladas (constante `QUICK_GUESS_THRESHOLD`). Abre 3 termos (o certo + 2 parecidos do glossário: mesma categoria, mesma inicial e tamanho próximo têm prioridade). Acertou = vence na hora, com bônus de velocidade de até 40 pontos (40 com 40% revelado, caindo a 0 com o termo todo revelado). Errou = −1 ponto de integridade. 1 chute por rodada, e há botão para voltar sem custo.
- **Pistas combinadas:** etiqueta `Categoria • N letras (• N palavras)`, definição curta e botão **Pedir pista à Aline**: revela a letra oculta que mais se repete e mostra uma frase de associação. Máximo 2 por rodada, cada uma tira 10% do **bônus** (os 100 pontos base não mudam).
- **Letras-âncora:** termo com 10+ letras começa com a primeira e a última reveladas (só essas posições; letra cuja ocorrência inteira foi revelada já sai marcada).
- **Acento e cedilha automáticos:** o jogo compara pela letra-base (A revela Á, Ã, Â; C revela Ç). Já funcionava por normalização; agora também aceita ã, ç, é digitados no teclado físico.

## 2) Interface
- Título compacto (30 px, antes 42) numa barra baixa com o rosto da Aline, rodada e pontuação; reserva o espaço dos botões TELA e PAUSAR.
- Palavra em **tiles** (um por letra, agrupados por palavra), com tamanho calculado para caber o termo mais longo; letra-âncora com borda dourada.
- Painel lateral: integridade, estado, erros, **dificuldade**, **recorde** (modo livre: melhor pontuação do minigame; campanha: pontuação da estação) e comentário da Aline no lugar do "terminal".
- Estilo Aline: paleta do jogo (ameixa/lilás) + papel de dicionário + dourado; sem grade, glitch e símbolos de código (`</>`, `SQL`, `λ`); letras e siglas da NBC flutuando.
- Usa o `DynamicLayout` (padrão 0.16.7) para não cortar com fonte grande ou tela baixa.

## 3) Outros ajustes
- Classificação final por proporção de acertos (antes fixa em 6/4/2 e não acompanhava 2, 4, 8 ou 10 rodadas).
- Termos de TI removidos do código (a reserva agora é do tema revisão pelos pares).
- Tutorial da Aline reescrito em 4 quadros por modo (teclado, pistas, chute rápido, integridade e pontos).
- Novo campo `pista_aline` nos 51 termos de `dicionario.json` (frase de associação sem citar o termo). Sem o campo, o jogo usa "Na prática" com o termo mascarado.

## Arquivos
`project.godot` e `scripts/ui/BrandText.gd` (0.16.15), `scenes/minigames/forca/ForcaTecnica.gd`, `scripts/core/question_bank.gd`, `scripts/core/data/dicionario.json`, `tutorials/data/forca_tecnica.json`, `docs/versionamento/CRONOGRAMA_VERSOES.md` e este arquivo.
