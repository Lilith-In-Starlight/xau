extends Area2D

class_name AreaTransition

## Node used to hide and show parts of the world
##
## To make the illusion of looking down on a 3D world, it's necessary to hide
## parts of rooms that would obscure the player from view. This node does that

export(int) var new_z_index: int = 1

onready var PlayerNode: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]


func _ready():
	pass

## Called when the player enters this body
func _on_body_entered(body):
	if body == PlayerNode:
		get_parent().get_parent().update_state(get_parent().name)
