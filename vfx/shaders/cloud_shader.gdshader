shader_type spatial;

#include "res://vfx/shaders/triplanar.gdshaderinc"

render_mode unshaded, cull_disabled;

uniform sampler2D noise;

uniform sampler2D height_gradient;
uniform sampler2D noise_gradient;


float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

float map_range(float value, float o_min, float o_max, float n_min, float n_max)
{
	return (value/(o_max-o_min) - o_min) * (n_max-n_min) + n_min;
}

void fragment()
{
	SPECULAR = 0.0;
	ROUGHNESS = 1.0;
	
	float fresnel_effect = fresnel(5.0, NORMAL, VIEW);
	float noise_effect = triplanar(noise, 0.005, inverse(MODEL_MATRIX) * INV_VIEW_MATRIX, VERTEX, NORMAL).r;
	float bottom_effect = pow(clamp(dot(vec3(0.0, -1.0, 0.0), (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz), 0.4, 0.99), 1.0);
	noise_effect = map_range(noise_effect, 0.0, 1.0, 0.0, 1.0);
	
	float cloud = (fresnel_effect) * noise_effect;
	
	//ALBEDO = vec3(COLOR.rgb);
	EMISSION = texture(height_gradient, vec2(bottom_effect * noise_effect)).rgb;
	ALPHA = cloud * COLOR.a;
	//ALPHA = 1.0;
}
