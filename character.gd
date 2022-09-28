extends KinematicBody2D

## The player character

## The maximum velocity of the character
const MAX_VEL = 90.0
## Multiplier when lerping to zero
const STOP_MULT = 0.3
## Multiplier when lerping to the maximum velocity
const GO_MULT = 0.2

var last_direction = "down"

var velocity := Vector2()

var undo_history := []

var current_section :Node2D

func _ready():
	if SaveData.data.has("player_pos_x"):
		position.x = SaveData.data["player_pos_x"]
		position.y = SaveData.data["player_pos_y"]
		z_index = SaveData.data["player_z_index"]
		current_section = get_node(SaveData.data["player_current_section"])


func _process(delta):
	if Input.is_action_pressed("up") and not Input.is_action_pressed("down"):
		velocity.y = lerp(velocity.y, -MAX_VEL * delta*60.0, GO_MULT)
	elif Input.is_action_pressed("down") and not Input.is_action_pressed("up"):
		velocity.y = lerp(velocity.y, MAX_VEL * delta*60.0, GO_MULT)
	else:
		velocity.y = lerp(velocity.y, 0.0, STOP_MULT)
	
	if Input.is_action_pressed("left") and not Input.is_action_pressed("right"):
		velocity.x = lerp(velocity.x, -MAX_VEL * delta*60.0, GO_MULT)
	elif Input.is_action_pressed("right") and not Input.is_action_pressed("left"):
		velocity.x = lerp(velocity.x, MAX_VEL * delta*60.0, GO_MULT)
	else:
		velocity.x = lerp(velocity.x, 0.0, STOP_MULT)
	
	if velocity.length() < 1.0:
		$Animations.play("standing_%s" % direction_from_velocity())
	else:
		$Animations.play("walking_%s" % direction_from_velocity())
	
	if Input.is_action_just_pressed("undo"):
		if !undo_history.empty():
			var last: Array = undo_history.pop_back()
			for i in last:
				if i[0] == "disconnect":
					i[1].connections.append(i[2])
					i[2].connections.append(i[1])
				elif i[0] == "connect":
					i[1].connections.erase(i[2])
					i[2].connections.erase(i[1])
				i[3].display_connections()
				i[3]._on_correctness_unverified()
	
func _physics_process(delta) -> void:
	move_and_slide(velocity, Vector2.ZERO)


func direction_from_velocity() -> String:
	var ret: String = last_direction
	match [sign(int(velocity.x)), sign(int(velocity.y))]:
		[1, 0]: ret = "right"
		[-1, 0]: ret = "left"
		[0, 1]: ret = "down"
		[0, -1]: ret = "up"
		[1, 1]: ret = "down_right"
		[1, -1]: ret = "up_right"
		[-1, 1]: ret = "down_left"
		[-1, -1]: ret = "up_left"
	last_direction = ret
	return ret
