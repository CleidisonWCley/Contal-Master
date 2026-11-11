# V0.14.1 — Otimização para Web (itch.io)

## Como aplicar
1. Copie o conteúdo do zip por cima do projeto (mantém as mesmas pastas). Abra no Godot 4.5: ele reimporta as imagens reduzidas sozinho.
2. Exportar > Web > **HTML > Custom HTML Shell** = `res://web/shell.html` (barra/ícone compactos). Mantenha **Threads desligado**.
3. Exporte de novo e suba o build. `build/web/index.html` do zip é só referência/teste rápido do loader.

## O que foi feito
| Pedido | Solução |
|---|---|
| Sair crasha | `get_tree().quit()` derruba o runtime WASM. Novo autoload `WebBridge`: na web o jogo salva, silencia, congela o motor e mostra uma tela de despedida em HTML ("Jogar novamente"). Fora da web continua `quit()`. |
| Respeitar o botão do navegador | Voltar do navegador: num minigame abre o **pause**; nas demais telas abre "Sair do ContalMaster?" (Voltar de novo = sair). Aba escondida/pagina fechando: pausa música e grava configurações. |
| Continuar / caixas da novel crasham | (1) O desfoque das novels era um shader de tela cheia (`hint_screen_texture`, 24 leituras/pixel) — na web agora vira uma película escura (custo zero). Para forçar o blur real: `?blur=1`. (2) Toque no celular gerava 2 avanços (toque + mouse emulado): `ClickGuard`. (3) Sprites de 13–16 MB cada na memória foram reduzidos (ver abaixo). |
| Música crashando / parar uma derruba as outras | `AudioManager` reescrito: 1 player de música, pool fixo de 8 efeitos, cache de sons, **sem criar bus em runtime** e sem chamadas ao `AudioServer` em loop (o motor do Desvio Lógico fazia isso todo frame). Watchdog religa a música se o navegador a interromper. O "perfil" de música do Desvio Lógico virou só um ajuste de volume. |
| Desvio Lógico só roda 2 fases | Mitigações: áudio leve, cache de texturas, só o fundo atual fica na memória, estrada/adereços redesenham em quadros alternados e água a 10 fps na web, limpeza completa ao sair. Use `?debug=1` (ver abaixo) para confirmar. |
| Tela de build ocupa tudo | `web/shell.html`: ícone 160 px e barra **da mesma largura** (branca com preenchimento roxo + %), centralizados, com fade ao terminar. |
| 6 fases com mais tráfego | `DLConfig.TRAFFIC_*`: Amanhecer→Noite = leve, calmo, moderado, intenso, pesado, caótico. Sobem: frequência de carros, carros simultâneos (+1 a partir do Entardecer, teto por dificuldade; no Fácil o teto é 3) e tamanho das ondas. **Os espaçamentos mínimos (área segura de desvio) não foram alterados.** O HUD mostra "Tráfego X". |
| Revisão das novels | Blur, clique duplo e memória dos sprites (acima). Layout não muda: os personagens são posicionados por metros/proporção, não por pixel. |

## Texturas reduzidas (RAM decodificada ~480 MB → ~196 MB nos arquivos afetados)
Sprites de personagens (máx. 1500 px de altura), insígnias (640 px), ícone (512 px), fundo do Show do Bilhão e Desvio Lógico Amanhecer (1920 px de largura). Mesma proporção, então nada se desloca.

## Diagnóstico e testes
- `?debug=1` na URL: no console (F12) aparece a cada 5 s e a cada troca de cena: memória, texturas, nós e FPS. Se ainda cair, me mande essas linhas.
- No editor, `-- --lite` ativa o perfil web; `-- --debug` ativa o log.

## Limites
Validei carregamento/execução em headless (Godot 4.5), mas **não rodei o build no navegador**: as causas acima são as que o código evidencia, não um crash reproduzido. Teste no itch e confirme.
