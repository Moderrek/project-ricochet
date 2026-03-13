extends Node2D
class_name BaseLevel

# Disables player, camera and HUD. Used for Main Menu background.
@export var is_cinematic_mode: bool = false

# Nodes
@onready var player_spawn: Marker2D = $PlayerSpawnMarker
@onready var level_camera: Camera2D = $LevelCamera

# Variables
var player: Node2D = null

# Shake
var shake_strength: float = 0.0
var shake_decay: float = 5.0

func _ready():
	if is_cinematic_mode:
		if has_node("LevelCamera"):
			$LevelCamera.enabled = false
		if has_node("HUD"):
			$HUD.visible = false
		return

	var level_data: LevelData

	if not GameManager.is_game_running:
		# F6
		print("Detected Level Testing mode")
		level_data = GameManager.start_test_scene(scene_file_path)
	else:
		# Normal
		level_data = GameManager.get_current_level_data()

	var requires_player = true
	var has_timer = true

	if level_data:
		requires_player = level_data.requires_player
		has_timer = level_data.has_timer
	

	if requires_player:
		_spawn_player()
	
	GameManager.is_timer_active = has_timer

func _spawn_player():
	player = GameManager.create_player()
	$Entities.add_child(player)
	player.set_deferred("global_position", player_spawn.global_position)

	var remote_transform = RemoteTransform2D.new()
	remote_transform.remote_path = level_camera.get_path()
	player.add_child(remote_transform)

	level_camera.global_position = player_spawn.global_position
	level_camera.reset_smoothing()
