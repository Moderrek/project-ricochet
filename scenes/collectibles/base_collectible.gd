extends Area2D
class_name BaseCollectible

var _is_collected: bool = false
var _collect_tween: Tween

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not _is_collected and body.is_in_group("player"):
		collect()

func collect() -> void:
	if _is_collected:
		return
	_is_collected = true
	set_deferred("monitoring", false)

	# invokes virtual function
	_on_collect()

	play_collect_animation()

func is_collected() -> bool:
	return _is_collected

func play_collect_animation() -> void:
	if _collect_tween and _collect_tween.is_valid():
		_collect_tween.kill()

	_collect_tween = create_tween()
	_collect_tween.set_parallel(true)
	
	_collect_tween.tween_property(self, "position:y", -80.0, 0.4).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_collect_tween.tween_property(self, "modulate:a", 0.0, 0.4)
	
	_collect_tween.chain().tween_callback(queue_free)

func _on_collect() -> void: pass # virtual
