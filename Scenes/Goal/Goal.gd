extends Area2D
@export var goal_id := 1



func _on_body_entered(body: Node2D) -> void:
	if body is Ball:
		if goal_id % 2 == 0 and body.current_possesion % 2 == 0:
			Engine.time_scale = 0.15
			await get_tree().create_timer(.3).timeout
			Engine.time_scale = 1.0
			GameManager.goal_scored(goal_id)
		elif goal_id % 2 != 0 and body.current_possesion % 2 != 0:
			Engine.time_scale = 0.15
			await get_tree().create_timer(.3).timeout
			Engine.time_scale = 1.0
			GameManager.goal_scored(goal_id)
