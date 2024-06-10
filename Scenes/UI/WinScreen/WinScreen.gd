extends Control

@onready var win_label: Label = $CenterContainer/VBoxContainer/WinLabel
@onready var character_texture: TextureRect = $CenterContainer/VBoxContainer/CharacterTexture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.team_left_score > GameManager.team_right_score:
		win_label.label_settings.outline_color = Color("241ee3")
		character_texture.modulate = Color("241ee3")
		win_label.text = "BLUE TEAM WINS"
	elif GameManager.team_right_score > GameManager.team_left_score:
		win_label.label_settings.outline_color = Color("cf1b1b")
		character_texture.modulate = Color("cf1b1b")
		win_label.text = "RED TEAM WINS"


func _on_play_again_button_pressed() -> void:
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://Scenes/Levels/sandbox.tscn")


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu/main_menu.tscn")
