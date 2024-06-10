extends RigidBody2D
class_name Ball
var current_possesion: int


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.player_id % 2 == 0:
			current_possesion = 2
			modulate = body.outline_color
		else:
			current_possesion = 1
			modulate = body.outline_color
