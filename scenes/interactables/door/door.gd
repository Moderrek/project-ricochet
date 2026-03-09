extends Area2D

@export_file("*.tscn") var next_level_path: String

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if not body.is_in_group("player"):
		return
	if next_level_path == "":
		push_warning("You forgot to set next level path in Door.")
		return
	
	SceneChanger.change_scene_smooth(next_level_path)
