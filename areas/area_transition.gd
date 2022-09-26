extends Area2D

## Node used to hide and show parts of the world
##
## To make the illusion of looking down on a 3D world, it's necessary to hide
## parts of rooms that would obscure the player from view. This node does that

export var BlockingLayer :NodePath
export(float, 0.0, 1.0) var goal :float = 0.0

export var UnblockingLayer :NodePath
export(float, 0.0, 1.0) var anti_goal :float = 0.0

export(int) var new_z_index: int = 1

onready var BlockingNode: Node2D = get_node_or_null(BlockingLayer)
onready var UnblockingNode: Node2D = get_node_or_null(UnblockingLayer)
onready var PlayerNode: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]

onready var parent :Node2D = get_parent()

func _ready():
	if !BlockingNode.visible:
		BlockingNode.modulate.a = 0.0
		BlockingNode.visible = true
	
	if UnblockingNode != null and !UnblockingNode.visible:
		UnblockingNode.modulate.a = 0.0
		UnblockingNode.visible = true

## Called when the player enters this body
func _on_body_entered(body):
	if body == PlayerNode:
		PlayerNode.z_index = parent.z_index
		if BlockingNode.modulate.a != goal:
			var tween = create_tween()
			tween.tween_property(BlockingNode, "modulate:a", goal, 0.5)
			tween.play()
		if UnblockingNode != null and UnblockingNode.modulate.a != anti_goal:
			var tween = create_tween()
			tween.tween_property(UnblockingNode, "modulate:a", anti_goal, 0.5)
			tween.play()
