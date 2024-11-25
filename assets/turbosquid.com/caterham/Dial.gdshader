shader_type spatial;

uniform sampler2D face;

void fragment() {
	ALBEDO = texture(face, vec2(1.0 - (UV.x * 2.0 - 1.0), UV.y * 2.0 - 1.0)).rgb;
	METALLIC = 0.3;
	ROUGHNESS = 0.1;
}
