@icon("res://assets/icons/coin_icon.png")
extends BaseCollectible
class_name CezCoinCollectible

@export var value: int = 1

func _on_collect() -> void:
	GameManager.add_coins(value)
