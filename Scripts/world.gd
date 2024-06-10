extends Node2D

func _ready() -> void:
	GameManager.game_ui = get_tree().get_first_node_in_group("game_ui")
	GameManager.set_starting_positions()
	GameManager.start_round()
