extends Node2D

## The code that controls every game element in a scene

## The node that represents the cursor
onready var CursorNode: Node2D = get_tree().get_nodes_in_group("Cursor")[0]


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	for i in $World.get_children():
		if SaveData.data.has(str(i.get_path())):
			i.modulate.a = SaveData.data[str(i.get_path())]
			i.visible = true
	get_tree().call_group("Puzzle", "update_correctness_visuals")
	get_tree().call_group("Puzzle", "update_enabled_visuals")

