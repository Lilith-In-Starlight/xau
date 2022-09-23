extends StaticBody2D

## A cell that contains the player in it. It is opened once a required
## puzzle is solved
##
## This element is used in the tutorial to direct the player's attention to
## the controls and the puzzles.


func _ready():
	$CollisionPolygon2D.disabled = $"../Tutorial".solved


## Called when the grid that opens this cell is solved
func _on_Tutorial_was_solved() -> void:
	$CollisionPolygon2D.disabled = true
	var tween := create_tween()
	tween.tween_property($JailOn, "modulate:a", 0.0, 0.1)
	tween.play()
