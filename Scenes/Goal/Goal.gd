extends Area2D
@export var goal_id := 1
@export var ball: RigidBody2D
@export var shader: ShaderMaterial
@onready var shader_container: ColorRect = $ShaderContainer

func _ready() -> void:
	shader_container.material = shader


func _on_body_entered(body: Node2D) -> void:
	if body is Ball:
		if goal_id % 2 == 0 and ball.current_possesion % 2 == 0:
			goal()
		elif goal_id % 2 != 0 and ball.current_possesion % 2 != 0:
			goal()

func goal():
	var blue_god_ray = get_tree().get_first_node_in_group("blue_god_ray")
	var red_god_ray = get_tree().get_first_node_in_group("red_god_ray")
	
	if goal_id == 1:
		red_god_ray.visible = true
	else: 
		blue_god_ray.visible = true
	
	Engine.time_scale = 0.15
	await get_tree().create_timer(.3).timeout
	Engine.time_scale = 1.0
	
	red_god_ray.visible = false
	blue_god_ray.visible = false
	
	GameManager.goal_scored(goal_id)
