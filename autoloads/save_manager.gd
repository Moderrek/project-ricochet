## Manager responsible for persistent saving and loading of player progress
##
## Loads data at start.
## Uses JSON format to store data in the user directory.
## Manages coins, unlocked skins and high scores.
extends Node

## Emitted when the total amount of coins in the bank changes.
signal total_coins_changed(new_amount: int)

## Path to the save file. [code]user://[/code]. Ensures compatibility across Windows, Linux and HTML5.
const SAVE_PATH = "user://save.json"

## Dictionary for holding state.
var save_data = {
	"total_coins": 0,
	"unlocked_skins": ["default_skin"],
	"high_scores": {}
}

func _ready():
	load_game()

## Converts [member save_data] to a JSON string and saves it to disk.
func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		printerr("ERROR: could not open file for writing: %s" % [SAVE_PATH])
		return
	
	var json_string = JSON.stringify(save_data)

	# Saving to file
	file.store_string(json_string)
	file.close()

	print("INFO: game state saved successfully.")

## Loads data from disk.
func load_game():
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

## Adds coins to the persistent bank and updates the file on disk.
## Emits the [signal total_coins_changed] signal.
func add_coins(amount: int):
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
