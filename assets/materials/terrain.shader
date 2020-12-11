shader_type spatial;

uniform sampler2D heightmap : hint_black;
uniform float height_scale = 10.0;
uniform vec2 height_uv_offset = vec2(-0.5, -0.5);
uniform vec2 height_uv_size = vec2(2048.0, 2048.0);

uniform sampler2D splatmap : hint_black;

uniform sampler2D terrain_texture : hint_albedo;
uniform sampler2D terrain_normalmap : hint_normal;
uniform float normal_depth = 1.0;
uniform vec2 terrain_scale = vec2(0.2, 0.2);

uniform sampler2D texture1 : hint_albedo;
uniform sampler2D normalmap1 : hint_normal;

uniform sampler2D texture2 : hint_albedo;
uniform sampler2D normalmap2 : hint_normal;

uniform sampler2D texture3 : hint_albedo;
uniform sampler2D normalmap3 : hint_normal;

uniform sampler2D noise : hint_white;
uniform vec2 noise_scale = vec2(0.01, 0.01);

float height(vec2 at) {
	vec2 height_uv = (at / height_uv_size) + height_uv_offset;
	vec4 height_val = texture(heightmap, height_uv);
	return height_scale * height_val.r;
}

void vertex() {
	vec2 base_uv = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xz;
	UV = (base_uv / height_uv_size) + height_uv_offset;
	UV2 = base_uv * terrain_scale;
	
	float y1 = height(base_uv - vec2(1.0, 0.0));
	float y2 = height(base_uv + vec2(1.0, 0.0));
	float y3 = height(base_uv - vec2(0.0, 1.0));
	float y4 = height(base_uv + vec2(0.0, 1.0));
	
	VERTEX.y += (y1+y2+y3+y4) * 0.25;
	TANGENT = normalize(vec3(-1.0, y1, 0.0) - vec3(1.0, y2, 0.0));
	BINORMAL = normalize(vec3(0.0, y3, -1.0) - vec3(0.0, y4, 1.0));
	NORMAL = normalize(cross(BINORMAL, TANGENT));
}

void fragment() {
	// splatmap values
	vec4 map = texture(splatmap, UV);
	map.a = clamp(1.0 - (map.r + map.g + map.b), 0.0, 1.0);
	map = normalize(map);
	
	// apply a random rotation to each tile to break up repetiveness
	vec2 noise_uv = vec2(floor(UV.x), floor(UV.y)) * noise_scale;
	float r = texture(noise, noise_uv).r * 2.0 * 3.1415;
	float c = cos(r);
	float s = sin(r);
	vec2 terrain_uv = vec2(UV2.x * c - UV2.y * s, UV2.x * s + UV2.y * c);
	
	vec3 albedo = texture(terrain_texture, terrain_uv).rgb * map.a;
	vec3 normalmap = texture(terrain_normalmap, terrain_uv).rgb * map.a;
	
	albedo += texture(texture1, terrain_uv).rgb * map.r;
	normalmap += texture(normalmap1, terrain_uv).rgb * map.r;
	
	albedo += texture(texture2, terrain_uv).rgb * map.g;
	normalmap += texture(normalmap2, terrain_uv).rgb * map.g;
	
	albedo += texture(texture3, terrain_uv).rgb * map.b;
	normalmap += texture(normalmap3, terrain_uv).rgb * map.b;
	
	ALBEDO = albedo;
	NORMALMAP = normalize(normalmap);
	NORMALMAP_DEPTH = normal_depth;
	METALLIC = 0.0;
	ROUGHNESS = 0.8;
}