extends Node2D

signal player_exited_world

## The code that controls every game element in a scene

const bg_color := Color("#040404")

const areas := {
		"first_nexus" : preload("res://areas/FullAreas/FirstArea.tscn"),
		"forest" : preload("res://areas/FullAreas/ForestArea.tscn"),
		"cycles" : preload("res://areas/FullAreas/CyclesArea.tscn"),
	}

## The node that represents the cursor
@onready var CursorNode: Node2D = $Cursor
@onready var PlayerNode: Node2D = $Character
@onready var AreaNode: Node2D = null

var was_safe := true
@onready var last_safe_pos := PlayerNode.position

var current_area := "first_nexus"

var fullscreen_workaround := false


func _ready():
	get_tree().paused = false
	$Camera2D.position = $Character.position
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	set_current_area(SaveData.save_handler.get_value("current_area", "first_nexus"), false)


func _process(_delta: float) -> void:
	if not fullscreen_workaround:
		fullscreen_workaround = true
		if SaveData.save_handler.vget_value(["options", "fullscreen"], true):
			get_window().mode = Window.MODE_FULLSCREEN
		else:
			get_window().mode = Window.MODE_WINDOWED
	var a = PlayerNode.position.length()
	var b = CursorNode.position.length()
	if get_viewport().get_mouse_position().x > DisplayServer.get_display_safe_area().size.x:
		return
	if get_viewport().get_mouse_position().x < 0:
		return
	if get_viewport().get_mouse_position().y > DisplayServer.get_display_safe_area().size.y:
		return
	if get_viewport().get_mouse_position().y < 0:
		return
	if a > 2300*1.5:
		CursorNode.change_blink(true)
		if get_window().has_focus():
			var playerp = PlayerNode.get_global_transform_with_canvas().get_origin()
			var mouse_goal = playerp - PlayerNode.position.normalized() * 100
			get_viewport().warp_mouse(get_viewport().get_mouse_position() + (mouse_goal - get_viewport().get_mouse_position()) / 20.0)
		RenderingServer.set_default_clear_color(bg_color.darkened((a - 2300)/600))
		if bg_color.darkened((a - 2300)/600).b <= Color.BLACK.b:
			get_tree().quit()
	else:
		last_safe_pos = PlayerNode.position
		RenderingServer.set_default_clear_color(bg_color)
		if b > 2300*1.5:
			CursorNode.change_blink(true)
			if get_window().has_focus():
				var cursor_goal = CursorNode.position.normalized() * 2300
				var pos_delta = CursorNode.position - cursor_goal
				get_viewport().warp_mouse(get_viewport().get_mouse_position() - pos_delta)
		else:
			CursorNode.change_blink(false)


func set_current_area(to: String, save := true):
	if areas.has(to):
		var next_area :PackedScene = areas[to]
		if to == "forest":
			PlayerNode.stepping_on[0] = "grass"
		else:
			PlayerNode.stepping_on[0] = "void"
		SaveData.current_area = to
		current_area = to
		SaveData.save_handler.save_value("current_area", to)
		RenderingServer.viewport_set_update_mode(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_UPDATE_DISABLED)
		RenderingServer.viewport_set_clear_mode(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_CLEAR_NEVER)
		if save:
			SaveData.save()
		if AreaNode != null:
			AreaNode.remove_from_group("World")
			AreaNode.name = "leaving"
			AreaNode.tree_exited.connect(instantiate_area.bind(next_area))
			AreaNode.queue_free()
		else:
			instantiate_area(next_area)


func add_one_second():
	SaveData.save_handler.profile_data["seconds"] += 1


func instantiate_area(area: PackedScene) -> void:
	AreaNode = area.instantiate()
	AreaNode.add_to_group("World")
	add_child.call_deferred(AreaNode)
	AreaNode.z_as_relative = false
