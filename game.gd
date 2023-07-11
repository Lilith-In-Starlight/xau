extends Node2D

signal player_exited_world

## The code that controls every game element in a scene

const bg_color := Color("#040404")

const areas := {
		"first_nexus" : preload("res://areas/FullAreas/FirstArea.tscn"),
		"forest" : preload("res://areas/FullAreas/ForestArea.tscn")
	}

## The node that represents the cursor
onready var CursorNode: Node2D = $Cursor
onready var PlayerNode: Node2D = $Character
onready var AreaNode: Node2D = null

var was_safe := true
onready var last_safe_pos := PlayerNode.position

var current_area := "first_nexus"

func _ready():
	$Camera2D.position = $Character.position
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if SaveData.data.has("current_area"):
		set_current_area(SaveData.data["current_area"], false)
	else:
		set_current_area("first_nexus", false)
	

func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
		OS.window_borderless = OS.window_fullscreen
	var a = PlayerNode.position.length()
	var b = CursorNode.position.length()
	if get_viewport().get_mouse_position().x > OS.get_window_safe_area().size.x:
		return
	if get_viewport().get_mouse_position().x < 0:
		return
	if get_viewport().get_mouse_position().y > OS.get_window_safe_area().size.y:
		return
	if get_viewport().get_mouse_position().y < 0:
		return
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

func set_current_area(to: String, save := true):
	if areas.has(to):
		SaveData.current_area = to
		current_area = to
		if save:
			SaveData.save()
		if AreaNode != null:
			AreaNode.remove_from_group("World")
			AreaNode.name = "leaving"
			AreaNode.queue_free()
		AreaNode = areas[to].instance()
		AreaNode.add_to_group("World")
		add_child(AreaNode)
		AreaNode.z_as_relative = false
