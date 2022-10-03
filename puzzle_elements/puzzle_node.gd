tool
extends StaticBody2D

class_name PuzzleNode

## A node in a [Puzzle].

signal connection_changed(from, to, type)
signal correctness_unverified
signal delete_node_connections_request(node, full)

enum COLORS {
	black,
	blue,
	yellow,
}

enum TYPES {
	NONE,
	## A path node must have only one conneciton and must connect to at least
	## another path node of the same color. Black doesn't care about color.
	PATH,
	## A Section node must be in a section whose edges amount to the sum
	## of all the Section nodes in it
	SECTION,
	## Two Isomorph nodes of the same color must be in isomorphic sections
	ISOMORPH,
	## A Loop node must be in a section that loops into itself
	LOOP,
	## A hardcoded node must be connected to the specified nodes
	HARDCODE,
}

export(TYPES) var node_rule := TYPES.NONE setget set_node_rule

var forced_edges: int

var color :int

var hardcoded_connections :Array

## The node that represents the cursor
onready var cursor_node: Node2D = get_tree().get_nodes_in_group("Cursor")[0]
## A [RayCast2D] that checks if the mouse will connect a node or not
onready var raycast: RayCast2D = $RayCast

onready var circle: Sprite = $Sprite2d

## The [PuzzleNode]s that this node is connected
var connections: Array = []

onready var parent :Puzzle = get_parent()

onready var player :KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]

func _ready():
	$PathMark.visible = node_rule == TYPES.PATH
	$PathMark.modulate = get_color()


func _process(delta):
	if not Engine.is_editor_hint():
		if cursor_node.global_position.distance_to(global_position) < 6:
			scale.x = 1.2
			scale.y = 1.2
		else:
			scale.x = 1
			scale.y = 1
	else:
		$PathMark.modulate = get_color()
		$PathMark.visible = node_rule == TYPES.PATH


func set_node_rule(value):
	node_rule = value
	property_list_changed_notify()

## Returns whether this node's requirements are satisfied
func check() -> bool:
	match node_rule:
		TYPES.PATH:
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
					if !current_check.node_rule == TYPES.PATH:
						for i in current_check.connections:
							if not i in already_checked:
								next_checks.append(i)
					else:
						if current_check.color == connection_color or connection_color == COLORS.black or current_check.color == COLORS.black:
							will_return = true
						else:
							will_return = false
				return will_return # if it gets here it's cuz it never found a goal
		TYPES.HARDCODE:
			if connections.size() != hardcoded_connections.size():
				return false
			else:
				for i in hardcoded_connections:
					if not get_node(i) in connections:
						return false
	return true

## Makes the node flash red
func show_failure(default_color: Color):
	var tween = create_tween()
	tween.tween_property(circle, "modulate:g", 0.0, 0.3)
	tween.parallel().tween_property(circle, "modulate:b", 0.0, 0.3)
	tween.tween_property(circle, "modulate", default_color, 0.3)
	tween.tween_property(circle, "modulate:g", 0.0, 0.3)
	tween.parallel().tween_property(circle, "modulate:b", 0.0, 0.3)
	tween.tween_property(circle, "modulate", default_color, 0.3)
	tween.play()



func _input(delta):
	if Input.is_action_just_pressed("connect"):
		if cursor_node.position.distance_to(global_position) < 6:
			var solved_sound := preload("res://sfx/ephemeral_sound.tscn").instance()
			solved_sound.stream = preload("res://sfx/node_connect.wav")
			solved_sound.pitch_scale = 0.5 + randf() * 1.5
			add_child(solved_sound)
	if Input.is_action_pressed("connect"):
		if cursor_node.position.distance_to(global_position) < 6:
			emit_signal("correctness_unverified")
			if cursor_node.connecting_from == null:
				cursor_node.connecting_from = self
		elif cursor_node.connecting_from == self:
			connect_puzzle(cursor_node.position)
	elif Input.is_action_just_pressed("noconnect"):
		if cursor_node.position.distance_to(global_position) < 6:
			emit_signal("correctness_unverified")
			emit_signal("delete_node_connections_request", self, false)
	elif Input.is_action_just_pressed("puzzle_reset"):
		if cursor_node.position.distance_to(global_position) < 6:
			emit_signal("correctness_unverified")
			emit_signal("delete_node_connections_request", self, true)
			var solved_sound := preload("res://sfx/ephemeral_sound.tscn").instance()
			solved_sound.stream = preload("res://sfx/xau_reset.wav")
			solved_sound.pitch_scale = 0.8 + randf()*0.2
			add_child(solved_sound)


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
					var solved_sound := preload("res://sfx/ephemeral_sound.tscn").instance()
					solved_sound.stream = preload("res://sfx/node_connect.wav")
					solved_sound.pitch_scale = 0.5 + randf() * 1.5
					add_child(solved_sound)
					if not raycast_collider in connections and not disconnect:
						connections.append(raycast_collider)
						raycast_collider.connections.append(self)
						cursor_node.connecting_from = raycast_collider
						raycast_collider.connect_puzzle(target)
						emit_signal("connection_changed", self, raycast_collider, "connect")
					else:
						connections.erase(raycast_collider)
						raycast_collider.connections.erase(self)
						cursor_node.connecting_from = raycast_collider
						raycast_collider.connect_puzzle(target)
						emit_signal("connection_changed", self, raycast_collider, "disconnect")
	raycast.cast_to = Vector2.ZERO


func get_color():
	match color:
		COLORS.black:
			return Color(0, 0, 0)
		COLORS.blue:
			return Color(0.2, 0.2, 0.9)
		COLORS.yellow:
			return Color(0.9, 0.6, 0.3)


func _get_property_list() -> Array:
	var properties := []
	match node_rule:
		TYPES.PATH:
			properties.append({
				name = "color",
				type = TYPE_INT,
				hint = PROPERTY_HINT_ENUM,
				hint_string = "Black,Blue,Yellow"
			})
		TYPES.SECTION:
			properties.append({
				name = "forced_edges",
				type = TYPE_INT,
				
			})
			properties.append({
				name = "color",
				type = TYPE_INT,
				hint = PROPERTY_HINT_ENUM,
				hint_string = "Black,Blue,Yellow"
			})
		TYPES.HARDCODE:
			properties.append({
				name = "hardcoded_connections",
				type = TYPE_ARRAY,
				hint = 26,
				hint_string = "15:",
			})
	return properties

func property_can_revert(property: String) -> bool:
	match property:
		"color", "forced_edges", "hardcoded_connections": return true
		_: return false


func property_get_revert(property: String):
	match property:
		"color": return 0
		"forced_edges": return 0
		"hardcoded_connections": return []
