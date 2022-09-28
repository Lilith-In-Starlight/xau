extends Node2D

## A simple door

## How many puzzles must be solved for this to open. Must be less than or equal
## to the [member Puzzle.was_solved] signals connected to this node
export var requirements := 1

## The player node
onready var player_node: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]

## How many required puzzles have been solved
var met_requirements := 0

var open := false


func _ready():
	if SaveData.has_data("doors|%s"%str(get_path())):
		$Sprite.position.y = -108.0
		$CollisionShape2D.disabled = true
		open = true


func _process(delta):
	if player_node.global_position.distance_to(global_position) < 100:
		if player_node.global_position.y < global_position.y and z_index != 1:
			z_index = 1
		elif player_node.global_position.y > global_position.y and z_index != 0:
			z_index = 0

## Must be called by [member Puzzle.was_solved]. Increases met_requirements by 1.
func _on_required_was_solved():
	var tween := create_tween()
	tween.tween_property($Sprite, "position:y", -108.0, 3.0)
	tween.play()
	tween.connect("finished", self, "_on_animation_finished")


## Disables the door's collisions when the animation of the door finishes
func _on_animation_finished() -> void:
	$CollisionShape2D.disabled = true
	open = true

func save():
	return open
