extends Node

const SAVE_PATH = "user://savegame.save"

func save_game(data):
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var json_string = JSON.stringify(data)
	file.store_line(json_string)

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return null

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = file.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		return null
	return json.get_data()
