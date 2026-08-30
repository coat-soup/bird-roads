shader_type spatial;

#include "res://vfx/shaders/triplanar.gdshaderinc"

uniform bool two_faced;
//render_mode diffuse_toon;

render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_toon;

uniform sampler2D albedo_tex : source_color, filter_nearest;
uniform sampler2D normal_tex : hint_normal, filter_nearest;
uniform sampler2D mask_tex : filter_nearest;
uniform vec3 modulate : source_color = vec3(1.0);

uniform bool invert_normals = false;

uniform float triplanar_scale = 0.0;

instance uniform bool override_triplanar = false;
instance uniform float triplanar_scale_override = 0.0;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float t_scale = override_triplanar? triplanar_scale_override : triplanar_scale;
	if(t_scale != 0.0){
		ALBEDO = triplanar(albedo_tex, t_scale, INV_VIEW_MATRIX, VERTEX, NORMAL);
	NORMAL_MAP = triplanar(normal_tex, t_scale, INV_VIEW_MATRIX, VERTEX, NORMAL);
	}
	else{
		ALBEDO = texture(albedo_tex, UV).rgb;
	NORMAL_MAP = texture(normal_tex, UV).rgb;
	}
	if (invert_normals) NORMAL_MAP_DEPTH = -1.0;
	ALBEDO *= modulate;
	SPECULAR = 0.0;
	ROUGHNESS = 1.0;
	
	if(textureSize(mask_tex, 0).x > 4){
		vec4 mask = texture(mask_tex, UV);
		//METALLIC = mask.r;
		ROUGHNESS = mask.b;
	}
}
