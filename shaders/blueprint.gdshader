shader_type canvas_item;

uniform vec4 blueprint_blue : source_color = vec4(0.0, 0.467, 1.0, 1.0); 
uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float line_threshold : hint_range(0.0, 1.0) = 0.6; 
uniform float line_smoothness : hint_range(0.0, 0.2) = 0.02; 

uniform float grid_strength : hint_range(0.0, 0.5) = 0.15;
uniform float grid_scale = 120.0;
uniform float grid_subdivisions = 4.0;

uniform vec2 scroll_speed = vec2(0.0, 0.0);

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	// Scrolling
	vec2 shifted_uv = UV + (TIME * scroll_speed);
	vec4 tex_color = texture(TEXTURE, shifted_uv);
	
	float luminosity = (tex_color.r + tex_color.g + tex_color.b) / 3.0;
	float mask = 1.0 - smoothstep(line_threshold - line_smoothness, line_threshold + line_smoothness, luminosity);
	vec3 blueprint_final = mix(blueprint_blue.rgb, line_color.rgb, mask);
	
	vec2 animated_world_pos = world_pos + (TIME * scroll_speed * 500.0);
	
	// Main grid
	vec2 grid_uv = animated_world_pos / grid_scale;
	vec2 grid_dist = abs(fract(grid_uv - 0.5) - 0.5);
	float grid_lines = 1.0 - smoothstep(0.0, 0.02, min(grid_dist.x, grid_dist.y));
	
	// Sub grid
	vec2 sub_grid_uv = animated_world_pos / (grid_scale / grid_subdivisions);
	vec2 sub_grid_dist = abs(fract(sub_grid_uv - 0.5) - 0.5);
	float sub_grid_lines = 1.0 - smoothstep(0.0, 0.04, min(sub_grid_dist.x, sub_grid_dist.y));
	
	vec3 grid_final = mix(blueprint_final, line_color.rgb, grid_lines * grid_strength);
	grid_final = mix(grid_final, line_color.rgb, sub_grid_lines * (grid_strength * 0.5));
	
	COLOR = vec4(grid_final, tex_color.a);
}