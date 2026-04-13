shader_type canvas_item;

uniform float fill_amount : hint_range(0.0, 1.0) = 0.5;
uniform vec4 energy_color : source_color = vec4(0.95, 0.75, 0.1, 1.0);
uniform vec4 bg_color : source_color = vec4(0.15, 0.15, 0.15, 1.0);

void fragment() {
    float wave = sin(UV.x * 20.0 - TIME * 5.0) * 0.01;
    float edge = fill_amount + (wave * fill_amount); 
    float is_filled = step(UV.x, edge);
    float white_edge = smoothstep(edge - 0.05, edge, UV.x) * is_filled;
    vec4 fluid_color = energy_color + vec4(0.1, 0.1, 0.1, 0.0) * (1.0 - UV.y);
    vec4 final_energy = mix(fluid_color, vec4(1.0, 1.0, 1.0, 1.0), white_edge);
    COLOR = mix(bg_color, final_energy, is_filled);
}