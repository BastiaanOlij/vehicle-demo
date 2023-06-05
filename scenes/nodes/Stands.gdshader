shader_type spatial;

uniform sampler2D people : source_color, filter_linear_mipmap;

uniform vec2 people_in_image = vec2(8,4);
uniform float num_people = 1;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
	vec2 offset = vec2(UV.x * num_people, UV.y);
	float which = floor(offset.x);
	offset.x = (offset.x - which) / people_in_image.x;
	offset.y = offset.y / people_in_image.y;
	
	vec2 pick = vec2(rand(vec2(MODEL_MATRIX[3][0] + which, MODEL_MATRIX[3][1])), rand(vec2(MODEL_MATRIX[3][0], MODEL_MATRIX[3][1] + which)));
	pick.x = floor(pick.x * people_in_image.x) / people_in_image.x;
	pick.y = floor(pick.y * people_in_image.y) / people_in_image.y;
	
	vec2 people_uv = pick + offset;
	vec4 color = texture(people, people_uv);
	ALBEDO = color.rgb;
	if (color.a < 0.8) {
		discard;
	}
}
