@tool
extends Node2D

class_name PuzzleSequence

## A sequence of puzzles where one requires the previous one
##
## All puzzles will be at the same y position

## The distance between puzzlews
@export var separation := 8.0
@export var row_size := -1

# Called when the node enters the scene tree for the first time.
func _ready():
	var n :Puzzle = null
	for i in get_children():
		if i is Puzzle:
			if not Engine.is_editor_hint():
					i.was_solved.connect(_on_child_was_solved.bind(i))
			if n != null:
				i.required_puzzle = i.get_path_to(n)
				if not n.is_connected("was_solved", i._on_required_was_solved):
					n.was_solved.connect(i._on_required_was_solved)
			n = i


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		set_process(false)
		return
	var x := 0.0
	var y := 0.0
	var column := 0
	var puzzle_id := 0
	var previous: Puzzle = null
	
	for i in get_children():
		if i is Cable:
			if previous == null:
				continue
			i.required_puzzle = previous
		if i is PuzzleGrid:
			if previous != null:
				i.required_puzzle = i.get_path_to(previous)
			previous = i
			puzzle_id += 1
			var new_name :StringName = &"PuzzleGrid%s" % str(puzzle_id)
			if puzzle_id == 1:
				new_name = &"PuzzleGrid"
			if i.name != new_name:
				i.set_name.call_deferred(new_name)
				
			if row_size <= -1:
				continue
				
			i.position.x = x
			i.position.y = y
			column += 1
			x += i.rect.size.x - i.rect.position.x + 16 + separation
			if column > row_size:
				column = 0.0
				x = 0.0
				y += i.rect.size.y + separation - i.rect.position.y + 16


func _on_child_was_solved(child: Puzzle):
	if get_child_count() > child.get_index() + 1:
		get_tree().call_group("Camera3D", "set_target_zoom", get_child(child.get_index() + 1))
	else:
		get_tree().call_group("Camera3D", "set_target_zoom", null)
