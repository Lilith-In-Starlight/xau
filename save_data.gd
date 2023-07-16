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

var save_handler := SaveHandler.new()

## The puzzles that have Unique Puzzle Identifiers
var upid := {}
var current_area := "first_nexus"


func _ready():
	save_handler.load_data()

func _input(event):
	if Input.is_action_just_pressed("confirm"):
		save()


## Get all information from the puzzles and save the game
func save():
	save_handler.save()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().call_group("Puzzle", "save_data")
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


func get_saved_value(key: Variant, default: Variant) -> Variant:
	if key == "accessibility_colors":
		print(key, ": ", data[key])
	if data.has(key):
		return data[key]
	return default


func get_node_color(key: NodeRule.COLORS) -> Color:
	return save_handler.vget_value(["options", "accessibility", "colors", str(key)], NodeRule.get_default_color(key))
