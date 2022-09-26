tool
extends StaticBody2D

class_name PuzzleNode

## A node in a [Puzzle].

signal connection_changed
signal correctness_unverified

enum COLORS {
	black,
	blue,
	yellow,
}

## A path node must have only one conneciton and must connect to at least
## another path node
export var path := false
## Deprecated
export var allow_branch := false

export(COLORS) var color := COLORS.black

## The node that represents the cursor
onready var cursor_node: Node2D = get_tree().get_nodes_in_group("Cursor")[0]
## A [RayCast2D] that checks if the mouse will connect a node or not
onready var raycast: RayCast2D = $RayCast

## The [PuzzleNode]s that this node is connected
var connections: Array = []

onready var parent :Puzzle = get_parent()

func _ready():
	$PathMark.visible = path
	$PathMark.modulate = get_color()


func _process(delta):
	if not Engine.is_editor_hint():
		set_process(false)
	else:
		$PathMark.modulate = get_color()
		$PathMark.visible = path


## Returns whether this node's requirements are satisfied
func check() -> bool:
	if path:
		if connections.size() > 1:
			return false
		else:
			if connections.empty():
				return false
			var next_checks: Array = [connections[0]]
			var already_checked: Array = [self]
			var connection_color :int = color
			var will_return := false
			while next_checks.size() > 0:
				var current_check = next_checks[0]
				already_checked.append(current_check)
				next_checks.remove(0)
				if !current_check.path:
					for i in current_check.connections:
						if not i in already_checked:
							next_checks.append(i)
				else:
					if current_check.color == connection_color or connection_color == COLORS.black or current_check.color == COLORS.black:
						will_return = true
					else:
						will_return = false
			return will_return # if it gets here it's cuz it never found a goal
	return true

## Makes the node flash red
func show_failure():
	var tween = create_tween()
	tween.tween_property(self, "modulate:g", 0.0, 0.3)
	tween.parallel().tween_property(self, "modulate:b", 0.0, 0.3)
	tween.tween_property(self, "modulate:g", 1.0, 0.3)
	tween.parallel().tween_property(self, "modulate:b", 1.0, 0.3)
	tween.tween_property(self, "modulate:g", 0.0, 0.3)
	tween.parallel().tween_property(self, "modulate:b", 0.0, 0.3)
	tween.tween_property(self, "modulate:g", 1.0, 0.3)
	tween.parallel().tween_property(self, "modulate:b", 1.0, 0.3)
	tween.play()



func _input(delta):
	if Input.is_action_pressed("connect"):
		if cursor_node.position.distance_to(global_position) < 6:
			emit_signal("correctness_unverified")
			if cursor_node.connecting_from == null:
				cursor_node.connecting_from = self
		elif cursor_node.connecting_from == self:
			connect_puzzle(cursor_node.position)
	elif Input.is_action_pressed("noconnect"):
		if cursor_node.position.distance_to(global_position) < 6:
			emit_signal("correctness_unverified")
			if cursor_node.connecting_from == null:
				cursor_node.connecting_from = self
		elif cursor_node.connecting_from == self:
			connect_puzzle(cursor_node.position, true)


## Try to connect to a node towards a particular direction, usually directed
## by the cursor
func connect_puzzle(target, disconnect := false):
	raycast.cast_to = target - global_position
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var raycast_collider = raycast.get_collider()
		if raycast_collider.is_in_group("PuzzleNode"):
			if raycast_collider.parent == parent or (!parent.framed and !raycast_collider.parent.framed):
				if raycast_collider.parent.is_enabled():
					if not raycast_collider in connections and not disconnect:
						connections.append(raycast_collider)
						raycast_collider.connections.append(self)
						cursor_node.connecting_from = raycast_collider
						raycast_collider.connect_puzzle(target)
						emit_signal("connection_changed")
					else:
						connections.erase(raycast_collider)
						raycast_collider.connections.erase(self)
						cursor_node.connecting_from = raycast_collider
						raycast_collider.connect_puzzle(target)
						emit_signal("connection_changed")
	raycast.cast_to = Vector2.ZERO


func get_color():
	match color:
		COLORS.black:
			return Color(0, 0, 0)
		COLORS.blue:
			return Color(0.2, 0.2, 0.9)
		COLORS.yellow:
			return Color(0.9, 0.6, 0.3)
