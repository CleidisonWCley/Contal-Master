# V0.16.17 — Forca Técnica: rebalanceamento (menos fácil) e mais espaço para o teclado

Base: 0.16.16. **Não testado no Godot** (script validado só quanto à sintaxe). Jogue algumas rodadas nas 3 dificuldades.

## Dificuldade
- **Sem letras reveladas no início:** removidas as letras-âncora (1ª e última letra em termos de 10+ letras).
- **Alfabeto completo (A a Z):** o teclado filtrado de 12 a 15 teclas foi removido.
- **Pista mais cara:** cada pista tira **15% dos pontos da rodada** (base + bônus), antes 10% só do bônus. Máx. 2 pistas por rodada.
- **Pista menos precisa:** revela uma letra oculta **sorteada** (antes sempre a que mais se repetia).
- Mantidos: erros por dificuldade (14 / 10 / 6), "Já sei o termo!" com 40% revelado, 1 chute por rodada, −1 de integridade se errar.
- Ajustes finos em `ForcaTecnica.gd`: `HINT_DISCOUNT`, `MAX_HINTS_PER_ROUND`, `QUICK_GUESS_THRESHOLD`, `SPEED_BONUS_MAX`, `ERRORS_BY_DIFFICULTY`.

## Cartão da Aline
- O cartão de pista e de provocação do chute rápido **sempre aparece**, mesmo com Tutoriais desligados (é parte da mecânica).

## Interface
- Área da palavra menor: tiles menores, painel que não ocupa mais o espaço livre.
- Teclado maior (66×58 px em tela normal) em linhas equilibradas, ocupando o espaço que sobrou.
- Botões laterais maiores (64 px de altura, fonte 22) e painel lateral um pouco mais largo.

## Arquivos
`project.godot`, `scripts/ui/BrandText.gd`, `scenes/minigames/forca/ForcaTecnica.gd`, `tutorials/data/forca_tecnica.json`, `docs/versionamento/CRONOGRAMA_VERSOES.md` e este arquivo.
