@tool
extends StaticBody2D


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
	$Sprite2D.texture = TREE_SPRITES[hash(global_position)%TREE_SPRITES.size()]
	$Sprite2D.offset.y = - $Sprite2D.texture.get_height() / 2.0 + 5.0
	$Sprite2D/VisibleOnScreenEnabler2D.rect.position.y = - $Sprite2D.texture.get_height()
	$Sprite2D.flip_h = bool(hash(global_position)%2)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		$Sprite2D.texture = TREE_SPRITES[hash(global_position)%TREE_SPRITES.size()]
		$Sprite2D.offset.y = - $Sprite2D.texture.get_height() / 2.0 + 5.0
		$Sprite2D/VisibleOnScreenEnabler2D.rect.position.y = - $Sprite2D.texture.get_height()
