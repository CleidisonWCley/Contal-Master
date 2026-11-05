# CM-V0.3 — Dilemas: Maleta Certa e Desvio Lógico

> Faixa **0.3** · cenário → decisão · `dilemas.json`

> **Legenda de IDs:** `PP-Vx.y.z` = versão do histórico **Party Pascal** (nome anterior do projeto; arquivos em [`../legado_party_pascal/`](../legado_party_pascal/)). `CM-Vx.y.z` = versão **Contal Master**. A numeração do Party Pascal (que chegou a V1.0.3.2.1) **não** é comparável à do Contal Master (que está em 0.9.2.1): aqui o histórico antigo foi reorganizado nas faixas 0.1 a 0.9.

## 1. Antes (herdado do Party Pascal)

| ID legado | O que entregou |
|---|---|
| [PP-V0.3.0](../legado_party_pascal/ESCOPO_V0_3_0_MALETA_CERTA.md) | **Maleta Certa**: problema + 3 maletas com soluções embaralhadas; correta comparada pelo texto da opção; pontuação integrada ao `ScoreManager` (Fácil +12/−5; Normal +10/−12). |
| Série 0.13.x (0.13.0 → 0.13.10.3 (51 docs)) | **Desvio Lógico**, minigame final da campanha (o jogador dirige por clique/toque em 3 faixas e escolhe a rota A/B numa bifurcação em T). Ver tabela abaixo. |

**Evolução do Desvio Lógico (resumo por série; lista completa em [MAPA_LEGADO](MAPA_LEGADO.md)):**

| Série | Docs | Foco |
|---|---|---|
| 0.13.0 – 0.13.1 | 2 | Base: 6 desafios (amanhecer → noite), 3 faixas, bifurcação em T, feedback pedagógico; refino da sensação de avanço e dos obstáculos em perspectiva. |
| 0.13.2 – 0.13.3.1 | 3 | Direção pseudo-3D, corrida viva, HUD de dano (integridade 0 encerra), cenário vivo. |
| 0.13.4.x | 15 | Faixas, NPCs e animação; props laterais; poste e placa fixa; redesenho dos HUDs; safe area; balanceamento (8/6/4 colisões aprox. em Fácil/Normal/Difícil). |
| 0.13.5 – 0.13.7.x | 6 | Tráfego dinâmico (5 cores de NPC), pause, **tutorial jogável**, correção de spawns injustos (timer de 35 s só após o tutorial), **pontuação inteligente** (ex.: rota certa +30/errada −25 no Fácil). |
| 0.13.8.x | 13 | Aceleração inicial, áudio do carro, colisão, zona segura final, chegada natural à bifurcação. |
| 0.13.9.x | 8 | Refinamento sonoro, limpeza de chiado, áudio limpo e **Traffic Director** recriado (tráfego justo, combos). |
| 0.13.10.x | 4 | Painel de tráfego com velocímetro, pressão de tráfego (limite de faixa livre ≈6,8/4,8/3,4 s), renome do carro nos textos visíveis, desaceleração e parada finais. |

## 2. Agora (Contal Master V0.9.2.1)

- **`dilemas.json`: 24 cenários** de decisão profissional (8 fáceis, 8 normais, 8 difíceis). Cada um traz a ação correta, **duas ações incorretas** e o **motivo de cada erro**.
- **Variável de bifurcação** no campo `tipo`: conflito de interesse, confidencialidade, intimidação, responsabilidade, procedimento, **tipo de relatório** (adequado / com deficiências / inadequado / limitação de escopo) e prazo.
- Uso por minigame: a **Maleta** mostra a certa + 2 erradas; o **Desvio Lógico** mostra a certa + 1 errada sorteada, em lado aleatório, com o motivo de cada lado.
- Rótulos de ação ≤36 caracteres (limite medido nas cenas; ainda não conferido em tela). Mecânica e pontuação do Desvio Lógico **inalteradas**.

## 3. A implementar

- Conferir em tela se algum rótulo de placa/maleta corta; ajustar o JSON, não a cena → **CM-V0.9.5**.
- Localizar o texto do **tutorial** do Desvio Lógico para o tema auditoria → **CM-V0.9.3**.
- Ampliar para ≥12 dilemas por nível → **CM-V0.9.6**.

## Documentos legados desta faixa

- Maleta Certa: [PP-V0.3.0](../legado_party_pascal/ESCOPO_V0_3_0_MALETA_CERTA.md)
- Série Desvio Lógico: 51 documentos (ver [MAPA_LEGADO](MAPA_LEGADO.md))
