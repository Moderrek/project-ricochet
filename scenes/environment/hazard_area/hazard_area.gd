@tool
@icon("res://assets/icons/hazard_icon.png")
extends Area2D
class_name HazardArea

@export var hazard_color := Color(0.98, 0.49, 0.49, 0.5)

func _ready() -> void:
	if Engine.is_editor_hint():
		set_process(true)
	else:
		set_process(false)
		body_entered.connect(_on_body_entered)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	for child in get_children():
		if child is CollisionPolygon2D and child.polygon.size() >= 3:
			draw_set_transform_matrix(child.transform)
			draw_colored_polygon(child.polygon, hazard_color)
			draw_set_transform_matrix(Transform2D.IDENTITY)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	if not _has_polygon():
		warnings.append("HazardArea requires at least one CollisionPolygon2D with a valid polygon (at least 3 points).")
	
	return warnings

func _has_polygon() -> bool:
	for child in get_children():
		if child is CollisionPolygon2D and child.polygon.size() >= 3:
			return true
	return false

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if not GameManager:
		print("WARN: GameManager not found. Cannot restart level.")
		return

	if not GameManager.has_method("restart_current_level"):
		printerr("ERROR: GameManager does not have method 'restart_current_level'. Cannot restart level.")
		return

	GameManager.restart_current_level()
