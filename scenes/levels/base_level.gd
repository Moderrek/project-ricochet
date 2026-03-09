extends Node2D
class_name BaseLevel

# Nodes
@onready var player_spawn: Marker2D = $PlayerSpawnMarker
@onready var level_camera: Camera2D = $LevelCamera

# Variables
var player: Node2D = null

# Shake
var shake_strength: float = 0.0
var shake_decay: float = 5.0

func _ready():
	_spawn_player()

func _spawn_player():
	player = GameManager.create_player()
	$Entities.add_child(player)
	player.set_deferred("global_position", player_spawn.global_position)
	level_camera.global_position = player_spawn.global_position
	
	GameManager.start_timer()

func _physics_process(_delta: float):
	if player:
		level_camera.global_position = player.global_position
