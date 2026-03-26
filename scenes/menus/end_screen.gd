extends Control

const TITLE_VICTORY_TEXT := "CEL OSIĄGNIĘTY!"
const TITLE_DEFEAT_TEXT  := "SPÓŹNIENIE!"
const VICTORY_COLOR      := Color("00aaff")
const DEFEAT_COLOR       := Color("ff3366")

@onready var title_label  = $Center/Panel/Margin/VBoxContainer/TitleLabel
@onready var stats_label  = $Center/Panel/Margin/VBoxContainer/StatsLabel
@onready var menu_button  = $Center/Panel/Margin/VBoxContainer/HorizontalButtonContainer/MenuButton
@onready var retry_button = $Center/Panel/Margin/VBoxContainer/HorizontalButtonContainer/RetryButton

func _ready():
	menu_button.pressed.connect(_on_menu_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	
	_panel_ease_in()	
	_setup_screen()

func _process(_delta):
	# Allow exiting to menu with Escape key
	if Input.is_action_just_pressed("ui_cancel"):
		_on_menu_pressed()
	
func _panel_ease_in():
	var panel = $Center/Panel
	panel.scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2.ONE, 0.4)\
		.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)

func _setup_screen():
	var time_spent := int(GameManager.get_time_spent())
	@warning_ignore("integer_division")
	var minutes = time_spent / 60
	var seconds = time_spent % 60

	# Apply collected coins during game to total coins in save.
	if GameManager.cez_coins > 0:
		SaveManager.add_coins(GameManager.cez_coins)
		GameManager.cez_coins = 0

	var is_win := GameManager.time_left > 0.0

	if is_win:
		title_label.text = TITLE_VICTORY_TEXT
		title_label.add_theme_color_override("font_color", VICTORY_COLOR)
	else:
		title_label.text = TITLE_DEFEAT_TEXT
		title_label.add_theme_color_override("font_color", DEFEAT_COLOR)
	stats_label.text = "Zebrano monet: %d\nPokonano w: %02dmin %02ds" % [GameManager.cez_coins, minutes, seconds]

func _on_menu_pressed():
	SceneChanger.change_scene_to_menu()

func _on_retry_pressed():
	GameManager.start_game()
