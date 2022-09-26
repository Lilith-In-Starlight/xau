tool
extends Puzzle

## A [Puzzle] where the nodes are set in a grid
##
## A PuzzleGrid automatically sets all its nodes to be in a grid-like
## configuration, allowing for spaces with holes

## The size of a row. If there are more than [member row_size] [PuzzleNode]s,
## there will be more than one row.
export var row_size :int = 1 setget set_row_size

## The separation between adjacent nodes in this puzzle
export var spacing :int = 16 setget set_spacing
		
## Positions of the puzzle where there should not be a node
export var holes: PoolVector2Array = []

func _init():
	base_display_connections = false

func _ready():
	update_children_positions()
	display_connections()

func set_row_size(value):
	row_size = value
	update_children_positions()
	
func set_spacing(value):
	spacing = value
	update_children_positions()

func _process(delta):
	if Engine.is_editor_hint():
		update_children_positions()


func _draw():
	._draw()
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
	if Engine.editor_hint:
		update()
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


func _on_child_entered_tree(new_child: Node) -> void:
	update_children_positions()
	._on_child_entered_tree(new_child)


func _on_child_exiting_tree(new_child: Node) -> void:
	update_children_positions([new_child])
	._on_child_exiting_tree(new_child)
