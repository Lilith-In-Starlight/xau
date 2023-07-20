extends Node2D

@onready var player_node: CharacterBody2D = get_tree().get_nodes_in_group("Player")[0]

@onready var depth_line :Line2D = get_node_or_null("DepthLine")
var points :PackedVector2Array = []

func _ready() -> void:
	if depth_line != null:
		points = depth_line.points
	

func _process(delta):
	var y_limit :float = points[0].y
	for index in points.size():
		if index == points.size() - 1:
			y_limit = points[index].y
			break
		var min_x :float = points[index].x
		var max_x :float = points[index+1].x
		
		if not (player_node.global_position.x > min_x and  player_node.global_position.x < max_x):
			continue
		
		var dy :float = points[index+1].y - points[index].y
		var dx :float = max_x - min_x
		var slope :float = dy/dx
		y_limit = (player_node.global_position.x - min_x) * slope + points[index].y
		break
	
	if player_node.global_position.y < y_limit and z_index != 1:
		z_index = 1
	elif player_node.global_position.y > y_limit and z_index != 0:
		z_index = 0
