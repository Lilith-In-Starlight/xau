extends Node

## The singletone that handles global data like save files



var save_handler := SaveHandler.new()

## The puzzles that have Unique Puzzle Identifiers
var upid := {}
var current_area := "first_nexus"


func _ready():
	if FileAccess.file_exists("user://.currentprofile"):
		var file := FileAccess.open("user://.currentprofile", FileAccess.READ)
		var line :String = file.get_line()
		file.close()
		if line.is_valid_int():
			save_handler.profile = line as int
		else:
			file = FileAccess.open("user://.currentprofile", FileAccess.WRITE)
			file.store_string(str(save_handler.profile))
			file.close()
	else:
		var file := FileAccess.open("user://.currentprofile", FileAccess.WRITE)
		file.store_string(str(save_handler.profile))
		file.close()
	print(save_handler.profile)
	save_handler.load_data()


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("confirm"):
		save()


func save():
	save_handler.save()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().call_group("Puzzle", "save_data")
		save()
		get_tree().quit()



func get_node_color(key: NodeRule.COLORS) -> Color:
	return save_handler.vget_value(["options", "accessibility", "colors", str(key)], NodeRule.get_default_color(key))


func take_screenshot() -> Image:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	return img


func reset_all_globals() -> void:
	save_handler = SaveHandler.new()
	upid = {}
	current_area = "first_nexus"
	StatesDefiner.state = ""
	MusicChannel.all_music_channels.clear()
