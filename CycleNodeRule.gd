extends NodeRule

class_name CycleNodeRule


func _init():
	resource_local_to_scene = true

func check_correctness(local_node: PuzzleNode) -> bool:
	var closest_loop := local_node.get_closest_loop()

	if closest_loop.is_empty():
		return false

	for node in closest_loop:
		if node == local_node:
			continue
		elif node.node_rule is CycleNodeRule and node.node_rule.color == color:
			return false
	return true
