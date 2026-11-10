# Hotfix — estabilidade do TutorialOverlay (1º card) com Animações ligadas/desligadas

> STATUS: **não testado em engine.** Feito por análise estática (o ambiente de autoria não tinha Godot nem rede).
> Rode `tools/tests/tutorial_smoke.gd` e o checklist abaixo antes de publicar.

## Alterações (tutorials/TutorialOverlay.gd)
- Tweens gerenciados: `_fade_tween` e um tween por retrato; cada novo cancela o anterior; `close()` e `_exit_tree()` cancelam todos.
- `process_mode = ALWAYS`: tweens e `_process` do tutorial não congelam se `get_tree().paused` estiver ativo.
- Layout: `_view_size()` (fallback quando `_root.size` ainda é 0/minúsculo), largura mínima no Label com autowrap, `clip_contents` no card e relayout após o 1º frame.
- Ouve `SettingsManager.settings_changed`: ao desligar Animações com o tutorial aberto, vai direto ao estado final (opaco, texto completo).
- `_resolve_spot` valida `is_instance_valid(host)`.

## Alterações (scenes/menus/ModeSelect.gd)
- Remove o meta `"tween"` obsoleto antes de aplicar o estado (com ou sem animações).

## Checklist manual
Para Animações ligadas e desligadas: Campanha e Modo livre, tutorial dos 8 minigames (passo 1 → fim), pular (Esc/botão), voltar, trocar a opção de animações dentro do tutorial, pausar logo depois do tutorial e voltar ao menu.
