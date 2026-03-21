extends Node2D
class_name BaseLevel

# Disables player, camera and HUD. Used for Main Menu background.
@export var is_cinematic_mode: bool = false

# Nodes
@onready var player_spawn: Marker2D = $PlayerSpawnMarker
@onready var level_camera: Camera2D = $LevelCamera
@onready var hud: CanvasLayer = $HUD
@onready var entities_container: Node = $Entities

# Variables
var player: Player = null

# Shake
var shake_strength: float = 0.0
var shake_decay: float = 5.0

func _on_before_level_start() -> void: pass
func _on_level_started() -> void: pass
func _on_player_spawned(_player: Player) -> void: pass
func _on_player_shot() -> void: pass

func _ready():
	_validate_level()

	_setup_cinematic_mode()
	if is_cinematic_mode:
		return
	
	_on_before_level_start()

	_setup_ui()
	var level_data = _load_level_data()
	_apply_level_settings(level_data)

	_on_level_started()

func _validate_level() -> void:
	assert(player_spawn != null)
	assert(level_camera != null)
	assert(hud != null)
	assert(entities_container != null)

func _setup_cinematic_mode() -> void:
	if not is_cinematic_mode:
		return

	if level_camera:
		level_camera.enabled = false
	if hud:
		hud.visible = false
	
func _setup_ui() -> void:
	if level_camera:
		level_camera.enabled = true
	if hud:
		hud.visible = true

func _load_level_data() -> LevelData:
	if not GameManager.is_game_running:
		# Propably F6
		print("Detected Level Testing mode")
		return GameManager.start_test_scene(scene_file_path)
	
	return GameManager.get_current_level_data()

func _apply_level_settings(level_data: LevelData) -> void:
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

	if entities_container:
		entities_container.add_child(player)
	else:
		add_child(player)

	player.global_position = player_spawn.global_position

	var remote_transform = RemoteTransform2D.new()
	remote_transform.remote_path = level_camera.get_path()
	player.add_child(remote_transform)

	level_camera.global_position = player_spawn.global_position
	level_camera.reset_smoothing()

	_on_player_spawned(player)
	player.player_shot.connect(_on_player_shot)
