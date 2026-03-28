extends CanvasLayer
class_name PhotoPopup

@onready var photo_texture: TextureRect = %PhotoTexture
@onready var title_label: Label = %TitleLabel
@onready var description_label: Label = %DescriptionLabel
@onready var close_button: Button = %CloseButton

var _is_closing: bool = false

func _ready() -> void:
	hide()

	close_button.pressed.connect(_on_close_pressed)

	if PhotoManager:
		PhotoManager.photo_unlocked.connect(_on_photo_unlocked)
	else:
		printerr("PhotoManager autoload not found. Please ensure it is set up correctly.")

func _unhandled_input(event: InputEvent) -> void:
	if not visible: return

	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_on_close_pressed()

func _on_photo_unlocked(photo: PhotoData) -> void:
	_is_closing = false

	get_tree().paused = true
	Engine.time_scale = 0.0

	title_label.text = photo.title
	description_label.text = photo.description
	photo_texture.texture = null


	var texture: Texture = _dynamic_load_texture(photo.image_path)
	if texture:
		photo_texture.texture = texture

	show()

	close_button.grab_focus()

func _dynamic_load_texture(path: String) -> Texture:
	if ResourceLoader.exists(path):
		var texture: Texture = load(path)
		if texture:
			return texture
		else:
			printerr("Failed to load texture at path: %s" % path)
			return null
	else:
		printerr("Texture path does not exist: %s" % path)
		return null

func _on_close_pressed() -> void:
	if _is_closing: return
	_is_closing = true

	hide()

	photo_texture.texture = null
	Engine.time_scale = 1.0
	get_tree().paused = false
