vec3 triplanar(sampler2D sampler, float scale, mat4 _INV_VIEW_MATRIX, vec3 _VERTEX, vec3 _NORMAL) {
	vec4 vertex = _INV_VIEW_MATRIX * vec4(_VERTEX, 1.0);
	vec3 normal = normalize((_INV_VIEW_MATRIX * vec4(_NORMAL, 0.0)).xyz);
	vec3 adjusted_normal = pow(abs(normal), vec3(8.0));
	vec3 weights = adjusted_normal / (adjusted_normal.x + adjusted_normal.y + adjusted_normal.z) * 3.0;
	
	vec2 uv_x = vertex.zy * scale;
	vec2 uv_y = vertex.xz * scale;
	vec2 uv_z = vertex.xy * scale;
	
	
	vec3 color_x = texture(sampler, uv_x).rgb * weights.x;
	vec3 color_y = texture(sampler, uv_y).rgb * weights.y;
	vec3 color_z = texture(sampler, uv_z).rgb * weights.z;
	
	return(color_x + color_y + color_z) / 3.0;

}