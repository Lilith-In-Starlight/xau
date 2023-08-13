extends Camera2D


var puzzle_zoom_factor := 1.1
var puzzle_zoom_speed := 0.04
var player_camera_speed := 0.1

var state := 0

var target_zoom :Puzzle = null

var existing_dist := 100.0
var existing_cursor_pos = Vector2()
var existing_puzzle_zoom = 1.0

var focus_objects : Array[Marker2D] = []


func _process(_delta: float) -> void:
	$Tutorial.scale = Vector2(1.0/zoom.x, 1.0/zoom.y)
	$NonHoldTutorial.scale = Vector2(1.0/zoom.x, 1.0/zoom.y)
	if target_zoom == null or focus_objects.is_empty() or focus_objects.back().global_position.distance_to($"../Character".position) > 150:
		position = lerp(position, $"../Character".position, player_camera_speed)
		zoom = lerp(zoom, Vector2(1, 1), player_camera_speed)
	elif not focus_objects.is_empty():
		print((focus_objects.is_empty() or focus_objects.back().global_position.distance_to($"../Character".position) > 150))
		if not is_instance_valid(focus_objects.back()):
			focus_objects.pop_back()
			return
		var true_pos :Vector2 = focus_objects.back().global_position
		var zoom_thing :float = (puzzle_zoom_factor - existing_puzzle_zoom + 1)
		var dist = true_pos - $"../Character".position
		position = lerp(position, $"../Character".position + dist * 0.8, puzzle_zoom_speed)
		zoom = lerp(zoom, Vector2(puzzle_zoom_factor, puzzle_zoom_factor), puzzle_zoom_speed)
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
	target_zoom = node
	if target_zoom == null:
		return
	var true_pos :Vector2 = target_zoom.get_rect().get_center() + target_zoom.global_position
	existing_dist = (position - true_pos).length()
	existing_cursor_pos = $"../Cursor".position - position
	existing_puzzle_zoom = zoom.x
