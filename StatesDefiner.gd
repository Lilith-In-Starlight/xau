extends Node

class_name StatesDefiner

static var state :String
var visible_objects :Array
@onready var tween: Tween = null


func _ready():
	var s :String = SaveData.save_handler.get_value("player_state", "first_room")
	update_state(s, false)


func set_visible_objects():
	pass

func update_state(set_to: String, transition := true):
	SaveData.save_handler.save_value("player_state", set_to)
	if set_to == StatesDefiner.state:
		return
	StatesDefiner.state = set_to
	set_visible_objects()
	if not tween == null and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	var tweened := false
	var children := get_tree().get_nodes_in_group("World")[0].get_children()
	for i in get_tree().get_nodes_in_group("SubArea"):
		children.append_array(i.get_children())

	for child in children:
		if not child is Node2D:
			continue
		if child.is_in_group("SubArea"):
			continue
		if child in visible_objects:
			child.visible = true
			if transition:
				tween.tween_property(child, "modulate:a", 1.0, 0.5)
				tweened = true
			else:
				child.modulate.a = 1.0
		else:
			if transition:
				tween.tween_property(child, "modulate:a", 0.0, 0.5)
				tween.tween_property(child, "visible", false, 1.0)
				tweened = true
			else:
				child.modulate.a = 0.0
				child.visible = false


		if not tweened:
			tween.kill()


func _on_area_transitioned(to: String) -> void:
	update_state(to)
