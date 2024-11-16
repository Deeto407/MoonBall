extends Node
class_name MultiplayerLobby

@export var level_scene: PackedScene
@export var win_screen: PackedScene
@onready var level_container: Node = $Level
@onready var status_label: Label = $UI/ConnectionsBox/StatusLabel
@onready var ip_line_edit: LineEdit = $UI/NotConnectedHBox/IPLineEdit
@onready var lobby_ui: Control = $UI
@onready var not_connected_h_box: HBoxContainer = $UI/NotConnectedHBox
@onready var host_h_box: HBoxContainer = $UI/HostHBox
@onready var start_button: Button = $UI/HostHBox/StartButton
@onready var connections_message: Label = $UI/ConnectionsBox/ConnectionsMessage

func _ready() -> void:
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.peer_connected.connect(_on_player_connected)
	
func _on_host_button_pressed() -> void:
	Lobby.create_game()
	not_connected_h_box.hide()
	host_h_box.show()
	status_label.text = "Hosting..."
	connections_message.visible = true


func _on_join_button_pressed() -> void:
	Lobby.join_game(ip_line_edit.text)
	not_connected_h_box.hide()
	status_label.text = "Connecting..."

func _on_start_button_pressed() -> void:
	hide_menu.rpc()
	change_level(level_scene)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu/main_menu.tscn")


func change_level(scene):
	for c in level_container.get_children():
		level_container.remove_child(c)
		c.queue_free()
	level_container.add_child(scene.instantiate())

func _on_connection_failed():
	not_connected_h_box.show()
	status_label.text = "Failed to connect"

func _on_connected_to_server():
	status_label.text = "Connected!"
	
func _on_player_connected(id):
	connections_message.text = "player " + str(id) + " connected!"
	
@rpc("any_peer", "call_local", "reliable")
func hide_menu():
	lobby_ui.hide()
