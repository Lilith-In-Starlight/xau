extends Node2D

## A simple door

## How many puzzles must be solved for this to open. Must be less than or equal
## to the [member Puzzle.was_solved] signals connected to this node
@export var requirements := 1

## The player node
@onready var player_node: CharacterBody2D = get_tree().get_nodes_in_group("Player")[0]


@onready var door_id := str(get_path())

## How many required puzzles have been solved
var met_requirements := 0

var open := false


func _ready():
	if SaveData.save_handler.vget_value(["doors", door_id], false):
		$Sprite2D.position.y = -128.0
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
	if !open:
		SaveData.save_handler.vsave_value(["doors", door_id], true)
		var tween := create_tween()
		tween.tween_property($Sprite2D, "position:y", -128.0, 3.0)
		tween.play()
		tween.connect("finished", Callable(self, "_on_animation_finished"))


## Disables the door's collisions when the animation of the door finishes
func _on_animation_finished() -> void:
	$CollisionShape2D.disabled = true
	open = true

func save():
	return open
