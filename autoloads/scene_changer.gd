extends CanvasLayer

@onready var color_rect = $Background

const FADE_DURATION: float = 0.3

func _ready():
	color_rect.color = Color(0.0, 0.0, 0.0, 0.0)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func change_scene_smooth(path: String):
	# Block interface
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP

	# Fade to black
	var fade_in = create_tween()
	fade_in.tween_property(color_rect, "color", Color(0.0, 0.0, 0.0, 1.0), FADE_DURATION)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await fade_in.finished

	# Change scene
	get_tree().change_scene_to_file(path)

	# Fade from black
	var fade_out = create_tween()
	fade_out.tween_property(color_rect, "color", Color(0.0, 0.0, 0.0, 0.0), FADE_DURATION)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await fade_out.finished

	# Unblock interface
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
