tool
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


## A Puzzle that is required to solve this one
export var required_puzzle: NodePath setget set_required_puzzle

var required_node: Node2D

## The color of this puzzle's screen while the puzzle is enabled
export var background_color: Color = Color("#131313")
## The color of this puzzle's screen while the puzzle is disabled
export var off_background_color: Color = Color("#0c0c0c")
## The color of this puzzle's correct nodes
export var correct_node_color: Color = Color( 0.866667, 0.627451, 0.866667)
## The color of this puzzle's regular nodes
export var node_color: Color = Color("#ffffff")

## Whether the puzzle can connect to other puzzles
export var framed := true

## Unique identifier used to connect puzzles across scenes
export var puzzle_id := "default"

onready var cursor_node :Cursor = get_tree().get_nodes_in_group("Cursor")[0]

## Whether the puzzle was solved or not
var solved := false

## The square area that contains all the nodes in the puzzle
var rect := Rect2()

## Whether the puzzle is currently verified as correct
var correct := false setget set_correct

var base_display_connections := true

onready var player :KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]

var is_visible := false

func _draw():
	get_rect()
	var new_rect = rect.grow(8)
	var color := off_background_color
	if is_enabled():
		color = background_color
	draw_rect(new_rect, color, true)
	draw_rect(rect.grow(8), color, true)


func _ready():
	required_node = get_node_or_null(required_puzzle)
	if not Engine.is_editor_hint():
		for i in get_children():
			if i.is_in_group("PuzzleNode"):
				i.connect("connection_changed", self, "_on_connection_changed")
				i.connect("correctness_unverified", self, "_on_correctness_unverified")
				i.connect("delete_node_connections_request", self, "_on_delete_node_connections_requested")
	
	var id = str(get_path())
	if SaveData.has_data("puzzles|%s" % id):
		var puzzle_data = SaveData.get_data("puzzles|%s" % id)
		solved = puzzle_data["solved"]
		correct = puzzle_data["correct"]
		if solved or correct: emit_signal("was_solved")
		for i in get_child_count():
			var child = get_child(i)
			if puzzle_data["connections"].has(str(i)):
				for j in puzzle_data["connections"][str(i)]:
					if j is String:
						child.connections.append(get_node(j))
					else:
						child.connections.append(get_child(j))
	
	if not required_node == null:
		required_node.connect("was_solved", self, "_on_required_was_solved")
	if Engine.editor_hint:
		connect("child_entered_tree", self, "_on_child_entered_tree")
		connect("child_exiting_tree", self, "_on_child_exiting_tree")
	if puzzle_id != "default":
		SaveData.upid[puzzle_id] = self
	if base_display_connections:
		display_connections()


func _input(delta):
	if is_visible:
		if Input.is_action_just_pressed("connect") and is_enabled():
			display_connections()
		if Input.is_action_just_pressed("confirm") and cursor_node.global_position.distance_to(global_position) < 200:
			if is_enabled():
				var unhappy_nodes := []
				var hardcoded := []
				var hardcode_fail := false
				var failed := false
				for i in get_children():
					if i.is_in_group("PuzzleNode"):
						if i.node_rule == i.TYPES.HARDCODE:
							hardcoded.append(i)
						if !i.check():
							failed = true
							if i.node_rule == i.TYPES.HARDCODE:
								hardcode_fail = true
							else:
								i.show_failure(node_color)
							unhappy_nodes.append(i)
				if hardcode_fail:
					for i in hardcoded:
						i.show_failure(node_color)
				if failed:
					var failed_sound := preload("res://sfx/ephemeral_sound.tscn").instance()
					failed_sound.stream = preload("res://sfx/xau_puzzle_fail.wav")
					failed_sound.attenuation = 40
					add_child(failed_sound)
				if unhappy_nodes.empty():
					if not correct:
						correct = true
						var solved_sound := preload("res://sfx/ephemeral_sound.tscn").instance()
						solved_sound.stream = preload("res://sfx/xau_puzzle_solve.wav")
						solved_sound.pitch_scale = 0.8 + randf()*0.2
						add_child(solved_sound)
					if not solved:
						solved = true
						emit_signal("was_solved")
					show_correct()

func set_correct(value):
	correct = value
	update_correctness_visuals()

func set_required_puzzle(value):
	required_puzzle = value
	required_node = get_node_or_null(value)
	update_enabled_visuals()

func check_correct():
	var unhappy_nodes := []
	for i in get_children():
		if i.is_in_group("PuzzleNode"):
			if !i.check():
				unhappy_nodes.append(i)
	return unhappy_nodes.empty()

## Makes the puzzle look green to indicate that it is correct
func show_correct():
	for i in get_children():
		if not i.name == "NoNode":
			var tween = i.create_tween()
			if i.is_in_group("PuzzleNode"):
				tween.tween_property(i.circle, "modulate", correct_node_color, 0.2)
			else:
				tween.tween_property(i, "modulate", correct_node_color, 0.2)
			tween.play()

## Makes the puzzle look white to show that it is not correct
func unshow_correct():
	for i in get_children():
		if not i.name == "NoNode":
			var tween = i.create_tween()
			if i.is_in_group("PuzzleNode"):
				tween.tween_property(i.circle, "modulate", node_color, 0.2)
			else:
				tween.tween_property(i, "modulate", node_color, 0.2)
			tween.play()

## Called when the puzzle required to interact with this one is solved
func _on_required_was_solved():
	update_enabled_visuals()


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
		if queue_redraw: update()

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
	update()

func _on_child_entered_tree(gone_node: Node):
	update()

func _on_child_exiting_tree(gone_node: Node):
	update()


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
	for i in get_children():
		var c_con = []
		if i.is_in_group("PuzzleNode"):
			for j in i.connections:
				if j.parent == self:
					c_con.append(j.get_index())
				else:
					c_con.append(str(j.get_path()))
		if not c_con.empty():
			conn[str(i.get_index())] = c_con
	if not conn.empty():
		dict["connections"] = conn
		dict["solved"] = solved
		dict["correct"] = correct
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
				new_line.default_color = ColorN("white")
				new_line.width = 2.0
				connection_display.add_child(new_line)
		elif known_connections.size() < connection_display.get_child_count():
			for i in abs(connection_display.get_child_count() - known_connections.size()):
				connection_display.remove_child(connection_display.get_child(0))
		
		for i in known_connections.size():
			var connection: Array = known_connections[i]
			var line: Line2D = connection_display.get_child(i)
			line.points = [connection[0].position, connection[1].global_position - global_position]


func _on_correctness_unverified():
	self.correct = false


func _on_delete_node_connections_requested(requester, full_reset):
	var group_undoes := []
	if not full_reset:
		for i in requester.connections:
			i.connections.erase(requester)
			group_undoes.append(["disconnect", requester, i, self])
		requester.connections = []
	else:
		for i in get_children():
			if i.is_in_group("PuzzleNode"):
				for j in i.connections:
					var connection := ["disconnect", i, j, self]
					var invert_connection := ["disconnect", j, i, self]
					if !group_undoes.has(invert_connection):
						group_undoes.append(connection)
				i.connections = []
	player.undo_history.append(group_undoes)
	display_connections()

func _on_connection_changed(from, to, type):
	player.undo_history.append([[type, from, to, self]])
	display_connections()
