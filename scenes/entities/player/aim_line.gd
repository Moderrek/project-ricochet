extends Node2D
class_name AimLine

@export_category("Behavior")
@export var max_bounces: int = 2

@export_category("Visual")
@export var cold_color = Color(0.3, 0.7, 1.0, 0.7)
@export var hot_color = Color(1.0, 0.5, 0.2, 1.0)
@export var boost_cold_color = Color(1.0, 0.2, 0.2, 0.8)
@export var boost_hot_color = Color(1.0, 0.8, 0.0, 1.0)

@onready var line_node = $Line2D
@onready var arrow_node = $ArrowPolygon
@onready var player: Player = get_parent()

var max_viz_dist = 600.0
var max_width = 15.0
var max_arrow_scale = 1.0

var _last_drag_vector := Vector2.ZERO
var _drag_threshold_sq := 4.0 # 2 pixels squared

var _points_cache := PackedVector2Array()
var _player_rid: RID

func _ready():
	set_as_top_level(true)
	global_position = Vector2.ZERO
	
	arrow_node.polygon = PackedVector2Array([
		Vector2(0, -10),
		Vector2(0, 10),
		Vector2(18, 0)
	])
	
	if player and player is CollisionObject2D:
		_player_rid = player.get_rid()
	
	line_node.hide()
	arrow_node.hide()
	set_process(false)

func start_aiming():
	line_node.show()
	arrow_node.show()
	_last_drag_vector = Vector2.INF
	set_process(true)

func stop_aiming():
	line_node.hide()
	arrow_node.hide()
	set_process(false)

func _process(_delta: float) -> void:
	if not player or not player.is_aiming:
		stop_aiming()
		return

	var current_drag_vector = player.get_drag_vector()
	if current_drag_vector.distance_squared_to(_last_drag_vector) < _drag_threshold_sq:
		return
	
	_last_drag_vector = current_drag_vector
	_update_aim_line(current_drag_vector)

func _update_aim_line(drag_vector: Vector2) -> void:
	var drag_length = drag_vector.length()
	if drag_length < 1.0:
		line_node.hide()
		arrow_node.hide()
		return
	
	if not line_node.visible:
		line_node.show()
	if not arrow_node.visible:
		arrow_node.show()
	
	var force_intensity = clamp(drag_length / player.max_drag_distance, 0.0, 1.0)
	var viz_dist = lerp(0.0, max_viz_dist, force_intensity)
	var line_width = lerp(2.0, max_width, force_intensity)
	var arrow_scale = lerp(0.5, max_arrow_scale, force_intensity)
	
	var current_cold = boost_cold_color if GameManager.boost_level > 0 else cold_color
	var current_hot = boost_hot_color if GameManager.boost_level > 0 else hot_color
	var overall_color = current_cold.lerp(current_hot, force_intensity)

	var start_pos = player.global_position
	var dir = player.get_aim_direction()

	_calculate_reflections(start_pos, dir, viz_dist, overall_color, line_width)
	_update_arrow(arrow_scale, overall_color)

func _calculate_reflections(start_pos: Vector2, dir: Vector2, remaining_dist: float, color: Color, width: float):
	_points_cache.clear()
	_points_cache.append(start_pos)
	
	var space_state = get_world_2d().direct_space_state
	var current_pos = start_pos
	var current_dir = dir
	
	var query = PhysicsRayQueryParameters2D.create(current_pos, current_pos + current_dir * remaining_dist)
	if _player_rid.is_valid():
		query.exclude = [_player_rid]
	
	for i in range(max_bounces):
		query.from = current_pos
		query.to = current_pos + current_dir * remaining_dist
		
		var result = space_state.intersect_ray(query)
		
		if result:
			var hit_point = result.position
			var hit_normal = result.normal
			
			_points_cache.append(hit_point)
			
			var dist_travelled = current_pos.distance_to(hit_point)
			remaining_dist -= dist_travelled
			
			if remaining_dist <= 0:
				break
				
			current_dir = current_dir.bounce(hit_normal)
			current_pos = hit_point + hit_normal * 1.5
		else:
			_points_cache.append(current_pos + current_dir * remaining_dist)
			break
			
	line_node.points = _points_cache
	line_node.width = width
	line_node.default_color = color

func _update_arrow(arrow_scale: float, color: Color):
	var point_count = _points_cache.size()
	if point_count > 1:
		var last_pt = _points_cache[point_count - 1]
		var prev_pt = _points_cache[point_count - 2]
		
		arrow_node.global_position = last_pt
		arrow_node.rotation = (last_pt - prev_pt).angle()
		arrow_node.scale = Vector2(arrow_scale, arrow_scale)
		arrow_node.modulate = color
	else:
		arrow_node.hide()