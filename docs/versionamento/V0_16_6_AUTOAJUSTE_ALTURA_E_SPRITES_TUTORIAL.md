# V0.16.6 — Auto-ajuste de altura (Show do Bilhão) e sprites do tutorial

## Show do Bilhão
`_fit_layout()` mede a coluna principal e, se não couber na altura da tela, aplica até 3 níveis de folga (margens,
espaços, painel da pergunta, altura mínima das respostas e ícones do título). Nível 0 = visual original. Roda ao carregar
a pergunta, ao trocar a fonte e ao redimensionar a janela/tela cheia. Corrige a alternativa D cortada em Extra grande.

## Tutorial (todos os minigames, todas as fontes)
Os sprites dos personagens nunca sobem acima de y = 68 (faixa dos botões Tela cheia/Pausar). Antes a cabeça de personagens
altos (ex.: Cleiton) cobria o botão Pausar quando o cartão ficava no topo; agora o grupo encolhe junto, mantendo a proporção.

## Versão
`project.godot` e `BrandText.DEFAULT_VERSION` → **0.16.6**.

## Pendente / observação
Perseguição e Maleta Certa usam o mesmo padrão de altura fixa; se mostrarem corte em Extra grande, replicar o `_fit_layout`.
