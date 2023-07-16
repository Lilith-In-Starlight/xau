extends Node2D

@export var first_section :NodePath
@onready var first_section_node : Node2D = get_node_or_null(first_section)
@onready var player_node: CharacterBody2D = get_tree().get_nodes_in_group("Player")[0]
func _ready() -> void:
	get_tree().call_group("Puzzle", "update_correctness_visuals")
	get_tree().call_group("Puzzle", "update_enabled_visuals")
	get_tree().call_group("AreaLoaders", "connect", "area_switched", self, "_on_area_switched")
	
	var s :String = SaveData.save_handler.get_value("player_state", "first_room")
	$StatesDefiner.update_state(s, false)
