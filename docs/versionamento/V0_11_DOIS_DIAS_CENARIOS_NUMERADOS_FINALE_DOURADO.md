# V0.11 — Dois Dias: Cenários de Novel Numerados e Finale Dourado

> **Status:** implementado, **ainda não testado dentro do Godot** (o ambiente de desenvolvimento desta entrega não tinha o editor). Ver a seção 9 (checklist de testes) antes de fechar a versão.
> **Substitui parcialmente** o [V0.10.1 — Roteiro Narrativo](V0_10_1_ROTEIRO_NARRATIVO.md): as seções 1 (premissa), 4 (estações 1, 4, 7 e 8), 5 (briefing) e 6 (cutscene final) mudaram. As demais continuam valendo.

## 1. Resumo da atualização

1. Os backgrounds das cutscenes foram remodelados e **numerados** (`assets/background/cutcines/NN_*.png`). Cada transição de novel de minigame agora tem **o seu próprio cenário**.
2. A campanha passou a acontecer em **dois dias**:
   - **Dia 1:** Show do Bilhão → Batalha Naval → Maleta Certa → Roleta de Risco → Perseguição → Forca Técnica → STOP.
   - **Dia 2 (manhã):** Desvio Lógico. O cenário de novel é a garagem ao nascer do sol, com o carro (Bionix) parado, e o minigame segue com os 6 períodos (amanhecer → noite).
3. Cutscene final remodelada: escritório à noite → **sala de reunião** (elenco aparece um por um agradecendo) → corte para o Ariel e o score → fala final do Jales → créditos.
4. **Novo ato após os créditos:** a imagem final com todos os personagens, **cortina de brilho dourado**, título *CONTAL MASTER* e *Obrigado por jogar!*, a tela escurece e entra o **GAME OVER** (com *Voltar ao menu*, que já existia).
5. Roteiros ajustados para o novo contexto de dois dias.
6. `APP_VERSION` passou de `0.10.2` para `0.11.0`.

## 2. Mapa dos assets de cutscene

| Arquivo | Resolução | Uso |
|---|---|---|
| `00_recepcao.png` | 1920×1080 | Intro, páginas 1–2 (boas-vindas) |
| `00_escritorio.png` | 1920×1080 | Intro, páginas 3–4 (briefing) |
| `01_show_bilhao.png` | 2560×1440 | Transição do Show do Bilhão (dia 1) |
| `02_batalha_naval.png` | 2560×1440 | Transição da Batalha Naval (dia 1) |
| `03_maleta_certa.png` | 1672×941 | Transição da Maleta Certa (dia 1) |
| `04_roleta_risco.png` | 2560×1440 | Transição da Roleta de Risco (dia 1, bônus) |
| `05_perseguicao.png` | 2560×1440 | Transição da Perseguição (dia 1) |
| `06_forca_tecnica.png` | 2560×1440 | Transição da Forca Técnica (dia 1) |
| `07_stop.png` | 2560×1440 | Transição do STOP (dia 1, noite) |
| `08_desvio_logico.png` | 1672×941 | Transição do Desvio Lógico (**dia 2**, garagem de manhã) |
| `09_escritorio.png` | 1920×1080 | Final: despedida do Jales, convite da Natalia e narração (noite) |
| `10_sala_reuniao.png` | 1920×1080 | Final: elenco agradecendo, Ariel + score, fala final do Jales, créditos |
| `11_cena_creditos.png` | 2560×1440 | Final: cena do elenco reunido após os créditos |

Os ids de uso ficam centralizados em `scripts/core/Paths.gd` (`CUTSCENE_BG_BY_PHASE`, `CUTSCENE_BG_INTRO`, `CUTSCENE_BG_FINAL`). Trocar um cenário = mudar **só** essa constante.

## 3. Fluxo da campanha

```
Intro (00_recepcao → 00_escritorio)
 DIA 1  [banner "DIA 1 · MANHÃ" no Show do Bilhão]
   01 Show do Bilhão → 02 Batalha Naval → 03 Maleta Certa → 04 Roleta (bônus)
   → 05 Perseguição → 06 Forca Técnica → 07 STOP
 DIA 2  [banner "DIA 2 · MANHÃ" no Desvio Lógico]
   08 Desvio Lógico (garagem, manhã)
 Final: 09 escritório (noite) → corte → 10 sala de reunião → score → Jales
        → créditos → 11 cena final (cortina dourada, título, agradecimento)
        → escurece → GAME OVER → menu
```

- `GameManager.DAY_TWO_FIRST_PHASE_KEY` define onde o dia 2 começa (hoje `"desvio_logico"`). Novas funções: `get_day_for_phase()`, `get_current_day()`, `is_first_phase_of_day()`. `DAY_LABELS` guarda os textos dos banners.
- A transição mostra o cabeçalho **"DIA n · FASE x/8"** (ou **"DIA 1 · RODADA BÔNUS"**). A faixa de dia no topo só aparece na transição que **abre** um dia.
- O modo livre não passa pelas transições e não foi alterado.

## 4. Arquivos alterados

| Arquivo | Mudança |
|---|---|
| `scripts/core/Paths.gd` | Removidas `BG_CUTSCENE_INTRO/FINAL` (apontavam para `curtcine_*.png`, que não existem mais). Novas constantes `BG_CUT_*` e os mapas de cenário. |
| `scripts/autoloads/GameManager.gd` | Conceito de dia; `APP_VERSION = "0.11.0"`. |
| `scenes/cutscenes/StageTransition.gd` | Fundo por minigame (com leve zoom e véu na cor do tema), banner de dia, cabeçalho com dia. |
| `scenes/cutscenes/CutsceneIntro.gd` | Cenário por página (`background` no JSON) com crossfade. |
| `scenes/cutscenes/CutsceneFinal.gd` | Cenário por bloco, cortes com troca de cenário, créditos → cena final → game over. |
| `scripts/data/dialogues/*.json` | Textos adaptados (seção 5); `intro.json` e `final.json` ganharam a chave `background`/`backgrounds`. |

`NovelStage.gd` **não** foi alterado: ele desenha só os personagens e a caixa de diálogo por cima do fundo da cena que o hospeda.

## 5. Roteiro adaptado ao contexto de dois dias

A revisão pelos pares passou de "amanhã às 9h" para **"daqui a dois dias, às 9h"**. Assim, no fim do dia 2, a fala do Jales "a revisão de amanhã" continua correta.

| Onde | Mudança |
|---|---|
| `intro.json` p.2 | "Daqui a dois dias, às 9h…" |
| `intro.json` p.3–4 | "nestes dois dias"; "Hoje passamos por sete delas; amanhã cedo, a última, e então a equipe se reúne…" |
| `show_do_bilhao.json` | "Primeira estação do nosso **primeiro dia**! A revisão pelos pares, daqui a dois dias…" |
| `roleta_risco.json` | "Já passamos da metade do nosso primeiro dia…" |
| `stop.json` | "Estamos na reta final do nosso **primeiro dia**!" |
| `desvio_logico.json` | Título "Segundo Dia: A Ética"; Jales abre com "**Bom dia!** Descansou?…"; Natalia cita que vão dirigir "o dia inteiro, da manhã até a noite". |
| `final.json` farewell | "…lado a lado, em dois dias intensos…" |
| `final.json` narration | "**Ontem** você começou aprendendo a norma e **hoje** termina tomando decisões éticas." |

Mantidos sem mudança: os textos de agradecimento do elenco, as falas do Ariel e as 4 falas finais do Jales por desempenho.

## 6. Cutscene final — fluxo e sala de reunião

1. **Escritório (09, noite):** despedida do Jales → Natalia chama para a reunião → narração de apoio.
2. **Corte** (fade) para a **sala de reunião (10)**: cada personagem **sobe na tela** no momento em que fala e permanece em cena (agradecimento do elenco).
3. **Corte** para o **Ariel** na mesma sala: ele puxa o score e a contagem sobe.
4. **Corte** para o **Jales**: fala final (4 variações por desempenho).
5. **Créditos.** A linha "Obrigado por jogar ContalMaster!" saiu da rolagem e foi para a cena final (evita duplicar).

## 7. Cena final dourada (decisão criativa)

Implementada em `CutsceneFinal.gd` (`_show_finale_act` e funções `_finale_*`), sobre `11_cena_creditos.png`. Linha do tempo:

| Tempo (aprox.) | O que acontece |
|---|---|
| 0,0–1,1 s | Fim dos créditos escurece; a imagem final entra coberta por um véu escuro. |
| 1,1–4,5 s | **Cortina de luz dourada** (faixa inclinada com 3 "dobras" mais fracas) atravessa da esquerda para a direita, **puxando o véu** e revelando o elenco; brilhos em estrela nascem no rastro. |
| 4,5–6,0 s | Elenco limpo, só poeira dourada flutuando (o zoom lento na imagem roda durante toda a cena). |
| 6,0–8,3 s | **Segunda cortina**, mais suave; a imagem escurece um pouco (52%) e, perto de 7 s, surge **CONTAL MASTER** (cores da marca) + linha dourada + **"Obrigado por jogar!"** + subtítulo. |
| ~8,2–12,8 s | Título parado na tela (≈ 4,6 s depois do fade-in). |
| +1,4 s | Tela escurece → **GAME OVER** → *Voltar ao menu*. |

- **Clique / Espaço / Enter:** antes do título (após 1,2 s) pula direto para o título; com o título na tela, segue para o Game Over. **Esc** volta ao menu, como em todo o resto.
- **Animações desligadas** (Configurações): mostra direto a composição final, sem cortina, e segue para o Game Over.
- Textos editáveis em `final.json > finale` (`title`, `thanks`, `subtitle`).
- Ajustes finos: constantes `FINALE_*` no topo de `CutsceneFinal.gd` (tempos, opacidade do véu/escurecimento, cor do dourado, limite de brilhos).

## 8. Observações técnicas e pontos de atenção

- **Arquivos `.import`:** as imagens novas em `cutcines/` não vinham com `.import`. O Godot os gera ao abrir o projeto no editor; **abra o projeto uma vez no editor antes de exportar**.
- **Resolução:** `03_maleta_certa.png` e `08_desvio_logico.png` têm 1672×941, enquanto as outras de cena têm 2560×1440 ou 1920×1080. Elas serão ampliadas e ficarão um pouco mais suaves; o ideal é regerá-las em 1920×1080 ou 2560×1440.
- **Memória (mobile):** só um fundo de cutscene fica carregado por vez (a intro carrega dois durante o crossfade). Se o consumo em celulares fracos incomodar, ative compressão VRAM nas importações de `cutcines/`.
- **Resíduo do desenho antigo:** `STYLE_MAP` e as partículas temáticas da `StageTransition` continuam ativos; agora ficam por cima do cenário novo.
- **`project.godot` não faz parte do pacote** recebido; nada nele precisou mudar.

## 9. Checklist de testes (no Godot)

- [ ] Abrir o projeto no editor sem erros de parse (principalmente `CutsceneFinal.gd`, mais alterado).
- [ ] Intro: troca de recepção para escritório entre as páginas 2 e 3, com crossfade.
- [ ] Cada uma das 8 transições mostra o cenário certo, com o título legível e a novel por cima.
- [ ] Banner "DIA 1 · MANHÃ" no Show do Bilhão e "DIA 2 · MANHÃ" no Desvio Lógico; cabeçalhos "DIA n · FASE x/8".
- [ ] Textos novos do Desvio Lógico e do STOP cabem na caixa de diálogo.
- [ ] Final: escritório → corte → sala de reunião; cada personagem sobe ao falar; corte para o Ariel; score; Jales; créditos.
- [ ] Cena final: cortina dourada, brilhos, título, escurecimento, Game Over, *Voltar ao menu*.
- [ ] Clique durante a cena final (antes e depois do título) e com animações desligadas.
- [ ] Layout compacto (celular): título e agradecimento não estouram a largura.
- [ ] As quatro variações de desempenho (Mestre/Confiança/Evolução/Formação) ainda funcionam.
