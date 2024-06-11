extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected


const PORT = 7000
const MAX_CONNECTIONS = 2

var players = {}

var player_info = {"name": "Player Name"}


func _ready() -> void:
	#if OS.has_feature("dedicated_server"):
		#print("server running")
		#create_game()
	var upnp = UPNP.new()
	var discover_result = upnp.discover()
	if discover_result == UPNP.UPNP_RESULT_SUCCESS:
		if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
			
			var map_result_udp = upnp.add_port_mapping(PORT, PORT, "godot_udp", "UDP", 0)
			var map_result_tcp = upnp.add_port_mapping(PORT, PORT, "godot_udp", "TCP", 0)
			print("port forwarded")
			if not map_result_udp == UPNP.UPNP_RESULT_SUCCESS:
				upnp.add_port_mapping(PORT, PORT, "", "UDP")
			
			if not map_result_tcp == UPNP.UPNP_RESULT_SUCCESS:
				upnp.add_port_mapping(PORT, PORT, "", "TCP")
	
	
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	
	players[1] = player_info
	player_connected.emit(1, player_info)

func join_game(address):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
	print("player connected")
	
func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)

func _on_connected_to_server():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)
	
	

func _on_connection_failed():
	multiplayer.multiplayer_peer = null
	
func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
