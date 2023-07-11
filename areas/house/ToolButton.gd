extends ToolButton


func _process(delta: float) -> void:
	visible = !get_parent().visible
