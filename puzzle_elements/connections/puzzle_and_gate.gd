extends Node2D

signal was_solved

@export var inputs = [] # (Array, NodePath)

var solved_things := 0
var solved := false

func _ready():
	for i in inputs:
		var node = get_node_or_null(i)
		if node != null and node is Puzzle:
			node.was_solved.connect(_on_required_was_solved)
			node.connect("was_solved", Callable(self, "_on_required_was_solved"))


func _on_required_was_solved():
	solved_things += 1
	if solved_things == inputs.size():
		was_solved.emit()
		solved = true
