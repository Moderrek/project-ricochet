extends Node

# Signals
signal time_out
signal coins_changed(new_amount: int)
signal boost_changed(new_amount: float)
signal camera_shake_request(strength: float)

# Game State
var cez_coins: int = 0
var boost_level: float = 0.0
var max_boost: float = 100.0
var boost_drain_rate: float = 10.0 # per s

var time_left: float = 180.0
var is_timer_active: bool = false

var player_scene: PackedScene = preload("res://scenes/entities/player/player.tscn")

@export var levels_data: Array[LevelData] = []
var current_level_index: int = 0

func get_current_level_data() -> LevelData:
	if current_level_index < levels_data.size():
		return levels_data[current_level_index]
	return null

func create_player() -> Node2D:
	if not player_scene:
		push_error("Cannot create player")
		return null
	
	return player_scene.instantiate()

func start_game():
	current_level_index = 0
	cez_coins = 0
	time_left = 180.0
	
	var first_level = get_current_level_data()
	if first_level:
		SceneChanger.change_scene_smooth(first_level.scene_path)
	else:
		push_error("Levels are not configured in GameManager")

func load_next_level():
	current_level_index += 1
	var next_level = get_current_level_data()
	
	if next_level:
		SceneChanger.change_scene_smooth(next_level.scene_path)
	else:
		SceneChanger.change_scene_smooth("res://scenes/menus/end_screen.tscn")

func _process(delta):
	# Timer drain
	if is_timer_active:
		time_left -= delta
		if time_left <= 0:
			time_left = 0
			is_timer_active = false
			time_out.emit()
			SceneChanger.change_scene_smooth("res://scenes/menus/end_screen.tscn")
	
	# Boost Drain
	if boost_level > 0:
		boost_level -= delta * boost_drain_rate
		if boost_level < 0:
			boost_level = 0
		boost_changed.emit(boost_level)

func start_timer():
	time_left = 180.0
	is_timer_active = true

func add_coins(amount: int):
	cez_coins += amount
	coins_changed.emit(cez_coins)

func add_boost(amount: float) -> void:
	boost_level = clamp(boost_level + amount, 0.0, max_boost)
	boost_changed.emit(boost_level)
