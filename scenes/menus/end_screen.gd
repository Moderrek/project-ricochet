extends Control

@onready var title_label = $Center/Panel/Margin/VBoxContainer/TitleLabel
@onready var stats_label = $Center/Panel/Margin/VBoxContainer/StatsLabel
@onready var menu_button = $Center/Panel/Margin/VBoxContainer/HorizontalButtonContainer/MenuButton
@onready var retry_button = $Center/Panel/Margin/VBoxContainer/HorizontalButtonContainer/RetryButton

func _ready():
	menu_button.pressed.connect(_on_menu_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	
	var panel = $Center/Panel
	panel.scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	
	setup_screen()

func setup_screen():
	var time_spent = 180.0 - GameManager.time_left
	var minutes = int(time_spent) / 60
	var seconds = int(time_spent) % 60
	stats_label.text = "Cez Coins: %d\nCzas: %02d:%02d" % [GameManager.cez_coins, minutes, seconds]
	
	if GameManager.time_left > 0:
		title_label.text = "CEL OSIĄGNIĘTY!"
		title_label.add_theme_color_override("font_color", Color("00aaff")) # Dopaminowy błękit
	else:
		title_label.text = "SPÓŹNIENIE!"
		title_label.add_theme_color_override("font_color", Color("ff3366")) # Czerwony/Różowy alarmowy
	
	if GameManager.cez_coins > 0:
		SaveManager.add_coins(GameManager.cez_coins)
		GameManager.cez_coins = 0

func _on_menu_pressed():
	SceneChanger.change_scene_smooth("res://scenes/menus/main_menu.tscn")

func _on_retry_pressed():
	GameManager.start_game()
