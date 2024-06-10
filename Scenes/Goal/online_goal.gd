extends Area2D
@export var goal_id = 1
@export var ball: RigidBody2D

func _on_body_entered(body: Node2D) -> void:
	if body is MultiplayerBall:
		if multiplayer.is_server():
			if goal_id % 2 == 0 and ball.current_possesion % 2 == 0:
				goal.rpc(ball)
			elif goal_id % 2 != 0 and ball.current_possesion % 2 != 0:
				goal.rpc(ball)


@rpc("call_local", "authority", "reliable")
func goal(ball):
	Engine.time_scale = 0.15
	await get_tree().create_timer(.3).timeout
	Engine.time_scale = 1.0
	OnlineGameManager.goal_scored(goal_id)
