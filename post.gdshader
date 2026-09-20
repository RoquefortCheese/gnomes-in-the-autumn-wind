shader_type canvas_item;
uniform sampler2D screen: hint_screen_texture;

void fragment() {
	vec2 point = floor(UV / SCREEN_PIXEL_SIZE / 16.) * 16. * SCREEN_PIXEL_SIZE;
	COLOR.rgb = texture(screen, point).rgb;
}