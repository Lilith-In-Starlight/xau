extends Node

const SONG_LERP := 0.01


class MusicChannel:
	var audio_player: AudioStreamPlayer
	var volume: float = 0.0
	var pitch_shift: float = 0.0
	static var all_music_channels :Array[MusicChannel] = []

	func _init(audio_player: AudioStreamPlayer, volume: float, pitch_shift: float) -> void:
		self.audio_player = audio_player
		self.volume = volume
		self.pitch_shift = pitch_shift
		MusicChannel.all_music_channels.append(self)


	func adjust_volume() -> void:
		audio_player.volume_db = lerp(audio_player.volume_db, volume, SONG_LERP)

@onready var player := %Character
@onready var camera := %Camera2D

@onready var home_guitar := $HomeGuitar
@onready var first_nexus_droning := MusicChannel.new($DroneBass, 0.0, 0.0)
@onready var forest_pam_flute := MusicChannel.new($PamFlute, 0.0, 0.0)
@onready var forest_tubular_bell := MusicChannel.new($TubularBell, 0.0, 0.0)
@onready var forest_little_bell := MusicChannel.new($LittleBell, 0.0, 0.0)
@onready var forest_choir_bass := MusicChannel.new($ChoirBass, 0.0, 0.0)


func _process(_delta: float) -> void:
	if SaveData.save_handler.get_value("first_enter", true):
		SaveData.save_handler.save_value("first_enter", false)
		$HomeGuitar.stream = preload("res://music/first_spawn.mp3")
		$HomeGuitar.play()


	first_nexus_droning.volume = -60
	forest_pam_flute.volume = -60
	forest_little_bell.volume = -60
	forest_choir_bass.volume = -60
	first_nexus_droning.volume = -60.0

	match get_parent().current_area:
		"first_nexus":
			match get_parent().AreaNode.get_node("StatesDefiner").state:
				"outside":
					first_nexus_droning.volume = 0.0
					if SaveData.save_handler.get_value("first_exit", true):
						SaveData.save_handler.save_value("first_exit", false)
						$WeirdSound.stream = preload("res://music/weird_sound_once.mp3")
						$WeirdSound.play()
						var tween = create_tween()
						tween.set_ease(Tween.EASE_OUT)
						tween.set_trans(Tween.TRANS_QUINT)
						tween.tween_property($"../Camera2D", "zoom", Vector2(1/5.0, 1/5.0), 2.0)
						tween.tween_property($"../Camera2D", "zoom", Vector2(1/5.0, 1/5.0), 2.0)
						tween.set_ease(Tween.EASE_IN_OUT)
						tween.set_trans(Tween.TRANS_QUAD)
						tween.tween_property($"../Camera2D", "zoom", Vector2(1, 1), 7.0)

					if player.position.x < -500:
						forest_pam_flute.volume = -10
						forest_little_bell.volume = -5
					if player.position.x < -800:
						forest_choir_bass.volume = -10

				"exit_hall":
					if SaveData.save_handler.get_value("first_exit", true):
						if player.position.y < 560:
							first_nexus_droning.volume = 0.0
						else:
							first_nexus_droning.volume = (player.position.y - 560) / 560.0 * 11.0
				_:
					first_nexus_droning.volume = 0.0
		"forest":
			$WeirdSound.volume_db = -6.0
			forest_choir_bass.volume = 0.0
			forest_pam_flute.volume = 0.0
			forest_tubular_bell.volume = 0.0
			forest_little_bell.volume = 0.0

	for channel in MusicChannel.all_music_channels:
		channel.adjust_volume()

func play_tutorial_guitar():
	$HomeGuitar.stream = preload("res://music/house_guitar_once.mp3")
	$HomeGuitar.play()
