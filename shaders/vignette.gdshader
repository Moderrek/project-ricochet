shader_type canvas_item;

uniform float vignette_power : hint_range(0.0, 1.0) = 0.6;

void fragment() {
	float dist = distance(UV, vec2(0.5));
	float alpha = smoothstep(0.3, 0.8, dist) * vignette_power;
	
	COLOR = vec4(0.0, 0.0, 0.0, alpha);
}