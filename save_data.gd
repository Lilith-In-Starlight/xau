extends Node

## The singletone that handles global data like save files

## The path where the game progress is saved
const SAVE_PATH := "user://savedata.xau"

## The data of the entire game
var data := {}

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
			data[str(i.get_path())] = i.save()
	
	for i in get_tree().get_nodes_in_group("World")[0].get_children():
		data[str(i.get_path())] = i.modulate.a
		
	var file := File.new()
	data["player_pos_x"] = get_tree().get_nodes_in_group("Player")[0].position.x
	data["player_pos_y"] = get_tree().get_nodes_in_group("Player")[0].position.y
	file.open(SAVE_PATH, File.WRITE)
	file.store_string(JSON.print(data))
	file.close()


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save()
		get_tree().quit()
