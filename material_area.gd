extends Area2D


# Called when the node enters the scene tree for the first time.
func connect_to(node: Node):
	if body_entered.is_connected(node._on_material_entered.bind(name)):
		return
	body_entered.connect(node._on_material_entered.bind(name))
	body_exited.connect(node._on_material_exited.bind(name))
