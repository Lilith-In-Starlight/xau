extends StatesDefiner

@onready var Player :CharacterBody2D = get_tree().get_first_node_in_group("Player")

func set_visible_objects() -> void:
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
					$"../Outside",
					$"../HouseForestTransitionOutside2",
					$"../Transition",
					$"../HouseVillageOutside",
					$"../HouseVillageInside",
					$"../HouseVillageOutside2",
					$"../HouseVillageInside2",
				]
			Player.z_index = $"../Outside".z_index + 1
		"in_house_1":
			visible_objects = [
					$"../Outside",
					$"../HouseVillageInside",
					$"../HouseVillageOutside2",
				]
		"in_house_2":
			visible_objects = [
					$"../Outside",
					$"../HouseVillageInside2",
					$"../HouseVillageOutside",
				]
			Player.z_index = $"../Outside".z_index + 1
