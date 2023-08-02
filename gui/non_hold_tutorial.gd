extends Node2D

## A node used to teach the player the basic controls

## Controls what we're teaching the player.
## On stage 1, the player is taught to press space to verify solutions
## On stage 2, they are taught to click to start a connection
## On stage 3, they are taught to right click to stop the connection
## On stage 4, they are taught to press space to verify solutions
## Stage 5 is the end
var stage := 0

@onready var player_node: CharacterBody2D = get_tree().get_nodes_in_group("Player")[0]
@onready var cursor_node = get_tree().get_nodes_in_group("Cursor")[0]
@onready var MusicHandler: Node = get_tree().get_nodes_in_group("MusicHandler")[0]


func _ready():
	if SaveData.save_handler.vget_value(["player", "completed_tutorial"], false):
		visible = false
	$Space.play()
	$Wasd.play()
	$ClickHold.play()
	$RightClick.play()
	$LeftClick.play()


func _input(_event: InputEvent) -> void:
	var hold_mode :bool = SaveData.save_handler.vget_value(["accessibility", "hold"], true)
	if hold_mode or SaveData.save_handler.vget_value(["player", "completed_tutorial"], false):
		visible = false
		stage = 0
		return
	else:
		visible = true
	match stage:
		0:
			if Input.is_action_just_pressed("confirm"):
				var tween := create_tween()
				tween.tween_property($Space, "modulate:a", 0.0, 0.2)
				tween.tween_property($LeftClick, "modulate:a", 1.0, 0.2)
				tween.play()
				stage = 1

			if SaveData.upid.has("tutorial_puzzle") and SaveData.upid["tutorial_puzzle"].check_correct():
				var tween := create_tween()
				tween.tween_property($RightClick, "modulate:a", 1.0, 0.2)
				tween.tween_property($Space, "modulate:a", 0.0, 0.2)
				tween.play()
				stage = 2

		1:
			if SaveData.upid.has("tutorial_puzzle") and SaveData.upid["tutorial_puzzle"].check_correct():
				var tween := create_tween()
				tween.tween_property($RightClick, "modulate:a", 1.0, 0.2)
				tween.tween_property($LeftClick, "modulate:a", 0.0, 0.2)
				tween.play()
				stage = 2

			if SaveData.upid.has("tutorial_puzzle") and SaveData.upid["tutorial_puzzle"].solved:
				MusicHandler.play_tutorial_guitar()
				var tween := create_tween()
				tween.tween_property($RightClick, "modulate:a", 0.0, 0.2)
				tween.tween_property($Wasd, "modulate:a", 1.0, 0.2)
				tween.play()
				stage = 4
		2:
			if Input.is_action_just_pressed("noconnect"):
				var tween := create_tween()
				tween.tween_property($Space, "modulate:a", 1.0, 0.2)
				tween.tween_property($RightClick, "modulate:a", 0.0, 0.2)
				tween.play()
				stage = 3

			if SaveData.upid.has("tutorial_puzzle") and SaveData.upid["tutorial_puzzle"].solved:
				MusicHandler.play_tutorial_guitar()
				var tween := create_tween()
				tween.tween_property($RightClick, "modulate:a", 0.0, 0.2)
				tween.tween_property($Wasd, "modulate:a", 1.0, 0.2)
				tween.play()
				stage = 4

			if SaveData.upid.has("tutorial_puzzle") and not SaveData.upid["tutorial_puzzle"].check_correct():
				var tween := create_tween()
				tween.tween_property($RightClick, "modulate:a", 0.0, 0.2)
				tween.tween_property($LeftClick, "modulate:a", 1.0, 0.2)
				tween.play()
				stage = 1
		3:
			if SaveData.upid.has("tutorial_puzzle") and SaveData.upid["tutorial_puzzle"].solved:
				MusicHandler.play_tutorial_guitar()
				var tween := create_tween()
				tween.tween_property($Space, "modulate:a", 0.0, 0.2)
				tween.tween_property($Wasd, "modulate:a", 1.0, 0.2)
				tween.play()
				stage = 4

			if SaveData.upid.has("tutorial_puzzle") and not SaveData.upid["tutorial_puzzle"].check_correct():
				var tween := create_tween()
				tween.tween_property($Space, "modulate:a", 0.0, 0.2)
				tween.tween_property($LeftClick, "modulate:a", 1.0, 0.2)
				tween.play()
				stage = 1
		4:
			if player_node.global_position.distance_to(Vector2(125, 125)) > 30:
				var tween := create_tween()
				tween.tween_property($Wasd, "modulate:a", 0.0, 0.2)
				tween.play()
				stage = 5
		5:
			var tween := create_tween()
			tween.tween_property(self, "modulate:a", 0.0, 0.2)
			tween.play()
			stage = 5
			SaveData.save_handler.vsave_value(["player", "completed_tutorial"], true)

