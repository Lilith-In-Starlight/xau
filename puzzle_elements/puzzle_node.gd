@tool
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

@export var node_rule := TYPES.NONE: set = set_node_rule


var forced_edges: int

var color :int

var hardcoded_connections :Array
var forced_connections: Array

## The node that represents the cursor
@onready var cursor_node: Node2D = get_tree().get_nodes_in_group("Cursor")[0]
## A [RayCast2D] that checks if the mouse will connect a node or not
@onready var raycast: RayCast2D = $RayCast3D

@onready var circle: Sprite2D = $Sprite2d

## The [PuzzleNode]s that this node is connected
var connections: Array = []

@onready var parent :Puzzle = get_parent()

@onready var player :CharacterBody2D = get_tree().get_nodes_in_group("Player")[0]

func _ready():
	$PathMark.visible = node_rule == TYPES.PATH
	$PathMark.modulate = get_color()
	$IsoMark.visible = node_rule == TYPES.ISOMORPH
	$IsoMark.modulate = get_color()
	$PathMark/PathMark2.visible = color != COLORS.black
	$IsoMark/IsoMark2.visible = color != COLORS.black


func _process(delta):
	if not Engine.is_editor_hint():
		if cursor_node.connecting_from == self:
			connect_puzzle(cursor_node.position)
		
		for i in forced_connections:
			var node = get_node_or_null(i)
			if node == null: continue
			if not node in connections:
				connections.append(node)
				emit_signal("connection_changed", self, node, "connect")
			if not self in node.connections:
				node.connections.append(self)
				node.emit_signal("connection_changed", node, self, "connect")
		
	elif not get_parent() is SubViewport:
		$PathMark.modulate = get_color()
		$PathMark.visible = node_rule == TYPES.PATH
		$PathMark/PathMark2.visible = color != COLORS.black
		$IsoMark/IsoMark2.visible = color != COLORS.black
		$IsoMark.visible = node_rule == TYPES.ISOMORPH
		$IsoMark.modulate = get_color()


func set_node_rule(value):
	node_rule = value
	notify_property_list_changed()

## Returns whether this node's requirements are satisfied
func check() -> bool:
	match node_rule:
		TYPES.PATH:
			if connections.size() > 1:
				return false
				
			if connections.is_empty():
				return false
			
			var next_checks: Array = [self]
			var already_checked: Array = []
			var connection_color :int = color
			while next_checks.size() > 0:
				var currently_checking = next_checks.pop_back()
				already_checked.append(currently_checking)
				for neighbor in currently_checking.connections:
					if neighbor in already_checked or neighbor == self:
						continue
					if neighbor.node_rule == TYPES.PATH:
						return neighbor.color == color or neighbor.color == COLORS.black or color == COLORS.black
						
					next_checks.append(neighbor)
			return false
		TYPES.HARDCODE:
			if connections.size() != hardcoded_connections.size():
				return false
			for i in hardcoded_connections:
				if not get_node(i) in connections:
					return false
		TYPES.ISOMORPH:
			pass
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



func _on_node_button_gui_input(event: InputEvent):
	if cursor_node.position.distance_to(global_position) >= 7:
		return
	if Input.is_action_just_pressed("connect"):
		var solved_sound := preload("res://sfx/ephemeral_sound.tscn").instantiate()
		solved_sound.stream = preload("res://sfx/node_connect.wav")
		solved_sound.pitch_scale = 0.5 + randf() * 1.5
		get_parent().add_child(solved_sound)
		emit_signal("correctness_unverified")
		
		if cursor_node.connecting_from == null:
			cursor_node.connecting_from = self
	
	elif Input.is_action_just_pressed("noconnect"):
		emit_signal("correctness_unverified")
		emit_signal("delete_node_connections_request", self, false)
	
	elif Input.is_action_just_pressed("puzzle_reset"):
		emit_signal("correctness_unverified")
		emit_signal("delete_node_connections_request", self, true)
		var solved_sound := preload("res://sfx/ephemeral_sound.tscn").instantiate()
		solved_sound.stream = preload("res://sfx/xau_reset.wav")
		solved_sound.pitch_scale = 0.8 + randf()*0.2
		add_child(solved_sound)


## Try to connect to a node towards a particular direction, usually directed
## by the cursor
func connect_puzzle(target, disconnect := false):
	raycast.target_position = target - global_position
	raycast.force_raycast_update()
	if not raycast.is_colliding():
		raycast.target_position = Vector2.ZERO
		return
	
	var raycast_collider = raycast.get_collider()
	if not raycast_collider.is_in_group("PuzzleNode"):
		raycast.target_position = Vector2.ZERO
		return
		
	if raycast_collider.parent == parent or (!parent.framed and !raycast_collider.parent.framed):
		if not raycast_collider.parent.is_enabled():
			raycast.target_position = Vector2.ZERO
			return
		
		var solved_sound := preload("res://sfx/ephemeral_sound.tscn").instantiate()
		solved_sound.stream = preload("res://sfx/node_connect.wav")
		solved_sound.pitch_scale = 0.5 + randf() * 1.5
		add_child(solved_sound)
		raycast.target_position = raycast_collider.global_position - raycast.global_position
		raycast.force_raycast_update()
		
		if not raycast.is_colliding():
			raycast.target_position = Vector2.ZERO
			return
		
		var raycast_verification_collider := raycast.get_collider()
		if not raycast_verification_collider == raycast_collider:
			raycast.target_position = Vector2.ZERO
			return
			
			
		if not raycast_collider in connections and not disconnect:
			connections.append(raycast_collider)
			raycast_collider.connections.append(self)
			cursor_node.connecting_from = raycast_collider
			raycast_collider.connect_puzzle(target)
			emit_signal("connection_changed", self, raycast_collider, "connect")
		elif raycast_collider in connections:
			connections.erase(raycast_collider)
			raycast_collider.connections.erase(self)
			cursor_node.connecting_from = raycast_collider
			raycast_collider.connect_puzzle(target)
			emit_signal("connection_changed", self, raycast_collider, "disconnect")
	
	raycast.target_position = Vector2.ZERO


func get_color():
	match color:
		COLORS.black:
			return Color(0, 0, 0)
		COLORS.blue:
			return Color(0.3, 0.3, 1.0)
		COLORS.yellow:
			return Color(0.9, 0.6, 0.3)


func _get_property_list() -> Array:
	var properties := []
	
	properties.append({
		name = "forced_connections",
		type = TYPE_ARRAY,
		hint = 26,
		hint_string = "15:"
	})
	match node_rule:
		TYPES.PATH:
			properties.append({
				name = "color",
				type = TYPE_INT,
				hint = PROPERTY_HINT_ENUM,
				hint_string = "Black,Blue,Yellow"
			})
		TYPES.ISOMORPH:
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

func _property_can_revert(property: StringName) -> bool:
	match property:
		"color", "forced_edges", "hardcoded_connections": return true
		_: return false


func _property_get_revert(property: StringName):
	match property:
		"color": return 0
		"forced_edges": return 0
		"hardcoded_connections": return []


func get_graph_shape():
	var node_ids := [self]
	var unchecked_nodes := [self]
	var checked_nodes := []
	var vertices := {
		0 : []
	}
	for checking in unchecked_nodes:
		var checking_id := node_ids.find(checking)
		checked_nodes.append(checking)
		for neighbor in checking.connections:
			if not node_ids.has(neighbor):
				node_ids.append(neighbor)
			var neighbor_id = node_ids.find(neighbor)
			if not vertices.has(neighbor_id):
				vertices[neighbor_id] = []
			if not vertices[checking_id].has(neighbor_id):
				vertices[checking_id].append(neighbor_id)
			if not neighbor in checked_nodes:
				unchecked_nodes.append(neighbor)
	
	for i in vertices:
		vertices[i].sort()
	
	return vertices

func get_all_nodes_in_graph():
	var unchecked_nodes := [self]
	var known_nodes := []
	for checking in unchecked_nodes:
		if not checking in known_nodes:
			known_nodes.append(checking)
		for neighbor in checking.connections:
			if not neighbor in known_nodes:
				unchecked_nodes.append(neighbor)
	return known_nodes


func get_neighbor_identifiers():
	var unchecked_nodes := [self]
	var checked_nodes := []
	var neighbor_id := {}
	for checking in unchecked_nodes:
		checked_nodes.append(checking)
		var new_neighbor_list := []
		for neighbor in checking.connections:
			new_neighbor_list.append(neighbor.connections.size())
			if not neighbor in checked_nodes:
				unchecked_nodes.append(neighbor)
		new_neighbor_list.sort()
		if not neighbor_id.has(hash(new_neighbor_list)):
			neighbor_id[hash(new_neighbor_list)] = 0
		neighbor_id[hash(new_neighbor_list)] += 1
	return neighbor_id


func get_unique_id():
	var already_seen := []
	var to_see := [self]
	var new_to_see := []
	var loop := true
	var id := []
	while not to_see.is_empty():
		var new_id_num := 0
		var next_already_seen := []
		for checking in to_see:
			next_already_seen.append(checking)
			for neighbor in checking.connections:
				print(already_seen)
				if not neighbor in already_seen and not neighbor in checking.connections:
					new_id_num += 1
					new_to_see.append(neighbor)
		id.append(new_id_num)
		already_seen.append_array(next_already_seen)
		to_see = new_to_see.duplicate()
		new_to_see = []
	return id


func _on_node_button_down() -> void:
	pass # Replace with function body.



func _on_mouse_entered() -> void:
	scale.x = 1.2
	scale.y = 1.2

func _on_mouse_exited() -> void:
	scale.x = 1
	scale.y = 1

