extends BaseLevel

@onready var tutorial_ui: Control = $TutorialUI

var has_shot: bool = false

func _on_level_loaded() -> void:
	if is_cinematic_mode:
		tutorial_ui.visible = false

func _on_player_shot() -> void:
	if has_shot:
		return
	has_shot = true

	var tween := create_tween()
	tween.tween_property(tutorial_ui, "modulate:a", 0.0, 1.0).\
		set_trans(Tween.TRANS_SINE)
	
	tween.tween_callback(tutorial_ui.queue_free)

