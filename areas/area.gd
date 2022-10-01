extends Node2D

export var first_section :NodePath
onready var first_section_node : Node2D = get_node_or_null(first_section)
onready var player_node: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]
func _ready() -> void:
	for i in get_children():
		if SaveData.data["sections"].has(str(i.get_path())):
			i.modulate.a = SaveData.data["sections"][str(i.get_path())]
			i.visible = true
	get_tree().call_group("Puzzle", "update_correctness_visuals")
	get_tree().call_group("Puzzle", "update_enabled_visuals")
	get_tree().call_group("AreaLoaders", "connect", "area_switched", self, "_on_area_switched")


func _on_area_switched(next_area, transport_position):
	var new_area = SectionLoading.sections[next_area].instance()
	match next_area:
		"forest":
			get_parent().call_deferred("add_child", new_area)
			queue_free()
			player_node.global_position -= transport_position
		"house":
			get_parent().call_deferred("add_child", new_area)
			queue_free()
			player_node.global_position -= transport_position
			player_node.global_position += Vector2(-1543, 930)
	player_node.align_camera()
