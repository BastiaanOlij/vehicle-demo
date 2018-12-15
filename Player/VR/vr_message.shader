shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D image : hint_albedo;
uniform float alpha = 1.0;

void fragment() {
	vec2 adjusted_uv = vec2(-UV.x * 10.0 - 0.5, UV.y * 5.0);
	if (adjusted_uv.x > -6.0 && adjusted_uv.x < -5.0 && adjusted_uv.y > 2.0 && adjusted_uv .y < 3.0) {
		ALBEDO = texture(image, adjusted_uv).rgb;
	} else {
		ALBEDO = vec3(0.0, 0.0, 0.0);
	}
	ALPHA = alpha;
	DEPTH = 0.1;
}