extends Node

var game_length := 4

var ball_starting_position: Vector2
var red_player_starting_position: Vector2
var blue_player_starting_position: Vector2
var players_in_game: Array[Player] = []

var game_ui: GameUI
var team_left_score := 0
var team_right_score := 0
var is_overtime := false

func set_starting_positions():
	for player in get_tree().get_nodes_in_group("player"):
		players_in_game.append(player)
	for n in players_in_game:
		if n.player_id == 1:
			red_player_starting_position = n.global_position
		elif n.player_id == 2:
			blue_player_starting_position = n.global_position
	ball_starting_position = get_tree().get_first_node_in_group("ball").global_position
	
func goal_scored(goal_id):
	if goal_id == 1:
		team_right_score += 1
		game_ui.red_score_label.text = "Red: " + str(team_right_score)
	elif goal_id == 2:
		team_left_score += 1
		game_ui.blue_score_label.text = "Blue: " + str(team_left_score)
	if is_overtime:
		get_tree().change_scene_to_file("res://Scenes/UI/WinScreen/win_screen.tscn")
	else:
		reset_positions()
		start_round()
	

func reset_positions():
	for n in players_in_game:
		n.dashing = false
		n.velocity = Vector2.ZERO
		n.is_stunned = false
		n.dodging = false
		if n.player_id == 1:
			n.global_position = red_player_starting_position
		elif n.player_id == 2:
			n.global_position = blue_player_starting_position
	PhysicsServer2D.body_set_state(
		get_tree().get_first_node_in_group("ball"),
		PhysicsServer2D.BODY_STATE_TRANSFORM,
		Transform2D.IDENTITY.translated(ball_starting_position)
	)
	get_tree().get_first_node_in_group("ball").linear_velocity = Vector2(0, 75)

func start_round():
	get_tree().paused = true
	
	game_ui.game_timer.stop()
	if is_overtime:
		game_ui.animation_player.play("overtime_countdown")
	else:
		game_ui.animation_player.play("countdown")
	await game_ui.animation_player.animation_finished
	get_tree().paused = false
	game_ui.game_timer.start(1)
		
	
func end_regulation():
	if team_left_score > team_right_score:
		get_tree().change_scene_to_file("res://Scenes/UI/WinScreen/win_screen.tscn")
	elif team_left_score < team_right_score:
		get_tree().change_scene_to_file("res://Scenes/UI/WinScreen/win_screen.tscn")
	elif team_left_score == team_right_score:
		print("overtime time")
		is_overtime = true
		reset_positions()
		start_round()
	
func reset_game():
	team_left_score = 0
	team_right_score = 0
	players_in_game = []
	is_overtime = false
	
