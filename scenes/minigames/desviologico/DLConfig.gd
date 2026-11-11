extends RefCounted
class_name DLConfig
## Constantes e regras de balanceamento do Desvio Logico (dados puros, sem logica).

const TOTAL_ROUNDS := 6
const DRIVE_DURATION_SECONDS := 35.0
const BACKGROUNDS := Paths.DL_BACKGROUNDS
const STAGE_NAMES := ["Amanhecer", "Manhã", "Tarde", "Entardecer", "Anoitecer", "Noite"]
const PLAYER_CAR_DISPLAY_NAME := "Bionix"
const CAR_SPRITES := Paths.DL_CAR_SPRITES
const NPC_SPRITES := Paths.DL_NPC_SPRITES
const PROP_POST := "post"
const PROP_POST_LEFT := "post_left"
const PROP_SIGN := "sign"
const PROP_CYCLIST := "cyclist"
const PROP_SPRITES := Paths.DL_PROP_SPRITES
const DEBUG_WATER_POINTS := false
# V0.13.12.7: qualidade padrão balanceada. Mantém o mar visível sem voltar
# ao excesso de ondas sobre o gramado/pista do background único.
# 0 = desligado, 1 = leve/visível, 2 = médio.
const WATER_EFFECT_QUALITY := 1
const WATER_REDRAW_INTERVAL := 0.0334  # na web o DesvioLogico usa WebLite.water_interval()
const WATER_USE_MASK_SHADER := false
const TUTORIAL_ARROW_SPRITES := Paths.DL_TUTORIAL_ARROWS
const ENGINE_ACCELERATION_SOUND := Paths.SFX_CAR_ACCELERATION
const ENGINE_LOOP_SOUND := Paths.SFX_CAR_ENGINE_LOOP
const ENGINE_ACCELERATION_SFX_KEY := "car_acceleration"
const ENGINE_LOOP_SFX_KEY := "car_engine_loop"
const ENGINE_ACCELERATION_LOOP_ID := "desvio_velox_acceleration"
const ENGINE_LOOP_ID := "desvio_velox_engine"
# V0.13.9.5: áudio limpo, sem filtros extras. Os volumes abaixo foram preservados
# da versão enviada pelo usuário após testes manuais de mixagem.
const DESVIO_MUSIC_VOLUME_DB := -1.0
const ENGINE_ACCELERATION_VOLUME_DB := -4.0
const ENGINE_LOOP_VOLUME_DB := -7.0
const VELOX_SFX_BUS := &"VeloxSFX"
const VELOX_SFX_BUS_SEND := &"Master"
const ENGINE_ACCELERATION_DURATION_BY_DIFFICULTY := {
	"facil": 5.0,
	"normal": 6.0,
	"dificil": 7.0
}
const CAR_DRIVE_START_Y_RATIO := 0.78
const CAR_DRIVE_END_Y_RATIO := 0.515
const CAR_APPROACH_Y_RATIO := 0.425
# V0.13.10.4: ajuste fino visual da parada final. O carro estava
# parando um pouco antes do encaixe ideal na bifurcação; este offset
# puxa o ponto de decisão alguns pixels para frente na perspectiva.
const CAR_DECISION_STOP_Y_OFFSET_RATIO := -0.026
# V0.13.8.4: o Bionix sobe na rota e precisa reduzir escala com a profundidade.
# V0.13.8.5: colisão usa o retângulo visual real do Velox durante toda a subida.
const PLAYER_CAR_NEAR_ROUTE_SCALE := 1.0
const PLAYER_CAR_FAR_ROUTE_SCALE := 0.70
# V0.13.8.7: zona segura final. O Bionix sobe, segura em uma altura jogável
# e só avança para mais perto da bifurcação quando os spawns novos já estão encerrando.
const CAR_ROUTE_SAFE_HOLD_Y_RATIO := 0.575
const CAR_ROUTE_SAFE_HOLD_DRIFT := 0.018
const CAR_ROUTE_HOLD_START_BY_DIFFICULTY := {
	"facil": 0.64,
	"normal": 0.70,
	"dificil": 0.75
}
const CAR_ROUTE_FINAL_ADVANCE_BY_DIFFICULTY := {
	"facil": 0.87,
	"normal": 0.90,
	"dificil": 0.92
}
# V0.13.8.8: depois que os spawns novos são bloqueados, o Bionix
# não deve dar um salto até a placa. Ele avança gradualmente para o centro
# da bifurcação durante a reta final e já chega praticamente parado na decisão.
const PLAYER_CAR_DECISION_SCALE := 0.66
const CAR_DECISION_CENTER_BLEND_START_BY_DIFFICULTY := {
	"facil": 0.88,
	"normal": 0.90,
	"dificil": 0.92
}
const NPC_FINAL_SPAWN_CUTOFF_PROGRESS := {
	"facil": 0.88,
	"normal": 0.90,
	"dificil": 0.92
}
const NPC_FINAL_SPAWN_CUTOFF_SECONDS := {
	"facil": 4.2,
	"normal": 3.5,
	"dificil": 2.8
}
# V0.13.8.6: colisão visual precisa acompanhar o Bionix em toda a subida.
# O grace antigo era longo demais: quando o Velox estava alto, o NPC passava pela
# área visual do carro ainda protegido e só podia causar dano quando já tinha descido.
const NPC_DAMAGE_GRACE_SECONDS := 0.18
const NPC_INITIAL_DAMAGE_GRACE_SECONDS := 0.48
const NPC_SWEPT_COLLISION_PADDING_Y := 10.0
const LANE_COUNT := 2
const LANE_LEFT := 0
const LANE_RIGHT := 1
const LANE_CENTER := -1
const PLAYABLE_LANES := [LANE_LEFT, LANE_RIGHT]
const MAX_ACTIVE_NPCS := 2
const INITIAL_TRAFFIC_COUNT := 1
# V0.13.13.2: distribuição fixa de tráfego por ondas com abertura guiada.
# A fase real abre sempre com 1 NPC na direita e depois 1 NPC na esquerda,
# ambos com distância segura. Depois disso entram ondas fixas por dificuldade.
const TRAFFIC_WAVE_SPAWN_GRACE_SECONDS := 0.24
const BIONIX_MAX_SPEED_KMH := {
	"facil": 160.0,
	"normal": 200.0,
	"dificil": 240.0
}
# V0.13.9.7: inclinação arcade leve do Bionix nas trocas de faixa.
const CAR_LANE_TILT_DEGREES := 5.0
const CAR_LANE_TILT_IN_SECONDS := 0.12
const CAR_LANE_TILT_RETURN_SECONDS := 0.22
const SPAWN_HORIZON_SAFETY_RATIO := {
	"facil": 0.205,
	"normal": 0.225,
	"dificil": 0.245
}
const SPAWN_HORIZON_SAFETY_OPPOSITE_RATIO := {
	"facil": 0.165,
	"normal": 0.185,
	"dificil": 0.205
}
const SIDE_PROP_COUNT := 9
const LEFT_POST_RETRY_DELAY := 1.85
const LEFT_POST_VISIBLE_MAX_T := 0.92
const POST_DEPTH_SLOTS := [0.10, 0.50, 0.86]
const STATE_TUTORIAL_INTRO := "tutorial_intro"
const STATE_TUTORIAL_LEFT := "tutorial_left"
const STATE_TUTORIAL_RIGHT := "tutorial_right"
const STATE_ACCELERATION := "acceleration"
const STATE_DRIVE := "drive"
const STATE_DECISION := "decision"
const STATE_TURN_EXIT := "turn_exit"
const STATE_FEEDBACK := "feedback"
const STATE_FINISH := "finish"
const STATE_FAILURE := "failure"
const DIFFICULTY_RULES := {
	"facil": {
		# V0.13.9.3: Fácil deixa de ser lento demais e passa a ficar só um nível abaixo do Normal.
		# Continua permitindo cerca de 8 colisões em carros antes de zerar a integridade.
		"collision_loss": 12.5,
		"wrong_loss": 6.0,
		"wrong_route_loss": 6.0,
		"world_speed": 540.0,
		"npc_speed": 255.0,
		"spawn_base": 2.58,
		"max_npcs": 3,
		"drive_base": 35.0
	},
	"normal": {
		# V0.13.5: Normal assume a sensação do antigo Difícil e ganha tráfego mais dinâmico.
		# Permite cerca de 6 colisões em carros.
		"collision_loss": 16.7,
		"wrong_loss": 8.0,
		"wrong_route_loss": 8.0,
		"world_speed": 620.0,
		"npc_speed": 292.0,
		# V0.13.13.4: Normal ganha um pouco mais de pressão,
		# mas mantém distâncias seguras de desvio.
		"spawn_base": 1.88,
		"max_npcs": 3,
		"drive_base": 35.0
	},
	"dificil": {
		# V0.13.13.3: Difícil recebe pressão maior por frequência/padrão,
		# mantendo distâncias seguras para desvio.
		# V0.13.5: Difícil vira tráfego intenso, com combos e pouca margem para pensar.
		# Permite no máximo cerca de 4 colisões em carros.
		"collision_loss": 25.0,
		"wrong_loss": 10.0,
		"wrong_route_loss": 10.0,
		"world_speed": 890.0,
		"npc_speed": 405.0,
		"spawn_base": 1.42,
		"max_npcs": 4,
		"drive_base": 35.0
	}
}
const SCORE_CHOICE_POINTS := {
	"facil": {"correct": 30, "wrong": -25},
	"normal": {"correct": 40, "wrong": -35},
	"dificil": {"correct": 50, "wrong": -45}
}
const SCORE_ROUTE_POINTS := {
	"facil": {"reached": 5, "failed": -20},
	"normal": {"reached": 10, "failed": -40},
	"dificil": {"reached": 15, "failed": -60}
}

# ---------------------------------------------------------------------------
# V0.14.1: 6 HORARIOS = 6 NIVEIS DE TRAFEGO (indice da rodada: 0 Amanhecer ... 5 Noite).
# Cada horario e mais movimentado que o anterior. A AREA SEGURA de desvio nao muda: os espacamentos
# minimos entre carros (DLTraffic._same_lane / _cross_lane / _opposite_critical) continuam valendo.
# O que sobe: frequencia de spawn, carros simultaneos, tamanho das ondas e pressa dentro da onda.
# Edite so esta tabela para rebalancear.
# ---------------------------------------------------------------------------
const TRAFFIC_LABELS := ["leve", "calmo", "moderado", "intenso", "pesado", "caótico"]
# Multiplica o intervalo entre ondas (menor = mais carros).
const TRAFFIC_SPAWN_MULT := [1.14, 1.00, 0.89, 0.79, 0.70, 0.62]
# Multiplica o intervalo minimo absoluto entre ondas.
const TRAFFIC_MIN_INTERVAL_MULT := [1.00, 0.97, 0.93, 0.89, 0.85, 0.80]
# Carros simultaneos extras (somados ao max_npcs da dificuldade, com teto TRAFFIC_MAX_NPCS_CAP).
const TRAFFIC_EXTRA_NPCS := [0, 0, 0, 1, 1, 1]
const TRAFFIC_MAX_NPCS_CAP := {"facil": 3, "normal": 4, "dificil": 5}
# Multiplica o atraso entre carros de uma mesma onda (menor = onda mais apertada, mas ainda escapavel).
const TRAFFIC_COMBO_DELAY_MULT := [1.00, 0.98, 0.95, 0.92, 0.89, 0.86]
# Mistura de tamanhos de onda (1 = carro solo, 2 = dupla, 3 = trio escalonado) por dificuldade e horario.
const TRAFFIC_COUNT_TEMPLATES := {
	"facil": [
		[1, 1, 1, 1, 1, 1, 1, 2],
		[1, 1, 1, 1, 2],
		[1, 1, 1, 2],
		[1, 1, 2, 2],
		[1, 2, 2, 2],
		[1, 2, 2, 2, 2]
	],
	"normal": [
		[1, 1, 1, 1, 1, 2, 2, 2],
		[1, 1, 1, 1, 2, 2, 2, 2, 2],
		[1, 1, 1, 2, 2, 2, 2, 2, 2],
		[1, 1, 1, 2, 2, 2, 2, 2, 2, 3],
		[1, 1, 2, 2, 2, 2, 2, 2, 3, 3],
		[1, 2, 2, 2, 2, 2, 3, 3, 3]
	],
	"dificil": [
		[1, 1, 1, 2, 2, 2, 2, 2, 3],
		[1, 1, 2, 2, 2, 2, 2, 2, 3],
		[1, 1, 2, 2, 2, 2, 2, 3, 3],
		[1, 1, 2, 2, 2, 2, 2, 3, 3, 3],
		[1, 2, 2, 2, 2, 3, 3, 3, 3],
		[2, 2, 2, 2, 3, 3, 3, 3, 3]
	]
}

static func traffic_index(round_index: int) -> int:
	return clampi(round_index, 0, TOTAL_ROUNDS - 1)

static func traffic_label(round_index: int) -> String:
	return str(TRAFFIC_LABELS[traffic_index(round_index)])
