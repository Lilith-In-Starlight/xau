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
var current_area := "first_nexus"

func _ready():
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		data = test_json_conv.data
		file.close()
	
	if data.has("version"):
		if data["version"] != "3":
			data = {
				"puzzles" : {},
				"doors" : {},
				"sections" : {},
			}
			data["version"] = "3"
			save()
	else:
		data = {
			"puzzles" : {},
			"doors" : {},
			"sections" : {},
		}
		data["version"] = "3"
		save()


func _input(event):
	if Input.is_action_just_pressed("confirm"):
		save()


## Get all information from the puzzles and save the game
func save():
	for i in get_tree().get_nodes_in_group("Puzzle"):
		var isave: Dictionary = i.save()
		if not isave.is_empty():
			data["puzzles"][str(i.get_path())] = i.save()
	
	for i in get_tree().get_nodes_in_group("Door"):
		if i.save() != false:
			data["doors"][str(i.get_path())] = true
	
		
	var player = get_tree().get_nodes_in_group("Player")[0]
	data["player_pos_x"] = player.position.x
	data["player_pos_y"] = player.position.y
	data["current_area"] = current_area
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
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
