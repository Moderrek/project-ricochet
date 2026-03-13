extends Resource
class_name LevelData

@export_group("Main Configuration")
@export var level_name: String = "Corridor"
@export_file("*.tscn") var scene_path: String

@export_group("Level Rules")
@export var requires_player: bool = true
@export var has_timer: bool = true
