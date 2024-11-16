extends RigidBody2D
class_name MultiplayerBall

@export var current_possesion: int

# these are configured as "Watch" in the MultiplayerSynchronizer
@export var replicated_position : Vector2
@export var replicated_linear_velocity : Vector2

func _integrate_forces(_state : PhysicsDirectBodyState2D) -> void:
  # Synchronizing the physics values directly causes problems since you can't
  # directly update physics values outside of _integrate_forces. This is
  # an attempt to resolve that problem while still being able to use
  # MultiplayerSynchronizer to replicate the values.

  # The object owner makes shadow copies of the physics values.
  # These shadow copies get synchronized by the MultiplyaerSynchronizer
  # The client copies the synchronized shadow values into the 
  # actual physics properties inside integrate_forces
	if is_multiplayer_authority():
		replicated_position = position
		replicated_linear_velocity = linear_velocity
	else:
		position = replicated_position
		linear_velocity = replicated_linear_velocity


func _on_body_entered(body: Node) -> void:
	if not multiplayer.is_server():
		return

	if body.is_in_group("player"):
		if body.player_id % 2 == 0:
			current_possesion = 2
			modulate = body.outline_color
		else:
			current_possesion = 1
			modulate = body.outline_color
