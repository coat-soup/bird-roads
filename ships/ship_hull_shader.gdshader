shader_type spatial;
render_mode cull_disabled, ensure_correct_normals;

#include "res://vfx/shaders/triplanar.gdshaderinc"

uniform vec3 ex_primary_color : source_color;
uniform vec3 ex_secondary_color : source_color;
uniform vec3 ex_tertiary_color : source_color;
uniform vec3 ex_quaternary_color : source_color;
uniform vec3 ex_quintary_color : source_color;

instance uniform int pattern_id = -1;
instance uniform int flip_normals = 0;

instance uniform vec3 primary_color : source_color;
instance uniform vec3 secondary_color : source_color;
instance uniform vec3 tertiary_color : source_color;
instance uniform vec3 quaternary_color : source_color;
instance uniform vec3 quintary_color : source_color;

uniform sampler2D voronoi_noise;

uniform sampler2D pattern : filter_linear;
uniform sampler2D wood_tex : filter_nearest;
uniform sampler2D wood_norm : filter_nearest, hint_normal;
uniform sampler2D canvas_tex : filter_nearest;
uniform sampler2D canvas_norm : filter_nearest, hint_normal;
uniform sampler2D metal_tex : filter_nearest;
uniform sampler2D metal_norm : filter_nearest, hint_normal;

// VERTEX COLOR R: color category
// 0: primary colour group
// 0.25: secondary colour group
// 0.5: tertiary colour group
// 0.75: quaternary colour group
// 1.0: quintary colour group 


// VERTEX COLOR G: material type
// 0: standard "metal" / dull ship hull material
// 0.25: shiny / unpainted metal
// 0.5: wood
// 0.75: canvas/gasbag/sail

varying flat vec3 vPos;

void vertex() {
	if(flip_normals > 0) NORMAL = -NORMAL;
}

void fragment() {
	// weird conversion for some reason: blender r=0.25 -> godot r is much lower
	if (COLOR.r < 0.05) ALBEDO = vec3(primary_color);
	else if (COLOR.r < 0.2) ALBEDO = vec3(secondary_color);
	else if (COLOR.r < 0.3) ALBEDO = vec3(tertiary_color);
	else if (COLOR.r < 0.6) ALBEDO = vec3(quaternary_color);
	else ALBEDO = vec3(quintary_color);
	
	vec3 pos = (inverse(MODEL_MATRIX) * INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).rgb / 20.0;
	//pos = VERTEX / 20.0;
	
	if (pattern_id >= 0){
		if(texture(pattern, UV.rg).r > 0.0) ALBEDO = vec3(secondary_color);
	}
	
	if (COLOR.g < 0.05){ // standard metal
		METALLIC = 1.0;
		ROUGHNESS = mix(0.8, 0.9, texture(voronoi_noise, pos.rg + pos.gb - pos.br + pos.br).r);
		
		ALBEDO *= triplanar(metal_tex, 0.08, inverse(MODEL_MATRIX) * INV_VIEW_MATRIX, VERTEX, NORMAL);
		NORMAL_MAP = triplanar(metal_norm, 0.08, inverse(MODEL_MATRIX) * INV_VIEW_MATRIX, VERTEX, NORMAL);
	}
	else if (COLOR.g < 0.2 ){ // shiny metal
		ALBEDO = mix(ALBEDO, vec3(1.0), 0.5);
		METALLIC = 1.0;
		ROUGHNESS = mix(0.3, 0.4, texture(voronoi_noise, pos.rg + pos.gb - pos.br + pos.br).r);
	}
	else if (COLOR.g < 0.3){ // wood
		ALBEDO = mix(ALBEDO, vec3(79, 44, 7)/600.0, 0.9);
		ALBEDO = texture(wood_tex, pos.zx * 5.0).rgb * vec3(81, 55, 38)/255.0;
		NORMAL_MAP = texture(wood_norm, pos.zx * 5.0).rgb;
	}
	else if (COLOR.g < 0.6){ // canvas
		//ALBEDO = mix(ALBEDO, vec3(0.8), 0.4);
		
		//ALBEDO *= texture(canvas_tex, (pos.rg + pos.gb - pos.br + pos.br) * 5.0).rgb;
		ALBEDO *= triplanar(canvas_tex, 0.08, inverse(MODEL_MATRIX) * INV_VIEW_MATRIX, VERTEX, NORMAL);
		NORMAL_MAP = triplanar(canvas_norm, 0.08, inverse(MODEL_MATRIX) * INV_VIEW_MATRIX, VERTEX, NORMAL);
	}
	else{
		
	};
	NORMAL_MAP_DEPTH = 1.0;
	//ALBEDO = mix(ALBEDO, ALBEDO * 0.9, texture(voronoi_noise, pos.rg + pos.gb - pos.br + pos.br).r);
}