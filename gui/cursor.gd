extends Node2D

class_name Cursor

## The cursor used in the game. 
##
## It is supposed to be a physical entity in the game
## And it is animated, so the software's way of using a custom cursor should not be
## used

## The [AnimatedSprite2D] that represents the cursor in-game
@onready var sprite: AnimatedSprite2D = $Cursor
## The [Line2D] used to show the connection between a node and the mouse
@onready var connection_line: Line2D = $Connection
## The [RayCast2D] used to check whether the mouse is connecting from a node
## that is obstructed by some puzzle element
@onready var connection_raycast: RayCast2D = $ConnectionCast

## The position of the cursor in the previous frame,
## used for calculating the rotation and any other visual effects
var past_pos = Vector2(0, 0)
## The node that the cursor is currently connecting
var connecting_from = null


func _process(delta):
	position = get_global_mouse_position()
	var pos_delta :Vector2 = position - past_pos
	sprite.speed_scale = 1 + pos_delta.length() / 20.0
	past_pos = position
	
	var abs_delta_x = abs(pos_delta.x * pos_delta.x)
	var angle_mult = min(abs_delta_x / 20.0, 0.8)

	if pos_delta.x < -1:
		sprite.rotation = lerp_angle(sprite.rotation, deg_to_rad(-45 * angle_mult), 0.2)
	elif pos_delta.x > 1:
		sprite.rotation = lerp_angle(sprite.rotation, deg_to_rad(45 * angle_mult), 0.2)
	else:
		sprite.rotation = lerp_angle(sprite.rotation, 0.0, 0.2)
	
	if connecting_from != null:
		connection_line.visible = true
		connection_raycast.position = connecting_from.global_position - global_position
		connection_raycast.target_position = -connection_raycast.position
		connection_raycast.force_raycast_update()
		var connection_line_to :Vector2 = Vector2(0, 0)
		if connection_raycast.is_colliding():
			var raycast_collider = connection_raycast.get_collider()
			if !raycast_collider.is_in_group("PuzzleNode"):
				connection_line_to = connection_raycast.get_collision_point() - global_position
		connection_line.points = [connecting_from.global_position - global_position, connection_line_to]
	else:
		connection_line.visible = false


func _input(delta):
	if Input.is_action_just_pressed("noconnect"):
		if connecting_from:
			connecting_from.queue_redraw()
			connecting_from = null
	if Input.is_action_just_released("connect") or Input.is_action_just_released("noconnect"):
		connecting_from = null
			
	if Input.is_action_just_pressed("confirm"):
		connecting_from = null


func change_blink(to: bool):
	if not to:
		return
		
	$Blinker.play("Blink")
	if not $Alarm.playing:
		$Alarm.play()
