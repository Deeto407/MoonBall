extends Control
class_name GameUI

@onready var game_timer: Timer = %GameTimer
@onready var blue_score_label: Label = %BlueScoreLabel
@onready var red_score_label: Label = %RedScoreLabel
@onready var timer_label: Label = %TimerLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_overtime = false
var start_minutes: int
var start_seconds = 59
var current_minutes: int:
	set(minutes_in):
		if minutes_in >= 0:
			current_minutes = minutes_in
		else: 
			current_minutes = 0
var current_seconds: int:
	set(seconds_in):
		if !GameManager.is_overtime:
			if seconds_in >= 0:
				current_seconds = seconds_in
				if current_minutes == 0 and current_seconds == 0:
					GameManager.end_regulation()
			else:
				current_minutes -= 1
				current_seconds = 59
		elif GameManager.is_overtime:
			if seconds_in <= 59:
				current_seconds = seconds_in
			else:
				current_minutes += 1
				current_seconds = 0
		if GameManager.is_overtime:
			if current_seconds < 10:
				timer_label.text = "+" + str(current_minutes) + ":0" + str(current_seconds)
			else:
				timer_label.text = "+" + str(current_minutes) + ":" + str(current_seconds)
		else:
			if current_seconds < 10:
				timer_label.text = str(current_minutes) + ":0" + str(current_seconds)
			else:
				timer_label.text = str(current_minutes) + ":" + str(current_seconds)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_minutes = GameManager.game_length
	current_minutes = start_minutes
	current_seconds = start_seconds
	blue_score_label.text = "Blue: " + str(GameManager.team_left_score)
	red_score_label.text = "Red: " + str(GameManager.team_right_score)
	game_timer.start(1)

func _on_game_timer_timeout() -> void:
	if GameManager.is_overtime:
		current_seconds += 1
	else:
		current_seconds -= 1
