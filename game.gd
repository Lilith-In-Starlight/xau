extends Node2D

## The code that controls every game element in a scene

## The node that represents the cursor
onready var CursorNode: Node2D = get_tree().get_nodes_in_group("Cursor")[0]


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

