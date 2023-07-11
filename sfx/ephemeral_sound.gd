extends AudioStreamPlayer2D


func _ready() -> void:
	play()
	var timer := Timer.new()
	timer.wait_time = stream.get_length()
	add_child(timer)
	timer.start()
	timer.timeout.connect(_on_finished)


func _on_finished() -> void:
	queue_free()
