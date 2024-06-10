extends Control

func _on_local_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/sandbox.tscn")


func _on_online_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/multiplayer_lobby.tscn")
