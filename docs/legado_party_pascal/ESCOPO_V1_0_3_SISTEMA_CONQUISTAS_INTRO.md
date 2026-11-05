# Party Pascal V1.0.3 — Sistema de Conquistas e música da intro

## Objetivo

Adicionar a última camada geral de progressão do Party Pascal: um sistema local de conquistas, tela dedicada no menu principal, notificações de desbloqueio e integração da música de intro da jornada.

## Sons identificados e integrados

- `assets/sounds/efeitos/conquista.ogg`
  - Tocado ao desbloquear uma conquista.
- `assets/sounds/musica/intro_jornada.ogg`
  - Tocado em loop durante a cutscene inicial.

## Menu principal

Novo botão:

- `🏅 CONQUISTAS`

Ordem oficial:

1. Iniciar Jogo
2. Configurações
3. Pontuação
4. Conquistas
5. Sair

## Tela de conquistas

A tela segue o padrão visual dos menus refinados e usa uma grade responsiva:

- Desktop: 3 conquistas por linha.
- Telas médias: 2 conquistas por linha.
- Telas pequenas: 1 conquista por linha.

Conquistas bloqueadas aparecem em cinza com cadeado. Conquistas desbloqueadas aparecem coloridas, com borda dourada e ícone próprio.

## Ranks

- Sem rank: 0 conquistas
- Bronze: 1 a 4 conquistas
- Prata: 5 a 8 conquistas
- Ouro: 9 a 14 conquistas
- Platina: 15/15 conquistas

## Conquistas oficiais

1. Primeiro Passo — Complete seu primeiro minigame.
2. O Início da Jornada — Inicie o modo campanha pela primeira vez.
3. Jornada Completa — Complete o modo campanha pela primeira vez.
4. Superação Técnica — Supere um recorde anterior.
5. Uma Jornada Difícil — Complete o modo campanha na dificuldade Difícil.
6. Mente Milionária — Acerte todas as perguntas no Show do Bilhão.
7. Estratégia Naval — Complete Batalha Naval com no máximo 3 erros marítimos.
8. Decisão de Risco — Acerte todas as rodadas no minigame Maleta Certa.
9. Piloto Imbatível — Complete Desvio Lógico no modo Difícil sem sofrer colisão.
10. Boas Práticas São Essenciais! — Passe pela primeira vez por uma Roleta de Risco.
11. Perigo Iminente — Conclua o modo Perseguição sem danos.
12. Sistema Intacto! — Complete Forca Tecnica com integridade 100% no sistema.
13. Profissional Dedicado! — Complete todos os minigames do modo livre em todas as dificuldades.
14. Ultrapassando o Sistema! — Alcance 4.350 pontos no modo campanha Difícil.
15. Mestre do STOP! — Complete o minigame STOP acertando todas as rodadas.

## Salvamento

As conquistas são salvas localmente em:

`user://party_pascal_achievements.json`

Não há ranking online, conta de usuário ou backend.

## Notificação

Ao desbloquear uma conquista, o jogo exibe um card pequeno na tela com:

- título `Conquista desbloqueada!`
- nome da conquista
- descrição
- som `conquista.ogg`

## Fora do escopo

- Conquistas online/Steam/Game Pass.
- Ranking global.
- Novos minigames.
- Mudanças estruturais na campanha.
