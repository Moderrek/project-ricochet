extends StaticBody2D

@export_category("Vending Machine")
@export var coffee_scene: PackedScene
@export var coffee_count: int = 1
@export var impact_threshold: float = 200.0

@export_category("Drop Physics")
@export var drop_distance: float = 80.0
@export var drop_spread: float = 50.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var spawn_point: Marker2D = $DropSpawnPoint

var hits_left: int
var is_shaking: bool = false

func _ready() -> void:
	hits_left = coffee_count

func hit(impact_velocity: float) -> void:
	if is_shaking or impact_velocity < impact_threshold:
		return
	
	is_shaking = true
	_play_shake_animation()
	
	if hits_left > 0:
		hits_left -= 1
		call_deferred("_spawn_coffee")

func _play_shake_animation() -> void:
	var tween = create_tween()
	var start_pos = Vector2.ZERO 
	
	tween.tween_property(sprite, "position", start_pos + Vector2(12, 0), 0.05)
	tween.tween_property(sprite, "position", start_pos + Vector2(-12, 0), 0.05)
	tween.tween_property(sprite, "position", start_pos + Vector2(6, 0), 0.05)
	tween.tween_property(sprite, "position", start_pos, 0.05)
	
	tween.finished.connect(func(): is_shaking = false)

func _spawn_coffee() -> void:
	if not coffee_scene:
		printerr("Coffee Scene is not assigned in vending machine")
		return
	
	var coffee = coffee_scene.instantiate()
	get_tree().current_scene.add_child(coffee)
	
	coffee.global_position = spawn_point.global_position
	
	var jump_tween = coffee.create_tween()
	jump_tween.set_parallel(true)
	
	var random_x_offset = randf_range(-drop_spread, drop_spread)
	var target_pos = coffee.global_position + Vector2(random_x_offset, drop_distance)
	
	jump_tween.tween_property(coffee, "global_position:x", target_pos.x, 0.4).set_trans(Tween.TRANS_LINEAR)
	jump_tween.tween_property(coffee, "global_position:y", target_pos.y, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	if coffee.has_method("play_hover_animation"):
		jump_tween.chain().tween_callback(coffee.play_hover_animation)
