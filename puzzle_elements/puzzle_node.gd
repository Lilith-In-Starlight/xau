@tool
extends StaticBody2D

class_name PuzzleNode

## A node in a [Puzzle].

signal connection_changed(from, to, type)
signal correctness_unverified
signal delete_node_connections_request(node, full)

const branch_symbols := [
		null,
		preload("res://sprites/puzzles/branch_node_1.png"),
		preload("res://sprites/puzzles/branch_node_2.png"),
		preload("res://sprites/puzzles/branch_node_3.png"),
		preload("res://sprites/puzzles/branch_node_4.png"),
		preload("res://sprites/puzzles/branch_node_5.png"),
		preload("res://sprites/puzzles/branch_node_6.png"),
	]

const branch_frame := [
		null,
		preload("res://sprites/puzzles/branch_node_1_bg.png"),
		preload("res://sprites/puzzles/branch_node_2_bgt.png"),
		preload("res://sprites/puzzles/branch_node_3_bgt.png"),
		preload("res://sprites/puzzles/branch_node_4_bg.png"),
		preload("res://sprites/puzzles/branch_node_5_bg.png"),
		preload("res://sprites/puzzles/branch_node_6_bgt.png"),
	]

@export var node_rule :NodeRule = null


var forced_edges: int

@export var forced_connections: Array[NodePath]

## The node that represents the cursor
@onready var cursor_node: Node2D = get_tree().get_first_node_in_group("Cursor")
## A [RayCast2D] that checks if the mouse will connect a node or not
@onready var raycast: RayCast2D = $RayCast3D

@onready var circle: Sprite2D = $Sprite2d

## The [PuzzleNode]s that this node is connected
var connections: Array[PuzzleNode] = []

@onready var parent :Puzzle = get_parent()

@onready var player :CharacterBody2D = get_tree().get_first_node_in_group("Player")

func _ready():
	if not Engine.is_editor_hint():
		get_tree().get_first_node_in_group("HUD").color_settings_changed.connect(set_node_visuals)
	set_node_visuals()


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		var hold_mode :bool = SaveData.save_handler.vget_value(["accessibility", "hold"], true)
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
	var hold_mode :bool = SaveData.save_handler.vget_value(["accessibility", "hold"], true)
	if to_local(cursor_node.position).length() >= 7:
		return
	get_parent().was_interacted_with.emit()
	if Input.is_action_just_pressed("connect"):
		emit_ephemeral_sound(preload("res://sfx/node_connect.wav"), 0.5 + randf() * 1.5)
		correctness_unverified.emit()

		if cursor_node.disconnected_from == self and not hold_mode:
			cursor_node.connecting_from = null
			cursor_node.disconnected_from = null
		elif cursor_node.connecting_from == null:
			cursor_node.connecting_from = self

	elif Input.is_action_just_pressed("noconnect"):
		if cursor_node.disconnected_from != self:
			emit_ephemeral_sound(preload("res://sfx/node_connect.wav"), 1.0 + randf() * 0.5, -5.0)
			correctness_unverified.emit()
			delete_node_connections_request.emit(self, false)
		else:
			emit_ephemeral_sound(preload("res://sfx/node_connect.wav"), 0.5 + randf() * 1.5)
			cursor_node.disconnected_from = null

	elif Input.is_action_just_pressed("puzzle_reset"):
		correctness_unverified.emit()
		delete_node_connections_request.emit(self, true)

		emit_ephemeral_sound(preload("res://sfx/xau_reset.wav"), 0.8 + randf()*0.2)


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

		emit_ephemeral_sound(preload("res://sfx/node_connect.wav"), 0.5 + randf() * 1.5)

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
		emit_ephemeral_sound(preload("res://sfx/node_connect.wav"), 1.0 + randf() * 0.5, -5.0)
		correctness_unverified.emit()
		delete_node_connections_request.emit(self, false)


func _on_mouse_exited() -> void:
	scale.x = 1
	scale.y = 1


func set_node_visuals() -> void:
	var is_rule_unset := node_rule == null
	var is_rule_hardcore := node_rule is HardcodeNodeRule

	$Symbol.visible = not is_rule_unset and not is_rule_hardcore
	$Background.visible = not is_rule_unset and not is_rule_hardcore and not node_rule.color == NodeRule.COLORS.black
	$Background.modulate = get_color()
	var col := get_color()
	var luminance := col.r * 0.2126 + col.g * 0.7152 + col.b * 0.722
	if not is_rule_unset and not is_rule_hardcore and not node_rule.color == NodeRule.COLORS.black:
		if get_color().get_luminance() > 0.5:
			$Symbol.modulate = get_color().darkened(0.6)
		else:
			$Symbol.modulate = get_color().lightened(0.6)

	if node_rule is PathNodeRule:
		$Symbol.texture = preload("res://sprites/puzzles/path_node.png")
	elif node_rule is IsoNodeRule:
		$Symbol.texture = preload("res://sprites/puzzles/iso_node.png")
	elif node_rule is FixNodeRule:
		$Symbol.texture = preload("res://sprites/puzzles/fix_node.png")
	elif node_rule is CycleNodeRule:
		$Symbol.texture = preload("res://sprites/puzzles/cycle_node.png")
	elif node_rule is BranchLengthNodeRule:
		$Symbol.texture = branch_symbols[node_rule.required_length]


func _draw():
	if Engine.is_editor_hint():
		for i in forced_connections:
			var ch = get_node_or_null(i)
			draw_line(Vector2(0, 0), to_local(ch.global_position), Color.AQUAMARINE, 2.0)


func get_closest_loop() -> Array:
	if Engine.is_editor_hint():
		return []
	var dogs :Array[Array] = [[self]]

	var latest_nodes := []
	var loop_found :bool = false
	var loop :Array

	while not dogs.is_empty():
		var dog = dogs.pop_back()
		var latest_node :PuzzleNode = dog.back()

		for neighbor in latest_node.connections:
			if dog.size() >= 2:
				var before_latest_node = dog[dog.size() - 2]
				if neighbor == before_latest_node:
					continue

			if neighbor == self:
				if dog.size() < loop.size() or loop.is_empty():
					loop = dog
				break

			elif neighbor in dog:
				continue

			var new_dog: Array = dog.duplicate()
			new_dog.append(neighbor)
			dogs.append(new_dog)

	return loop


func get_branch() -> Array[PuzzleNode]:
	var already_checked :Array[PuzzleNode] = []
	var to_check :Array[PuzzleNode] = [self]
	var nodes_in_branch :Array[PuzzleNode] = []

	for checking_node in to_check:
		already_checked.append(checking_node)
		nodes_in_branch.append(checking_node)

		if checking_node.connections.size() > 2:
			continue

		for neighbor in checking_node.connections:
			if neighbor in already_checked:
				continue
			if not neighbor in to_check:
				to_check.append(neighbor)


	return nodes_in_branch


func emit_ephemeral_sound(resource: AudioStream, pitch: float = 1.0, volume: float = 1.0) -> void:
		var solved_sound := preload("res://sfx/ephemeral_sound.tscn").instantiate()
		solved_sound.stream = resource
		solved_sound.pitch_scale = pitch
		solved_sound.volume_db = volume
		add_child(solved_sound)
