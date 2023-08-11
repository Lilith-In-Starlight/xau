extends Resource

class_name NodeRule
enum COLORS {
	black,
	blue,
	yellow,
	green,
	purple,
}

@export var color : COLORS = COLORS.black

func _init():
	resource_local_to_scene = true

func check_correctness(_local_node: PuzzleNode) -> bool:
	return true


static func get_default_color(c: COLORS) -> Color:
	var preset :String = SaveData.save_handler.vget_value(["options", "accessibility", "preset"], "default")


	match preset:
		"tritanopia":
			match c:
				NodeRule.COLORS.black:
					return Color(0, 0, 0)
				NodeRule.COLORS.blue:
					return Color("#87FF00")
				NodeRule.COLORS.yellow:
					return Color("FFAA46")
				NodeRule.COLORS.green:
					return Color("#C52525")
				NodeRule.COLORS.purple:
					return Color("#44A059")
				_:
					return Color("#ff00ff")
		"deuteranopia":
			match c:
				NodeRule.COLORS.black:
					return Color(0, 0, 0)
				NodeRule.COLORS.blue:
					return Color("#71b1ff")
				NodeRule.COLORS.yellow:
					return Color("ffaa46")
				NodeRule.COLORS.green:
					return Color("#004D92")
				NodeRule.COLORS.purple:
					return Color("#ff7bb7")
				_:
					return Color("#ff00ff")
		"protanopia":
			match c:
				NodeRule.COLORS.black:
					return Color(0, 0, 0)
				NodeRule.COLORS.blue:
					return Color("#71b1ff")
				NodeRule.COLORS.yellow:
					return Color("ffaa46")
				NodeRule.COLORS.green:
					return Color("#D63636")
				NodeRule.COLORS.purple:
					return Color("#ff7bb7")
				_:
					return Color("#ff00ff")
		_:
			match c:
				NodeRule.COLORS.black:
					return Color(0, 0, 0)
				NodeRule.COLORS.blue:
					return Color("#71b1ff")
				NodeRule.COLORS.yellow:
					return Color("ffaa46")
				NodeRule.COLORS.green:
					return Color("#72c157")
				NodeRule.COLORS.purple:
					return Color("#ff7bb7")
				_:
					return Color("#ff00ff")
