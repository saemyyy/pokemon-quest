extends CharacterBody2D

@export var walk_speed = 4.0
const TILE_SIZE = 16

@onready var anim_tree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")

enum PlayerState {IDLE, TURNING, WALKING}
enum FacingDirection {LEFT, RIGHT, UP, DOWN}

var player_state = PlayerState.IDLE
var facing_direction = FacingDirection.DOWN

var initial_position = Vector2(0, 0)
var input_direction = Vector2(0, 0)
var is_moving = false
var percent_moved_to_next_tile = 0.0

func _ready():
	anim_tree.active = true
	initial_position = position
	

func _physics_process(delta):
	if player_state == PlayerState.TURNING:
		return
	elif is_moving == false:
		process_player_input()
	elif input_direction != Vector2.ZERO:
		anim_state.travel("Walk")
		move(delta)
	else:
		anim_state.travel("Idle")
		is_moving = false

func process_player_input():
	if input_direction.y == 0:
		input_direction.x = int(Input.get_action_strength("ui_right")) - int(Input.get_action_strength("ui_left")) 
	if input_direction.x == 0:
		input_direction.y = int(Input.get_action_strength("ui_down")) - int(Input.get_action_strength("ui_up")) 

	# Check if any input direction is pressed
	if input_direction != Vector2.ZERO:
		anim_tree.set("parameters/Idle/blend_position", input_direction)
		anim_tree.set("parameters/Walk/blend_position", input_direction)
		anim_tree.set("parameters/Turn/blend_position", input_direction)
		
		if need_to_turn():
			player_state = PlayerState.TURNING
			anim_state.travel("Turn")
		else:
			initial_position = position
			is_moving = true
	else:
		anim_state.travel("Idle")

func need_to_turn():
	var new_facing_direction
	if input_direction.x < 0:
		new_facing_direction = FacingDirection.LEFT
	elif input_direction.x > 0:
		new_facing_direction = FacingDirection.RIGHT
	elif input_direction.y < 0:
		new_facing_direction = FacingDirection.UP
	elif input_direction.y > 0:
		new_facing_direction = FacingDirection.DOWN

	if facing_direction != new_facing_direction:
		facing_direction = new_facing_direction
		return true
	return false
	
func finished_turning():
	player_state = PlayerState.IDLE
	
func move(delta):
	percent_moved_to_next_tile += walk_speed * delta
	if percent_moved_to_next_tile >= 1.0:
		position = initial_position + (TILE_SIZE * input_direction)
		percent_moved_to_next_tile = 0.0
		is_moving = false
	else:
		position = initial_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)
