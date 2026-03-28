extends BaseCollectible
class_name PhotoCollectible

@export_range(0.0, 1.0) var spawn_change: float = 0.5

func _ready() -> void:
	super()
	if not PhotoManager:
		printerr("PhotoManager autoload not found. Please ensure it is set up correctly.")
		queue_free()
		return

	var available_photo: PhotoData = PhotoManager.get_random_locked_photo()
	if not available_photo:
		print("INFO: No locked photos available to unlock.")
		queue_free()
		return

	if randf() > spawn_change:
		queue_free()

func _on_collect() -> void:
	var unlocked_photo: PhotoData = PhotoManager.get_random_locked_photo()
	if not unlocked_photo:
		print("WARN: No locked photos available to unlock.")
		return
	
	print("INFO: Unlocked photo: %s" % unlocked_photo.title)

	PhotoManager.unlock_photo(unlocked_photo)
