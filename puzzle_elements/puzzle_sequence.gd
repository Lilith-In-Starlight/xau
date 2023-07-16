@tool
extends Node2D

class_name PuzzleSequence

## A sequence of puzzles where one requires the previous one
##
## All puzzles will be at the same y position

## The distance between puzzlews
@export var separation := 8.0

# Called when the node enters the scene tree for the first time.
func _ready():
	var n :Node2D = null
	for i in get_children():
		if not Engine.is_editor_hint():
			if i is Puzzle:
				i.was_solved.connect(_on_child_was_solved.bind(i))
		if n != null:
			i.required_puzzle = i.get_path_to(n)
			if not n.is_connected("was_solved", i._on_required_was_solved):
				n.was_solved.connect(i._on_required_was_solved)
		n = i


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not Engine.is_editor_hint():
		return
	
	var x = 0
	for i in get_children():
		i.position.x = x
		i.position.y = 0
		if i is PuzzleGrid:
			if i.node_arrangement is NodeArrangementGrid:
				x += i.node_arrangement.size.x * i.node_arrangement.spacing.x + separation


func _on_child_was_solved(child: Puzzle):
	if get_child_count() > child.get_index() + 1:
		get_tree().call_group("Camera3D", "set_target_zoom", get_child(child.get_index() + 1))
	else:
		get_tree().call_group("Camera3D", "set_target_zoom", null)
