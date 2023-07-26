extends Node

class_name StatesDefiner

static var state :String
var visible_objects :Array
@onready var tween: Tween = null

func set_visible_objects():
	pass

func update_state(set_to: String, transition := true):
	SaveData.save_handler.save_value("player_state", set_to)
	if set_to == StatesDefiner.state:
		return
	StatesDefiner.state = set_to
	set_visible_objects()
	if not tween == null:
		tween.stop()
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	var tweened := false
	for child in get_tree().get_nodes_in_group("World")[0].get_children():
		if not child is Node2D:
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

