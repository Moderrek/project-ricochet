extends BaseLevel

func _on_player_shot() -> void:
	GameManager.is_timer_active = true

func _on_level_started() -> void:
	GameManager.is_timer_active = false
