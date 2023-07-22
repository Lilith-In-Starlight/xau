extends NodeRule

class_name BranchLengthNodeRule

@export var required_length := 3


func _init():
	resource_local_to_scene = true

func check_correctness(local_node: PuzzleNode) -> bool:
	var branch :Array[PuzzleNode] = local_node.get_branch()
	var collective_required_length := required_length
	for node in branch:
		if node == local_node:
			continue
		if node.node_rule is BranchLengthNodeRule and node.node_rule.color == color:
			collective_required_length += node.node_rule.required_length
	
		
	return branch.size() == collective_required_length
