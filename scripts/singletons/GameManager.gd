extends Node

var players = {}

func add_player(id):
	players[id] = {
		"id": id,
		"name": "Jugador " + str(id),
		"score": 0
	}

func remove_player(id):
	players.erase(id)

func start_game():
	if multiplayer.is_server():
		change_level.rpc("res://scenes/levels/level_0.tscn")

@rpc("authority", "call_local", "reliable")
func change_level(scene_path):
	get_tree().change_scene_to_file(scene_path)
