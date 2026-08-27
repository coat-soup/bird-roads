shader_type spatial;


uniform bool two_faced;
//render_mode diffuse_toon;

render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_toon;

uniform sampler2D albedo_tex : source_color, filter_nearest;
uniform sampler2D normal_tex : hint_normal, filter_nearest;
uniform sampler2D face_tex : source_color, filter_nearest;
uniform vec3 skin_color : source_color = vec3(1.0);
uniform vec3 highlight_color : source_color = vec3(1.0);
uniform vec3 eye_color : source_color = vec3(0.2, 0.1, 0.05);


instance uniform vec3 modulate_override : source_color = vec3(1.0);


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 mask = texture(albedo_tex, UV).rgb;
	ALBEDO = skin_color;
	ALBEDO = mix(ALBEDO, ALBEDO * 0.5, 1.0 - mask.g);
	ALBEDO = mix(ALBEDO, highlight_color, 1.0 - mask.r);
	
	if (COLOR.r == 0.0){
		vec4 face = texture(face_tex, UV * 2.0);
		//face.a = 0.0;
		ALBEDO = mix(ALBEDO, face.rgb, face.a);
		if(ALBEDO.g > 0.2 && ALBEDO.r < 0.1 && ALBEDO.b < 0.2) ALBEDO = eye_color;
	}
	SPECULAR = 0.0;
	ROUGHNESS = 1.0;
}
