extends NodeRule

class_name BranchLengthNodeRule

@export var required_length := 3


func _init():
	resource_local_to_scene = true

func check_correctness(local_node: PuzzleNode) -> bool:
	return not local_node.get_branch_length() == required_length
