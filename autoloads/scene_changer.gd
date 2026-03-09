extends CanvasLayer

@onready var animation_player = $AnimationPlayer
@onready var color_rect = $Background

func _ready():
	color_rect.color = Color(0.0, 0.0, 0.0, 0.0)

func change_scene_smooth(path: String):
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	
	get_tree().change_scene_to_file(path)
	
	animation_player.play("fade_from_black")
	await animation_player.animation_finished
