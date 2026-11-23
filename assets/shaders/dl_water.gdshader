shader_type canvas_item;
render_mode blend_mix;
// Desvio Logico - agua do fundo "viva" (V0.16.12).
// Em vez de desenhar linhas/retangulos por cima da agua (centenas de comandos por quadro na CPU), este shader roda na GPU e
// faz o proprio reflexo do fundo ondular: cada linha da agua e deslocada para o lado em passos de 1 px (visual retro/pixel art),
// com a frequencia ficando mais fina perto do horizonte (perspectiva). Brilhos so aparecem onde o fundo ja e claro
// (reflexo do sol, da lua e das luzes da cidade), entao a agua acompanha o cenario de cada horario.
// Nao usa hint_screen_texture (instavel no WebGL): so amostra a textura do proprio fundo.
// Coordenadas em pixels do palco (1280x720). A borda grama/agua e uma reta, igual nos 6 fundos.

uniform sampler2D bg_tex : filter_linear, repeat_disable;
uniform float t = 0.0;                 // tempo (s)
uniform float amp = 1.6;               // deslocamento maximo da onda (px), perto da camera
uniform float speed = 1.0;             // velocidade das ondas
uniform float sparkle = 0.35;          // intensidade dos brilhos (0 desliga)
uniform vec3 sparkle_color : source_color = vec3(1.0, 0.85, 0.5);
uniform float light_x = 0.5;           // x (0..1) do sol/lua refletido: os brilhos se concentram em volta dele
uniform float quality = 1.0;           // 1 completo, 0 simples (aparelho fraco: 1 onda e sem brilhos)

uniform float water_top = 244.0;       // linha do horizonte do mar
uniform float water_bottom = 585.0;    // abaixo disso a agua some atras da grama
uniform float edge_x0 = 550.0;         // x da borda da grama no horizonte (lado esquerdo)
uniform float edge_slope = 1.68;       // quanto a borda anda para a esquerda por pixel descido
uniform float edge_margin = 9.0;       // folga entre a borda da grama e o efeito
uniform float stage_w = 1280.0;
uniform float stage_h = 720.0;

float water_mask(vec2 p) {
	float edge = edge_x0 - edge_slope * (p.y - water_top);
	float left = 1.0 - smoothstep(edge - edge_margin - 6.0, edge - edge_margin, p.x);
	float right = smoothstep(stage_w - edge + edge_margin, stage_w - edge + edge_margin + 6.0, p.x);
	float vert = smoothstep(water_top, water_top + 5.0, p.y) * (1.0 - smoothstep(water_bottom - 10.0, water_bottom, p.y));
	return max(left, right) * vert;
}

// Faixas suaves de luz/sombra que vem para a camera (perspectiva): iguais em qualquer cor de agua, escura ou clara.
float wave_band(float z, float x, float tt) {
	float a = sin(z * 6.0 + tt * speed * 1.2 + sin(x * 0.012 + tt * 0.35) * 1.4);
	float b = sin(z * 11.0 + tt * speed * 1.9 + x * 0.008);
	return a * 0.65 + b * 0.35;
}

void fragment() {
	vec2 p = UV * vec2(stage_w, stage_h);
	float m = water_mask(p);
	if (m <= 0.001) {
		COLOR = vec4(0.0);
	} else {
		float d = clamp((p.y - water_top) / (water_bottom - water_top), 0.0, 1.0);
		float z = 1.0 / (0.10 + d);                         // perspectiva: faixas finas no horizonte, largas na frente
		float a = amp * (0.25 + d * 0.95);
		// 1) o proprio reflexo do fundo ondula para o lado, em passos de 1 px (pixel art nitido)
		float ox = sin(z * 9.0 + t * speed * 1.6 + sin(p.x * 0.018 + t * 0.55 * speed) * 1.8) * a;
		if (quality > 0.5) {
			ox += sin(z * 15.0 + t * speed * 1.15 + p.x * 0.011) * a * 0.45;
		}
		ox = floor(ox + 0.5);
		vec4 c = texture(bg_tex, vec2(p.x + ox, p.y) / vec2(stage_w, stage_h));
		float lum = dot(c.rgb, vec3(0.299, 0.587, 0.114));
		float dark = 1.0 - smoothstep(0.22, 0.65, lum);      // 1 em agua escura, 0 em reflexo claro
		float depth_gain = 0.45 + d * 0.80;                  // ondas mais fortes perto da camera
		if (quality > 0.5) {
			// 2) faixas de luz que se movem sobre TODA a agua (visiveis tambem na agua escura onde o deslocamento nao aparece)
			float bnd = wave_band(z, p.x, t);
			c.rgb *= 1.0 + bnd * mix(0.04, 0.10, dark) * depth_gain;
			float crest_soft = smoothstep(0.50, 1.0, bnd);
			c.rgb += sparkle_color * crest_soft * (0.03 + 0.055 * dark) * depth_gain * min(sparkle * 3.0, 1.0);
			// 3) brilhos pontuais so onde o fundo ja e claro (sol/lua/luzes), mais fracos que antes
			float crest = smoothstep(0.82, 1.0, sin(z * 11.0 + t * speed * 2.1 + p.x * 0.05 + sin(t * 0.7 + p.x * 0.02) * 2.0));
			float near_sun = 1.0 - smoothstep(0.06, 0.34, abs(UV.x - light_x));
			float glint = crest * smoothstep(0.30, 0.85, lum) * (0.30 + near_sun) * sparkle;
			c.rgb = mix(c.rgb, sparkle_color, clamp(glint, 0.0, 0.32));
		} else {
			c.rgb *= 1.0 + sin(z * 7.0 + t * speed * 1.3) * 0.04 * depth_gain;
		}
		COLOR = vec4(c.rgb, m);
	}
}
