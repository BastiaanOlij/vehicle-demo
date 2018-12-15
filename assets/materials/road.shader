shader_type spatial;

uniform sampler2D road_texture;
uniform sampler2D road_normalmap;

void fragment() {
	vec2 road_uv = vec2(UV.y, UV.x * 0.25);
	
	vec4 color = texture(road_texture, road_uv);
	NORMALMAP = texture(road_normalmap, road_uv).rgb;
	ALBEDO = color.rgb;
	METALLIC = 0.0;
	ROUGHNESS = 0.8;
}