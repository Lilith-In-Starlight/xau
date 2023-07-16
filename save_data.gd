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

var colors := {
	str(NodeRule.COLORS.blue) : NodeRule.get_default_color(NodeRule.COLORS.blue).to_html(),
	str(NodeRule.COLORS.yellow) : NodeRule.get_default_color(NodeRule.COLORS.yellow).to_html(),
	str(NodeRule.COLORS.green) : NodeRule.get_default_color(NodeRule.COLORS.green).to_html(),
	str(NodeRule.COLORS.purple) : NodeRule.get_default_color(NodeRule.COLORS.purple).to_html(),
}


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
	
	colors = get_saved_value("accessibility_colors", colors)

func _input(event):
	if Input.is_action_just_pressed("confirm"):
		save()


## Get all information from the puzzles and save the game
func save():
	data["accessibility_colors"] = colors
	print(colors)
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


func get_saved_value(key: Variant, default: Variant) -> Variant:
	if key == "accessibility_colors":
		print(key, ": ", data[key])
	if data.has(key):
		return data[key]
	return default


func get_node_color(key: NodeRule.COLORS) -> Color:
	if colors.has(str(key)):
		if colors[str(key)] is String and colors[str(key)].is_valid_html_color():
			return Color(colors[str(key)])
		elif colors[str(key)] is Color:
			return colors[str(key)]
	return NodeRule.get_default_color(key)
