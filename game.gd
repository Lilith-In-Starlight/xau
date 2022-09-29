extends Node2D

## The code that controls every game element in a scene

## The node that represents the cursor
onready var CursorNode: Node2D = $Cursor
onready var PlayerNode: Node2D = $Character

	
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
