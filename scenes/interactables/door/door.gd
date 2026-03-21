extends Area2D
class_name Door

@export var next_level: PackedScene

func trigger() -> void:
	if next_level == null:
		push_error("Door.triger(): next_level is not set; cannot change scene.")
		return

	var path := next_level.resource_path
	if path == "":
		push_error("Door.triger(): next_level does not have a valid resource path; cannot change scene.")
		return

	SceneChanger.change_scene_smooth(path)

func _ready():
	assert(next_level != null, "next_level not set!")

	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if not body.is_in_group("player"):
		return

	trigger()
