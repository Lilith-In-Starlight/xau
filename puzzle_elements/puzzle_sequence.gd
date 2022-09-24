tool
extends Node2D

class_name PuzzleSequence

## A sequence of puzzles where one requires the previous one
##
## All puzzles will be at the same y position

## The distance between puzzlews
export var separation := 8.0

# Called when the node enters the scene tree for the first time.
func _ready():
	var n :Node2D = null
	for i in get_children():
		if n != null:
			i.required_puzzle = i.get_path_to(n)
			n.connect("was_solved", i, "_on_required_was_solved")
		n = i


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var x = 0
	for i in get_children():
		i.position.x = x
		i.position.y = 0
		x += i.row_size * i.spacing + separation
