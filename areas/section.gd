extends Node2D


func _ready() -> void:
	get_tree().call_group("SectionTransition", "connect", "player_exited_section", self, "_on_player_exited_section")
	get_tree().call_group("Puzzle", "update_correctness_visuals")
	get_tree().call_group("Puzzle", "update_enabled_visuals")


func _on_player_exited_section(emitter: Node2D, new_scene: String, new_section_entrance: int):
	var instance :Node2D = load(new_scene).instantiate()
	get_parent().call_deferred("add_child", instance)
	queue_free()
