extends PathFollow2D
class_name CameraCinematic

const SPEED := 0.02

func _process(delta: float) -> void:
	progress_ratio += SPEED * delta

