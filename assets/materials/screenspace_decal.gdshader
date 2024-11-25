shader_type spatial;

uniform sampler2D texture_albedo : source_color;
uniform sampler2D texture_metallic : hint_default_black;
uniform sampler2D texture_roughness : hint_default_white;
uniform sampler2D texture_normal : hint_normal;
uniform vec2 uv_offset = vec2(0.1, 0.1);
uniform vec2 uv_scale = vec2(0.8, 0.8);

uniform vec2 min_uv = vec2(0.0, 0.0);
uniform vec2 max_uv = vec2(1.0, 1.0);
uniform vec2 depth_scale = vec2(1.0, 1.0);

uniform sampler2D depth_texture : hint_depth_texture;

varying float frag_z;

void vertex() {
	UV = uv_offset + (UV * uv_scale);
	frag_z = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).z;
}

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).r;
	vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth, 1.0);
	vec3 ppos = upos.xyz / upos.w;
	
	vec3 view_dir = normalize(normalize(-VERTEX)*mat3(TANGENT,-BINORMAL,NORMAL));
	float dist = ppos.z - frag_z;
	vec2 offs = view_dir.xy * dist * depth_scale;
	
	vec2 text_uv = UV + offs;
	if (text_uv.x < min_uv.x) {
		discard;
	} else if (text_uv.y < min_uv.y) {
		discard;
	} else if (text_uv.x > max_uv.x) {
		discard;
	} else if (text_uv.y > max_uv.y) {
		discard;
	}
	
	vec4 color = texture(texture_albedo, text_uv);
	ALBEDO = color.rgb;
	ALPHA = color.a;
	METALLIC = texture(texture_metallic, text_uv).r;
	ROUGHNESS = texture(texture_roughness, text_uv).r;
	NORMAL_MAP = texture(texture_normal, text_uv).rgb;
}
