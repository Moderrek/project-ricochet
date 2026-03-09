extends Control

@onready var start_button = $MarginContainer/VBoxContainer/StartButton
@onready var coin_label = $MarginContainer/VBoxContainer/CoinLabel

func _update_ui():
	_update_coin_label(SaveManager.total_coins)
	
func _update_coin_label(amount):
	coin_label.text = "Coins: " + str(amount)

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	$MarginContainer/VBoxContainer/ExitButton.pressed.connect(_on_exit_pressed)
	
	SaveManager.total_coins_changed.connect(_update_coin_label)
	
	_update_ui()

func _on_start_pressed():
	GameManager.start_game()

func _on_exit_pressed():
	get_tree().quit() # works on PC, in HTML5 does nothing.
