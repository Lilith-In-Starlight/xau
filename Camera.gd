extends Camera2D


var puzzle_zoom_factor := 1.25
var puzzle_zoom_speed := 0.04
var player_camera_speed := 0.1

var state := 0

var target_zoom :Puzzle = null

@onready var tween := get_tree().create_tween()
var existing_dist := 100.0
var existing_cursor_pos = Vector2()
var existing_puzzle_zoom = 1.0


func _process(delta: float) -> void:
	if target_zoom == null:
		position = lerp(position, $"../Character".position, player_camera_speed)
		zoom = lerp(zoom, Vector2(1, 1), player_camera_speed)
	else:
		if not is_instance_valid(target_zoom):
			set_target_zoom(null)
			return
		var true_pos :Vector2 = target_zoom.get_rect().get_center() + target_zoom.global_position
		var zoom_thing :float = (puzzle_zoom_factor - existing_puzzle_zoom + 1)
		var dist :Vector2 = (existing_cursor_pos * zoom_thing - existing_cursor_pos) / zoom_thing
		var tdist :Vector2 = position - true_pos
		position = lerp(position, $"../Character".position + dist, puzzle_zoom_speed)
		zoom = lerp(zoom, Vector2(puzzle_zoom_factor, puzzle_zoom_factor), puzzle_zoom_speed)
		if tdist.length() < existing_dist:
			existing_dist = tdist.length()
		if tdist.length() > existing_dist + 20:
			set_target_zoom(null)


func set_target_zoom(node: Puzzle):
	if node == target_zoom:
		return
	tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	target_zoom = node
	if target_zoom == null:
		return
	var true_pos :Vector2 = target_zoom.get_rect().get_center() + target_zoom.global_position
	existing_dist = (position - true_pos).length()
	existing_cursor_pos = $"../Cursor".position - position
	existing_puzzle_zoom = zoom.x
