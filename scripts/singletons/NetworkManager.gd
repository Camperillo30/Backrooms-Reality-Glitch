extends Node

signal connection_success
signal connection_failed
signal player_list_changed

const DEFAULT_PORT = 7000
const MAX_CLIENTS = 4

var peer = ENetMultiplayerPeer.new()

func host_game():
	var error = peer.create_server(DEFAULT_PORT, MAX_CLIENTS)
	if error != OK:
		print("Error al crear el servidor: ", error)
		return error

	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)

	print("Servidor iniciado en el puerto: ", DEFAULT_PORT)
	_on_player_connected(1) # Host es siempre ID 1
	return OK

func join_game(address):
	if address == "": address = "127.0.0.1"
	var error = peer.create_client(address, DEFAULT_PORT)
	if error != OK:
		print("Error al conectar: ", error)
		return error

	multiplayer.multiplayer_peer = peer
	return OK

func _on_player_connected(id):
	print("Jugador conectado: ", id)
	GameManager.add_player(id)
	player_list_changed.emit()

func _on_player_disconnected(id):
	print("Jugador desconectado: ", id)
	GameManager.remove_player(id)
	player_list_changed.emit()
