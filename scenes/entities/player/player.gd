@icon("res://assets/icons/player_icon.png")
extends RigidBody2D
class_name Player

signal player_shot

@export_range(0, 5000, 1, "suffix:px") var max_force: float = 2400.0
@export_range(0, 10, 0.1, "suffix:x") var power_multiplier: float = 5.0
@export_range(0, 1000, 1, "suffix:px") var click_radius: float = 120.0

var is_aiming := false 
var max_drag_distance: float # will be calculated at _ready

@onready var particles: CPUParticles2D = $HitParticles
@onready var death_particles: CPUParticles2D = $DeathParticles
@onready var aim_line: AimLine = $AimLine
@onready var bounce_sound: AudioStreamPlayer2D = $BounceSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound
@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound

var _is_dead: bool = false

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

func _on_body_entered(_body):
	var speed = linear_velocity.length()

	# Sound
	if speed > 50.0:
		if bounce_sound:
			bounce_sound.pitch_scale = 0.8 + (speed / max_force) * 0.4
			bounce_sound.play()

	
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

func shatter_and_respawn(spawn_position: Vector2):
	if _is_dead: return
	_is_dead = true

	set_deferred("freeze", true)
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0

	$Sprite2D.hide()
	is_aiming = false
	if aim_line:
		aim_line.stop_aiming()
	
	if death_particles:
		death_particles.restart()
	
	if death_sound:
		death_sound.play()
	GameManager.camera_shake_request.emit(30.0)

	var tween = create_tween()
	tween.tween_interval(1.2)
	tween.tween_callback(func():
		global_position = spawn_position
		$Sprite2D.show()
		set_deferred("freeze", false)
		_is_dead = false
	)

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

func _shoot():
	var drag_vector = get_drag_vector()
	var current_multiplier = power_multiplier
	
	var final_force = drag_vector * current_multiplier
	
	if final_force.length() > max_force:
		final_force = final_force.limit_length(max_force)
	
	if GameManager.current_boost_level > 0:
		final_force *= 1.5
	
	apply_central_impulse(final_force)
	player_shot.emit()
	if shoot_sound:
		shoot_sound.pitch_scale = 0.8 + (final_force.length() / max_force) * 0.4
		shoot_sound.play()
