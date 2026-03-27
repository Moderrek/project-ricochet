extends Node2D

@onready var menu_buttons_container = $UILayer/MainMargin/MainLayout/ContentArea/MenuButtons
@onready var play_button: Button = $UILayer/MainMargin/MainLayout/ContentArea/MenuButtons/PlayButton
@onready var lockers_button: Button = $UILayer/MainMargin/MainLayout/ContentArea/MenuButtons/LockersButton
@onready var quit_button: Button = $UILayer/MainMargin/MainLayout/ContentArea/MenuButtons/QuitButton
@onready var news_button: Button = $UILayer/MainMargin/MainLayout/ContentArea/NewsCard/MarginContainer/VBoxContainer/NewsButton
@onready var coin_amount_label: Label = $UILayer/MainMargin/MainLayout/TopBar/CoinDisplay/CoinAmount
@onready var hover_sound: AudioStreamPlayer = $HoverSound
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var click_particles: CPUParticles2D = $ClickParticles

func _ready() -> void:
	set_process_unhandled_input(true)

	play_button.grab_focus()

	_update_coin_display(SaveManager.get_coins())
	SaveManager.total_coins_changed.connect(_update_coin_display)
	
	if OS.has_feature("web"):
		quit_button.hide()
	
	_setup_buttons()
	NetworkManager.fetch_news(_on_news_loaded, _on_news_error)
	
func _setup_buttons() -> void:
	var buttons = menu_buttons_container.get_children()
	buttons.append(news_button)

	for button in buttons:
		if button is Button:
			button.pivot_offset = button.size / 2.0
			button.mouse_entered.connect(_on_button_hover.bind(button))
			button.mouse_exited.connect(_on_button_unhover.bind(button))
			button.pressed.connect(_on_button_pressed.bind(button))


func _update_coin_display(amount: int) -> void:
	coin_amount_label.text = str(amount)

func _on_button_hover(button: Button):
	hover_sound.pitch_scale = randf_range(0.95, 1.05)
	hover_sound.play()

	var tween = button.create_tween()
	tween.tween_property(button, "scale", Vector2.ONE * 1.04, 0.1)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
func _on_button_unhover(button: Button):
	var tween = button.create_tween()
	tween.tween_property(button, "scale", Vector2.ONE, 0.15)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_button_pressed(button: Button):
	click_sound.pitch_scale = randf_range(0.9, 1.1)
	click_sound.play()

	click_particles.global_position = get_global_mouse_position()
	click_particles.restart()

	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.05).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2.ONE * 1.04, 0.15).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	_handle_button_action(button)

func _handle_button_action(button: Button) -> void:
	var action_name = button.name

	match action_name:
		"PlayButton":
			await get_tree().create_timer(0.2).timeout
			GameManager.start_game()

		"LockersButton":
			print("Moduł szafek jeszcze w budowie.")

		"NewsButton":
			OS.shell_open("https://cez.lodz.pl/2026/03/06/konkurs-school-games-2026/")
			
			SaveManager.add_coins(50)
			
			button.disabled = true
			button.text = "Odebrano!"

		"QuitButton":
			get_tree().quit()

func _on_news_loaded(news_data: Variant) -> void:
	print(news_data)

func _on_news_error(error_message: String) -> void:
	print("ERROR: NetworkManager: ", error_message)

