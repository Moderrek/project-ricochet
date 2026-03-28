extends Resource
class_name PhotoData

@export var id: String = "unique_photo_id"
@export var title: String = "Photo Title"
@export_multiline var description: String = "A brief description of the photo."
@export var coin_reward: int = 10
@export_file("*.png", "*.jpg", "*.webp") var image_path: String