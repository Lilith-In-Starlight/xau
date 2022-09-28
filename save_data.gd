extends Node

## The singletone that handles global data like save files

## The path where the game progress is saved
const SAVE_PATH := "user://savedata.xau"

## The data of the entire game
var data := {
	"puzzles" : {},
	"doors" : {},
	"sections" : {},
}

## The puzzles that have Unique Puzzle Identifiers
var upid := {}

func _ready():
	var file := File.new()
	if file.file_exists(SAVE_PATH):
		file.open(SAVE_PATH, File.READ)
		data = JSON.parse(file.get_as_text()).result
		file.close()


func _input(event):
	if Input.is_action_just_pressed("confirm"):
		save()


## Get all information from the puzzles and save the game
func save():
	for i in get_tree().get_nodes_in_group("Puzzle"):
		var isave: Dictionary = i.save()
		if not isave.empty():
			data["puzzles"][str(i.get_path())] = i.save()
	
	for i in get_tree().get_nodes_in_group("Door"):
		if i.save() != false:
			data["doors"][str(i.get_path())] = true
	
	for i in get_tree().get_nodes_in_group("World")[0].get_children():
		data["sections"][str(i.get_path())] = i.modulate.a
		
	var file := File.new()
	var player = get_tree().get_nodes_in_group("Player")[0]
	data["player_pos_x"] = player.position.x
	data["player_pos_y"] = player.position.y
	data["player_z_index"] = player.z_index
	data["player_current_section"] = player.get_path_to(player.current_section)
	file.open(SAVE_PATH, File.WRITE)
	file.store_string(JSON.print(data))
	file.close()


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save()
		get_tree().quit()


func get_data(path: String):
	var parts = path.split("|")
	var current = data
	for i in parts:
		current = current[i]
	return current


func has_data(path: String):
	var parts = path.split("|")
	var current = data
	for i in parts:
		if i in current:
			current = current[i]
		else:
			return false
	return true
