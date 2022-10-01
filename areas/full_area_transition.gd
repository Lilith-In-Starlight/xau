extends Area2D

class_name FullAreaTransition

signal area_switched(destination)

## Node used to unload and load areas

export var destination_name := ""


onready var PlayerNode: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]

onready var parent :Node2D = get_parent()



func _on_body_entered(body: Node) -> void:
	emit_signal("area_switched", destination_name)
