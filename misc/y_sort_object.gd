extends Sprite

onready var player_node: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]

func _process(delta):
	if player_node.position.distance_to(position) < 60:
		if player_node.position.y < position.y and z_index != 1:
			z_index = 1
		elif player_node.position.y > position.y and z_index != 0:
			z_index = 0
