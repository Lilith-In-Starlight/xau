extends Button


func _process(_delta: float) -> void:
	visible = !get_parent().visible
