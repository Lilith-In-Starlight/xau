extends Node2D


@export var to_area := ""
@export var destination_state := ""
@export var destination_position := Vector2(0, 0)

@onready var PlayerNode: CharacterBody2D = get_tree().get_nodes_in_group("Player")[0]
@onready var CameraNode: Camera2D = get_tree().get_nodes_in_group("Camera3D")[0]
@onready var GameNode: Node2D = get_tree().get_nodes_in_group("GameNode")[0]

var player_pos := Vector2()
var camera_pos := Vector2()
var on_top_side := false
var previous_side := false


func _ready() -> void:
	player_pos = PlayerNode.position
	camera_pos = CameraNode.position
	on_top_side = player_pos.y < global_position.y
	previous_side = on_top_side


func _process(_delta: float) -> void:
	player_pos = PlayerNode.position
	camera_pos = CameraNode.position
	on_top_side = player_pos.y < global_position.y

	if on_top_side != previous_side and player_pos.x > global_position.y - 100 and player_pos.x < global_position.x + 100:
		CameraNode.position += destination_position - global_position
		PlayerNode.position += destination_position - global_position
		SaveData.save_handler.vsave_value(["player", "position"], PlayerNode.position)
		SaveData.save_handler.save_value("player_state", destination_state)
		GameNode.set_current_area(to_area)

	previous_side = on_top_side

