extends Node2D

## The code that controls every game element in a scene

## The node that represents the cursor
@onready var CursorNode = get_tree().get_first_node_in_group("Cursor")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	for i in $World.get_children():
		if SaveData.data.has(str(i.get_path())):
			i.modulate.a = SaveData.data[str(i.get_path())]

