extends BaseCollectible

@export var value: int = 1

func _apply_effect() -> void:
	GameManager.add_coins(value)
