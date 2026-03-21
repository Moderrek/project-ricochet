extends RigidBody2D
class_name Player

# Exports
@export_range(0, 5000, 1, "suffix:px") var max_force: float = 2400.0
@export_range(0, 10, 0.1, "suffix:x") var power_multiplier: float = 5.0
@export_range(0, 1000, 1, "suffix:px") var click_radius: float = 120.0

# Nodes
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var aim_line: AimLine = $AimLine

# Variables
var is_aiming: bool = false 
var max_drag_distance: float

func _ready():
	input_pickable = false
	body_entered.connect(_on_body_entered)
	
	max_drag_distance = max_force / power_multiplier

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var mouse_pos = get_global_mouse_position()
			var distance = global_position.distance_to(mouse_pos)
			
			if distance <= click_radius:
				is_aiming = true
				aim_line.start_aiming()
		else:
			if is_aiming:
				is_aiming = false
				aim_line.stop_aiming()
				_shoot()

func _shoot():
	var drag_vector = get_drag_vector()
	var current_multiplier = power_multiplier
	
	
	var final_force = drag_vector * current_multiplier
	
	if final_force.length() > max_force:
		final_force = final_force.limit_length(max_force)
	
	if GameManager.boost_level > 0:
		final_force *= 1.5
	
	apply_central_impulse(final_force)

func _on_body_entered(_body):
	var speed = linear_velocity.length()
	
	# Communicate with environment
	if _body.has_method("hit"):
		_body.hit(speed)
	
	if speed > 150:
		# Run particles if exists
		if particles:
			particles.restart()
		
		# Calculate shake strength
		var shake_strength = speed * 0.01
		shake_strength = clamp(shake_strength, 0.0, 30.0)
		
		# Emit shake request
		GameManager.camera_shake_request.emit(shake_strength)

func get_drag_vector() -> Vector2:
	var drag_end = get_global_mouse_position()
	var impulse_vector = global_position - drag_end
	
	if impulse_vector.length() > max_drag_distance:
		impulse_vector = impulse_vector.limit_length(max_drag_distance)
		
	return impulse_vector

func get_aim_direction() -> Vector2:
	var drag_vec = get_drag_vector()
	if drag_vec.length() > 0:
		return drag_vec.normalized()
	return Vector2.ZERO
