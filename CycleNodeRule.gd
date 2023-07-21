extends NodeRule

class_name CycleNodeRule


func _init():
	resource_local_to_scene = true

func check_correctness(local_node: PuzzleNode) -> bool:
	return true
