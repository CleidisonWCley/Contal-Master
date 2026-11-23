extends RefCounted
class_name DLConfig
## Constantes e regras de balanceamento do Desvio Logico (dados puros, sem logica).

const TOTAL_ROUNDS := 6
## percurso ate a bifurcacao 
const DRIVE_DURATION_SECONDS := 22.0
const BACKGROUNDS := Paths.DL_BACKGROUNDS
const STAGE_NAMES := ["Amanhecer", "Manhã", "Tarde", "Entardecer", "Anoitecer", "Noite"]
const CAR_SPRITES := Paths.DL_CAR_SPRITES
const NPC_SPRITES := Paths.DL_NPC_SPRITES
const PROP_TRAIL_LEFT := "trail_left"
const PROP_TRAIL_RIGHT := "trail_right"
const PROP_SIGN := "sign"
const PROP_CYCLIST := "cyclist"
const PROP_SPRITES := Paths.DL_PROP_SPRITES
const WATER_EFFECT_QUALITY := 1          # 0 desliga o efeito de agua; >0 liga (shader dl_water.gdshader)
# V0.16.12: agua por shader. Valores em pixels do palco (1280x720); a borda grama/agua e uma reta igual nos 6 fundos.
const WATER_WAVE_AMPLITUDE := 1.4        # deslocamento maximo das ondas (px) perto da camera. 1.0 sutil | 3.0 forte
const WATER_WAVE_SPEED := 1.0            # velocidade das ondas
const WATER_SPARKLE := 0.26              # brilhos so onde o fundo ja e claro (reflexo do sol/lua/luzes). 0 desliga
const WATER_TOP_Y := 244.0               # linha do horizonte do mar
const WATER_BOTTOM_Y := 585.0            # abaixo disso o mar some atras da grama
const WATER_EDGE_X0 := 550.0             # x da borda da grama no horizonte (lado esquerdo; o direito e o espelho)
const WATER_EDGE_SLOPE := 1.68           # quanto a borda vai para a esquerda a cada pixel descido
const WATER_EDGE_MARGIN := 9.0           # folga entre a grama e o efeito (o efeito nunca invade a mureta)
const TUTORIAL_ARROW_SPRITES := Paths.DL_TUTORIAL_ARROWS
const ENGINE_ACCELERATION_SOUND := Paths.SFX_CAR_ACCELERATION
const ENGINE_LOOP_SOUND := Paths.SFX_CAR_ENGINE_LOOP
const ENGINE_ACCELERATION_LOOP_ID := "desvio_velox_acceleration"
const ENGINE_LOOP_ID := "desvio_velox_engine"
const DESVIO_MUSIC_VOLUME_DB := -1.0
const ENGINE_ACCELERATION_VOLUME_DB := -4.0
const ENGINE_LOOP_VOLUME_DB := -7.0
const ENGINE_ACCELERATION_DURATION_BY_DIFFICULTY := {
	"facil": 3.2,
	"normal": 3.8,
	"dificil": 4.4
}
const CAR_DRIVE_START_Y_RATIO := 0.78
const CAR_APPROACH_Y_RATIO := 0.425
const CAR_DECISION_STOP_Y_OFFSET_RATIO := -0.026
# V0.16.11.1: onde o Bionix PARA no meio da pista (fracao da altura). Antes parava em ~0.399, colado na placa (y~0.367).
# Agora para mais embaixo: chega nesse ponto EXATAMENTE em DRIVE_DURATION_SECONDS (18 s), junto com o cenario zerando a velocidade.
const CAR_DECISION_STOP_Y_RATIO := 0.425   # V0.16.11.1b: ponto final, mais perto da placa (antes 0.48)
const CAR_PRE_STOP_Y_RATIO := 0.500        # onde o carro esta quando comeca a aproximacao final da placa
const CAR_SIGN_APPROACH_SECONDS := 2.0     # aproximacao final da placa: so nos ultimos 2 s do percurso
# V0.16.11.1f: sequencia final = (1) Bionix vai para o MEIO da pista, (2) chega perto da placa, (3) PARA e o velocimetro zera,
# (4) uma pausa curta com o carro parado, (5) so entao aparecem as rotas A/B.
const CENTER_BLEND_LEAD_SECONDS := 2.6     # a centralizacao comeca 2,6 s antes do fim...
const CENTER_DONE_BEFORE_END_SECONDS := 0.6  # ...e termina 0,6 s antes do fim (o carro chega reto na placa)
const DECISION_STOP_HOLD_SECONDS := 0.7    # carro parado + velocimetro 0 antes da pergunta aparecer
#o Bionix sobe na rota e precisa reduzir escala com a profundidade.
# colisão usa o retângulo visual real do Velox durante toda a subida.
const PLAYER_CAR_NEAR_ROUTE_SCALE := 1.0
# V0.16.14: o Bionix encolhe de forma continua ate a parada (antes parava de encolher em 0.70 na metade da subida e dava pulo para 0.66).
# 1.0 = tamanho do inicio; 0.50 = tamanho ao chegar na bifurcacao (coerente com o tamanho dos NPCs na mesma altura). 0.60 encolhe menos, 0.45 mais.
const PLAYER_CAR_FAR_ROUTE_SCALE := 0.50
# zona segura final. O Bionix sobe, segura em uma altura jogável
# só avança para mais perto da bifurcação quando os spawns novos já estão encerrando.
const CAR_ROUTE_SAFE_HOLD_Y_RATIO := 0.52   # V0.16.12: altura que o Bionix alcanca na subida (era 0.575, ~metade da pista). 0.575 antigo | 0.50 bem perto da bifurcacao
const CAR_ROUTE_SAFE_HOLD_DRIFT := 0.025    # continua subindo devagar ate o inicio da freada final (era 0.018)
# V0.16.12: progresso (0..1 do percurso) em que o Bionix chega na altura acima. Antes 0.64/0.70/0.75: a subida era lenta e ele
# ficava parado na metade da pista. Agora sobe mais rapido e segue avancando devagar ate a freada final.
const CAR_ROUTE_HOLD_START_BY_DIFFICULTY := {
	"facil": 0.46,
	"normal": 0.52,
	"dificil": 0.58
}
const CAR_ROUTE_FINAL_ADVANCE_BY_DIFFICULTY := {
	"facil": 0.87,
	"normal": 0.90,
	"dificil": 0.92
}

const PLAYER_CAR_DECISION_SCALE := 0.50   # igual ao FAR: sem pulo de tamanho na parada
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
# colisão visual precisa acompanhar o Bionix em toda a subida.
# O grace antigo era longo demais: quando o Velox estava alto, o NPC passava pela
# área visual do carro ainda protegido e só podia causar dano quando já tinha descido.
const NPC_INITIAL_DAMAGE_GRACE_SECONDS := 0.48
const NPC_SWEPT_COLLISION_PADDING_Y := 10.0
const LANE_LEFT := 0
const LANE_RIGHT := 1
const LANE_CENTER := -1
const PLAYABLE_LANES := [LANE_LEFT, LANE_RIGHT]
const MAX_ACTIVE_NPCS := 2
# distribuição fixa de tráfego por ondas com abertura guiada.
# A fase real abre sempre com 1 NPC na direita e depois 1 NPC na esquerda,
# ambos com distância segura. Depois disso entram ondas fixas por dificuldade.
const TRAFFIC_WAVE_SPAWN_GRACE_SECONDS := 0.24
const BIONIX_MAX_SPEED_KMH := {
	"facil": 160.0,
	"normal": 200.0,
	"dificil": 240.0
}
# inclinação arcade leve do Bionix nas trocas de faixa.
const CAR_LANE_TILT_DEGREES := 5.0
const CAR_LANE_TILT_IN_SECONDS := 0.12
const CAR_LANE_TILT_RETURN_SECONDS := 0.22
# o fundo e 100% ESTATICO (sem zoom, sem ondulacao, sem faixa do horizonte crescendo) e nao ha mais postes.
# Referencia de perspectiva das listras decorativas do gramado: linha de fuga e distancia calcada -> centro do gramado,
# em px por px de profundidade abaixo de GRASS_VANISH_Y.
const GRASS_VANISH_Y := 190.0
const GRASS_LINES_OFFSET_PER_DEPTH := 0.135
# ---------------------------------------------------------------------------
# V0.16.11.1: POSTES FIXOS (desenhados por script, sobre a CALCADA). Sao 6: 3 em cada lado, parados (nao nascem, nao se movem).
# Posicao: markers PostLeft*/PostRight* (Start = perto da placa, Mid = meio, End = canto inferior). O poste do canto inferior e o unico que o
# Bionix "ultrapassa" (fica perto de onde o carro comeca). Altura em px (base 1280x720), do chao ate o topo do braco.
# ---------------------------------------------------------------------------
const POLE_HEIGHT_FAR := 46.0           # V0.16.11.1b: postes ~40% menores (antes 80 / 210 / 390)
const POLE_HEIGHT_MID := 120.0
const POLE_ARM_RATIO := 0.20            # comprimento do braco em fracao da altura do poste (aponta para a pista)
# Bolinha de luz no alto do poste por horario (Amanhecer, Manha, Tarde, Entardecer, Anoitecer, Noite). 0 = apagada.
const POLE_LIGHT_BY_ROUND := [0.0, 0.0, 0.0, 0.70, 0.90, 1.0]
# luzes dos carros por horario (indice = current_round). Lanternas vermelhas atras de TODOS os carros (NPCs e Bionix)
# a partir do Entardecer; farol do Bionix (cone de luz a frente) so nos horarios noturnos.
const CAR_TAILLIGHT_BY_ROUND := [0.0, 0.0, 0.0, 0.65, 0.90, 1.0]

# ajustes do farol de LUZ So aparece nos horarios noturnos.
# Tamanhos em fracao do sprite do carro (largura = 1.0 / altura = 1.0). Opacidades de 0.0 (invisivel) a 1.0.
# 1) INTENSIDADE POR HORARIO (multiplica TUDO abaixo). Ordem: Amanhecer, Manha, Tarde, Entardecer, Anoitecer, Noite.
const CAR_HEADLIGHT_BY_ROUND := [0.0, 0.0, 0.0, 0.0, 0.50, 1.0]
# 2) CONE de luz (abre do capo para frente, some na ponta)
const AURA_CONE_LENGTH := 0.24          # V0.16.12: cone mais curto (era 0.42); a largura (NEAR/FAR_HALF_W) ficou igual
const AURA_CONE_NEAR_HALF_W := 0.26     # meia-largura junto ao carro (era 0.26)
const AURA_CONE_FAR_HALF_W := 0.48      # meia-largura na ponta (era 0.48)
const AURA_CONE_ALPHA := 0.15           # brilho do cone junto ao carro. 0.10 bem sutil | 0.30 forte
const AURA_CONE_START_Y := 0.22         # onde o cone nasce, a partir do topo do sprite (maior = nasce mais "dentro" do carro)
# 3) POCA de luz no asfalto (so aparelho forte; aparelho fraco desenha so o cone)
const AURA_POOL_ALPHA := 0.09           # brilho da poca. 0.0 desliga
const AURA_POOL_WIDTH := 0.75           # largura da poca (era 0.75)
const AURA_POOL_HEIGHT := 0.12          # altura da poca (era 0.12)
const AURA_POOL_Y := -0.16             # V0.16.12: poca acompanha o fim do cone mais curto (era -0.36). Negativo = mais a frente do carro
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
# Carros simultaneos extras (somados ao max_npcs da dificuldade, com teto TRAFFIC_MAX_NPCS_CAP).
const TRAFFIC_EXTRA_NPCS := [0, 0, 0, 1, 1, 1]
const TRAFFIC_MAX_NPCS_CAP := {"facil": 3, "normal": 4, "dificil": 5}
# Multiplica o atraso entre carros de uma mesma onda (menor = onda mais apertada, mas ainda escapavel).
const TRAFFIC_COMBO_DELAY_MULT := [1.00, 0.98, 0.95, 0.92, 0.89, 0.86]
# V0.16.13 - DIRETOR DINAMICO DE TRAFEGO (substitui as ondas fixas e a sacola de padroes).
# Intervalo medio entre ondas (s) por dificuldade, multiplicado por horario (Amanhecer ... Noite) e sorteado entre 0.78x e 1.30x.
const DIRECTOR_INTERVAL := {"facil": 1.50, "normal": 1.38, "dificil": 1.10}
const DIRECTOR_INTERVAL_ROUND_MULT := [1.00, 0.95, 0.90, 0.86, 0.82, 0.78]
# Chance de a onda ter 2 carros (senao 1). Nunca 3. Sobe a cada horario; multiplicada por dificuldade.
const DIRECTOR_PAIR_CHANCE_BY_ROUND := [0.18, 0.26, 0.34, 0.42, 0.48, 0.55]
const DIRECTOR_PAIR_DIFFICULTY_MULT := {"facil": 0.90, "normal": 1.00, "dificil": 1.15}
const DIRECTOR_PAIR_OPPOSITE_CHANCE := 0.40   # 2o carro da dupla na faixa oposta (senao na mesma, em sequencia)
# Maximo de segundos que uma faixa pode ficar sem receber carro (garante o que desviar dos dois lados).
const DIRECTOR_MAX_LANE_GAP := {"facil": 5.4, "normal": 4.2, "dificil": 3.6}
# Pesos do sorteio de faixa: faixa ociosa, faixa do jogador (+ quanto tempo ele esta parado nela) e anti-repeticao.
# A faixa sorteada para a onda espera ate este tempo (bloqueada por espacamento/folga) antes de ceder o carro a outra faixa.
const DIRECTOR_FORCED_PATIENCE_SECONDS := 2.2
const DIRECTOR_IDLE_WEIGHT := 0.35
const DIRECTOR_PLAYER_LANE_BIAS := 0.45
const DIRECTOR_DWELL_BIAS := 0.90
const DIRECTOR_DWELL_FULL_SECONDS := 4.0
# Maximo de ondas seguidas na mesma faixa (a seguinte vai para a outra): evita fila longa numa faixa so.
const DIRECTOR_MAX_SAME_LANE_STREAK := 2
# Folga do jogador por TEMPO: o NPC so nasce se levar pelo menos isso ate o Bionix (na faixa oposta vale o fator abaixo).
const SPAWN_MIN_REACTION_SECONDS := {"facil": 1.10, "normal": 0.90, "dificil": 0.66}
const SPAWN_OTHER_LANE_REACTION_FACTOR := 0.80
# Teto de carros visiveis ao mesmo tempo (inclui os que ja passaram do Bionix e ainda saem da tela): protege o desempenho no navegador.
const DIRECTOR_MAX_VISIBLE_NPCS := 6
# O ultimo NPC precisa sair de vista pelo menos isto antes de a pergunta abrir.
const DIRECTOR_EXIT_MARGIN_SECONDS := 0.5

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
