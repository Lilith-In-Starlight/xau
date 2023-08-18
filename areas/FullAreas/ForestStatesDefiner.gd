extends StatesDefiner

const default_bg := Color("c14f1b")

@onready var Player :CharacterBody2D = get_tree().get_first_node_in_group("Player")

func set_visible_objects() -> void:
	AudioServer.set_bus_effect_enabled(1, 0, false)
	Player = get_tree().get_first_node_in_group("Player")
	match StatesDefiner.state:
		"transition_to_first_nexus":
			visible_objects = [
					$"../Transition",
					$"../Outside",
					$"../HouseForestTransitionOutside2",
				]
			Player.z_index = $"../Transition".z_index + 1
		"outside":
			$"../CanvasLayer/ColorRect".color =default_bg
			visible_objects = [
					$"../Outside",
					$"../HouseForestTransitionOutside2",
					$"../Transition",
					$"../HouseVillageOutside",
					$"../HouseVillageInside",
					$"../HouseVillageOutside2",
					$"../HouseVillageInside2",
					$"../House/Exterior",
					$"../House/LivingRoom",
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
		"white_house_livingroom":
			$"../CanvasLayer/ColorRect".color = Color.BLACK
			visible_objects = [
					$"../House/LivingRoom",
					$"../House/DoorLivExt",
				]
			Player.z_index = $"../House/LivingRoom".z_index + 1
		"white_house_kitchen":
			visible_objects = [
					$"../House/Kitchen",
					$"../House/DoorKitchLiv",
				]
			$"../CanvasLayer/ColorRect".color = Color.BLACK
			Player.z_index = $"../House/Kitchen".z_index + 1
		"white_house_bedroom":
			visible_objects = [
					$"../House/Bedroom",
					$"../House/DoorBedKitch",
				]
			$"../CanvasLayer/ColorRect".color = Color.BLACK
			Player.z_index = $"../House/Bedroom".z_index + 1
		"white_house_prison":
			visible_objects = [
					$"../House/Prison",
				]
			$"../CanvasLayer/ColorRect".color = Color.BLACK
			Player.z_index = $"../House/Prison".z_index + 1
