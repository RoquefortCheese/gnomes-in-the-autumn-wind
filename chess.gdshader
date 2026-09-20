shader_type spatial;
render_mode world_vertex_coords;

void fragment() {
	vec3 point = (INV_VIEW_MATRIX * vec4(VERTEX, 1.)).xyz;
	point = floor(point + vec3(0.001));
	if (bool(int(mod(point.x + point.y + point.z, 2.)))) {
		ALBEDO.rgb = vec3(0.875);
	} else {
		ALBEDO.rgb = vec3(1.);
	}
}
