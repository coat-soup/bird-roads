shader_type spatial;


uniform bool two_faced;
//render_mode diffuse_toon;

render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_toon;

uniform sampler2D albedo_tex : source_color, filter_nearest;
uniform sampler2D normal_tex : hint_normal, filter_nearest;
uniform sampler2D face_tex : source_color, filter_nearest;
uniform vec3 modulate : source_color = vec3(1.0);

uniform bool invert_normals = false;

instance uniform vec3 modulate_override : source_color = vec3(1.0);


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = texture(albedo_tex, UV).rgb;
	ALBEDO *= modulate * modulate_override;
	
	if (COLOR.r == 0.0){
		vec4 face = texture(face_tex, UV);
		face.a = 0.0;
		ALBEDO = mix(modulate * modulate_override, face.rgb, face.a);
	}
	SPECULAR = 0.0;
	ROUGHNESS = 1.0;
}
