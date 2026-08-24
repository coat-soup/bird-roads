shader_type spatial;


uniform bool two_faced;
//render_mode diffuse_toon;

render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_toon;

uniform sampler2D albedo_tex : source_color, filter_nearest;
uniform sampler2D normal_tex : hint_normal, filter_nearest;
uniform vec3 modulate : source_color = vec3(1.0);

uniform bool invert_normals = false;

instance uniform vec3 modulate_override : source_color = vec3(1.0);


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = texture(albedo_tex, UV).rgb;
	NORMAL_MAP = texture(normal_tex, UV).rgb;
	
	if (invert_normals) NORMAL_MAP_DEPTH = -1.0;
	ALBEDO *= modulate * modulate_override;
	SPECULAR = 0.0;
	ROUGHNESS = 1.0;
}
