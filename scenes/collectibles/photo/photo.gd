extends BaseCollectible
class_name PhotoCollectible

@export_range(0.0, 100, 0.1, "suffix:%") var spawn_chance: float = 50.0

func _ready() -> void:
	super()

	if not PhotoManager:
		printerr("PhotoManager autoload not found. Please ensure it is set up correctly.")
		queue_free()
		return

	if not PhotoManager.is_any_photo_locked():
		# There are no more locked photos to unlock
		# so player shouldnt be able to collect this collectible
		print("INFO: All photos are already unlocked.")
		queue_free()
		return

	if randf() > (spawn_chance / 100.0):
		queue_free()

func _on_collect() -> void:
	var photo: PhotoData = PhotoManager.get_random_locked_photo()
	if not photo:
		# There are no more locked photos to unlock
		print("INFO: All photos are already unlocked.")
		return
	
	PhotoManager.unlock_photo(photo)
	print("INFO: Unlocked photo: %s" % photo.title)
