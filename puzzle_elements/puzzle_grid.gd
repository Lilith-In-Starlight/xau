@tool
extends Puzzle

class_name PuzzleGrid
## A [Puzzle] where the nodes are set in a grid
##
## A PuzzleGrid automatically sets all its nodes to be in a grid-like
## configuration, allowing for spaces with holes

enum MODES {
	GRID,
	BINTREE,
}

@export var mode: MODES

## The size of a row. If there are more than [member row_size] [PuzzleNode]s,
## there will be more than one row.
@export var row_size :int = 1: set = set_row_size

## The separation between adjacent nodes in this puzzle
@export var spacing :int = 16: set = set_spacing
		
## Positions of the puzzle where there should not be a node
@export var holes: PackedVector2Array = []

@export var bintree_solution := ""


func _init():
	base_display_connections = false

func _ready():
	super._ready()
	update_children_positions()
	display_connections()
	if not Engine.is_editor_hint():
		set_bintree_solution()

func set_row_size(value):
	row_size = value
	update_children_positions()
	
func set_spacing(value):
	spacing = value
	update_children_positions()

func _process(delta):
	if Engine.is_editor_hint():
		update_children_positions()
	else:
		set_process(false)


func _draw():
	super._draw()
	if framed:
		$NoNode/Frame.visible = true
		var new_rect = rect.grow(8)
		$NoNode/Frame/TopLeft.position = new_rect.position + Vector2(-2,-2)
		$NoNode/Frame/TopRight.position = new_rect.position + Vector2(new_rect.size.x - 14, -2)
		$NoNode/Frame/BottomLeft.position = new_rect.position + Vector2(-2, new_rect.size.y - 13)
		$NoNode/Frame/BottomRight.position = new_rect.position + Vector2(-14, -13) + new_rect.size
		$NoNode/Frame/Left.position = new_rect.position + Vector2(-2, 1)
		$NoNode/Frame/Left.scale.y = new_rect.size.y - 2
		$NoNode/Frame/Right.position = new_rect.position + Vector2(new_rect.size.x-1, 1)
		$NoNode/Frame/Right.scale.y = new_rect.size.y - 2
		$NoNode/Frame/Bottom.position = new_rect.position + Vector2(2, new_rect.size.y)
		$NoNode/Frame/Bottom.scale.y = new_rect.size.x - 2
		$NoNode/Frame/Top.position = new_rect.position + Vector2(2, -2)
		$NoNode/Frame/Top.scale.y = new_rect.size.x - 2
	else:
		$NoNode/Frame.visible = false


## Updates the node's children positions to match the row size
func update_children_positions(exclusions: Array = []):
	var x := 0
	var y := 0
	if Engine.is_editor_hint():
		queue_redraw()
	match mode:
		MODES.GRID:
			for i in get_children():
				if i.is_in_group("PuzzleNode") and not i in exclusions:
					while Vector2(x, y) in holes:
						x += 1
						if x >= row_size:
							x = 0
							y += 1
					i.position = Vector2(x, y) * spacing
					x += 1
					if x >= row_size:
						x = 0
						y += 1
		MODES.BINTREE:
			var current_depth_max_x = 1
			var expected_max_x = 0
			var c = get_child_count()
			while c > 1:
				expected_max_x += 1
				c /= 2.0
			for i in get_children():
				if i.is_in_group("PuzzleNode") and not i in exclusions:
					if not i.node_rule is HardcodeNodeRule:
						i.node_rule = HardcodeNodeRule.new()
					else:
						i.node_rule = i.node_rule.duplicate(true)
					i.position = Vector2(expected_max_x / 2.0 - current_depth_max_x / 2.0 + x, y) * spacing
					x += 1
					if x >= current_depth_max_x:
							x = 0
							y -= 1
							current_depth_max_x *= 2
							
			


func _on_child_entered_tree(new_child: Node) -> void:
	update_children_positions()
	super._on_child_entered_tree(new_child)


func _on_child_exiting_tree(new_child: Node) -> void:
	update_children_positions([new_child])
	super._on_child_exiting_tree(new_child)


func _on_screen_entered() -> void:
	is_visible = true


func _on_screen_exited() -> void:
	is_visible = false


func set_bintree_solution() -> void:
	if not mode == MODES.BINTREE:
		return
	var parenthesis_depth := 0
	var tree_positions := [1]
	for ch in bintree_solution:
		var current_child := get_child(tree_positions[parenthesis_depth])
		match ch:
			"l":
				tree_positions[parenthesis_depth] *= 2
				var new_child = get_child(tree_positions[parenthesis_depth])
				new_child.node_rule.hardcoded_connections.append(current_child)
				current_child.node_rule.hardcoded_connections.append(new_child)
			"r":
				tree_positions[parenthesis_depth] *= 2
				tree_positions[parenthesis_depth] += 1
				var new_child :PuzzleNode = get_child(tree_positions[parenthesis_depth])
				new_child.node_rule.hardcoded_connections.append(current_child)
				current_child.node_rule.hardcoded_connections.append(new_child)
			"(":
				parenthesis_depth += 1
				tree_positions.append(tree_positions[parenthesis_depth-1])
			")":
				parenthesis_depth -= 1
				tree_positions.pop_back()
	
	display_connections()
