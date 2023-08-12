extends Node2D

@export var first_section :NodePath
@onready var first_section_node : Node2D = get_node_or_null(first_section)
@onready var player_node: CharacterBody2D = get_tree().get_nodes_in_group("Player")[0]
@onready var cursor_node: Node2D = get_tree().get_nodes_in_group("Cursor")[0]

var player_in_boundaries := true
var player_in_edges := true

var visible_puzzles := []

func _ready() -> void:
	RenderingServer.viewport_set_update_mode(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_UPDATE_ALWAYS)
	RenderingServer.viewport_set_clear_mode(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_CLEAR_ALWAYS)
	get_tree().call_group("Puzzle", "update_correctness_visuals", false)
	get_tree().call_group("Puzzle", "update_enabled_visuals")
	get_tree().call_group("AreaLoaders", "connect", "area_switched", self, "_on_area_switched")
	get_tree().call_group("MaterialAreas", "connect_to", player_node)


func _process(_delta) -> void:
	if not player_in_boundaries:
		cursor_node.change_blink(true)

		if not player_in_edges:
			get_tree().quit()

		if get_window().has_focus():
			var cursor_goal = -(player_node.position - $"AreaBoundaries/CollisionShape2D".global_position).normalized() * 20 + player_node.position
			var pos_delta = (cursor_node.position - cursor_goal) * 0.5
			get_viewport().warp_mouse(get_viewport().get_mouse_position() - pos_delta)




func _on_area_boundaries_entered(body: Node2D) -> void:
	player_in_boundaries = true


func _on_area_boundaries_exited(body: Node2D) -> void:
	player_in_boundaries = false


func _on_area_edges_entered(body: Node2D) -> void:
	player_in_edges = true


func _on_area_edges_exited(body: Node2D) -> void:
	player_in_edges = false


func add_to_visible_puzzles(puzzle: Puzzle) -> void:
	visible_puzzles.append(puzzle)


func remove_from_visible_puzzles(puzzle: Puzzle) -> void:
	visible_puzzles.erase(puzzle)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("confirm"):
		var all :Array[Puzzle] = []
		for i in visible_puzzles:
			if i.correct or not i.is_enabled():
				continue
			all.append(i)

		for i in all:
			i.verify()
#			if i.correct or not i.is_enabled():
#				continue
#			if closest == null:
#				closest = i
#				continue
#
#			var i_dist_to_cursor :float = i.global_position.distance_to(cursor_node.global_position)
#			var closest_dir_to_cursor :float = closest.global_position.distance_to(cursor_node.global_position)
#			if i_dist_to_cursor < closest_dir_to_cursor:
#				second_closest = closest
#				closest = i
#
#		if closest != null:
#			closest.verify()
#			if second_closest != null and second_closest.global_position.distance_to(cursor_node.global_position) <= closest.global_position.distance_to(cursor_node.global_position) * 5.0:
#				second_closest.verify()
