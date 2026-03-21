extends Node2D
class_name AimLine

@onready var line_node = $Line2D
@onready var arrow_node = $ArrowPolygon
@onready var raycast_node = $RayCast
@onready var player = get_parent()

var max_viz_dist = 600.0
var max_width = 15.0
var max_arrow_scale = 1.0
var pulse_base_speed = 300.0

var time_accum = 0.0

func _ready():
	set_as_top_level(true)
	global_position = Vector2.ZERO
	
	arrow_node.polygon = PackedVector2Array([
		Vector2(0, -10),
		Vector2(0, 10),
		Vector2(18, 0)
	])
	
	if player:
		raycast_node.add_exception(player)

func _process(delta):
	if player and player.is_aiming:
		line_node.show()
		arrow_node.show()
		update_aim_line(delta, player)
	else:
		line_node.hide()
		arrow_node.hide()

func update_aim_line(delta, player):
	time_accum += delta
	
	var drag_vector = player.get_drag_vector() 
	var force_intensity = clamp(drag_vector.length() / player.max_drag_distance, 0.0, 1.0) 

	var viz_dist = lerp(0.0, max_viz_dist, force_intensity)
	var line_width = lerp(2.0, max_width, force_intensity)
	var arrow_scale = lerp(0.5, max_arrow_scale, force_intensity)
	
	var cold_color = Color(0.3, 0.7, 1.0, 0.7)
	var hot_color = Color(1.0, 0.5, 0.2, 1.0)
	if GameManager.boost_level > 0:
		cold_color = Color(1.0, 0.2, 0.2, 0.8)
		hot_color = Color(1.0, 0.8, 0.0, 1.0)
	var overall_color = cold_color.lerp(hot_color, force_intensity)

	calculate_reflections(player.global_position, player.get_aim_direction(), viz_dist, overall_color, line_width)

	var pulse = (sin(time_accum * pulse_base_speed / 50.0) + 1.0) / 2.0
	line_node.default_color.a = lerp(0.5, 1.0, pulse * clamp(line_node.default_color.a, 0.0, 1.0))

	update_arrow(delta, arrow_scale, overall_color)

func calculate_reflections(start_pos, dir, viz_dist, color, width):
	line_node.clear_points()
	line_node.add_point(start_pos)
	line_node.width = width
	line_node.default_color = color
	
	raycast_node.global_position = start_pos
	raycast_node.target_position = dir * viz_dist
	raycast_node.force_raycast_update()
	
	if raycast_node.is_colliding():
		var hit_point = raycast_node.get_collision_point()
		var hit_normal = raycast_node.get_collision_normal()
		
		line_node.add_point(hit_point)
		
		var reflect_dir = -dir.reflect(hit_normal)
		var hint_length = clamp(viz_dist * 0.25, 20.0, 80.0)
		var hint_end = hit_point + hit_normal * 1.5 + reflect_dir * hint_length
		
		line_node.add_point(hint_end)
	else:
		line_node.add_point(start_pos + dir * viz_dist)

func update_arrow(_delta, arrow_scale, color):
	var point_count = line_node.get_point_count()
	if point_count > 1:
		var last_pt = line_node.get_point_position(point_count - 1)
		var prev_pt = line_node.get_point_position(point_count - 2)
		
		arrow_node.global_position = last_pt
		arrow_node.rotation = (last_pt - prev_pt).angle()
		arrow_node.scale = Vector2.ONE * arrow_scale
		arrow_node.modulate = color 
	elif point_count == 1:
		if player:
			arrow_node.global_position = player.global_position + player.get_aim_direction() * 50.0 
			arrow_node.rotation = player.get_aim_direction().angle()
			arrow_node.scale = Vector2.ONE * arrow_scale
			arrow_node.modulate = color
