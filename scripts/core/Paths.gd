extends RefCounted
class_name Paths
## Fonte unica de caminhos res:// e user:// do projeto.
## Mudou uma pasta ou renomeou um arquivo? Ajuste SOMENTE aqui.
## Uso: Paths.BG_STOP, Paths.SCENE_MAIN_MENU, Paths.DL_BACKGROUNDS ...

# ---- CENAS -------------------------------------------------------
const SCENE_MAIN_MENU := "res://scenes/menus/MainMenu.tscn"
const SCENE_MODE_SELECT := "res://scenes/menus/ModeSelect.tscn"
const SCENE_SETTINGS := "res://scenes/menus/Settings.tscn"
const SCENE_SCORE := "res://scenes/menus/ScoreMenu.tscn"
const SCENE_ACHIEVEMENTS := "res://scenes/menus/AchievementsMenu.tscn"
const SCENE_FREE_MENU := "res://scenes/menus/MenuMinigames.tscn"
const SCENE_CUTSCENE_INTRO := "res://scenes/cutscenes/CutsceneIntro.tscn"
const SCENE_STAGE_TRANSITION := "res://scenes/cutscenes/StageTransition.tscn"
const SCENE_CUTSCENE_FINAL := "res://scenes/cutscenes/CutsceneFinal.tscn"
const SCENE_SHOW_DO_BILHAO := "res://scenes/minigames/showdobilhao/ShowDoBilhao.tscn"
const SCENE_BATALHA_NAVAL := "res://scenes/minigames/batalhanaval/BatalhaNaval.tscn"
const SCENE_MALETA_CERTA := "res://scenes/minigames/maletacerta/MaletaCerta.tscn"
const SCENE_ROLETA_RISCO := "res://scenes/minigames/roletarisco/RoletaRisco.tscn"
const SCENE_PERSEGUICAO := "res://scenes/minigames/perseguicao/Perseguicao.tscn"
const SCENE_FORCA_TECNICA := "res://scenes/minigames/forca/ForcaTecnica.tscn"
const SCENE_STOP := "res://scenes/minigames/stop/Stop.tscn"
const SCENE_DESVIO_LOGICO := "res://scenes/minigames/desviologico/DesvioLogico.tscn"

# ---- BACKGROUNDS - menus e cutscenes -----------------------------
const BG_MENU_MAIN := "res://assets/background/menus/menu_inicial/main_clean.png"
const BG_CUTSCENE_INTRO := "res://assets/background/cutcines/curtcine_intro.png"
const BG_CUTSCENE_FINAL := "res://assets/background/cutcines/curtcine_final.png"

# ---- BACKGROUNDS - minigames -------------------------------------
const BG_BATALHA_NAVAL := "res://assets/background/minegames/batalhanaval/background_batalha_naval.png"
const BG_FORCA := "res://assets/background/minegames/forca/background_forca.png"
const BG_MALETA_CERTA := "res://assets/background/minegames/maletacerta/background_maleta_certa.png"
const BG_PERSEGUICAO := "res://assets/background/minegames/perseguicao/background_perseguicao.png"
const BG_ROLETA_RISCO := "res://assets/background/minegames/roletarisco/background_roleta_risco.png"
const BG_SHOW_DO_BILHAO := "res://assets/background/minegames/showbilhao/background_show_do_bilhao.jpg"
const BG_STOP := "res://assets/background/minegames/stop/background_stop.png"
const BG_DL_AMANHECER := "res://assets/background/minegames/desviologico/background_dl_amanhecer.png"
const BG_DL_MANHA := "res://assets/background/minegames/desviologico/background_dl_manha.png"
const BG_DL_TARDE := "res://assets/background/minegames/desviologico/background_dl_tarde.png"
const BG_DL_ENTARDECER := "res://assets/background/minegames/desviologico/background_dl_entardecer.png"
const BG_DL_ANOITECER := "res://assets/background/minegames/desviologico/background_dl_anoitecer.png"
const BG_DL_NOITE := "res://assets/background/minegames/desviologico/background_dl_noite.png"

# ---- ICONES ------------------------------------------------------
const ICON_LOCK := "res://assets/icons/cadeado.png"
const ICON_TROPHY := "res://assets/icons/trofeu.png"
const ICON_PLAY := "res://assets/icons/play.png"
const ICON_MONEY := "res://assets/icons/money.png"
const ICON_NAVAL := "res://assets/icons/naval.png"
const ICON_SUITCASE := "res://assets/icons/mala.png"
const ICON_DANGER := "res://assets/icons/perigo.png"
const ICON_STOP := "res://assets/icons/stop.png"

const ICONS_UI_DIR := "res://assets/icons/ui/"

# ---- ICONES MONOCROMATICOS (brancos, tingiveis via cor do tema do botao) -----
const ICON_UI_PLAY := "res://assets/icons/ui/icon_play.png"
const ICON_UI_SETTINGS := "res://assets/icons/ui/icon_settings.png"
const ICON_UI_EXIT := "res://assets/icons/ui/icon_exit.png"
const ICON_UI_TROPHY := "res://assets/icons/ui/icon_trophy.png"
const ICON_UI_STAR := "res://assets/icons/ui/icon_star.png"

# ---- ICONES DE CONQUISTAS ----------------------------------------
const ACH_PRIMEIRO_PASSO := "res://assets/icons/achievements/primeiro_passo.png"
const ACH_INICIO_JORNADA := "res://assets/icons/achievements/inicio_jornada.png"
const ACH_JORNADA_COMPLETA := "res://assets/icons/achievements/jornada_completa.png"
const ACH_SUPERACAO_TECNICA := "res://assets/icons/achievements/superacao_tecnica.png"
const ACH_JORNADA_DIFICIL := "res://assets/icons/achievements/jornada_dificil.png"
const ACH_MENTE_MILIONARIA := "res://assets/icons/achievements/mente_milionaria.png"
const ACH_ESTRATEGIA_NAVAL := "res://assets/icons/achievements/estrategia_naval.png"
const ACH_DECISAO_RISCO := "res://assets/icons/achievements/decisao_risco.png"
const ACH_PILOTO_IMBATIVEL := "res://assets/icons/achievements/piloto_imbativel.png"
const ACH_BOAS_PRATICAS := "res://assets/icons/achievements/boas_praticas.png"
const ACH_PERIGO_IMINENTE := "res://assets/icons/achievements/perigo_iminente.png"
const ACH_SISTEMA_INTACTO := "res://assets/icons/achievements/sistema_intacto.png"
const ACH_PROFISSIONAL_DEDICADO := "res://assets/icons/achievements/profissional_dedicado.png"
const ACH_ULTRAPASSANDO_SISTEMA := "res://assets/icons/achievements/ultrapassando_sistema.png"
const ACH_MESTRE_STOP := "res://assets/icons/achievements/mestre_stop.png"

# ---- INSIGNIAS ---------------------------------------------------
const INSIGNIA_BRONZE := "res://assets/insignias/bronze_conquist.png"
const INSIGNIA_SILVER := "res://assets/insignias/prata_conquist.png"
const INSIGNIA_GOLD := "res://assets/insignias/ouro_conquist.png"
const INSIGNIA_PLATINUM := "res://assets/insignias/platina_conquist.png"

# ---- SPRITES -----------------------------------------------------
# Mascote Jales (substituiu o antigo pascal.png). Cutscenes usam so a versao "receptivo" (recortada, fundo transparente).
const SPRITE_JALES_RECEPTIVO := "res://assets/sprites/jales-receptivo-transparente.png"

# ---- SPRITES - Desvio Logico -------------------------------------
const DL_CAR_STRAIGHT := "res://assets/sprites/desvio_logico/carro_desvio_reto.png"
const DL_CAR_LEFT := "res://assets/sprites/desvio_logico/carro_desvio_esquerda.png"
const DL_CAR_RIGHT := "res://assets/sprites/desvio_logico/carro_desvio_direita.png"
const DL_CAR_SIDE_LEFT := "res://assets/sprites/desvio_logico/carro_desvio_lateral_esquerda.png"
const DL_CAR_SIDE_RIGHT := "res://assets/sprites/desvio_logico/carro_desvio_lateral_direita.png"
const DL_NPC_RED := "res://assets/sprites/desvio_logico/carro_npc_vermelho.png"
const DL_NPC_YELLOW := "res://assets/sprites/desvio_logico/carro_npc_amarelo.png"
const DL_NPC_GREEN := "res://assets/sprites/desvio_logico/carro_npc_verde.png"
const DL_NPC_ORANGE := "res://assets/sprites/desvio_logico/carro_npc_laranja_queimado.png"
const DL_NPC_SILVER := "res://assets/sprites/desvio_logico/carro_npc_cinza_prata.png"
const DL_PROP_POST := "res://assets/sprites/desvio_logico/props/poste_lateral.png"
const DL_PROP_POST_LEFT := "res://assets/sprites/desvio_logico/props/poste_lateral_esquerdo.png"
const DL_PROP_SIGN := "res://assets/sprites/desvio_logico/props/placa_bifurcacao_y.png"
const DL_PROP_CYCLIST := "res://assets/sprites/desvio_logico/props/ciclista_lateral.png"
const DL_TUTORIAL_ARROW_LEFT := "res://assets/sprites/desvio_logico/tutorial_seta_esquerda.png"
const DL_TUTORIAL_ARROW_RIGHT := "res://assets/sprites/desvio_logico/tutorial_seta_direita.png"

# ---- MUSICAS -----------------------------------------------------
const MUSIC_MENU := "res://assets/sounds/musica/music_menu.ogg"
const MUSIC_LOOP_START := "res://assets/sounds/musica/loop_start.ogg"
const MUSIC_INTRO_JORNADA := "res://assets/sounds/musica/intro_jornada.ogg"
const MUSIC_SHOW_DO_BILHAO := "res://assets/sounds/musica/musica_show_do_bilhao.ogg"
const MUSIC_BATALHA_NAVAL := "res://assets/sounds/musica/musica_batalha_naval.ogg"
const MUSIC_MALETA_CERTA := "res://assets/sounds/musica/musica_maleta_certa.ogg"
const MUSIC_RODADA_BONUS := "res://assets/sounds/musica/musica_rodada_bonus.ogg"
const MUSIC_PERSEGUICAO := "res://assets/sounds/musica/musica_perseguicao.ogg"
const MUSIC_FORCA_TECNICA := "res://assets/sounds/musica/forca_tecnica.ogg"
const MUSIC_STOP := "res://assets/sounds/musica/musica_stop.ogg"
const MUSIC_DESVIO_LOGICO := "res://assets/sounds/musica/desvio_logico.ogg"
const MUSIC_FINAL := "res://assets/sounds/musica/musica_final.ogg"

# ---- EFEITOS SONOROS ---------------------------------------------
const SFX_CLICK := "res://assets/sounds/efeitos/clique.ogg"
const SFX_CORRECT := "res://assets/sounds/efeitos/correto.wav"
const SFX_WRONG := "res://assets/sounds/efeitos/errado.wav"
const SFX_EXPLOSION := "res://assets/sounds/efeitos/explosion.wav"
const SFX_ROULETTE := "res://assets/sounds/efeitos/roleta.wav"
const SFX_ACHIEVEMENT := "res://assets/sounds/efeitos/conquista.ogg"
const SFX_CAR_ACCELERATION := "res://assets/sounds/efeitos/car_acceleration.ogg"
const SFX_CAR_ENGINE_LOOP := "res://assets/sounds/efeitos/car_engine_loop.ogg"

# ---- SAVES (user://) ----------------------------------------
const SAVE_SCORES := "user://contal_master_scores.json"
const SAVE_ACHIEVEMENTS := "user://contal_master_achievements.json"
# Nomes ANTIGOS: usados somente por migrate_legacy_saves() para nao perder progresso de testadores.
# Quando ninguem mais tiver save antigo, apague estas 2 constantes e a funcao abaixo.
const LEGACY_SAVE_SCORES := "user://party_pascal_scores.json"
const LEGACY_SAVE_ACHIEVEMENTS := "user://party_pascal_achievements.json"
const SAVE_SETTINGS := "user://settings.json"

# ---- COLECOES (agrupam constantes acima) ------------------------------
const DL_BACKGROUNDS := [BG_DL_AMANHECER, BG_DL_MANHA, BG_DL_TARDE, BG_DL_ENTARDECER, BG_DL_ANOITECER, BG_DL_NOITE]
const DL_CAR_SPRITES := {"reto": DL_CAR_STRAIGHT, "esquerda": DL_CAR_LEFT, "direita": DL_CAR_RIGHT, "lateral_esquerda": DL_CAR_SIDE_LEFT, "lateral_direita": DL_CAR_SIDE_RIGHT}
const DL_NPC_SPRITES := [DL_NPC_RED, DL_NPC_YELLOW, DL_NPC_GREEN, DL_NPC_ORANGE, DL_NPC_SILVER]
const DL_PROP_SPRITES := {"post": DL_PROP_POST, "post_left": DL_PROP_POST_LEFT, "sign": DL_PROP_SIGN, "cyclist": DL_PROP_CYCLIST}
const DL_TUTORIAL_ARROWS := {"left": DL_TUTORIAL_ARROW_LEFT, "right": DL_TUTORIAL_ARROW_RIGHT}

# ---- BANCO DE PERGUNTAS (auditoria / NBC PA 11) -------------------
const QUESTION_BANK := "res://scripts/core/question_bank.gd"
const DATA_QUIZ_AUDITORIA := "res://scripts/core/data/quiz_auditoria.json"
const DATA_DILEMAS := "res://scripts/core/data/dilemas.json"
const DATA_DICIONARIO := "res://scripts/core/data/dicionario.json"
const DATA_MATRIZ_RISCOS := "res://scripts/core/data/matriz_riscos.json"


## Copia o save antigo para o nome novo (uma unica vez). Seguro de chamar varias vezes.
static func migrate_legacy_saves() -> void:
	_migrate_save(LEGACY_SAVE_SCORES, SAVE_SCORES)
	_migrate_save(LEGACY_SAVE_ACHIEVEMENTS, SAVE_ACHIEVEMENTS)


static func _migrate_save(old_path: String, new_path: String) -> void:
	if FileAccess.file_exists(new_path) or not FileAccess.file_exists(old_path):
		return
	var text: String = FileAccess.get_file_as_string(old_path)
	var out: FileAccess = FileAccess.open(new_path, FileAccess.WRITE)
	if out == null:
		push_warning("Nao foi possivel migrar o save antigo para %s" % new_path)
		return
	out.store_string(text)
	out.close()
	DirAccess.remove_absolute(old_path)
