extends PathFollow2D

const SPEED: float = 0.02

func _process(delta: float) -> void:
	progress_ratio += SPEED * delta
