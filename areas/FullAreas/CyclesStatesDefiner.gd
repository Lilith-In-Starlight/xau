extends StatesDefiner

@onready var Player :CharacterBody2D = get_tree().get_first_node_in_group("Player")

func set_visible_objects() -> void:
	AudioServer.set_bus_effect_enabled(1, 0, false)
	Player = get_tree().get_first_node_in_group("Player")
	match StatesDefiner.state:
		"transition_to_first_nexus":
			visible_objects = [
					$"../Transition",
					$"../Outside",
					$"../HouseForestTransitionOutside",
				]
			Player.z_index = $"../Transition".z_index + 1
		"outside":
			visible_objects = [
					$"../Transition",
					$"../HouseForestTransitionOutside",
					$"../Outside",
				]
			Player.z_index = $"../Outside".z_index + 1
