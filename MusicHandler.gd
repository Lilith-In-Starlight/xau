extends Node

const SONG_LERP := 0.01

func _process(delta: float) -> void:
	if not SaveData.data.has("not_first_enter"):
		SaveData.data["not_first_enter"] = true
		$HomeGuitar.stream = preload("res://music/first_spawn.mp3")
		$HomeGuitar.play()
	
	if get_parent().current_area == "first_nexus":
		$TubularBell.volume_db = lerp($TubularBell.volume_db, -60.0, SONG_LERP)
		if $"../Character".position.x > -500:
			$PamFlute.volume_db = lerp($PamFlute.volume_db, -60.0, SONG_LERP)
			$LittleBell.volume_db = lerp($LittleBell.volume_db, -60.0, SONG_LERP)
		else:
			$PamFlute.volume_db = lerp($PamFlute.volume_db, -10.0, SONG_LERP)
			$LittleBell.volume_db = lerp($LittleBell.volume_db, -5.0, SONG_LERP)
		if $"../Character".position.x > -800:
			$ChoirBass.volume_db = lerp($ChoirBass.volume_db, -60.0, SONG_LERP)
		else:
			$ChoirBass.volume_db = lerp($ChoirBass.volume_db, -10.0, SONG_LERP)
		if get_parent().AreaNode.get_node("StatesDefiner").state == "outside":
			if not SaveData.data.has("not_first_exit"):
				SaveData.data["not_first_exit"] = true
				$WeirdSound.stream = preload("res://music/weird_sound_once.mp3")
				$WeirdSound.play()
				var tween = create_tween()
				tween.set_ease(Tween.EASE_OUT)
				tween.set_trans(Tween.TRANS_QUINT)
				tween.tween_property($"../Camera2D", "zoom", Vector2(1/5.0, 1/5.0), 1.0)
				tween.tween_property($"../Camera2D", "zoom", Vector2(1/5.0, 1/5.0), 2.0)
				tween.set_ease(Tween.EASE_IN_OUT)
				tween.set_trans(Tween.TRANS_QUAD)
				tween.tween_property($"../Camera2D", "zoom", Vector2(1, 1), 6.0)
			else:
				$DroneBass.volume_db = lerp($DroneBass.volume_db, 0.0, SONG_LERP)
		elif get_parent().AreaNode.get_node("StatesDefiner").state == "exit_hall":
			if not SaveData.data.has("not_first_exit"):
				if $"../Character".position.y < 560:
					$DroneBass.volume_db = lerp($DroneBass.volume_db, 0.0, SONG_LERP)
				else:
					$DroneBass.volume_db = lerp($DroneBass.volume_db, ($"../Character".position.y - 560) / 560.0 * 11.0, SONG_LERP)
			else:
				$DroneBass.volume_db = lerp($DroneBass.volume_db, 0.0, SONG_LERP)
		else:
			$DroneBass.volume_db = lerp($DroneBass.volume_db, 0.0, SONG_LERP)
	elif get_parent().current_area == "forest":
		$DroneBass.volume_db = lerp($DroneBass.volume_db, -60.0, SONG_LERP)
		$WeirdSound.volume_db = lerp($WeirdSound.volume_db, -60.0, SONG_LERP)
		$ChoirBass.volume_db = lerp($ChoirBass.volume_db, 0.0, SONG_LERP)
		$PamFlute.volume_db = lerp($PamFlute.volume_db, 0.0, SONG_LERP)
		$TubularBell.volume_db = lerp($TubularBell.volume_db, 0.0, SONG_LERP)
		$LittleBell.volume_db = lerp($LittleBell.volume_db, 0.0, SONG_LERP)
	


func play_tutorial_guitar():
	$HomeGuitar.stream = preload("res://music/house_guitar_once.mp3")
	$HomeGuitar.play()
