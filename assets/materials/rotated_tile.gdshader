shader_type spatial;

uniform sampler2D terrain_texture : source_color;
uniform sampler2D terrain_normalmap : hint_normal;
uniform float normal_depth = 1.0;
uniform vec2 terrain_scale = vec2(0.2, 0.2);

uniform sampler2D noise : hint_default_white;
uniform vec2 noise_scale = vec2(0.01, 0.01);

void vertex() {
	UV = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz * terrain_scale;
}

void fragment() {
	// apply a random rotation to each tile to break up repetiveness
	vec2 noise_uv = vec2(floor(UV.x), floor(UV.y)) * noise_scale;
	float r = texture(noise, noise_uv).r * 2.0 * 3.1415;
	float c = cos(r);
	float s = sin(r);
	
	vec2 terrain_uv = vec2(UV.x * c - UV.y * s, UV.x * s + UV.y * c);
	
	vec4 color = texture(terrain_texture, terrain_uv);
	NORMAL_MAP = texture(terrain_normalmap, terrain_uv).rgb;
	NORMAL_MAP_DEPTH = normal_depth;
	ALBEDO = color.rgb;
	METALLIC = 0.0;
	ROUGHNESS = 0.8;
}
