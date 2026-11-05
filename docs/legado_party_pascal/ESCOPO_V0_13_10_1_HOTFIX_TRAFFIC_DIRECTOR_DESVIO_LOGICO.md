# Party Pascal V0.13.10.1 — Hotfix Traffic Director

## Objetivo
Corrigir erro de compilação da V0.13.10 causado por variáveis do Traffic Director usadas sem declaração no escopo global do `DesvioLogico.gd`.

## Correção aplicada
Foram adicionadas as variáveis globais:

```gdscript
var traffic_player_lane_safe_time: float = 0.0
var traffic_player_observed_lane: int = LANE_CENTER
```

## Motivo
Essas variáveis são usadas para medir quanto tempo a faixa atual do jogador ficou sem ameaça e permitir que o Traffic Director pressione a faixa do Bionix quando ela fica segura por tempo demais.

## Arquivo alterado
- `scenes/minigames/DesvioLogico.gd`

## Observação
Nenhuma lógica de gameplay, painel, áudio, colisão ou HUD foi alterada nesta correção. Este patch apenas resolve os identificadores não declarados.
