extends Button


func _process(delta: float) -> void:
	visible = !get_parent().visible
