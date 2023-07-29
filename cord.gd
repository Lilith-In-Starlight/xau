extends Line2D

class_name Cable

## Node used to display connections between puzzles

## The color for when the puzzle this cable comes from is solved
@export var on_color := Color("#72ffdf")
## The color for when the puzzle this cable comes from is unsolved
@export var off_color := Color("#588b86")
## The puzzle this cable comes from
@export var required_puzzle: NodePath

@onready var required_node := get_node_or_null(required_puzzle)


func _ready():
	if required_node != null:
		if required_node is Puzzle:
			on_color = required_node.get_solved_cable_color()
			off_color = required_node.get_unsolved_cable_color()
		required_node.connect("was_solved", Callable(self, "_on_required_was_solved"))
		var data_get = SaveData.save_handler.vget_value(["puzzles", str(required_node.get_path())], null)
		if data_get == null or not data_get["solved"]:
			default_color = off_color
		elif data_get["solved"]:
			default_color = on_color
		for i in get_children():
			if i is Cable:
				i.default_color = default_color
				if i.required_node != null:
					i.required_node.disconnect("was_solved", Callable(i, "_on_required_was_solved"))
				i.required_node = required_node
				required_node.connect("was_solved", Callable(i, "_on_required_was_solved"))


## Called when the puzzle this cable comes from is solved
func _on_required_was_solved():
	var tween = create_tween()
	tween.tween_property(self, "default_color", on_color, 0.3)

