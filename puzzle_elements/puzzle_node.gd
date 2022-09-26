tool
extends StaticBody2D

class_name PuzzleNode

signal connection_changed
signal correctness_unverified

## A node in a [Puzzle].

## A path node must have only one conneciton and must connect to at least
## another path node
export var path := false
## Deprecated
export var allow_branch := false

## The node that represents the cursor
onready var cursor_node: Node2D = get_tree().get_nodes_in_group("Cursor")[0]
## A [RayCast2D] that checks if the mouse will connect a node or not
onready var raycast: RayCast2D = $RayCast

## The [PuzzleNode]s that this node is connected
var connections: Array = []

onready var parent :Puzzle = get_parent()

func _ready():
	$PathMark.visible = path


func _process(delta):
	if not Engine.is_editor_hint():
		if cursor_node.position.distance_to(global_position) < 6:
			$Sprite2d.scale.x = 1.2
			$Sprite2d.scale.y = 1.2
		else:
			$Sprite2d.scale.x = 1.0
			$Sprite2d.scale.y = 1.0
	else:
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
			while next_checks.size() > 0:
				var current_check = next_checks[0]
				if !current_check.path:
					already_checked.append(current_check)
					next_checks.remove(0)
					for i in current_check.connections:
						if not i in already_checked:
							next_checks.append(i)
				else:
					return true
			return false # if it gets here it's cuz it never found a goal
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

