extends CanvasLayer
class_name HUD

var _coin_tween: Tween
var _boost_tween: Tween

@onready var time_label = $Panel/TimeLabel
@onready var coin_label = $Control/MarginContainer/HBoxContainer/CoinLabel
@onready var boost_bar  = $BoostBar

func _ready():
	call_deferred("_setup_ui")
	
	GameManager.coins_changed.connect(_on_coins_changed)
	GameManager.boost_changed.connect(_on_boost_changed)
	GameManager.time_ticked.connect(_on_time_ticked)
	
	_update_coins(GameManager.current_collected_coins)
	
	boost_bar.max_value  = GameManager.max_boost
	boost_bar.value      = GameManager.current_boost_level
	boost_bar.modulate.a = 0.0

func _process(_delta):
	if GameManager.is_timer_active:
		if GameManager.timer_seconds <= 30.0:
			var pulse = (sin(Time.get_ticks_msec() / 150.0) + 1.0) / 2.0
			time_label.modulate = Color(1.0, pulse, pulse)
		else:
			time_label.modulate = Color.WHITE

func _setup_ui():
	coin_label.pivot_offset = coin_label.size / 2.0

func _update_coins(total_collected_coins: int):
	coin_label.text = "Monety: %d" % total_collected_coins

func _on_coins_changed(total_collected_coins: int):
	_update_coins(total_collected_coins)
	
	if _coin_tween and _coin_tween.is_valid():
		_coin_tween.kill()
		
	_coin_tween = create_tween()
	_coin_tween.tween_property(coin_label, "scale", Vector2(1.3, 1.3), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_coin_tween.parallel().tween_property(coin_label, "modulate", Color(1.0, 0.8, 0.2), 0.05)
	
	_coin_tween.tween_property(coin_label, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_coin_tween.parallel().tween_property(coin_label, "modulate", Color.WHITE, 0.15)

func _on_time_ticked(current_seconds: int) -> void:
	if current_seconds <= 0:
		time_label.text = "--:--"
		return

	@warning_ignore("integer_division")
	var minutes: int = current_seconds / 60
	var seconds: int = current_seconds % 60

	time_label.text = "%02d:%02d" % [minutes, seconds]

func _on_boost_changed(current_boost_level: float) -> void:
	boost_bar.value = current_boost_level
	
	if _boost_tween and _boost_tween.is_valid():
		_boost_tween.kill()
		
	_boost_tween = create_tween()
	if current_boost_level > 0 and boost_bar.modulate.a < 1.0:
		_boost_tween.tween_property(boost_bar, "modulate:a", 1.0, 0.2)
	elif current_boost_level <= 0 and boost_bar.modulate.a > 0.0:
		_boost_tween.tween_property(boost_bar, "modulate:a", 0.0, 0.5)
