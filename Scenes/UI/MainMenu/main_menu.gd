extends Node2D

@onready var ball: Ball = $Ball
var y_velocity_range := 500.0
var x_velocity_range := 300.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ball.linear_velocity = Vector2(-75, 50)


func _physics_process(delta: float) -> void:
	if ball.linear_velocity.x > -10.0 and ball.linear_velocity.x < 10.0:
		if ball.linear_velocity.y > -10 and ball.linear_velocity.y < 10:
			ball.linear_velocity = Vector2(randf_range(-x_velocity_range, x_velocity_range), randf_range(-y_velocity_range, y_velocity_range))


