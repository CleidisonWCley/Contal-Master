extends RefCounted
class_name DLConfig
## Constantes e regras de balanceamento do Desvio Logico (dados puros, sem logica).

const TOTAL_ROUNDS := 6
## V0.16.2: percurso ate a bifurcacao mais curto (era 35 s) para o Desvio ficar mais agil mantendo os 6 desafios.
const DRIVE_DURATION_SECONDS := 22.0
const BACKGROUNDS := Paths.DL_BACKGROUNDS
const STAGE_NAMES := ["Amanhecer", "Manhã", "Tarde", "Entardecer", "Anoitecer", "Noite"]
const CAR_SPRITES := Paths.DL_CAR_SPRITES
const NPC_SPRITES := Paths.DL_NPC_SPRITES
# V0.16.11: postes removidos. TRAIL_* sao so as trilhas (markers PostLeft*/PostRight* da cena) usadas pelas listras do gramado.
const PROP_TRAIL_LEFT := "trail_left"
const PROP_TRAIL_RIGHT := "trail_right"
const PROP_SIGN := "sign"
const PROP_CYCLIST := "cyclist"
const PROP_SPRITES := Paths.DL_PROP_SPRITES
const DEBUG_WATER_POINTS := false
# V0.13.12.7: qualidade padrão balanceada. Mantém o mar visível sem voltar
# ao excesso de ondas sobre o gramado/pista do background único.
# 0 = desligado, 1 = leve/visível, 2 = médio.
const WATER_EFFECT_QUALITY := 1
const WATER_REDRAW_INTERVAL := 0.0334  # na web o DesvioLogico usa WebLite.water_interval()
const TUTORIAL_ARROW_SPRITES := Paths.DL_TUTORIAL_ARROWS
const ENGINE_ACCELERATION_SOUND := Paths.SFX_CAR_ACCELERATION
const ENGINE_LOOP_SOUND := Paths.SFX_CAR_ENGINE_LOOP
const ENGINE_ACCELERATION_LOOP_ID := "desvio_velox_acceleration"
const ENGINE_LOOP_ID := "desvio_velox_engine"
# V0.13.9.5: áudio limpo, sem filtros extras. Os volumes abaixo foram preservados
# da versão enviada pelo usuário após testes manuais de mixagem.
const DESVIO_MUSIC_VOLUME_DB := -1.0
const ENGINE_ACCELERATION_VOLUME_DB := -4.0
const ENGINE_LOOP_VOLUME_DB := -7.0
const ENGINE_ACCELERATION_DURATION_BY_DIFFICULTY := {
	"facil": 3.2,
	"normal": 3.8,
	"dificil": 4.4
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
const NPC_INITIAL_DAMAGE_GRACE_SECONDS := 0.48
const NPC_SWEPT_COLLISION_PADDING_Y := 10.0
const LANE_LEFT := 0
const LANE_RIGHT := 1
const LANE_CENTER := -1
const PLAYABLE_LANES := [LANE_LEFT, LANE_RIGHT]
const MAX_ACTIVE_NPCS := 2
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
# V0.16.11: o fundo e 100% ESTATICO (sem zoom, sem ondulacao, sem faixa do horizonte crescendo) e nao ha mais postes.
# Referencia de perspectiva das listras decorativas do gramado: linha de fuga e distancia calcada -> centro do gramado,
# em px por px de profundidade abaixo de GRASS_VANISH_Y.
const GRASS_VANISH_Y := 190.0
const GRASS_LINES_OFFSET_PER_DEPTH := 0.135
# V0.16.9.6: luzes dos carros por horario (indice = current_round). Lanternas vermelhas atras de TODOS os carros (NPCs e Bionix)
# a partir do Entardecer; farol do Bionix (cone de luz a frente) so nos horarios noturnos.
const CAR_TAILLIGHT_BY_ROUND := [0.0, 0.0, 0.0, 0.65, 0.90, 1.0]
# V0.16.11: farol removido. No lugar, uma AUREOLA de luz branca suave a frente do Bionix (so horarios noturnos), sem feixes nem pontos.
# ============================================================================
# LUZ A FRENTE DO BIONIX (aureola) - e AQUI que voce ajusta nos testes. So aparece nos horarios noturnos.
# Tamanhos em fracao do sprite do carro (largura = 1.0 / altura = 1.0). Opacidades de 0.0 (invisivel) a 1.0.
# ============================================================================
# 1) INTENSIDADE POR HORARIO (multiplica TUDO abaixo). Ordem: Amanhecer, Manha, Tarde, Entardecer, Anoitecer, Noite.
const CAR_HEADLIGHT_BY_ROUND := [0.0, 0.0, 0.0, 0.0, 0.70, 1.0]
# 2) CONE de luz (abre do capo para frente, some na ponta)
const AURA_CONE_LENGTH := 0.62          # comprimento do cone. Maior = luz chega mais longe
const AURA_CONE_NEAR_HALF_W := 0.26     # meia-largura junto ao carro
const AURA_CONE_FAR_HALF_W := 0.48      # meia-largura na ponta (maior = cone mais aberto)
const AURA_CONE_ALPHA := 0.20           # brilho do cone junto ao carro. 0.10 bem sutil | 0.30 forte
const AURA_CONE_START_Y := 0.22         # onde o cone nasce, a partir do topo do sprite (maior = nasce mais "dentro" do carro)
# 3) POCA de luz no asfalto (so aparelho forte; aparelho fraco desenha so o cone)
const AURA_POOL_ALPHA := 0.16           # brilho da poca. 0.0 desliga
const AURA_POOL_WIDTH := 0.95           # largura da poca
const AURA_POOL_HEIGHT := 0.34          # altura da poca
const AURA_POOL_Y := -0.36              # posicao da poca (negativo = mais a frente do carro)
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

## V0.16.1: horario (0..5) de uma questao quando o minigame tem 2, 4, 8 ou 10 questoes: a primeira e sempre o
## Amanhecer, a ultima a Noite, e o trafego nunca diminui. Com 6 questoes devolve a propria posicao.
static func stage_for_round(question_index: int, total_questions: int) -> int:
	if total_questions <= 1:
		return 0
	var ratio: float = float(clampi(question_index, 0, total_questions - 1)) / float(total_questions - 1)
	return clampi(int(round(ratio * float(TOTAL_ROUNDS - 1))), 0, TOTAL_ROUNDS - 1)

static func traffic_index(round_index: int) -> int:
	return clampi(round_index, 0, TOTAL_ROUNDS - 1)

static func traffic_label(round_index: int) -> String:
	return str(TRAFFIC_LABELS[traffic_index(round_index)])

# V0.14.2: cor das bolinhas de trafego (azul -> amarelo -> vermelho).
# Horarios 1-2 = azul, 3-4 = amarelo, 5-6 = vermelho.
static func traffic_dot_color(round_index: int) -> Color:
	var i: int = traffic_index(round_index)
	if i <= 1:
		return Color(0.27, 0.62, 1.0)
	if i <= 3:
		return Color(1.0, 0.82, 0.20)
	return Color(1.0, 0.27, 0.24)

# V0.14.2: ritmo da musica por horario. Sobe de forma gradual e perceptivel (1.00 -> 1.12), sem acelerar demais.
const MUSIC_TEMPO_STEP := 0.024
static func music_tempo_for_round(round_index: int) -> float:
	return 1.0 + MUSIC_TEMPO_STEP * float(traffic_index(round_index))
