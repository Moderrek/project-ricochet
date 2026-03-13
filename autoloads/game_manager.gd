extends Node

# Exports
@export var time_limit: float = 180.0 # 3 minutes
@export var levels_data: Array[LevelData] = []

# Signals
signal time_out
signal coins_changed(new_amount: int)
signal boost_changed(new_amount: float)
signal camera_shake_request(strength: float)

# Game State
var is_game_running: bool = false
var cez_coins: int = 0
var boost_level: float = 0.0
var max_boost: float = 100.0
var boost_drain_rate: float = 10.0 # per s
var time_left: float = 0.0
var is_timer_active: bool = false
var current_level_index: int = 0

var player_scene: PackedScene = preload("res://scenes/entities/player/player.tscn")

func get_current_level_data() -> LevelData:
	if current_level_index < levels_data.size():
		return levels_data[current_level_index]
	return null

func create_player() -> Node2D:
	if not player_scene:
		push_error("Cannot create player")
		return null
	
	return player_scene.instantiate()

func _init_run_state() -> void:
	cez_coins = 0
	time_left = time_limit
	is_game_running = true
	is_timer_active = false
	print("Initialized Game State")

func start_game():
	print("Starting game...")
	_init_run_state()
	current_level_index = 0
	
	var first_level = get_current_level_data()
	if first_level:
		_change_level(first_level)
	else:
		push_error("Levels are not configured in GameManager")

func start_test_scene(scene_path: String) -> LevelData:
	if is_game_running: return
	_init_run_state()

	for i in range(levels_data.size()):
		var data: LevelData = levels_data[i]
		if not data:
			continue

		var target_path = data.scene_path
		if target_path.begins_with("uid://"):
			var uid_int = ResourceUID.text_to_id(target_path)
			target_path = ResourceUID.get_id_path(uid_int)
		
		if target_path == scene_path:
			current_level_index = i
			return data
	
	push_warning("Testing scene is not in GameManager. Using default settings.")

	var fallback = LevelData.new()
	fallback.requires_player = true
	fallback.has_timer = true
	return fallback

func load_next_level():
	current_level_index += 1
	var next_level = get_current_level_data()
	_change_level(next_level)

func _change_level(level: LevelData) -> void:
	if level == null:
		SceneChanger.change_scene_smooth("res://scenes/menus/end_screen.tscn")
		is_game_running = false
		return
	SceneChanger.change_scene_smooth(level.scene_path)
	
func _process(delta):
	# Timer drain
	if is_timer_active && is_game_running:
		time_left -= delta
		if time_left <= 0:
			time_left = 0
			is_timer_active = false
			is_game_running = false
			time_out.emit()
			SceneChanger.change_scene_smooth("res://scenes/menus/end_screen.tscn")
	
	# Boost Drain
	if boost_level > 0:
		boost_level -= delta * boost_drain_rate
		if boost_level < 0:
			boost_level = 0
		boost_changed.emit(boost_level)

func add_coins(amount: int):
	cez_coins += amount
	coins_changed.emit(cez_coins)

func add_boost(amount: float) -> void:
	boost_level = clamp(boost_level + amount, 0.0, max_boost)
	boost_changed.emit(boost_level)
