extends Node2D

## A node used to teach the player the basic controls

## Controls what we're teaching the player.
## On stage 1, the player is taught to press space to verify solutions
## On stage 2, they are taught how to interact with puzzles
## On stage 3, they are taught how to move
## Stage 4 is the end
var stage := 0

onready var player_node: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]
onready var cursor_node = get_tree().get_nodes_in_group("Cursor")[0]

func _ready():
	if SaveData.upid.has("tutorial_puzzle"):
		if SaveData.upid["tutorial_puzzle"].solved:
			var tween := create_tween()
			tween.tween_property($Space, "modulate:a", 0.0, 0.2)
			tween.play()
			stage = 4


func _input(event):
	match stage:
		0:
			if Input.is_action_just_pressed("confirm"):
				var tween := create_tween()
				tween.tween_property($Space, "modulate:a", 0.0, 0.2)
				tween.tween_property($ClickHold, "modulate:a", 1.0, 0.2)
				tween.play()
				stage = 1
			
			if SaveData.upid.has("tutorial_puzzle"):
				if SaveData.upid["tutorial_puzzle"].check_correct():
					var tween := create_tween()
					tween.tween_property($Space, "modulate:a", 1.0, 0.2)
					tween.play()
					stage = 2
		1:
			if SaveData.upid.has("tutorial_puzzle"):
				if SaveData.upid["tutorial_puzzle"].check_correct():
					var tween := create_tween()
					tween.tween_property($Space, "modulate:a", 1.0, 0.2)
					tween.tween_property($ClickHold, "modulate:a", 0.0, 0.2)
					tween.play()
					stage = 2
		2:
			if SaveData.upid["tutorial_puzzle"].solved:
				var tween := create_tween()
				tween.tween_property($Space, "modulate:a", 0.0, 0.2)
				tween.tween_property($Wasd, "modulate:a", 1.0, 0.2)
				tween.play()
				stage = 3
		3:
			if player_node.global_position.distance_to(Vector2(125, 125)) > 30:
				var tween := create_tween()
				tween.tween_property($Wasd, "modulate:a", 0.0, 0.2)
				tween.play()
				stage = 4
		4:
			var tween := create_tween()
			tween.tween_property(self, "modulate:a", 0.0, 0.2)
			tween.play()
			stage = 5

