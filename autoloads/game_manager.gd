extends Node

signal time_out
signal time_ticked(current_seconds: int, remaining_seconds: int)
signal coins_changed(total_coins_collected: int)
signal boost_changed(current_boost_level: float)
@warning_ignore("unused_signal") # signal is used in player and camera, but not emitted in GameManager itself
signal camera_shake_request(strength: float)


@export_category("Game Settings")
@export_range(0.0, 600.0, 1.0, "suffix:sec") var game_time: float = 180.0 # 3 minutes
@export var levels_data: Array[LevelData] = []
@export var player_scene: PackedScene = preload("res://scenes/entities/player/player.tscn")
@export_category("Boost Settings")
@export_range(0.0, 100.0, 1.0, "suffix:%") var max_boost: float = 100.0
@export_range(0.0, 10.0, 0.1, "suffix:%/s") var boost_drain_rate: float = 3.0 # per s

@onready var soundtrack: AudioStreamPlayer = $Soundtrack

var is_timer_active: bool = false
var is_game_running: bool = false
var timer_seconds: float = 0.0
var current_collected_coins: int = 0
var current_boost_level: float = 0.0
var current_level_index: int = 0

var _last_tick_seconds: int = -1

func _process(delta) -> void:
	if is_game_running:
		_process_game(delta)

func get_current_level_data() -> LevelData:
	if current_level_index < levels_data.size():
		return levels_data[current_level_index]
	return null

func create_player() -> Node2D:
	if not player_scene:
		push_error("Cannot create player")
		return null
	
	return player_scene.instantiate()

func start_game() -> void:
	print("Starting game...")
	_init_run_state()
	current_level_index = 0
	time_ticked.emit(int(timer_seconds), int(get_remaining_time()))

	var first_level = get_current_level_data()
	if first_level:
		_change_level(first_level)
	else:
		push_error("Levels are not configured in GameManager")

func start_test_scene(scene_path: String) -> LevelData:
	if is_game_running: 
		return get_current_level_data()
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

func add_coins(amount: int) -> void:
	current_collected_coins += amount
	if current_collected_coins < 0:
		current_collected_coins = 0
	coins_changed.emit(current_collected_coins)

func add_boost(amount: float) -> void:
	current_boost_level = clamp(current_boost_level + amount, 0.0, max_boost)
	boost_changed.emit(current_boost_level)

func get_time_spent() -> float:
	return timer_seconds

func get_remaining_time() -> float:
	return max(game_time - timer_seconds, 0.0)

func restart_current_level() -> void:
	call_deferred("_teleport_player_to_spawn")

func _teleport_player_to_spawn() -> void:
	var player_node: Player = get_tree().get_first_node_in_group("player")
	var spawn_marker: Marker2D = get_tree().get_first_node_in_group("spawn_point")
	if not player_node or not spawn_marker:
		push_error("Cannot restart level: Missing player or spawn point.")
		return
	player_node.shatter_and_respawn(spawn_marker.global_position)

func _change_level(level: LevelData) -> void:
	if level == null:
		is_game_running = false
		_end_game()
		SceneChanger.change_scene_to_end_screen()
		return
	
	SceneChanger.change_scene_smooth(level.scene_path)

func _init_run_state() -> void:
	is_game_running = true
	is_timer_active = false
	current_collected_coins = 0
	current_boost_level = 0.0
	timer_seconds = 0.0
	_last_tick_seconds = -1
	print("Initialized Game State")
	if soundtrack:
		soundtrack.play()

func _end_game() -> void:
	is_game_running = false
	is_timer_active = false
	if soundtrack:
		soundtrack.stop()
	

## Internal game loop processing. Called from _process when game is running.
func _process_game(delta: float) -> void:
	_timer(delta)
	_boost_drain(delta)

func _timer(delta: float) -> void:
	if not is_timer_active:
		return
	if timer_seconds >= game_time:
		return
	
	# Draining time.
	timer_seconds += delta

	# Checking for time out.
	var time_over: bool = timer_seconds >= game_time
	if time_over:
		timer_seconds = game_time
		is_timer_active = false
		is_game_running = false
		time_out.emit()
		_end_game()
		SceneChanger.change_scene_to_end_screen()
	
	# Emiting time tick signal every second.
	var current_sec = int(timer_seconds)
	if current_sec != _last_tick_seconds:
		_last_tick_seconds = current_sec
		time_ticked.emit(current_sec, int(get_remaining_time()))

func _boost_drain(delta: float) -> void:
	if current_boost_level <= 0.0:
		return

	# Draining boost over time.
	current_boost_level = clamp(current_boost_level - boost_drain_rate * delta, 0.0, max_boost)
	boost_changed.emit(current_boost_level)
