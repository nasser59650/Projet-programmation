shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform float time_val = 0.0;

void fragment() {
	vec2 uv = SCREEN_UV;

	// Distorsion ondulante
	uv.x += sin(uv.y * 8.0 + time_val * 2.5) * 0.04 * intensity;
	uv.y += cos(uv.x * 6.0 + time_val * 1.8) * 0.03 * intensity;

	// Double vision (aberration chromatique)
	float ab = 0.012 * intensity;
	float r = texture(SCREEN_TEXTURE, uv + vec2(ab, 0.0)).r;
	float g = texture(SCREEN_TEXTURE, uv).g;
	float b = texture(SCREEN_TEXTURE, uv - vec2(ab, 0.0)).b;

	COLOR = vec4(r, g, b, 1.0);
}
