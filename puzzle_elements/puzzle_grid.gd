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

@export var node_arrangement: NodeArrangement = null

@export var is_on_floor: bool = true


func _init():
	base_display_connections = false
	

func _ready():
	update_children_positions()
	super._ready()
	display_connections()
	
	if not Engine.is_editor_hint():
		if is_on_floor:
			var new_shape = RectangleShape2D.new()
			var rectt := get_rect()
			new_shape.size = rectt.grow(8).size
			$NoNode/metal/CollisionShape2D.shape = new_shape
			$NoNode/metal/CollisionShape2D.position = rectt.get_center()
		else:
			$NoNode/metal.queue_free()


func _process(_delta: float) -> void:
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
		$NoNode/Frame/Background.scale.y = (new_rect.size.y) * 0.5
		$NoNode/Frame/Background.scale.x = new_rect.size.x - 1
		$NoNode/Frame/Background.position = new_rect.position
		if is_enabled():
			$NoNode/Frame/Background.modulate = get_on_background_color()
		else:
			$NoNode/Frame/Background.modulate = get_off_background_color()
	else:
		$NoNode/Frame.visible = false


## Updates the node's children positions to match the row size
func update_children_positions(exclusions: Array[Node] = []):	
	if Engine.is_editor_hint():
		queue_redraw()
		
	if not node_arrangement == null:
		node_arrangement.arrange_nodes(self, exclusions)
	


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


func get_rect() -> Rect2:
	if node_arrangement == null:
		return super.get_rect()
	rect = node_arrangement.get_used_area(self)
	return rect
