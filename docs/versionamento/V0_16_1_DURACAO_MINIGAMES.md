# V0.16.1 - Duração dos minigames (questões por rodada)

Motivo: jogadores acharam os minigames cansativos. Agora o jogador escolhe quantas questões cada minigame terá.

## O que mudou
- **Opções (iguais nos dois modos):** 2, 4, 8 ou 10 questões. **Padrão:** campanha = 2, modo livre = 4.
- **SettingsManager.gd**: novas chaves `campaign_questions_count` e `free_mode_questions_count` no `settings.json` (o sistema atual de save foi mantido: grava em JSON com atraso, bom para IndexedDB na web; o `ConfigFile` não foi necessário). Valores inválidos ou saves antigos voltam ao padrão.
  - `get_target_questions_count(is_campaign: bool) -> int`
  - `get_current_questions_count()` (usa o modo em andamento), `set_campaign_questions_count()`, `set_free_mode_questions_count()` (salvam na hora).
  - `question_score_scale(minigame_key)`: ver "Pontuação".
- **Nova tela** `scenes/menus/QuestionSettings.tscn/.gd` ("Duração dos minigames"): duas colunas (Campanha | Modo livre) com bolinhas numeradas. Escolher já salva. Ao tocar em **Voltar** abre as Configurações com o card **"Configurações salvas com sucesso"** (`scripts/ui/SavedToast.gd`).
- **Settings.gd**: botão "Duração dos minigames" que mostra os valores atuais e abre a tela nova.
- **Minigames ligados à configuração:** Show do Bilhão, Perseguição, Maleta Certa, STOP, Forca Técnica e Desvio Lógico. Tutoriais usam `{rounds}` com o valor real.
- **Fora da configuração (de propósito):** Roleta do Risco (um único giro) e Batalha Naval (quantidade de ameaças vem da dificuldade).

## Desvio Lógico
Os 6 horários (Amanhecer a Noite) continuam sendo o cenário, o tráfego e a música. Com N questões eles são distribuídos do Amanhecer à Noite (`DLConfig.stage_for_round`), então o tráfego sempre cresce. `current_round` = horário; `round_index` = número da questão.

## Pontuação
Antes tudo era calibrado para 6 questões (recordes, capítulos da firma, platina de 4350, finais por pontuação). Para não quebrar isso, os pontos por questão são multiplicados por `6 / N` nos 6 minigames por questão (DifficultyManager, Forca e Desvio). O **máximo** do minigame é o mesmo em qualquer duração. Pontos exibidos podem ficar maiores com poucas questões (ex.: 2 questões = 300 por acerto em vez de 100).

## Pontos de atenção
- O banco de dilemas (Desvio Lógico e Maleta Certa) tem 8 itens por dificuldade; com 10 questões o sorteio completa com outros níveis (já suportado por `pick_rounds`).
- Conquistas de "perfeito" ficam mais fáceis com 2 questões (decisão de design em aberto).
- Não testado no editor do Godot nesta entrega: abrir o projeto e conferir o console.
