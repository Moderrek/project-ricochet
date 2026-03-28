extends CanvasLayer

@onready var resume_button = $VBoxContainer/ResumeButton
@onready var main_menu_button = $VBoxContainer/MainMenuButton
@onready var quit_button = $VBoxContainer/QuitButton

func _ready() -> void:
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

	hide()

	if OS.has_feature("web") and quit_button:
		quit_button.hide()
	

func _unhandled_input(event: InputEvent) -> void:
	if not GameManager.is_game_running:
		return
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused and not visible:
			return
		toggle_pause()

func toggle_pause() -> void:
	var is_paused = not get_tree().paused
	get_tree().paused = is_paused
	visible = is_paused
	Engine.time_scale = 0.0 if is_paused else 1.0

	if is_paused:
		if resume_button:
			resume_button.grab_focus()

func _on_resume_pressed() -> void:
	toggle_pause()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0

	hide()

	GameManager.is_game_running = false
	GameManager.is_timer_active = false

	SceneChanger.change_scene_smooth("res://scenes/menus/main_menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
