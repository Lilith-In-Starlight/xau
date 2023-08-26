extends Node


@onready var player := %Character
@onready var camera := %Camera2D

@onready var home_guitar := $HomeGuitar
@onready var first_nexus_droning := MusicChannel.new($DroneBass, 0.0, 0.0)
@onready var forest_pam_flute := MusicChannel.new($PamFlute, 0.0, 0.0)
@onready var forest_tubular_bell := MusicChannel.new($TubularBell, 0.0, 0.0)
@onready var forest_little_bell := MusicChannel.new($LittleBell, 0.0, 0.0)
@onready var forest_choir_bass := MusicChannel.new($ChoirBass, 0.0, 0.0)

@onready var pause_music := MusicChannel.new($PauseMenuMusic, 0.0, 0.0)


func _process(_delta: float) -> void:
	if SaveData.save_handler.get_value("first_enter", true):
		SaveData.save_handler.save_value("first_enter", false)
		$HomeGuitar.stream = preload("res://music/first_spawn.mp3")
		$HomeGuitar.play()


	for channel in MusicChannel.all_music_channels:
		channel.volume = -60.0

	manage_single_events()
	if not get_tree().paused:
		AudioServer.get_bus_effect(3, 1).pitch_scale = lerp(AudioServer.get_bus_effect(3, 1).pitch_scale, 1.3, 0.1)
		match get_parent().current_area:
			"first_nexus":
				match StatesDefiner.state:
					"outside":
						first_nexus_droning.volume = 0.0
						if player.position.x < -500:
							forest_pam_flute.volume = -10
							forest_little_bell.volume = -5
						if player.position.x < -800:
							forest_choir_bass.volume = -10
					"transition_to_forest":
						first_nexus_droning.volume = 0.0
						forest_choir_bass.volume = -10
						forest_pam_flute.volume = -10
						forest_tubular_bell.volume = -10
						forest_little_bell.volume = -5
					"exit_hall":
						var player_has_not_exited_house :bool = SaveData.save_handler.get_value("first_exit", true)
						if player_has_not_exited_house:
							first_nexus_droning.volume = fit_in_range(player.position.y, 538.0, 1244.0, 0.0, 12.0)
						else:
							first_nexus_droning.volume = 0.0
					_:
						first_nexus_droning.volume = 0.0
			"forest":
				$WeirdSound.volume_db = -60.0
				match StatesDefiner.state:
					"white_house_livingroom":
						first_nexus_droning.volume = -10.0
						forest_choir_bass.volume = -10.0
						forest_pam_flute.volume = 0.0
						forest_tubular_bell.volume = 0.0
						forest_little_bell.volume = 0.0
					"white_house_kitchen":
						first_nexus_droning.volume = 0.0
						forest_choir_bass.volume = -15.0
						forest_pam_flute.volume = -20.0
						forest_tubular_bell.volume = -10.0
						forest_little_bell.volume = -10.0
					"white_house_bedroom":
						first_nexus_droning.volume = -60.0
						forest_choir_bass.volume = -15.0
						forest_pam_flute.volume = -20.0
						forest_tubular_bell.volume = -10.0
						forest_little_bell.volume = -10.0
					"white_house_prison":
						first_nexus_droning.volume = 5.0
					_:
						forest_choir_bass.volume = 0.0
						forest_pam_flute.volume = 0.0
						forest_tubular_bell.volume = 0.0
						forest_little_bell.volume = 0.0
	else:
		pause_music.volume = -15.0
		AudioServer.get_bus_effect(3, 1).pitch_scale = lerp(AudioServer.get_bus_effect(3, 1).pitch_scale, 1.0, 0.2)

	AudioServer.get_bus_effect(3, 0).pan = sin(Time.get_ticks_msec() / 6120.0) * 0.5
	for channel in MusicChannel.all_music_channels:
		channel.adjust_volume()


func play_tutorial_guitar():
	$HomeGuitar.stream = preload("res://music/house_guitar_once.mp3")
	$HomeGuitar.play()


func manage_single_events():
	var player_has_not_left_house :bool = SaveData.save_handler.get_value("first_exit", true)
	if get_parent().current_area == "first_nexus" and StatesDefiner.state == "outside" and player_has_not_left_house:
		SaveData.save_handler.save_value("first_exit", false)
		$WeirdSound.stream = preload("res://music/weird_sound_once.mp3")
		$WeirdSound.play()
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_QUAD)
		tween.tween_property($"../Camera2D", "zoom", Vector2(1/5.0, 1/5.0), 1.0)
		tween.tween_property($"../Camera2D", "zoom", Vector2(1/5.0, 1/5.0), 3.0)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_QUAD)
		tween.tween_property($"../Camera2D", "zoom", Vector2(1, 1), 7.0)


func fit_in_range(input: float, min_input: float, max_input: float, min_output: float, max_output: float) -> float:
	if input < min_input:
		return min_output
	elif input > max_input:
		return max_output
	else:
		var output_range := max_output - min_output
		var input_range := min_input - max_input

		var input_in_range := (input - min_input)
		var fraction_of_input_in_range :float = abs(input_in_range / input_range)
		return fraction_of_input_in_range * output_range + min_output


func _on_pause_menu_music_finished() -> void:
	var all_pause_musics := [
		preload("res://music/understandable/xau_menu1.wav"),
		preload("res://music/understandable/xau_menu2.wav"),
		preload("res://music/understandable/xau_menu3.wav"),
		preload("res://music/understandable/xau_menu4.wav"),
		preload("res://music/understandable/xau_menu5.wav"),
	]
	$PauseMenuMusic.stream = all_pause_musics.pick_random()
	$PauseMenuMusic.play()
