extends KinematicBody2D


const TREE_SPRITES := [
	preload("res://sprites/misc/trees/orange/puzzle_1.png"),
	preload("res://sprites/misc/trees/orange/puzzle_2.png"),
	preload("res://sprites/misc/trees/orange/puzzle_3.png"),
	preload("res://sprites/misc/trees/orange/puzzle_4.png"),
	preload("res://sprites/misc/trees/orange/puzzle_5.png"),
	preload("res://sprites/misc/trees/orange/tree_6.png"),
	preload("res://sprites/misc/trees/orange/tree_7.png"),
	preload("res://sprites/misc/trees/orange/tree_8.png"),
	preload("res://sprites/misc/trees/orange/tree_9.png"),
	preload("res://sprites/misc/trees/orange/tree_10.png"),
	preload("res://sprites/misc/trees/orange/tree_11.png"),
	preload("res://sprites/misc/trees/orange/tree_12.png"),
	preload("res://sprites/misc/trees/orange/tree_13.png"),
	preload("res://sprites/misc/trees/orange/tree_14.png"),
	preload("res://sprites/misc/trees/orange/tree_15.png"),
	preload("res://sprites/misc/trees/orange/tree_16.png"),
	preload("res://sprites/misc/trees/orange/tree_17.png"),
]

func _ready() -> void:
	$Sprite.texture = TREE_SPRITES[hash(global_position)%TREE_SPRITES.size()]
	$Sprite.offset.y = - $Sprite.texture.get_height() / 2.0 + 5.0
