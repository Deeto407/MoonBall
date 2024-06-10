extends Control

@onready var win_label: Label = $CenterContainer/VBoxContainer/WinLabel
@onready var character_texture: TextureRect = $CenterContainer/VBoxContainer/CharacterTexture
@onready var play_again_button: Button = $CenterContainer/VBoxContainer/HBoxContainer/PlayAgainButton
@onready var main_menu_button: Button = $CenterContainer/VBoxContainer/HBoxContainer/MainMenuButton

var player_lobby
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not multiplayer.is_server():
		play_again_button.hide()
	if OnlineGameManager.team_left_score > OnlineGameManager.team_right_score:
		win_label.label_settings.outline_color = Color("241ee3")
		character_texture.modulate = Color("241ee3")
		win_label.text = "BLUE TEAM WINS"
	elif OnlineGameManager.team_right_score > OnlineGameManager.team_left_score:
		win_label.label_settings.outline_color = Color("cf1b1b")
		character_texture.modulate = Color("cf1b1b")
		win_label.text = "RED TEAM WINS"


func _on_play_again_button_pressed() -> void:
	var player_lobby: MultiplayerLobby = get_tree().get_first_node_in_group("multiplayer_lobby")
	if multiplayer.is_server():
		OnlineGameManager.reset_game.rpc()
	player_lobby.change_level.call_deferred(player_lobby.level_scene)
	
	
	

func _on_main_menu_button_pressed() -> void:
	OnlineGameManager.reset_game()
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu/main_menu.tscn")
