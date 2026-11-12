# V0.14.4.1 — Hotfix: "WebGL context lost" no Desvio Lógico (web)

Relato: no itch.io, durante o horário do pôr do sol (Entardecer, 4º desafio) o navegador mostra
"WebGL context lost, please reload the page" e o jogo não continua.

## O que o erro significa
O navegador/GPU **derrubou o contexto gráfico** (pouca memória de vídeo ou GPU sobrecarregada). Não é um erro de script;
o Godot 4 não consegue restaurar o contexto e só pede para recarregar. **A causa exata não foi reproduzida aqui** (não há navegador
neste ambiente): o que segue são as causas que o código evidencia e a mitigação.

## O que o código mostrou
- O fundo do Entardecer é pequeno (1024×572, ~2 MB): **não é a imagem** do pôr do sol que pesa.
- A camada de **água** (`DLWaterFX`) redesenha várias centenas de comandos por redesenho (retas, polilinhas **com antialias**, retângulos),
  dos dois lados da pista, e **ignorava o perfil leve da web**: `WebLite.water_quality()` só ligava/desligava, o desenho usava sempre a quantidade cheia.
- Do Entardecer em diante o tráfego passa a ter +1 carro simultâneo (V0.14.1): a carga do desenho cresce a cada horário, então o limite do aparelho
  aparece nos horários mais avançados.

## O que mudou
| Arquivo | Mudança |
|---|---|
| `scripts/core/WebLite.gd` | `water_density()`: 1.0 (desktop), 0.6 (web), 0.35 (aparelho fraco). |
| `modules/DLWaterFX.gd` | Todas as quantidades (linhas de brilho, faixas, cintilações, raios) passam por `_lod()` (com mínimo). Polilinhas **sem antialias** na web. Desktop fica igual. |
| `web/shell.html` | Intercepta `webglcontextlost` **antes do motor**: sem `alert()` bloqueante, mostra tela "Recarregar" (fases concluídas ficam salvas). |
| `scripts/autoloads/WebBridge.gd` | Log `?debug=1` agora inclui **vram** e **desenhos por quadro**. |
| `project.godot`, `BrandText.gd` | Versão 0.14.4.1. |

## Como testar
1. Exporte para Web (shell `res://web/shell.html`), suba e teste com cache limpo (Ctrl+Shift+R).
2. Jogue até o Entardecer, Anoitecer e Noite.
3. **Se ainda cair**: abra com `?debug=1` na URL, F12 → Console, e me envie as linhas `[CM-DEBUG]` dos últimos ~30 s antes da queda
   (cena, mem, texturas, **vram**, **desenhos**, nós, fps). Com isso dá para saber se é memória de vídeo ou excesso de desenho.
4. Para simular aparelho fraco num PC forte: `?low=1`.

## Limites (leia)
- **Não testado no navegador.** É uma mitigação baseada no código, não uma causa confirmada. Se a causa for outra (ex.: vazamento de memória
  acumulado entre os 6 horários), o log novo vai mostrar a curva de vram/nós.
- A tela de "Recarregar" evita o alert, mas **não recupera a partida em andamento**: a rodada atual do Desvio Lógico é perdida; fases concluídas, não.
- Se o desenho da água continuar pesado em algum aparelho, o próximo passo é desligar a água no perfil fraco (`WATER_EFFECT_QUALITY` 0) ou trocar por uma imagem animada.
