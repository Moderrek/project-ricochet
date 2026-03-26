extends Node

signal total_coins_changed(new_amount: int)

const SAVE_PATH = "user://save.json"

var save_data = {
	"total_coins": 0,
	"unlocked_skins": ["default_skin"],
	"high_scores": {}
}

func _ready() -> void:
	load_game()

func save_game() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		printerr("ERROR: could not open file for writing: %s" % [SAVE_PATH])
		return
	
	var json_string = JSON.stringify(save_data)

	# Saving to file
	file.store_string(json_string)
	file.close()

	print("INFO: game state saved successfully.")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("INFO: no save file found. starting fresh.")
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		printerr("ERROR: could not read existing save file: %s" % [SAVE_PATH])
		return
	
	# Converting string into json
	var json_string = file.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(json_string)

	if parse_result == OK:
		var loaded_data = json.get_data()
		for key in loaded_data.keys():
			save_data[key] = loaded_data[key]
		print("INFO: game state loaded successfully.")
	
	file.close()

func add_coins(amount: int) -> void:
	save_data["total_coins"] += amount
	total_coins_changed.emit(save_data["total_coins"])
	save_game()

func get_coins() -> int:
	return save_data["total_coins"]

func is_skin_unlocked(skin_id: String) -> bool:
	return skin_id in save_data["unlocked_skins"]

func unlock_skin(skin_id: String) -> void:
	if is_skin_unlocked(skin_id):
		return
	save_data["unlocked_skins"].append(skin_id)
	save_game()
