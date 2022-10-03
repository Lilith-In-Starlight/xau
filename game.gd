extends Node2D

signal player_exited_world

## The code that controls every game element in a scene

const bg_color := Color("#040404")

## The node that represents the cursor
onready var CursorNode: Node2D = $Cursor
onready var PlayerNode: Node2D = $Character

var was_safe := true
onready var last_safe_pos := PlayerNode.position

	
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	var a = PlayerNode.position.length()
	var b = CursorNode.position.length()
	if a > 2300:
		CursorNode.change_blink(true)
		if OS.is_window_focused():
			var playerp = PlayerNode.get_global_transform_with_canvas().get_origin()
			var mouse_goal = playerp - PlayerNode.position.normalized() * 100
			get_viewport().warp_mouse(get_viewport().get_mouse_position() + (mouse_goal - get_viewport().get_mouse_position()) / 20.0)
		VisualServer.set_default_clear_color(bg_color.darkened((a - 2300)/600))
		if bg_color.darkened((a - 2300)/600).b <= ColorN("Black").b:
			get_tree().quit()
	else:
		last_safe_pos = PlayerNode.position
		VisualServer.set_default_clear_color(bg_color)
		if b > 2300:
			CursorNode.change_blink(true)
			if OS.is_window_focused():
				var cursor_goal = CursorNode.position.normalized() * 2300
				var pos_delta = CursorNode.position - cursor_goal
				get_viewport().warp_mouse(get_viewport().get_mouse_position() - pos_delta)
		else:
			CursorNode.change_blink(false)
