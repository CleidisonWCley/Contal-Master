# V0.11.0 — Forca Técnica

## Objetivo

Adicionar o minigame **Forca Técnica** à Jornada SI do Party Pascal, com foco em vocabulário técnico amplo de Sistemas de Informação.

A Forca Técnica não usa o boneco clássico da forca. A identidade visual foi definida como **Integridade do Sistema / Sistema em Falha**.

## Decisões implementadas

- Minigame novo: `ForcaTecnica.tscn` + `ForcaTecnica.gd`.
- 6 rodadas por partida, seguindo o padrão dos demais minigames.
- 1 termo técnico oculto por rodada.
- Cada termo possui área e dica.
- O jogador escolhe letras pelo teclado físico ou pelos botões na tela.
- Letras corretas revelam o termo.
- Letras erradas reduzem a integridade do sistema.
- Cada rodada permite até 6 erros.
- Ao falhar uma palavra, a resposta é revelada e o jogo continua para a próxima rodada.
- Ao final das 6 rodadas, é exibido o resultado geral.
- A Forca Técnica entra na campanha antes do STOP.
- A Forca Técnica também aparece no modo livre.
- O background é estático e importado como imagem.
- Símbolos técnicos são animados por cima no Godot.
- Música própria `forca_tecnica.ogg` foi integrada ao `AudioManager`.

## Áreas do banco de palavras

- Engenharia de Software
- Estruturas de Dados
- Front-end
- Back-end
- Banco de Dados
- Redes
- Segurança
- IHC
- DevOps
- Qualidade de Software

## Pontuação

- Palavra acertada: 100 pontos.
- Bônus por erro restante: 10 pontos por tentativa preservada.
- Pontuação máxima por palavra: 160 pontos.
- Pontuação máxima do minigame: 960 pontos.
- Falha na palavra: 0 pontos naquela rodada.

## Estados de integridade

| Erros | Estado |
|---:|---|
| 0 | Sistema íntegro |
| 1 | Pequena instabilidade |
| 2 | Instabilidade detectada |
| 3 | Sistema em alerta |
| 4 | Sistema crítico |
| 5 | Falha iminente |
| 6 | Sistema em falha |

## Arquivos adicionados

- `scenes/minigames/ForcaTecnica.tscn`
- `scenes/minigames/ForcaTecnica.gd`
- `scenes/minigames/ForcaTecnica.gd.uid`
- `assets/background/background_forca.png.import`
- `assets/sounds/musica/forca_tecnica.ogg.import`
- `docs/ESCOPO_V0_11_0_FORCA_TECNICA.md`

## Arquivos modificados

- `scripts/GameManager.gd`
- `scripts/AudioManager.gd`
- `scenes/menus/MenuMinigames.gd`
- `scenes/menus/MenuMinigames.tscn`
- `scenes/cutscenes/StageTransition.gd`

## Critérios de aceite

- A campanha apresenta a Forca Técnica antes do STOP.
- O modo livre mostra o botão Forca Técnica.
- A música `forca_tecnica.ogg` toca ao iniciar o minigame.
- O background `background_forca.png` aparece corretamente.
- Os símbolos técnicos flutuam sobre o background quando as animações estão ativadas.
- O jogador consegue responder usando botões ou teclado.
- O minigame possui exatamente 6 rodadas.
- A integridade do sistema é reduzida a cada erro.
- O minigame não exibe boneco clássico.
- Ao final, o jogo mostra acertos, falhas, pontos do minigame e classificação.
- Após concluir, a campanha segue normalmente para o STOP.
