extends Node2D

@onready var play_button: Button = $UILayer/MainMargin/MainLayout/ContentArea/MenuButtons/PlayButton
@onready var lockers_button: Button = $UILayer/MainMargin/MainLayout/ContentArea/MenuButtons/LockersButton
@onready var quit_button: Button = $UILayer/MainMargin/MainLayout/ContentArea/MenuButtons/QuitButton

@onready var news_button: Button = $UILayer/MainMargin/MainLayout/ContentArea/NewsCard/MarginContainer/VBoxContainer/NewsButton
@onready var coin_amount_label: Label = $UILayer/MainMargin/MainLayout/TopBar/CoinDisplay/CoinAmount

func _ready() -> void:
	_update_coin_display()
	
	if OS.has_feature("web"):
		quit_button.hide()
	else:
		quit_button.pressed.connect(_on_quit_pressed)

	play_button.pressed.connect(_on_play_pressed)
	lockers_button.pressed.connect(_on_lockers_pressed)
	news_button.pressed.connect(_on_news_pressed)
	
	play_button.grab_focus()

func _update_coin_display() -> void:
	coin_amount_label.text = str(SaveManager.total_coins)

func _on_play_pressed() -> void:
	GameManager.start_game()

func _on_lockers_pressed() -> void:
	print("Moduł szafek jeszcze w budowie.")

func _on_news_pressed() -> void:
	OS.shell_open("https://cez.lodz.pl/2026/03/06/konkurs-school-games-2026/")
	
	SaveManager.add_coins(50)
	_update_coin_display()
	
	news_button.disabled = true
	news_button.text = "Odebrano!"
	

func _on_quit_pressed() -> void:
	get_tree().quit()
