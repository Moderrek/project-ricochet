extends CanvasLayer
class_name PhotoPopup

@onready var blur_bg: ColorRect = $Blur
@onready var vignette_bg: ColorRect = $Vignette
@onready var center_container: CenterContainer = $CenterContainer
@onready var popup_panel: PanelContainer = $CenterContainer/OuterMargin/PopupPanel
@onready var photo_texture: TextureRect = %PhotoTexture
@onready var title_label: Label = %TitleLabel
@onready var description_label: Label = %DescriptionLabel
@onready var close_button: Button = %CloseButton
@onready var close_button_x: Button = %CloseButtonX

var _is_closing: bool = false
var _tween: Tween

func _ready() -> void:
	hide()
	close_button.pressed.connect(_on_close_pressed)
	close_button_x.pressed.connect(_on_close_pressed)

	if PhotoManager:
		PhotoManager.photo_unlocked.connect(_on_photo_unlocked)
	else:
		printerr("PhotoManager autoload not found.")

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

	_animate_open()

func _animate_open() -> void:
	show()
	
	if _tween and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.set_ignore_time_scale(true)
	_tween.set_parallel(true)

	blur_bg.modulate.a = 0.0
	vignette_bg.modulate.a = 0.0
	center_container.modulate.a = 0.0
	popup_panel.scale = Vector2(0.5, 0.5)

	_tween.tween_property(blur_bg, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tween.tween_property(vignette_bg, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tween.tween_property(center_container, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	_tween.tween_property(popup_panel, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	_tween.finished.connect(func(): close_button.grab_focus())

func _dynamic_load_texture(path: String) -> Texture:
	if ResourceLoader.exists(path):
		var texture: Texture = load(path)
		if texture:
			return texture
		return null
	return null

func _on_close_pressed() -> void:
	if _is_closing: return
	_is_closing = true

	if _tween and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.set_ignore_time_scale(true)
	_tween.set_parallel(true)

	_tween.tween_property(blur_bg, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_tween.tween_property(vignette_bg, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_tween.tween_property(center_container, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	_tween.tween_property(popup_panel, "scale", Vector2(0.8, 0.8), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	_tween.finished.connect(_finish_close)

func _finish_close() -> void:
	hide()

	photo_texture.texture = null
	Engine.time_scale = 1.0
	get_tree().paused = false
