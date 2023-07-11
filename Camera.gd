extends Camera2D


var state := 0


func _process(delta: float) -> void:
	position = lerp(position, $"../Character".position, 0.3)
