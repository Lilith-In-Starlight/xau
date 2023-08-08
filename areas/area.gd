extends Node2D

@export var first_section :NodePath
@onready var first_section_node : Node2D = get_node_or_null(first_section)
@onready var player_node: CharacterBody2D = get_tree().get_nodes_in_group("Player")[0]


func _ready() -> void:
	RenderingServer.viewport_set_update_mode(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_UPDATE_ALWAYS)
	RenderingServer.viewport_set_clear_mode(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_CLEAR_ALWAYS)
	get_tree().call_group("Puzzle", "update_correctness_visuals", false)
	get_tree().call_group("Puzzle", "update_enabled_visuals")
	get_tree().call_group("AreaLoaders", "connect", "area_switched", self, "_on_area_switched")
	get_tree().call_group("MaterialAreas", "connect_to", player_node)
