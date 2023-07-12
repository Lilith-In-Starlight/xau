extends Node2D

@export var first_section :NodePath
@onready var first_section_node : Node2D = get_node_or_null(first_section)
@onready var player_node: CharacterBody2D = get_tree().get_nodes_in_group("Player")[0]
func _ready() -> void:
	for i in get_children():
		if SaveData.data["sections"].has(str(i.get_path())):
			i.modulate.a = SaveData.data["sections"][str(i.get_path())]
			i.visible = true
	get_tree().call_group("Puzzle", "update_correctness_visuals")
	get_tree().call_group("Puzzle", "update_enabled_visuals")
	get_tree().call_group("AreaLoaders", "connect", "area_switched", self, "_on_area_switched")
	
	if SaveData.data.has("player_state"):
		$StatesDefiner.update_state(SaveData.data["player_state"], false)
	else:
		$StatesDefiner.update_state("first_room", false)
