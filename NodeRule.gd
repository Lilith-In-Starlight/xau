extends Resource

class_name NodeRule
enum COLORS {
	black,
	blue,
	yellow,
}

@export var color : COLORS = COLORS.black

func _init():
	resource_local_to_scene = true

func check_correctness(local_node: PuzzleNode) -> bool:
	return true
