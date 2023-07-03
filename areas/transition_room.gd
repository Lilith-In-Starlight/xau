extends Node2D


export var to_area := ""
export var destination_state := ""

onready var PlayerNode: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]
onready var GameNode: Node2D = get_tree().get_nodes_in_group("GameNode")[0]

var player_pos := Vector2()
var on_left_side := false
var previous_side := false


func _ready() -> void:
	player_pos = PlayerNode.position
	on_left_side = player_pos.x < global_position.x
	previous_side = on_left_side


func _process(delta: float) -> void:
	player_pos = PlayerNode.position
	on_left_side = player_pos.x < global_position.x
	if on_left_side != previous_side and player_pos.y > global_position.y-50 and player_pos.y < global_position.y + 50:
		SaveData.data["player_state"] = destination_state
		SaveData.save()
		GameNode.set_current_area(to_area)
	
	previous_side = on_left_side
