extends CanvasLayer

const FADE_DURATION := 0.3 # Duration for fade in/out in seconds

@export var menu_scene: PackedScene = preload("res://scenes/menus/main_menu.tscn")
@export var end_screen_scene: PackedScene = preload("res://scenes/menus/end_screen.tscn")

@onready var background: ColorRect = $Background

func _ready() -> void:
	background.color = Color(0.0, 0.0, 0.0, 0.0)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE

func change_scene_smooth(path: String) -> void:
	if not ResourceLoader.exists(path):
		push_error("Scene path does not exist: " + path)
		return

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

func change_scene_immediate(path: String) -> void:
	get_tree().change_scene_to_file(path)

func change_scene_to_menu() -> void:
	if not menu_scene:
		push_error("Menu scene is not assigned in SceneChanger.")
		return
	change_scene_smooth(menu_scene.resource_path)

func change_scene_to_end_screen() -> void:
	if not end_screen_scene:
		push_error("End screen scene is not assigned in SceneChanger.")
		return
	change_scene_smooth(end_screen_scene.resource_path)
