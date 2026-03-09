extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return
	
	set_deferred("monitoring", false)
	
	GameManager.load_next_level()
