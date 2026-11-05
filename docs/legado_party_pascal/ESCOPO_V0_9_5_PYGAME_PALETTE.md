# V0.9.5 — Fidelidade Visual da Paleta Pygame

## Objetivo

Ajustar a identidade visual dos botões da versão Godot para ficar mais fiel à paleta usada na versão original em Pygame, mantendo o acabamento visual criado no Godot.

## Diagnóstico

A versão V0.9.4 padronizou os botões por script, mas a paleta ficou mais próxima de um estilo neon/cyberpunk. A versão Pygame usa cores mais sólidas e diretas: vermelho, azul, cinza, azul-roxo, verde e dourado.

## Alterações aplicadas

- Recriação de `scripts/ui/ButtonStyles.gd` com paleta baseada nas cores do Pygame.
- Criação de variantes específicas de estilo:
  - `main_start`
  - `main_settings`
  - `main_exit`
  - `mode_campaign`
  - `mode_free`
  - `mode_back`
  - `free_option`
  - `free_back`
  - `settings_easy`
  - `settings_normal`
  - `settings_hard`
  - `toggle_on`
  - `toggle_off`
  - `cutscene_menu`
  - `cutscene_skip`
  - `cutscene_return`
- Menu principal ajustado para usar vermelho, azul e cinza do Pygame.
- Seleção de modo ajustada para campanha vermelho, livre azul e voltar cinza.
- Modo livre ajustado com botões azul-roxo e botão voltar vermelho.
- Configurações ajustadas para dificuldade colorida conforme a opção selecionada.
- Botões ON/OFF mantidos, mas agora com verde/cinza mais alinhados à paleta original.
- Botões das cutscenes ajustados para cinza/vermelho/vermelho principal.

## Paleta de referência

| Uso | Cor normal | Hover |
|---|---:|---:|
| Iniciar Jogo | `rgb(200, 70, 70)` | `rgb(240, 110, 110)` |
| Configurações | `rgb(70, 110, 200)` | `rgb(120, 160, 250)` |
| Sair / Voltar | `rgb(80, 80, 80)` | `rgb(130, 130, 130)` |
| Campanha | `rgb(200, 60, 60)` | `rgb(240, 100, 100)` |
| Modo Livre | `rgb(60, 100, 200)` | `rgb(100, 140, 240)` |
| Botões Modo Livre | `rgb(60, 60, 100)` | `rgb(100, 100, 180)` |
| Voltar Modo Livre | `rgb(180, 50, 50)` | `rgb(220, 80, 80)` |
| Fácil | `rgb(50, 120, 220)` | `rgb(90, 160, 255)` |
| Normal | `rgb(220, 180, 40)` | `rgb(250, 215, 75)` |
| Difícil | `rgb(200, 50, 50)` | `rgb(240, 85, 85)` |
| ON | `rgb(40, 150, 60)` | `rgb(70, 190, 90)` |
| OFF | `rgb(80, 80, 90)` | `rgb(120, 120, 130)` |

## Fora do escopo

Esta versão não altera:

- lógica dos minigames;
- pontuação;
- áudio;
- fluxo de campanha;
- modo livre;
- cutscenes narrativas;
- exportação multiplataforma.

## Testes recomendados

- Menu Principal: verificar cores dos botões Iniciar, Configurações e Sair.
- Seleção de Modo: verificar Campanha, Livre e Voltar.
- Modo Livre: verificar botões dos minigames e Voltar.
- Configurações: alternar dificuldade e conferir mudança de cor do seletor.
- Configurações: testar ON/OFF de tela cheia e animações.
- Cutscene Inicial: verificar botões Menu e Pular.
- Cutscene Final: verificar botão Voltar ao Menu.
