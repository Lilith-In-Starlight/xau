@tool
extends StaticBody2D

class_name PuzzleNode

## A node in a [Puzzle].

signal connection_changed(from, to, type)
signal correctness_unverified
signal delete_node_connections_request(node, full)


@export var node_rule :NodeRule = null


var forced_edges: int

@export var forced_connections: Array[NodePath]

## The node that represents the cursor
@onready var cursor_node: Node2D = get_tree().get_first_node_in_group("Cursor")
## A [RayCast2D] that checks if the mouse will connect a node or not
@onready var raycast: RayCast2D = $RayCast3D

@onready var circle: Sprite2D = $Sprite2d

## The [PuzzleNode]s that this node is connected
var connections: Array = []

@onready var parent :Puzzle = get_parent()

@onready var player :CharacterBody2D = get_tree().get_first_node_in_group("Player")

func _ready():
	if not Engine.is_editor_hint():
		get_tree().get_first_node_in_group("HUD").color_settings_changed.connect(set_node_visuals)
	set_node_visuals()


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		if cursor_node.connecting_from == self:
			connect_puzzle(cursor_node.position)
		
		for i in forced_connections:
			var node = get_node_or_null(i)
			if node == null: continue
			if not node in connections:
				connections.append(node)
				connection_changed.emit(self, node, "connect")
			if not self in node.connections:
				node.connections.append(self)
				node.connection_changed.emit(node, self, "connect")
		
	elif not get_parent() is Viewport:
		set_node_visuals()
		queue_redraw()


func set_node_rule(value):
	node_rule = value
	notify_property_list_changed()

## Returns whether this node's requirements are satisfied
func check() -> bool:
	if node_rule == null:
		return true
	return node_rule.check_correctness(self)

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



func _on_node_button_gui_input(_event: InputEvent) -> void:
	if to_local(cursor_node.position).length() >= 7:
		return
	get_parent().was_interacted_with.emit()
	if Input.is_action_just_pressed("connect"):
		var solved_sound := preload("res://sfx/ephemeral_sound.tscn").instantiate()
		solved_sound.stream = preload("res://sfx/node_connect.wav")
		solved_sound.pitch_scale = 0.5 + randf() * 1.5
		get_parent().add_child(solved_sound)
		correctness_unverified.emit()
		
		if cursor_node.connecting_from == null:
			cursor_node.connecting_from = self
	
	elif Input.is_action_just_pressed("noconnect"):
		correctness_unverified.emit()
		delete_node_connections_request.emit(self, false)
	
	elif Input.is_action_just_pressed("puzzle_reset"):
		correctness_unverified.emit()
		delete_node_connections_request.emit(self, true)
		var solved_sound := preload("res://sfx/ephemeral_sound.tscn").instantiate()
		solved_sound.stream = preload("res://sfx/xau_reset.wav")
		solved_sound.pitch_scale = 0.8 + randf()*0.2
		add_child(solved_sound)


## Try to connect to a node towards a particular direction, usually directed
## by the cursor
func connect_puzzle(target, disconnect := false):
	raycast.target_position = to_local(target)
	
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
		
		raycast.target_position = to_local(raycast_collider.global_position)
		raycast.force_raycast_update()
		
		if not raycast.is_colliding():
			raycast.target_position = Vector2.ZERO
			return
		
		var raycast_verification_collider := raycast.get_collider()
		if not raycast_verification_collider == raycast_collider:
			raycast.target_position = Vector2.ZERO
			return
		
		var solved_sound := preload("res://sfx/ephemeral_sound.tscn").instantiate()
		solved_sound.stream = preload("res://sfx/node_connect.wav")
		solved_sound.pitch_scale = 0.5 + randf() * 1.5
		add_child(solved_sound)
			
		if not raycast_collider in connections and not disconnect:
			connections.append(raycast_collider)
			raycast_collider.connections.append(self)
			cursor_node.connecting_from = raycast_collider
			raycast_collider.connect_puzzle(target)
			connection_changed.emit(self, raycast_collider, "connect")
		elif raycast_collider in connections:
			connections.erase(raycast_collider)
			raycast_collider.connections.erase(self)
			cursor_node.connecting_from = raycast_collider
			raycast_collider.connect_puzzle(target)
			connection_changed.emit(self, raycast_collider, "disconnect")
	
	raycast.target_position = Vector2.ZERO


func get_color() -> Color:
	if node_rule == null:
		return Color(0, 0, 0)
	match node_rule.color:
		NodeRule.COLORS.black:
			return Color(0, 0, 0)
		_:
			if Engine.is_editor_hint():
				return NodeRule.get_default_color(node_rule.color)
			return SaveData.get_node_color(node_rule.color)


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


func get_unique_id():
	var already_seen := []
	var to_see := [self]
	var new_to_see := []
	var id := []
	while not to_see.is_empty():
		var new_id_num := 0
		var next_already_seen := []
		for checking in to_see:
			next_already_seen.append(checking)
			for neighbor in checking.connections:
				if not neighbor in already_seen and not neighbor == checking:
					new_id_num += 1
					new_to_see.append(neighbor)
		id.append(new_id_num)
		already_seen.append_array(next_already_seen)
		to_see = new_to_see.duplicate()
		new_to_see = []
	return id


func _on_mouse_entered() -> void:
	scale.x = 1.2
	scale.y = 1.2
	
	if Input.is_action_pressed("noconnect"):
		correctness_unverified.emit()
		delete_node_connections_request.emit(self, false)


func _on_mouse_exited() -> void:
	scale.x = 1
	scale.y = 1


func set_node_visuals() -> void:
	$PathMark.visible = node_rule is PathNodeRule
	$PathMark.modulate = get_color()
	$IsoMark.visible = node_rule is IsoNodeRule
	$IsoMark.modulate = get_color()
	$FixMark.visible = node_rule is FixNodeRule
	if node_rule != null:
		$PathMark/PathMark2.visible = node_rule.color != NodeRule.COLORS.black
		$IsoMark/IsoMark2.visible = node_rule.color != NodeRule.COLORS.black


func _draw():
	if Engine.is_editor_hint():
		for i in forced_connections:
			var ch = get_node_or_null(i)
			draw_line(Vector2(0, 0), to_local(ch.global_position), Color.AQUAMARINE, 2.0)
