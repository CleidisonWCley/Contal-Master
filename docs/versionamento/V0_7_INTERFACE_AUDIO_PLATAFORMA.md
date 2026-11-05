# CM-V0.7 — Interface, Áudio e Plataforma

> Faixa **0.7** · UI, botões, áudio, responsividade e backgrounds

> **Legenda de IDs:** `PP-Vx.y.z` = versão do histórico **Party Pascal** (nome anterior do projeto; arquivos em [`../legado_party_pascal/`](../legado_party_pascal/)). `CM-Vx.y.z` = versão **Contal Master**. A numeração do Party Pascal (que chegou a V1.0.3.2.1) **não** é comparável à do Contal Master (que está em 0.9.2.1): aqui o histórico antigo foi reorganizado nas faixas 0.1 a 0.9.

## 1. Antes (herdado do Party Pascal)

| ID legado | O que entregou |
|---|---|
| [PP-V0.8.1](../legado_party_pascal/HOTFIX_V0_8_1_BACKGROUNDS.md) / [PP-V0.8.2](../legado_party_pascal/HOTFIX_V0_8_2_BACKGROUNDS_CLEAN.md) | Backgrounds do menu e do modo (`background_main`, `game_modo`; versões "clean"). |
| [PP-V0.9.1](../legado_party_pascal/HOTFIX_V0_9_1_INPUT_SETTINGS_ANIMATIONS.md) | Entrada por `_input()` (mouse, toque e teclado) nas cutscenes; botões Menu/Pular fixos. |
| [PP-V0.9.2](../legado_party_pascal/HOTFIX_V0_9_2_SETTINGS_ANIMATIONS_GLOBAL.md) | Configurações salvam automaticamente; tela cheia e animações viram ON/OFF; animações globais desligáveis. |
| [PP-V0.9.3](../legado_party_pascal/HOTFIX_V0_9_3_AUDIO_LOOP.md) | Loop infinito das músicas OGG/MP3. |
| [PP-V0.9.4](../legado_party_pascal/HOTFIX_V0_9_4_BUTTON_STYLES.md) | `ButtonStyles.gd`: padronização dos botões por script (principal, secundário, perigo, discreto, ON/OFF, opção). |
| [PP-V0.9.5](../legado_party_pascal/ESCOPO_V0_9_5_PYGAME_PALETTE.md) | Fidelidade visual da paleta Pygame (variantes `main_start`, `main_settings`, `main_exit`, `mode_campaign`). |
| [PP-V0.10.2](../legado_party_pascal/ESCOPO_V0_10_2_OTIMIZACAO_TELAS_MULTIPLATAFORMA.md) | `ScreenTools.gd` e `stretch aspect="expand"`: telas adaptáveis, tela cheia oculta em Android/iOS. |

## 2. Agora (Contal Master V0.9.2.1)

- **Marca em duas cores** via novo `scripts/ui/BrandText.gd` e tokens `BRAND_CONTAL` (branco), `BRAND_MASTER` (roxo `#8B3DFF`), `BRAND_VERSION` e `BRAND_OUTLINE` no `UiPalette` (cores continuam centralizadas na paleta).
- **Selo de versão** no canto inferior direito do menu: "Contal Master V0.9.2.1" (antes: texto amarelo do nome anterior).
- **Quebra de linha** nos botões do Show do Bilhão, Perseguição e Maleta (textos de auditoria são mais longos que os de TI).

## 3. A implementar

- Passada de responsividade com os textos longos em telas compactas/Android → **CM-V0.9.5**.
- Nova identidade visual: logo, ícone e splash do Contal Master → **CM-V0.9.8**.

## Documentos legados desta faixa

- [PP-V0.8.1](../legado_party_pascal/HOTFIX_V0_8_1_BACKGROUNDS.md) — Hotfix V0.8.1 — Backgrounds do Menu e Modo
- [PP-V0.8.2](../legado_party_pascal/HOTFIX_V0_8_2_BACKGROUNDS_CLEAN.md) — V0.8.2 — Hotfix dos backgrounds main/modo
- [PP-V0.9.1](../legado_party_pascal/HOTFIX_V0_9_1_INPUT_SETTINGS_ANIMATIONS.md) — V0.9.1 — Hotfix de Cutscenes, Configurações e Animações
- [PP-V0.9.2](../legado_party_pascal/HOTFIX_V0_9_2_SETTINGS_ANIMATIONS_GLOBAL.md) — V0.9.2 — Configurações Globais, Animações e UI
- [PP-V0.9.3](../legado_party_pascal/HOTFIX_V0_9_3_AUDIO_LOOP.md) — V0.9.3 — Hotfix de Loop Infinito das Músicas
- [PP-V0.9.4](../legado_party_pascal/HOTFIX_V0_9_4_BUTTON_STYLES.md) — V0.9.4 — Padronização dos Botões por Script
- [PP-V0.9.5](../legado_party_pascal/ESCOPO_V0_9_5_PYGAME_PALETTE.md) — V0.9.5 — Fidelidade Visual da Paleta Pygame
- [PP-V0.10.2](../legado_party_pascal/ESCOPO_V0_10_2_OTIMIZACAO_TELAS_MULTIPLATAFORMA.md) — V0.10.2 — Otimização de Telas para Multiplataforma
