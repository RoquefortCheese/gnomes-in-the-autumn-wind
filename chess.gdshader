shader_type spatial;
render_mode world_vertex_coords;

void fragment() {
	vec3 point = (INV_VIEW_MATRIX * vec4(VERTEX, 1.)).xyz;
	int closeaxis;
	float closest = 0.;
	for (int axis = 0; axis < 3; axis++) {
		float closeness = abs(mod(point[axis], 1.) - 0.5);
		if (closeness > closest) {
			closeaxis = axis;
			closest = closeness;
		}
	}
	point[closeaxis] = round(point[closeaxis]);
	point = floor(point);
	bool even = bool(int(mod(point.x + point.y + point.z, 2.)));
	ALBEDO.rgb = vec3(even ? 1. : 0.875);
}
