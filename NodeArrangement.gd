@tool
extends Resource

class_name NodeArrangement


func _init():
	resource_local_to_scene = true


func arrange_nodes(puzzle: Puzzle, exclusions: Array[Node]):
	var node_count := 0
	var holes_count := 0
	var valid_children_count := 0
	
	for child in puzzle.get_children():
		if (not child is PuzzleNode) or child in exclusions:
			continue
			
		var new_name := "PuzzleNode"
			
		if node_count != 0:
			new_name += str(node_count + 1)
		
		if child.name != new_name:
			child.set_name.call_deferred(new_name)
		node_count += 1
		valid_children_count += 1
