shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 5.0) = 2.5;
uniform vec4 mix_color : source_color = vec4(0.02, 0.04, 0.12, 0.8);

void fragment() {
	vec4 blur = textureLod(screen_texture, SCREEN_UV, blur_amount);
	COLOR = mix(blur, mix_color, mix_color.a);
}