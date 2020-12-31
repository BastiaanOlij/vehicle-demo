shader_type spatial;

uniform sampler2D road_texture;
uniform sampler2D road_normalmap;
uniform vec2 uv_scale = vec2(1.0, 0.25);

void vertex() {
	UV = vec2(UV.y, UV.x) * uv_scale;
}

void fragment() {
	vec4 color = texture(road_texture, UV);
	NORMALMAP = texture(road_normalmap, UV).rgb;
	NORMALMAP_DEPTH = 0.5;
	ALBEDO = color.rgb;
	METALLIC = 0.0;
	ROUGHNESS = 0.8;
}