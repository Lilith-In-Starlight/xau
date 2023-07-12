@tool
extends NodeArrangement

class_name NodeArrangementGrid

@export var size := Vector2i(3, 3)
@export var spacing := Vector2(16, 16)
@export var holes: Array[Vector2i] = []

func arrange_nodes(puzzle: Puzzle, exclusions: Array[Node]):
	var node_count := 0
	var spaces_count := 0
	
	for child in puzzle.get_children():
		if (not child is PuzzleNode) or child in exclusions:
			continue
		
		var new_name := "PuzzleNode"
		if node_count != 0:
			new_name += str(node_count + 1)
		
		if child.name != new_name:
			child.set_name.call_deferred(new_name)
		
		var x_position :int = (spaces_count) % size.x
		var y_position :int = (spaces_count) / size.x
		
		node_count += 1
		spaces_count += 1
		
		while Vector2i(x_position, y_position) in holes:
			x_position = (spaces_count) % size.x
			y_position = (spaces_count) / size.x
			spaces_count += 1
		
		child.position = Vector2(x_position, y_position) * spacing
