extends BaseCollectible
class_name CoffeeCollectible

@export_category("Collectible")
@export_range(0.0, 100.0, 1.0, "suffix:MAX%") var boost_amount: float = 50.0 # maximum boost: 100 

var _hover_tween: Tween

func _apply_effect() -> void:
	GameManager.add_boost(boost_amount)

func play_collect_animation() -> void:
	if _hover_tween:
		_hover_tween.kill()
	super()

func play_hover_animation() -> void:
	if _hover_tween:
		_hover_tween.kill()
	
	_hover_tween = create_tween().set_loops()
	
	_hover_tween.tween_property(self, "position:y", -5.0, 1.0).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_hover_tween.tween_property(self, "position:y", 5.0, 1.0).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
