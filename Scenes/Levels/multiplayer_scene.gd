extends Node2D

@export var players_container: Node2D
@export var player_scene: PackedScene
@export var spawn_points: Array[Node2D]
@export var player_spawner: MultiplayerSpawner
@export var red_player_shader: ShaderMaterial
@export var blue_player_shader: ShaderMaterial
@export var red_player_god_ray: ShaderMaterial
@export var blue_player_god_ray: ShaderMaterial
var next_spawn_point_index := 0
var player_count = 0

func _enter_tree() -> void:
	player_spawner.spawn_function = spawn_player

func _ready() -> void:
	OnlineGameManager.game_ui = get_tree().get_first_node_in_group("game_ui")
	OnlineGameManager.set_starting_positions.call_deferred()
	OnlineGameManager.start_round.call_deferred()
	player_count = 0
	
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_disconnected.connect(delete_player)
	
	add_player(1)
	
	for id in multiplayer.get_peers():
		add_player(id)
	
	
	
	

func _exit_tree() -> void:
	if not multiplayer.is_server():
		return
	multiplayer.peer_disconnected.disconnect(delete_player)
	
func spawn_player(id):
	var player_instance = player_scene.instantiate()
	print("player " + str(player_count) + " spawned")
	if id == 1:
		player_instance.outline_shader = red_player_shader
		player_instance.player_id = 1
		player_instance.outline_color = Color.RED
		player_instance.god_ray_shader = red_player_god_ray
	else:
		player_instance.outline_shader = blue_player_shader
		player_instance.player_id = 2
		player_instance.outline_color = Color.BLUE
		player_instance.god_ray_shader = blue_player_god_ray
	player_instance.name = str(id)
	player_instance.position = get_spawn_point()
	return player_instance

func add_player(id):
	player_count += 1
	player_spawner.spawn(id)

func delete_player(id):
	if not players_container.has_node(str(id)):
		return
	
	players_container.get_node(str(id)).queue_free()

func get_spawn_point():
	var spawn_point = spawn_points[next_spawn_point_index].position
	next_spawn_point_index += 1
	if next_spawn_point_index >= len(spawn_points):
		next_spawn_point_index = 0
	return spawn_point
