# V0.16.16 — Forca Técnica: layout sem cortes, só um rosto da Aline, cartões de pista/chute e chutes parecidos

Base: 0.16.15. **Não testado no Godot** (sem o editor no ambiente de geração; o script passou na checagem de sintaxe). Teste em fonte Normal, Grande e Extra grande, janela pequena e no navegador.

## Corte de layout (prints)
- Causas: o teclado e os botões ficavam abaixo da dobra; a fonte grande não encolhia com o fator do `DynamicLayout`; o teclado quebrava com 1 letra sozinha na última linha.
- Agora **fontes, teclas, tiles e botões** multiplicam pelo fator do `DynamicLayout` (1,00 → 0,54), então tudo cabe em pequena, média, grande e extra grande.
- Teclado em **linhas equilibradas e centralizadas** (15 teclas = 8 + 7; sem letra sozinha).
- Bloco "Pista:" some só no nível mais apertado (a pista continua no cartão da Aline).
- Painel de palavra e área do palco com largura mínima menor (não estoura em telas estreitas).

## Rostos da Aline
- Fica **só o rosto do título**. Saíram: botão de pista, comentário lateral, chute rápido, feedback e final.

## Botões no painel lateral
- **Pista da Aline (n)** e **Já sei o termo!** ficam no painel da direita (no lugar do comentário da Aline).
- **Pista:** abre o cartão do tutorial com a Aline e a pista (avisa o custo de 10% do bônus). Ao confirmar, a letra-chave aparece **animada** (pulo + brilho dourado). "Deixa pra lá" cancela sem custo. As letras certas comuns também entram animadas.
- **Já sei o termo!:** a Aline provoca no cartão, depois abrem as 3 opções ("Ainda não" volta sem custo).
- Com **Tutoriais desligados** nas Configurações o cartão não aparece e o fluxo segue direto.

## Chutes parecidos por dificuldade
- Similaridade = prefixo em comum + palavras em comum + radical + distância de edição + categoria + nº de palavras + tamanho, **mais** quanto o termo combina com as letras já reveladas nas mesmas posições.
- **Difícil:** os 2 mais parecidos (peso máximo no padrão revelado). **Normal:** também muito parecidos, com mais sorteio. **Fácil:** 1 parecido + 1 claramente mais distante.
- Calculado no momento do clique (considera o que já está na tela).

## Navegador (desempenho)
- Efeito de brilho redesenhado a ~12 Hz (antes todo quadro); no modo "lite" só desenha a moldura de perigo.
- Menos letras flutuantes (18) e, no "lite", sem rotação nem pulso de transparência.
- Teclado remontado só quando muda o número de linhas; tremor de tela só mexe na posição quando necessário.

## Arquivos
`project.godot`, `scripts/ui/BrandText.gd`, `scenes/minigames/forca/ForcaTecnica.gd`, `tutorials/data/forca_tecnica.json`, `docs/versionamento/CRONOGRAMA_VERSOES.md` e este arquivo.
