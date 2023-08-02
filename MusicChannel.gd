extends RefCounted

class_name MusicChannel

const SONG_LERP := 0.01

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
