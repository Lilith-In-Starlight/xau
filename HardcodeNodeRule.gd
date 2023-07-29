extends NodeRule

class_name HardcodeNodeRule

@export var hardcoded_connections :Array[NodePath]


func check_correctness(local_node: PuzzleNode) -> bool:
	if local_node.connections.size() != hardcoded_connections.size():
		return false
	for hardcoded_node in hardcoded_connections:
		if not local_node.get_node(hardcoded_node) in local_node.connections:
			return false
	return true
