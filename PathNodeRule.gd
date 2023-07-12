extends NodeRule

class_name PathNodeRule

func check_correctness(local_node: PuzzleNode):
	if local_node.connections.size() > 1:
		return false
		
	if local_node.connections.is_empty():
		return false
	
	var next_checks: Array = [local_node]
	var already_checked: Array = []
	while next_checks.size() > 0:
		var currently_checking = next_checks.pop_back()
		already_checked.append(currently_checking)
		for neighbor in currently_checking.connections:
			if neighbor in already_checked or neighbor == local_node:
				continue
			if neighbor.node_rule is PathNodeRule:
				return neighbor.node_rule.color == color or neighbor.node_rule.color == COLORS.black or color == COLORS.black
				
			next_checks.append(neighbor)
	return false
