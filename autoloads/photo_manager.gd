extends Node

signal photo_unlocked(photo: PhotoData)

var _photo_db: PhotoDatabase = preload("res://resources/photos/photo_database.tres")
var _unlocked_photo_ids: Array[String] = []

func _ready() -> void:
	_load_photos_from_save()

func get_random_locked_photo() -> PhotoData:
	var locked_photos: Array[PhotoData] = get_all_locked_photos()
	if len(locked_photos) == 0:
		return null
	return locked_photos[randi() % locked_photos.size()]

func unlock_photo(photo: PhotoData) -> void:
	if photo.id in _unlocked_photo_ids:
		return
	_unlocked_photo_ids.append(photo.id)
	photo_unlocked.emit(photo)

func get_all_unlocked_photos() -> Array[PhotoData]:
	var unlocked_photos: Array[PhotoData] = []

	for photo in _photo_db.photos:
		if photo.id in _unlocked_photo_ids:
			unlocked_photos.append(photo)

	return unlocked_photos

func get_all_locked_photos() -> Array[PhotoData]:
	var locked_photos: Array[PhotoData] = []

	for photo in _photo_db.photos:
		if photo.id not in _unlocked_photo_ids:
			locked_photos.append(photo)

	return locked_photos

func _load_photos_from_save() -> void:
	pass