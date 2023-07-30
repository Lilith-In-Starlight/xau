@tool
extends Sprite2D

enum COLORS {
	BLUE,
}

const TEXTURES := {
	COLORS.BLUE : [
		preload("res://sprites/misc/floor_elements/blue_section/grass1.png"),
		preload("res://sprites/misc/floor_elements/blue_section/grass2.png"),
		preload("res://sprites/misc/floor_elements/blue_section/grass3.png"),
		preload("res://sprites/misc/floor_elements/blue_section/grass4.png"),
	]
}

@export var color :COLORS = COLORS.BLUE


func _ready() -> void:
	texture = TEXTURES[color][hash(global_position) % TEXTURES[color].size()]
	if not Engine.is_editor_hint():
		set_process(false)


func _process(delta: float) -> void:
	texture = TEXTURES[color][hash(global_position) % TEXTURES[color].size()]
