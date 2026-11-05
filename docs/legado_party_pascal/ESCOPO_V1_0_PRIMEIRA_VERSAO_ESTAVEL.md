# Party Pascal V1.0 — Primeira Versão Estável

## Objetivo

Consolidar o Party Pascal como versão jogável, estável e apresentável, sem adicionar sistemas grandes novos.

## Prioridades da entrega

1. Fluxo principal funcionando: Menu Principal → Seleção de Modo → Campanha ou Modo Livre → Minigames → Pontuação/retorno.
2. Menus padronizados com identidade mágica: Menu Principal, Seleção de Modo, Modo Livre, Configurações e Pontuação.
3. Modo Livre com 7 minigames jogáveis e Roleta de Risco fora da seleção livre.
4. Campanha mantendo a Roleta de Risco como rodada bônus/surpresa.
5. Pontuação local com nickname, campanha geral e melhores resultados por minigame.
6. Configurações funcionais: música, efeitos, dificuldade, tela cheia e animações visuais.
7. Revisão de responsividade em 1280x720.
8. Polimento visual final sem comprometer desempenho em PC fraco.

## Ajustes aplicados nesta consolidação

- Definida versão do projeto como `1.0.0` no `project.godot`.
- Adicionado indicador discreto `Party Pascal v1.0` no Menu Principal.
- Centralizada a identificação de versão em `GameManager`.
- Corrigida a grafia oficial de `Forca Tecnica` nos gerenciadores.
- Padronizados símbolos de transição da campanha com os ícones oficiais dos minigames.
- Adicionada identificação `Party Pascal v1.0` nos créditos finais.

## Ícones oficiais consolidados

- `$` Show do Bilhão
- `⚓` Batalha Naval
- `💼` Maleta Certa
- `🚨` Perseguição
- `🧩` Forca Tecnica
- `🛑` STOP
- `🚗` Desvio Lógico

## Critérios de aprovação

A V1.0 está pronta quando:

- todos os menus principais abrem sem erro;
- todos os botões de voltar retornam corretamente;
- campanha inicia, avança e finaliza;
- modo livre abre os 7 minigames jogáveis;
- Roleta de Risco aparece somente no fluxo de campanha;
- pontuação local salva e exibe resultados;
- configurações são salvas e aplicadas;
- layout se mantém legível em 1280x720;
- não há erro crítico no console do Godot.
