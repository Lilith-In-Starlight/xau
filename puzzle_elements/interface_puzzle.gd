extends Node2D


@onready var player_node :CharacterBody2D = get_tree().get_nodes_in_group("Player")[0]

var children_modulate := 0

func _ready():
	for i in get_children():
		i.modulate.a = 0.0


func _process(delta: float) -> void:
	if player_node.global_position.distance_to(global_position) < 30 and children_modulate == 0:
		var tween := create_tween()
		for i in get_children():
			tween.tween_property(i, "modulate:a", 2.0, 0.2)
		children_modulate = 1
		tween.play()
	elif children_modulate == 1:
		var tween := create_tween()
		for i in get_children():
			tween.tween_property(i, "modulate:a", 0.0, 0.2)
		children_modulate = 0
		tween.play()

