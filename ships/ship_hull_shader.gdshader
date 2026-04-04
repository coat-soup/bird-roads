shader_type spatial;

uniform vec3 ex_primary_color : source_color;
uniform vec3 ex_secondary_color : source_color;
uniform vec3 ex_tertiary_color : source_color;
uniform vec3 ex_quaternary_color : source_color;
uniform vec3 ex_quintary_color : source_color;

instance uniform vec3 primary_color : source_color;
instance uniform vec3 secondary_color : source_color;
instance uniform vec3 tertiary_color : source_color;
instance uniform vec3 quaternary_color : source_color;
instance uniform vec3 quintary_color : source_color;

uniform sampler2D voronoi_noise;

uniform sampler2D pattern : filter_linear;

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
	//color = COLOR;
}

void fragment() {
	// weird conversion for some reason: blender r=0.25 -> godot r is much lower
	if (COLOR.r < 0.05) ALBEDO = vec3(primary_color);
	else if (COLOR.r < 0.2) ALBEDO = vec3(secondary_color);
	else if (COLOR.r < 0.3) ALBEDO = vec3(tertiary_color);
	else if (COLOR.r < 0.6) ALBEDO = vec3(quaternary_color);
	else ALBEDO = vec3(quintary_color);
	
	vec3 pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).rgb / 20.0;
	
	if (COLOR.g < 0.05){ // standard metal
		METALLIC = 1.0;
		ROUGHNESS = mix(0.6, 0.7, texture(voronoi_noise, pos.rg + pos.gb - pos.br + pos.br).r);
	}
	else if (COLOR.g < 0.2){ // shiny metal
		ALBEDO = mix(ALBEDO, vec3(1.0), 0.5);
		METALLIC = 1.0;
		ROUGHNESS = mix(0.3, 0.4, texture(voronoi_noise, pos.rg + pos.gb - pos.br + pos.br).r);
	}
	else if (COLOR.g < 0.3){ // wood
		ALBEDO = mix(ALBEDO, vec3(79, 44, 7)/600.0, 0.9);
	}
	else if (COLOR.g < 0.6){ // canvas
		//ALBEDO = mix(ALBEDO, vec3(0.8), 0.4);
		
		if(texture(pattern, UV.rg).r > 0.0) ALBEDO = vec3(secondary_color);
	}
	else{
		
	};
	
	ALBEDO = mix(ALBEDO, ALBEDO * 0.9, texture(voronoi_noise, pos.rg + pos.gb - pos.br + pos.br).r);
}