extends Node2D

signal was_solved

export(Array, NodePath) var inputs = []

var solved_things := 0
var solved := false

func _ready():
	for i in inputs:
		var node = get_node_or_null(i)
		if node != null and node is Puzzle:
			node.connect("was_solved", self, "_on_required_was_solved")


func _on_required_was_solved():
	solved_things += 1
	if solved_things == inputs.size():
		emit_signal("was_solved")
		solved = true
