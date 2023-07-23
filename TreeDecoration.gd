@tool
extends StaticBody2D

enum COLOR {
	ORANGE,
	BLUE
}

const TREE_SPRITES := {
		COLOR.ORANGE: [
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
			preload("res://sprites/misc/trees/orange/tree_18.png"),
			preload("res://sprites/misc/trees/orange/tree_19.png"),
			preload("res://sprites/misc/trees/orange/tree_20.png"),
			preload("res://sprites/misc/trees/orange/tree_21.png"),
			preload("res://sprites/misc/trees/orange/tree_22.png"),
			preload("res://sprites/misc/trees/orange/tree_23.png"),
			preload("res://sprites/misc/trees/orange/tree_24.png"),
		],
		COLOR.BLUE: [
			preload("res://sprites/misc/trees/blue/tree_1.png"),
			preload("res://sprites/misc/trees/blue/tree_2.png"),
			preload("res://sprites/misc/trees/blue/tree_3.png"),
		],
	}

@export var species: COLOR = COLOR.ORANGE
@export var force_id := -1
@export var flip := false

func _ready() -> void:
	set_style()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		set_style()
	else:
		set_process(false)

func set_style():
	var id_to_use := force_id
	var flip_to_use := flip
	if id_to_use == -1:
		id_to_use = hash(global_position)%TREE_SPRITES[species].size()
		flip_to_use = bool(hash(global_position)%2)
	$Sprite2D.texture = TREE_SPRITES[species][id_to_use]
	$Sprite2D.offset.y = - $Sprite2D.texture.get_height() / 2.0 + 5.0
	$Sprite2D/VisibleOnScreenEnabler2D.rect.position.y = - $Sprite2D.texture.get_height()
	$Sprite2D.flip_h = flip_to_use
	
