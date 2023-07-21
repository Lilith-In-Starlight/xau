@tool
extends Resource

class_name NodeArrangement


func _init():
	resource_local_to_scene = true


func arrange_nodes(puzzle: Puzzle, exclusions: Array[Node]):
	var node_count := 0
	
	for child in puzzle.get_children():
		if (not child is PuzzleNode) or child in exclusions:
			continue
			
		var new_name := "PuzzleNode"
			
		if node_count != 0:
			new_name += str(node_count + 1)
		
		if child.name != new_name:
			child.set_name.call_deferred(new_name)
		node_count += 1


func get_used_area(puzzle: Puzzle) -> Rect2:
	var area := Rect2(Vector2(), Vector2())
	for child in puzzle.get_children():
		if child is Node2D and not child.name == "NoNode":
			area = area.expand(child.position)
	
	return area
