shader_type canvas_item;
// Desfoque suave do que esta ATRAS deste no (fundo das novels). Sem mipmaps de tela: funciona em
// Forward+, Mobile e Compatibilidade. Disco de 24 amostras em espiral (angulo aureo), mais pesado no centro.

uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_linear;
// Raio do desfoque como FRACAO DA ALTURA da tela (0.005 = ~3,6 px em 720p, ~5,4 px em 1080p).
uniform float radius : hint_range(0.0, 0.02) = 0.005;
// 0 = sem efeito, 1 = desfoque total.
uniform float amount : hint_range(0.0, 1.0) = 1.0;

const int TAPS = 24;
const float GOLDEN_ANGLE = 2.39996323;

void fragment() {
	vec2 aspect_fix = vec2(SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y, 1.0);
	vec3 sum = texture(screen_tex, SCREEN_UV).rgb;
	float total = 1.0;
	for (int i = 1; i <= TAPS; i++) {
		float fi = float(i);
		float r = sqrt(fi / float(TAPS));
		float a = fi * GOLDEN_ANGLE;
		vec2 offset = vec2(cos(a), sin(a)) * r * radius * aspect_fix;
		float w = 1.0 - 0.55 * r;
		sum += texture(screen_tex, SCREEN_UV + offset).rgb * w;
		total += w;
	}
	// COLOR.a ja carrega o modulate do no (fade-in) e o alpha do ColorRect.
	COLOR = vec4(sum / total, COLOR.a * amount);
}
