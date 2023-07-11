extends StatesDefiner

onready var Player :KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]

func set_visible_objects() -> void:
	Player = get_tree().get_nodes_in_group("Player")[0]
	match state:
		"transition_to_first_nexus":
			visible_objects = [
					$"../Transition",
					$"../Outside",
				]
			Player.z_index = $"../Transition".z_index + 1
		"outside":
			visible_objects = [
					$"../Outside",
					$"../HouseForestTransitionOutside2",
					$"../Transition",
					$"../HouseVillageOutside",
					$"../HouseVillageInside",
				]
			Player.z_index = $"../Outside".z_index + 1
		"in_house_1":
			visible_objects = [
					$"../Outside",
					$"../HouseVillageInside",
				]
			Player.z_index = $"../Outside".z_index + 1
