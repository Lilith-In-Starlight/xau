extends Node2D

export var first_section :NodePath
onready var first_section_node : Node2D = get_node(first_section)
onready var player_node: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]
func _ready() -> void:
	player_node.current_section = first_section_node
	for i in get_children():
		if SaveData.data["sections"].has(str(i.get_path())):
			i.modulate.a = SaveData.data["sections"][str(i.get_path())]
			i.visible = true
	get_tree().call_group("Puzzle", "update_correctness_visuals")
	get_tree().call_group("Puzzle", "update_enabled_visuals")
