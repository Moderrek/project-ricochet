extends CanvasLayer

const FADE_DURATION := 0.3 # Duration for fade in/out in seconds

@onready var background: ColorRect = $Background

func _ready() -> void:
	background.color = Color(0.0, 0.0, 0.0, 0.0)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE

func change_scene_smooth(path: String) -> void:
	background.mouse_filter = Control.MOUSE_FILTER_STOP

	# Fade to black
	var fade_in = create_tween()
	fade_in.tween_property(background, "color", Color(0.0, 0.0, 0.0, 1.0), FADE_DURATION)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await fade_in.finished

	# Change scene
	get_tree().change_scene_to_file(path)

	# Fade out to reveal new scene
	var fade_out = create_tween()
	fade_out.tween_property(background, "color", Color(0.0, 0.0, 0.0, 0.0), FADE_DURATION)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await fade_out.finished

	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
