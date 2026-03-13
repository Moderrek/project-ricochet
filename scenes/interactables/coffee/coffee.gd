extends Area2D

@export var boost_amount: float = 50.0

var _hover_tween: Tween

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	#_start_hover_animation()

func _start_hover_animation() -> void:
	_hover_tween = create_tween().set_loops()
	
	_hover_tween.tween_property(self, "position:y", -5.0, 1.0).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_hover_tween.tween_property(self, "position:y", 5.0, 1.0).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_collect()

func _collect() -> void:
	set_deferred("monitoring", false)
	
	if _hover_tween and _hover_tween.is_valid():
		_hover_tween.kill()
	
	GameManager.add_boost(boost_amount)
	
	var collect_tween = create_tween()
	collect_tween.set_parallel(true)
	
	collect_tween.tween_property(self, "position:y", -80.0, 0.4).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	collect_tween.tween_property(self, "modulate:a", 0.0, 0.4)
	
	collect_tween.chain().tween_callback(queue_free)
