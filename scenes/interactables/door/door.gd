extends Area2D
class_name Door

@export var next_level: PackedScene

func trigger() -> void:
	SceneChanger.change_scene_smooth(next_level.resource_path)

func _ready():
	assert(next_level != null, "next_level not set!")

	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if not body.is_in_group("player"):
		return
	trigger()
