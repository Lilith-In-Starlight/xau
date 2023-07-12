@tool
extends NodeArrangement

class_name NodeArrangementTree

@export var spacing := Vector2(16, 16)
@export var tree_solution := ""

func arrange_nodes(puzzle: Puzzle, exclusions: Array[Node]):
	var current_depth_max_x = 1
	var expected_max_x = 0
	var c = puzzle.get_child_count()
	var x := 0
	var y := 0
	var node_count := 0
	
	while c > 1:
		expected_max_x += 1
		c /= 2.0
		
	for i in puzzle.get_children():
		if (not i is PuzzleNode) or i in exclusions:
			continue
		
		if not i.node_rule is HardcodeNodeRule:
			i.node_rule = HardcodeNodeRule.new()
		elif not Engine.is_editor_hint():
			i.node_rule = i.node_rule.duplicate(true)
		
		i.position = Vector2(expected_max_x / 2.0 - current_depth_max_x / 2.0 + x, y) * spacing
		x += 1
		if x >= current_depth_max_x:
			x = 0
			y -= 1
			current_depth_max_x *= 2
			
		var new_name := "PuzzleNode"
		if node_count != 0:
			new_name += str(node_count + 1)
		
		if i.name != new_name:
			i.set_name.call_deferred(new_name)
		
		node_count += 1
	
	if Engine.is_editor_hint():
		return
	
	var parenthesis_depth := 0
	var tree_positions := [1]
	
	for ch in tree_solution:
		var current_child := puzzle.get_child(tree_positions[parenthesis_depth])
		match ch:
			"l":
				tree_positions[parenthesis_depth] *= 2
				var new_child = puzzle.get_child(tree_positions[parenthesis_depth])
				new_child.node_rule.hardcoded_connections.append(current_child)
				current_child.node_rule.hardcoded_connections.append(new_child)
			"r":
				tree_positions[parenthesis_depth] *= 2
				tree_positions[parenthesis_depth] += 1
				var new_child :PuzzleNode = puzzle.get_child(tree_positions[parenthesis_depth])
				new_child.node_rule.hardcoded_connections.append(current_child)
				current_child.node_rule.hardcoded_connections.append(new_child)
			"(":
				parenthesis_depth += 1
				tree_positions.append(tree_positions[parenthesis_depth-1])
			")":
				parenthesis_depth -= 1
				tree_positions.pop_back()
