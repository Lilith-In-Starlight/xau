extends Sprite

onready var player_node: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]

func _process(delta):
	if player_node.global_position.distance_to(global_position) < 60:
		if player_node.global_position.y < global_position.y and z_index != 2:
			z_index = 2
		elif player_node.global_position.y > global_position.y and z_index != 1:
			z_index = 1
