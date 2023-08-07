extends Marker2D

@onready var camera := get_tree().get_first_node_in_group("Camera3D")


func _on_screen_entered() -> void:
	camera.focus_objects.append(self)


func _on_screen_exited() -> void:
	camera.focus_objects.erase(self)
