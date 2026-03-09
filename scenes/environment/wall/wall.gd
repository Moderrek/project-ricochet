@tool
extends StaticBody2D

@export var size: Vector2 = Vector2(100, 20):
		set(value):
			size = value
			if Engine.is_editor_hint():
				_update_wall()

func _ready():
	_update_wall()
	
func _update_wall():
	var rect = get_node_or_null("ColorRect")
	if rect:
		rect.size = size
		rect.position = -size / 2
	var col = get_node_or_null("CollisionShape2D")
	if col:
		var shape = col.shape as RectangleShape2D
		if shape:
			shape.size = size
