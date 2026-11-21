# Patch V0.16.11 — Limpeza para o build web (sem postes, sem farol, fundo estático)

Copie os arquivos por cima do projeto, mantendo as pastas. Nenhum asset novo. Depois de copiar, feche e reabra o Godot (ele reconstrói o cache de UIDs).

## O que mudou (Desvio Lógico)
- **Postes removidos de vez.** Saíram o desenho por script, a luz noturna, os PNGs referenciados (`poste_lateral*.png`, que nem existiam mais no projeto), os sprites de pré-visualização da cena e as constantes `POST_*`.
- **Farol removido.** No lugar entra uma **aureola de luz branca suave** à frente do Bionix, só no Anoitecer e na Noite (`DLCarLights.KIND_HEAD`). Forma: cone suave que abre à frente do carro + poça no asfalto. Todos os controles ficam juntos no bloco "LUZ A FRENTE DO BIONIX" do `DLConfig.gd` (`CAR_HEADLIGHT_BY_ROUND`, `AURA_CONE_*`, `AURA_POOL_*`). Aparelho fraco (`WebLite.low_end()`) desenha 1 camada em vez de 2. As lanternas vermelhas continuam.
- **Fundo 100% estático.** Removidos o zoom/ondulação do fundo (`_update_background_motion_fx`) e a faixa do horizonte que crescia (`SkylineApproach`). Sai uma cópia da textura do fundo por partida e um update por quadro.
- **Markers da cena mantidos:** `PostLeft*` / `PostRight*` continuam em `SidePropMarkers`, mas agora só guiam as listras decorativas do gramado (`PROP_TRAIL_LEFT/RIGHT`). A perspectiva delas usa `DLConfig.GRASS_VANISH_Y` (era `POST_VANISH_Y`, mesmo valor).

## Erros do console corrigidos
- `DesvioLogico.tscn`: `invalid UID` + `Resource file not found` de `poste_lateral*.png` (ext_resources e 6 sprites de preview removidos).
- `Paths.gd`: `DL_PROP_POST` / `DL_PROP_POST_LEFT` removidos do dicionário de sprites.
- `ForcaTecnica.tscn`: UID do script estava desatualizado (mesmo warning `invalid UID`).
- `DesvioLogico.tscn`: o script `DLEditorGuide.gd` ganhou o UID correto.

## Versão
- `project.godot` e `BrandText.gd`: 0.16.10 → 0.16.11.

## Arquivos modificados
- `project.godot`
- `scripts/ui/BrandText.gd`
- `scripts/core/Paths.gd`
- `scenes/minigames/desviologico/DesvioLogico.gd`
- `scenes/minigames/desviologico/DesvioLogico.tscn`
- `scenes/minigames/desviologico/DLConfig.gd`
- `scenes/minigames/desviologico/modules/DLSideProps.gd`
- `scenes/minigames/desviologico/modules/DLCarLights.gd`
- `scenes/minigames/forca/ForcaTecnica.tscn`

## Observação
- `tools/dl_calibrar_postes.py` ficou obsoleto (calibrava os postes). Pode ser apagado; não afeta o jogo.
- Rode `python tools/verificar_caixa_build.py build/web/index.pck` antes de publicar.
