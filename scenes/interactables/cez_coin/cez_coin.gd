extends Area2D

@export var value: int = 1

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		_collect()

func _collect():
	# Blocking collider.
	set_deferred("monitoring", false)
	
	GameManager.add_coins(value)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 80, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	
	tween.finished.connect(queue_free)
