extends CanvasLayer

@onready var time_label = $Panel/TimeLabel
@onready var coin_label = $Control/MarginContainer/HBoxContainer/CoinLabel
@onready var boost_bar = $BoostBar

var _coin_tween: Tween
var _boost_tween: Tween

var _last_displayed_seconds: int = -1

func _ready():
	call_deferred("_setup_ui")
	
	GameManager.coins_changed.connect(_on_coins_changed)
	GameManager.boost_changed.connect(_on_boost_changed)
	
	_update_coins(GameManager.cez_coins)
	
	boost_bar.max_value = GameManager.max_boost
	boost_bar.value = GameManager.boost_level
	boost_bar.modulate.a = 0.0

func _setup_ui():
	coin_label.pivot_offset = coin_label.size / 2.0

func _process(_delta):
	if GameManager.is_timer_active:
		var time = GameManager.time_left
		var current_seconds = int(time)
		
		if current_seconds != _last_displayed_seconds:
			var minutes = current_seconds / 60
			var seconds = current_seconds % 60
			time_label.text = "%02d:%02d" % [minutes, seconds]
			_last_displayed_seconds = current_seconds
		
		if time <= 30.0:
			var pulse = (sin(Time.get_ticks_msec() / 150.0) + 1.0) / 2.0
			time_label.modulate = Color(1.0, pulse, pulse)
		else:
			time_label.modulate = Color.WHITE
	else:
		if time_label.text != "--:--":
			time_label.text = "--:--"
			time_label.modulate = Color.WHITE
			_last_displayed_seconds = -1

func _update_coins(new_amount: int):
	coin_label.text = "Cez Coins: " + str(new_amount)

func _on_coins_changed(new_amount: int):
	_update_coins(new_amount)
	
	if _coin_tween and _coin_tween.is_valid():
		_coin_tween.kill()
		
	_coin_tween = create_tween()
	_coin_tween.tween_property(coin_label, "scale", Vector2(1.3, 1.3), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_coin_tween.parallel().tween_property(coin_label, "modulate", Color(1.0, 0.8, 0.2), 0.05)
	
	_coin_tween.tween_property(coin_label, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_coin_tween.parallel().tween_property(coin_label, "modulate", Color.WHITE, 0.15)

func _on_boost_changed(new_amount: float) -> void:
	boost_bar.value = new_amount
	
	if _boost_tween and _boost_tween.is_valid():
		_boost_tween.kill()
		
	_boost_tween = create_tween()
	if new_amount > 0 and boost_bar.modulate.a < 1.0:
		_boost_tween.tween_property(boost_bar, "modulate:a", 1.0, 0.2)
	elif new_amount <= 0 and boost_bar.modulate.a > 0.0:
		_boost_tween.tween_property(boost_bar, "modulate:a", 0.0, 0.5)
