@tool
extends Node2D

class_name Puzzle

## A node graph that must be solved.
##
## Puzzles are node graphs. Every child of this node that is in
## the group "PuzzleNode" is interpreted as a node.
##
## When every node's demands are satisified, the puzzle is correct
## if the node's demands have been satisified at any point in the past,
## it is considered solved, even when not currently correct.
##
## A Puzzle must have a NoNode puzzle, which will be used for extra things like
## decoration and connection displays

## Emitted when the puzzle is solved
signal was_solved
signal was_interacted_with(puzzle)


## A Puzzle that is required to solve this one
@export var required_puzzle: NodePath: set = set_required_puzzle

var required_node: Node2D


@export var puzzle_theme: PuzzleTheme = null

## Whether the puzzle can connect to other puzzles
@export var framed := true

## Unique identifier used to connect puzzles across scenes
@export var puzzle_id := "default"

@onready var cursor_node :Cursor = get_tree().get_first_node_in_group("Cursor")

@onready var id = str(get_path())

## Whether the puzzle was solved or not
var solved := false

## The square area that contains all the nodes in the puzzle
var rect := Rect2()

## Whether the puzzle is currently verified as correct
var correct := false: set = set_correct

var base_display_connections := true

@onready var player :CharacterBody2D = get_tree().get_first_node_in_group("Player")

var is_visible := false

func _draw():
	get_rect()


func _ready():
	if Engine.is_editor_hint():
		child_entered_tree.connect(_on_child_entered_tree)
		child_exiting_tree.connect(_on_child_exiting_tree)
	else:
		tree_exiting.connect(save_data)
		var camera_node = get_tree().get_first_node_in_group("Camera3D")
		was_interacted_with.connect(camera_node.set_target_zoom.bind(self))
		required_node = get_node_or_null(required_puzzle)
		for i in get_children():
			if i.is_in_group("PuzzleNode"):
				i.connection_changed.connect(_on_connection_changed)
				i.correctness_unverified.connect(_on_correctness_unverified)
				i.delete_node_connections_request.connect(_on_delete_node_connections_requested)

		var puzzle_data = SaveData.save_handler.vget_value(["puzzles", id], {"solved": false, "correct": false, "connections": {}})

		solved = puzzle_data["solved"]
		correct = puzzle_data["correct"]

		if solved or correct: was_solved.emit()

		for i in get_child_count():
			var child = get_child(i)

			if not child.is_in_group("PuzzleNode"):
				continue

			if puzzle_data["connections"].has(str(i)):
				for j in puzzle_data["connections"][str(i)]:
					if j is String:
						var new_j = get_node_or_null(j)
						if new_j == null:
							continue
						child.connections.append(new_j)
					else:
						if j < get_child_count():
							child.connections.append(get_child(j))

		if not required_node == null:
			required_node.was_solved.connect(_on_required_was_solved)
		if puzzle_id != "default":
			SaveData.upid[puzzle_id] = self
		if base_display_connections:
			display_connections()


func _input(_event: InputEvent) -> void:
	if not is_visible or not is_enabled():
		return


	if Input.is_action_just_pressed("connect"):
		display_connections()

	if Input.is_action_just_pressed("confirm") and cursor_node.global_position.distance_to(global_position) < 200:
		var unhappy_nodes := get_incorrect_nodes()
		if unhappy_nodes.is_empty():
			show_correct()
			if not correct:
				correct = true
				var solved_sound := preload("res://sfx/ephemeral_sound.tscn").instantiate()
				solved_sound.stream = preload("res://sfx/xau_puzzle_solve.wav")
				solved_sound.pitch_scale = 0.8 + randf()*0.2
				add_child(solved_sound)
			if not solved:
				solved = true
				was_solved.emit()
		else:
			var failed_sound := preload("res://sfx/ephemeral_sound.tscn").instantiate()
			failed_sound.stream = preload("res://sfx/xau_puzzle_fail.wav")
			failed_sound.attenuation = 40
			add_child(failed_sound)
			for i in unhappy_nodes:
				i.show_failure(get_node_color())

		SaveData.save_handler.vsave_value(["puzzles", id], save())


func get_incorrect_nodes() -> Array:
	var unhappy_nodes := []
	var hardcode_fail := false
	var graph_shapes := {}
	var unhappy_graph_colors := []
	var correct_hardcodes := []
	var iso_nodes := []
	var fix_nodes := []

	for i in get_children():
		if not i.is_in_group("PuzzleNode"):
			continue

		if i.node_rule is IsoNodeRule:
			iso_nodes.append(i)
			if i.node_rule.color in unhappy_graph_colors:
				unhappy_nodes.append(i)
				continue

			if not i.node_rule.color in graph_shapes:
				graph_shapes[i.node_rule.color] = [i, []]

				if i.connections.is_empty():
					unhappy_nodes.append(i)
					unhappy_graph_colors.append(i.node_rule.color)
					continue

				for node_in_graph in i.get_all_nodes_in_graph():
					graph_shapes[i.node_rule.color][1].append(node_in_graph.get_unique_id())

					if node_in_graph.node_rule is IsoNodeRule and node_in_graph.node_rule.color == i.node_rule.color and not i == node_in_graph:
						unhappy_nodes.append(i)
						unhappy_graph_colors.append(i.node_rule.color)
						break

			else:
				var current_id := []

				for node_in_graph in i.get_all_nodes_in_graph():
					current_id.append(node_in_graph.get_unique_id())

				if not compare_arrays_by_content(graph_shapes[i.node_rule.color][1], current_id):
					unhappy_nodes.append(i)
					unhappy_nodes.append(graph_shapes[i.node_rule.color][0])
					unhappy_graph_colors.append(i.node_rule.color)

		elif i.node_rule is HardcodeNodeRule:
			if hardcode_fail:
				unhappy_nodes.append(i)

			elif !i.check():
				hardcode_fail = true
				unhappy_nodes.append(i)
				unhappy_nodes.append_array(correct_hardcodes)
				correct_hardcodes = []
			else:
				correct_hardcodes.append(i)

		elif i.node_rule is FixNodeRule:
			fix_nodes.append(i)

		elif !i.check():
			unhappy_nodes.append(i)

	if graph_shapes.size() > 1:
		var black_iso_with :NodeRule.COLORS = NodeRule.COLORS.black
		var comparisons := []
		for color1 in graph_shapes:
			for color2 in graph_shapes:
				if color1 == color2:
					continue

				if [color2, color1] in comparisons:
					continue

				comparisons.append([color1, color2])

				if compare_arrays_by_content(graph_shapes[color1][1], graph_shapes[color2][1]):
					if black_iso_with == NodeRule.COLORS.black and (color1 == NodeRule.COLORS.black or color2 == NodeRule.COLORS.black):
						continue
					else:
						unhappy_nodes.append(graph_shapes[color1][0])
						unhappy_nodes.append(graph_shapes[color2][0])
						unhappy_graph_colors.append(color1)
						unhappy_graph_colors.append(color2)
						break

	for i in iso_nodes:
		if i.node_rule.color in unhappy_graph_colors:
			if not i in unhappy_nodes:
				unhappy_nodes.append(i)

	for i in fix_nodes:
		var found_unhappy := false
		for j in i.get_all_nodes_in_graph():
			if j in unhappy_nodes:
				unhappy_nodes.erase(j)
				found_unhappy = true
				break
		if not found_unhappy:
			unhappy_nodes.append(i)

	return unhappy_nodes


func set_correct(value):
	correct = value
	update_correctness_visuals()

func set_required_puzzle(value):
	required_puzzle = value
	required_node = get_node_or_null(value)
	update_enabled_visuals()

func check_correct():
	var unhappy_nodes := get_incorrect_nodes()
	return unhappy_nodes.is_empty()

## Makes the puzzle look green to indicate that it is correct
func show_correct():
	for i in get_children():
		if not i.name == "NoNode":
			var tween = i.create_tween()
			if i.is_in_group("PuzzleNode"):
				tween.tween_property(i.circle, "modulate", get_correct_node_color(), 0.2)
			else:
				tween.tween_property(i, "modulate", get_correct_node_color(), 0.2)
			tween.play()

## Makes the puzzle look white to show that it is not correct
func unshow_correct():
	for i in get_children():
		if not i.name == "NoNode":
			var tween = i.create_tween()
			if i.is_in_group("PuzzleNode"):
				tween.tween_property(i.circle, "modulate", get_node_color(), 0.2)
			else:
				tween.tween_property(i, "modulate", get_node_color(), 0.2)
			tween.play()

## Called when the puzzle required to interact with this one is solved
func _on_required_was_solved():
	display_connections()
	update_enabled_visuals()
	update_correctness_visuals()


## Whether the puzzle is enabled
func is_enabled() -> bool:
	if required_node == null or Engine.is_editor_hint():
		return true
	return required_node.solved

## Display the correctness of the puzzle
func update_correctness_visuals(queue_redraw: bool = false) -> void:
	if not Engine.is_editor_hint():
		if is_enabled():
			if correct: show_correct()
			else: unshow_correct()
		if queue_redraw: queue_redraw()

## Display whether the puzzle is enabled
func update_enabled_visuals() -> void:
	for i in get_children():
		if not i.name == "NoNode":
			if is_enabled():
				i.modulate.a = 1.0
			elif Engine.is_editor_hint():
				i.modulate.a = 1.0
			else:
				i.modulate.a = 0.0
	queue_redraw()

func _on_child_entered_tree(_gone_node: Node):
	queue_redraw()

func _on_child_exiting_tree(_gone_node: Node):
	queue_redraw()


## Calculates the square area that contains all the [PuzzleNode]s
## in this puzzle
func get_rect() -> Rect2:
	var lesser :Vector2 = Vector2(0, 0)
	var greater := Vector2(0, 0)
	for i in get_children():
		if not i.name == "NoNode":
			if i.position.x < lesser.x:
				lesser.x = i.position.x
			elif i.position.x > greater.x:
				greater.x = i.position.x
			if i.position.y < lesser.y:
				lesser.y = i.position.y
			elif i.position.y > greater.y:
				greater.y = i.position.y
	rect = Rect2(lesser, greater - lesser)
	return Rect2(lesser, greater - lesser)

## Returns a dictionary containting all the information needed to recreate the
## state of this puzzle when the game is opened after being closed
func save() -> Dictionary:
	var dict := {}
	var conn := {}
	dict["solved"] = solved
	dict["correct"] = correct
	dict["connections"] = {}
	for i in get_children():
		var c_con = []
		if i.is_in_group("PuzzleNode"):
			for j in i.connections:
				if j.parent == self:
					c_con.append(j.get_index())
				else:
					c_con.append(str(j.get_path()))
		if not c_con.is_empty():
			conn[str(i.get_index())] = c_con
	if not conn.is_empty():
		dict["connections"] = conn
	return dict


## Updates the connection display
func display_connections():
	var connection_display: Node2D = get_node_or_null("NoNode/Lines")
	if connection_display:
		var known_connections := []
		for child in get_children():
			if child.is_in_group("PuzzleNode"):
				for connection in child.connections:
					if not known_connections.has([connection, child]):
						known_connections.append([child, connection])

		if known_connections.size() > connection_display.get_child_count():
			for i in abs(connection_display.get_child_count() - known_connections.size()):
				var new_line := Line2D.new()
				new_line.default_color = Color.WHITE
				new_line.width = 2.0
				connection_display.add_child(new_line)
		elif known_connections.size() < connection_display.get_child_count():
			for i in abs(connection_display.get_child_count() - known_connections.size()):
				connection_display.remove_child(connection_display.get_child(0))

		for i in known_connections.size():
			var connection: Array = known_connections[i]
			var line: Line2D = connection_display.get_child(i)
			if connection[0] != null and connection[1] != null and connection[0].is_in_group("PuzzleNode") and connection[1].is_in_group("PuzzleNode"):
				var fc_0 := []
				var fc_1 := []
				for fc in connection[0].forced_connections:
					var n = connection[0].get_node_or_null(fc)
					if n == null: continue
					fc_0.append(n)
				for fc in connection[1].forced_connections:
					var n = connection[1].get_node_or_null(fc)
					if n == null: continue
					fc_1.append(n)
				if connection[0] in fc_1 or connection[1] in fc_0:
					line.width = 2.8
					line.default_color = get_correct_node_color().lightened(0.7)
					if !is_enabled():
						line.default_color = get_off_background_color()

				else:
					line.width = 1.8
					line.default_color = Color.WHITE
				line.points = [connection[0].position, to_local(connection[1].global_position)]



func _on_correctness_unverified():
	self.correct = false


func _on_delete_node_connections_requested(requester, full_reset):
	var group_undoes := []
	if not full_reset:
		for i in requester.connections:
			i.connections.erase(requester)
			group_undoes.append(["disconnect", requester, i, self])
		requester.connections.clear()
	else:
		for i in get_children():
			if i.is_in_group("PuzzleNode"):
				for j in i.connections:
					var connection := ["disconnect", i, j, self]
					var invert_connection := ["disconnect", j, i, self]
					if !group_undoes.has(invert_connection):
						group_undoes.append(connection)
				i.connections.clear()
	player.undo_history.append(group_undoes)
	display_connections()

func _on_connection_changed(from, to, type):
	player.undo_history.append([[type, from, to, self]])
	display_connections()


func check_isomorphism(shape1: Dictionary, shape2: Dictionary):
	if shape1.size() != shape2.size():
		return false
	for i in shape1:
		if not i in shape2:
			return false
		if shape1[i] != shape2[i]:
			return false
	return true


func apply_matrix_transform(vec: Vector2) -> Vector2:
	return transform.basis_xform_inv(vec)


func compare_arrays_by_content(array1: Array, array2: Array) -> bool:
	var test_array_1 :Array = array1.duplicate()

	var identical := true
	var test_array_2 = array2.duplicate()

	if test_array_2.size() != test_array_1.size():
		identical = false

	while not test_array_2.is_empty() and identical == true:
		var match_find := test_array_1.find(test_array_2[test_array_2.size() - 1])

		if match_find == -1:
			identical = false
			break

		test_array_2.pop_back()
		test_array_1.pop_at(match_find)

	return identical


func get_node_color() -> Color:
	if puzzle_theme == null:
		return Color.WHITE
	return puzzle_theme.node_color


func get_correct_node_color() -> Color:
	if puzzle_theme == null:
		return Color( 0.866667, 0.627451, 0.866667)
	return puzzle_theme.correct_node_color


func get_off_background_color() -> Color:
	if puzzle_theme == null:
		return Color("#0c0c0c")
	return puzzle_theme.off_background_color

func get_on_background_color() -> Color:
	if puzzle_theme == null:
		return Color("#131313")
	return puzzle_theme.on_background_color


func save_data():
	var saving :Dictionary = save()
	SaveData.save_handler.vsave_value(["puzzles", id], saving)


