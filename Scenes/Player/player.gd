extends CharacterBody2D
class_name Player

const STUN_TIME := 1.0
const KNOCKBACK_POWER := 150.0

@export var speed := 200.0
@export var dodge_speed := 100.0
@export var dodge_time := 0.5 
@export var dash_speed := 600.0
@export var dash_time := 0.2
@export var dash_cooldown := 0.5
@export var jump_velocity = -400.0
@export var coyote_time := .15
@export var max_jumps := 2
@export var max_dodges := 2
@export var ghost_sprite : PackedScene
@export var player_id := 1
@export var outline_color: Color

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_available := true
var jump_count := 0
var can_dash := true
var dashing := false
var dash_direction: Vector2
var dodge_direction: Vector2
var is_stunned := false
var can_dodge := true
var dodging := false
var dodge_count := 0

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var dash_timer: Timer = $DashTimer
@onready var dash_cd_timer: Timer = $DashCdTimer
@onready var ghost_timer: Timer = $GhostTimer
@onready var dash_attack: Area2D = $DashAttack
@onready var stun_timer: Timer = $StunTimer
@onready var dodge_timer: Timer = $DodgeTimer
@onready var hurtbox: Area2D = $Hurtbox



func _ready() -> void:
	material.set_shader_parameter("outline_color", outline_color)
func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left_%s" % [player_id], "move_right_%s" % [player_id])
	var aerial_direction := Input.get_vector(
		"move_left_%s" % [player_id], "move_right_%s" % [player_id], "aim_up_%s" % [player_id], "aim_down_%s" % [player_id]
		)
	
	
	var is_falling = velocity.y > 0.0 and not (is_on_floor() or is_on_wall())
	var is_dodging = Input.is_action_just_pressed("dodge_%s" % [player_id]) and can_dodge
	var is_jumping = Input.is_action_just_pressed("jump_%s" % [player_id]) and (is_on_floor() or is_on_wall())
	var is_dashing = Input.is_action_just_pressed("dash_%s" % [player_id]) and can_dash
	var is_jump_cancelled = Input.is_action_just_released("jump_%s" % [player_id]) and velocity.y < 0.0
	var is_idle = is_zero_approx(velocity.x) and is_on_floor()
	var is_running = not is_zero_approx(velocity.x) and is_on_floor()
	
	if not can_dash:
		if dash_cd_timer.is_stopped() and (is_on_floor() or is_on_wall()):
			can_dash = true
	if not can_dodge:
		if dodge_timer.is_stopped() and (is_on_floor() or is_on_wall()):
			can_dodge = true
			dodge_count = 0
			
	if !dashing and !is_stunned and !dodging :
		velocity.x = direction * speed
		if is_on_wall() and velocity.y >= 0.0:
			velocity.y += (gravity / 6) * delta
		else: 
			velocity.y += gravity * delta
	
	if is_dodging and not is_stunned:
		dodge_direction = aerial_direction
		start_dodge()
	elif is_dashing and not is_stunned and not dodging:
		dash_direction = aerial_direction
		start_dash()
	elif is_jumping and not is_stunned:
		velocity.y += jump_velocity
	elif is_jump_cancelled and not is_stunned:
		velocity.y = 0.0
	if dodging:
		velocity.x = dodge_direction.x * dodge_speed
		velocity.y += (gravity / 20) * delta
	elif dashing:
		velocity = dash_direction * dash_speed
	
	move_and_slide()
	
	if is_stunned:
		anim_sprite.play("stunned")
	elif dodging:
		anim_sprite.play("dash")
	elif dashing:
		anim_sprite.play("dash")
	elif is_falling:
		anim_sprite.play("falling")
	elif is_jumping:
		anim_sprite.play("jump")
	elif is_running:
		anim_sprite.play("run")
	elif is_idle:
		anim_sprite.play("idle")
	
	if not is_zero_approx(velocity.x):
		if velocity.x < 0:
			anim_sprite.flip_h = true
		else:
			anim_sprite.flip_h = false
	
func stun_knockback():
	if anim_sprite.flip_h:
		velocity.x = KNOCKBACK_POWER
	else:
		velocity.x = -KNOCKBACK_POWER
		
func start_dodge():
	
	dodging = true
	can_dodge = false
	dodge_count += 1
	hurtbox.monitorable = false
	scale = Vector2(.75,.75)
	var tween = get_tree().create_tween()
	tween.tween_method(set_shader_value, 1.0, 3.0, .33)
	dodge_timer.start(dodge_time)
	if velocity.y > 0:
		velocity.y = 0.0
	
func set_shader_value(value: float):
	material.set_shader_parameter("aspect_ratio", value)
	
func start_dash():
	dashing = true
	can_dash = false
	dash_attack.monitoring = true
	dash_timer.start(dash_time)
	dash_cd_timer.start(dash_cooldown)
	ghost_timer.start(.05)
	add_ghost()
	
func add_ghost():
	var ghost = ghost_sprite.instantiate()
	ghost.flip_h = anim_sprite.flip_h
	ghost.position = position
	ghost.modulate = outline_color
	get_tree().current_scene.add_child(ghost)

func get_stunned():
	is_stunned = true
	hurtbox.monitorable = false
	stun_knockback()
	stun_timer.start(STUN_TIME)


func _on_dash_timer_timeout() -> void:
	dashing = false
	dash_attack.monitoring = false
	ghost_timer.stop()


func _on_dash_cd_timer_timeout() -> void:
	if is_on_floor() or is_on_wall():
		can_dash = true


func _on_ghost_timer_timeout() -> void:
	add_ghost()

func _on_stun_timer_timeout() -> void:
	is_stunned = false
	hurtbox.monitorable = true

func _on_dash_attack_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox") and area != self.hurtbox:
		area.get_parent().get_stunned()
	

func _on_dodge_timer_timeout() -> void:
	dodging = false
	hurtbox.monitorable = true
	scale = Vector2(1,1)
	set_shader_value(1.0)
	if dodge_count < max_dodges:
		can_dodge = true
