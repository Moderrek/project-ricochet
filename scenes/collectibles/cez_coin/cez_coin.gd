extends BaseCollectible
class_name CezCoinCollectible

@export var value: int = 1

func _apply_effect() -> void:
	GameManager.add_coins(value)

