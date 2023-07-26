extends StatesDefiner

@onready var Player :CharacterBody2D = get_tree().get_nodes_in_group("Player")[0]

func set_visible_objects() -> void:
	Player = get_tree().get_nodes_in_group("Player")[0]
	match StatesDefiner.state:
		"first_room":
			AudioServer.set_bus_effect_enabled(1, 0, true)
			visible_objects = [$"../House"]
			Player.z_index = $"../House".z_index + 1
		"bedroom":
			AudioServer.set_bus_effect_enabled(1, 0, true)
			visible_objects = [$"../HouseRoom2", $"../HouseRoom3"]
			Player.z_index = $"../HouseRoom3".z_index + 1
		"kitchen":
			AudioServer.set_bus_effect_enabled(1, 0, true)
			visible_objects = [$"../HouseRoom2"]
			Player.z_index = $"../HouseRoom2".z_index + 1
		"living_room":
			AudioServer.set_bus_effect_enabled(1, 0, true)
			visible_objects = [$"../HouseRoom4"]
			Player.z_index = $"../HouseRoom4".z_index + 1
		"exit_hall":
			AudioServer.set_bus_effect_enabled(1, 0, true)
			visible_objects = [$"../HouseRoom4", $"../HouseExit"]
			Player.z_index = $"../HouseExit".z_index + 1
		"outside":
			AudioServer.set_bus_effect_enabled(1, 0, false)
			visible_objects = [$"../HouseOutside", $"../Transition"]
			Player.z_index = $"../HouseOutside".z_index + 1
		"transition_to_forest":
			AudioServer.set_bus_effect_enabled(1, 0, false)
			visible_objects = [$"../Transition"]
			Player.z_index = $"../Transition".z_index + 1
