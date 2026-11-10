# Contal Master — Atualização 0.11.1 (ajustes de novels, sprites e alturas)

## Como aplicar
1. Feche o Godot e copie o conteúdo do zip **por cima** do projeto (mesmas pastas).
2. Apague os arquivos antigos sem número (`jales.png`, `natalia.png`, `priscila.png`, `julios.png`, `tiago.png`, `anderson.png`, `ariel.png`, `cleiton.png`, `aline.png`) **e seus `.import`**: eles foram renomeados para `_1`.
3. Abra o projeto no Godot 4.5 uma vez (gera os `.import` dos `_1`) e rode o checklist em `docs/versionamento/V0_11_DOIS_DIAS_CENARIOS_NUMERADOS_FINALE_DOURADO.md` (seção 10).

> Importante: testei a composição por simulação em imagem, **não dentro do Godot**. Teste o fluxo completo antes de entregar.

## Regra de numeração dos sprites
- `_1` = **novels** (transições e introdução), corpo inteiro (era o arquivo sem número).
- `_2` = **cena final**, corpo inteiro.
- `_3` = **tutoriais**, da cintura para cima.

## Alturas dos personagens
A escala de todos vem de uma tabela única: `scripts/core/CharacterHeights.gd`. Numa novel, 1 m = 230 px (tela 1280×720).

| Personagem | Altura | Perfil | Altura na novel |
|---|---|---|---|
| Julios | 1.85 m | alto | 426 px |
| Anderson | 1.83 m | alto | 422 px |
| Jales | 1.80 m | alto | 415 px |
| Cleiton | 1.77 m | médio-alto | 408 px |
| Priscila | 1.75 m | médio-alto (alta, mas menor que Jales) | 403 px |
| Tiago | 1.72 m | médio | 396 px |
| Natalia | 1.68 m | médio-baixo | 387 px |
| Ariel | 1.66 m | baixo | 382 px |
| Aline | 1.62 m | a mais baixa | 373 px |

Valores são alturas "de desenho" (incluem cabelo, boné e salto). Para mudar alguém, edite só `HEIGHTS_M`.

## O que foi alterado
- **Título com cenário desfocado** (transições dos minigames), com entrada suave.
- **Novels com sprites `_1`**, quadro de diálogo **sempre embaixo**, personagens de corpo inteiro **em pé acima do quadro**, mais afastados dele.
- **Introdução:** Jales centralizado.
- **Cena final:** quadros embaixo (cobrem parte das pernas/pés); **corredor** com Natalia no meio (tamanho `_2`, pernas visíveis até o quadro); **sala de reunião** com o elenco mais para trás.
- **Tutorial da Natalia (Desvio Lógico):** corrigido o cartão que crescia/descia com o retrato preso no alto; agora a altura acompanha o texto e o retrato sobe e desce junto.
- **Alturas** aplicadas em novels, cena final e (suavizadas) tutoriais.

## Ajustes finos
- `Paths.NOVEL_LAYOUT`: `ppm` (tamanho geral das novels), `gap` (distância dos pés ao quadro).
- `Paths.CUTSCENE_FLOOR`: chão (`front`/`back`) e escala (`ppm`/`row_ppm`) de cada cenário do final.

## Pontos de atenção
- O pacote recebido já era o **V0.12** (`APP_VERSION = "0.12.0"` e doc V0_12). Como pedido, o bloco foi registrado como **0.11.1** dentro do md da V0.11; não alterei `APP_VERSION`.
- Os cortes (pernas atrás do quadro) no final são intencionais, conforme pedido.
