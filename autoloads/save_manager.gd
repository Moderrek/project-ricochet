extends Node

signal total_coins_changed(new_amount: int)

const SAVE_PATH = "user://save.json"

var total_coins: int = 0:
	set(value):
		total_coins = value
		total_coins_changed.emit(total_coins)

var unlocked_skins: Array = ["default"]
var equipped_skin: String = "default"

func _ready():
	load_game()

func add_coins(amount: int):
	total_coins += amount # It will emit signal
	save_game()

# Save
func save_game():
	# Opening file for writing
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		return
	
	var data = {
		"total_coins": total_coins,
		"unlocked_skins": unlocked_skins,
		"equipped_skin": equipped_skin
	}
	
	# Storing data as JSON in file
	var json_string = JSON.stringify(data)
	file.store_string(json_string)
	file.close()
	
	print("Game saved")

func load_game():
	# Opening file for reading
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	
	# Reading file
	var json_string = file.get_as_text()
	file.close()
	
	# Parsing JSON
	var data = JSON.parse_string(json_string)
	if not data:
		return
	
	total_coins = data.get("total_coins", 0)
	unlocked_skins = data.get("unlocked_skins", ["default"])
	equipped_skin = data.get("equipped_skin", "default")
	
	total_coins_changed.emit(total_coins)
	
	print("Game loaded")
	
	
