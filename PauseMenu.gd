extends Control

signal color_settings_changed

const PROFILE_PANEL = preload("res://gui/profile_panel.tscn")

@onready var BlueColorButton := $Background/ColorSelect/ColorButtons/BlueButton
@onready var YellowColorButton := $Background/ColorSelect/ColorButtons/YellowButton
@onready var GreenColorButton := $Background/ColorSelect/ColorButtons/GreenButton
@onready var PurpleColorButton := $Background/ColorSelect/ColorButtons/PurpleButton

@onready var BlueColorButtonIcon := $Background/ColorSelect/ColorButtons/BlueButton/Icon
@onready var YellowColorButtonIcon := $Background/ColorSelect/ColorButtons/YellowButton/Icon
@onready var GreenColorButtonIcon := $Background/ColorSelect/ColorButtons/GreenButton/Icon
@onready var PurpleColorButtonIcon := $Background/ColorSelect/ColorButtons/PurpleButton/Icon

@onready var BlueColorButtonBG := $Background/ColorSelect/ColorButtons/BlueButton/NodeBG
@onready var YellowColorButtonBG := $Background/ColorSelect/ColorButtons/YellowButton/NodeBG
@onready var GreenColorButtonBG := $Background/ColorSelect/ColorButtons/GreenButton/NodeBG
@onready var PurpleColorButtonBG := $Background/ColorSelect/ColorButtons/PurpleButton/NodeBG

@onready var ColorPickerNode := $Background/ColorSelectPicker/PickerContainer/ColorPicker

@onready var ColorButtons := $Background/ColorSelect/ColorButtons

@onready var PauseMenu := $Background/Paused
@onready var ProfilesMenu := $Background/Profiles
@onready var OptionsMenu := $Background/Options
@onready var CreditsMenu := $Background/Credits
@onready var ColorSelectMenu := $Background/ColorSelect
@onready var ColorSelectPicker := $Background/ColorSelectPicker
@onready var ProfileList := $Background/Profiles/ProfilesScroll/ProfileUI/ProfileList

var editing_color :int = -1

var handling_profile := -1
var previous_state := &"pause"

func _ready():
	$Background/AudioSettings/Buttons/MasterVolume/Slider.value = SaveData.save_handler.vget_value(["options", "mastervol"], 1.0)
	$Background/AudioSettings/Buttons/SFXVolume/Slider.value = SaveData.save_handler.vget_value(["options", "sfxvol"], 1.0)
	$Background/AudioSettings/Buttons/MusicVolume/Slider.value = SaveData.save_handler.vget_value(["options", "musicvol"], 0.8)
	var tween := create_tween()
	tween.tween_property($"../Panel", "modulate:a", 0.0, 0.2)
	tween.tween_property($"../Panel", "visible", false, 0.0)
	BlueColorButton.pressed.connect(open_color_picker.bind(NodeRule.COLORS.blue))
	YellowColorButton.pressed.connect(open_color_picker.bind(NodeRule.COLORS.yellow))
	GreenColorButton.pressed.connect(open_color_picker.bind(NodeRule.COLORS.green))
	PurpleColorButton.pressed.connect(open_color_picker.bind(NodeRule.COLORS.purple))
	set_gui_state(&"pause")

	if not DirAccess.dir_exists_absolute("user://profiles"):
		DirAccess.make_dir_absolute("user://profiles")

	var profiles := DirAccess.get_directories_at("user://profiles")

	if not profiles.is_empty():
		for path in profiles:
			var last := path.rsplit("/", false, 1)[0] as int
			add_profile_panel(last)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and $"../Panel".visible == false:
		SaveData.save_handler.save_profile_data()
		$Background/Paused/ProfilePanel.set_profile(SaveData.save_handler.profile)
		get_tree().paused = !get_tree().paused
		set_gui_state(&"pause")

		if get_tree().paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	visible = get_tree().paused

	set_preview_color(BlueColorButtonIcon, BlueColorButtonBG, NodeRule.COLORS.blue)
	set_preview_color(YellowColorButtonIcon, YellowColorButtonBG, NodeRule.COLORS.yellow)
	set_preview_color(GreenColorButtonIcon, GreenColorButtonBG, NodeRule.COLORS.green)
	set_preview_color(PurpleColorButtonIcon, PurpleColorButtonBG, NodeRule.COLORS.purple)


func set_preview_color(preview: Control, preview_bg: Control, color: NodeRule.COLORS):
	var col := SaveData.get_node_color(color)
	preview_bg.modulate = col
	if col.get_luminance() > 0.5:
		preview.modulate = col.darkened(0.6)
	else:
		preview.modulate = col.lightened(0.6)


func open_color_picker(color: NodeRule.COLORS):
	editing_color = color
	ColorPickerNode.color = SaveData.get_node_color(color)
	set_gui_state(&"color_picker")


func _on_done_pressed():
	SaveData.save_handler.vsave_value(["options", "accessibility", "colors", str(editing_color)], ColorPickerNode.color)
	set_gui_state("color_setting")
	SaveData.save()
	color_settings_changed.emit()


func _on_reset_pressed():
	SaveData.save_handler.vsave_value(["options", "accessibility", "colors", str(editing_color)], NodeRule.get_default_color(editing_color as NodeRule.COLORS))
	ColorPickerNode.color = NodeRule.get_default_color(editing_color as NodeRule.COLORS)
	SaveData.save()
	color_settings_changed.emit()


func _on_quit_pressed():
	get_tree().call_group("Puzzle", "save_data")
	SaveData.save()
	get_tree().quit()


func set_gui_state(state: StringName):
	match state:
		&"pause":
			previous_state = state
			PauseMenu.visible = true
			ProfilesMenu.visible = false
			OptionsMenu.visible = false
			CreditsMenu.visible = false
			ColorSelectMenu.visible = false
			ColorSelectPicker.visible = false
			$Background/ProfileRenaming.visible = false
			$Background/ViewControls.visible = false
			$Background/Paused/ProfilePanel.set_profile(SaveData.save_handler.profile)
			$Background/AudioSettings.visible = false
		&"options":
			PauseMenu.visible = false
			ProfilesMenu.visible = false
			OptionsMenu.visible = true
			CreditsMenu.visible = false
			ColorSelectMenu.visible = false
			ColorSelectPicker.visible = false
			$Background/ViewControls.visible = false
			$Background/AudioSettings.visible = false

			$Background/Options/Buttons/HoldMode.button_pressed = SaveData.save_handler.vget_value(["accessibility", "hold"], true)
			$Background/Options/Buttons/FullscreenButton.button_pressed = get_window().mode == Window.MODE_FULLSCREEN

		&"profiles":
			previous_state = state
			PauseMenu.visible = false
			ProfilesMenu.visible = true
			OptionsMenu.visible = false
			CreditsMenu.visible = false
			ColorSelectMenu.visible = false
			ColorSelectPicker.visible = false
			$Background/ProfileRenaming.visible = false
			$Background/ProfileDeleting.visible = false
			$Background/ProfileSwitching.visible = false
			$Background/ViewControls.visible = false
			$Background/AudioSettings.visible = false
			var index := 0
			for i in ProfileList.get_children():
				i.set_profile(index)
				index += 1
		&"credits":
			PauseMenu.visible = false
			ProfilesMenu.visible = false
			OptionsMenu.visible = false
			CreditsMenu.visible = true
			ColorSelectMenu.visible = false
			ColorSelectPicker.visible = false
			$Background/ViewControls.visible = false
		&"color_setting":
			PauseMenu.visible = false
			ProfilesMenu.visible = false
			OptionsMenu.visible = false
			CreditsMenu.visible = false
			ColorSelectMenu.visible = true
			ColorSelectPicker.visible = false
			$Background/ViewControls.visible = false
		&"color_picker":
			PauseMenu.visible = false
			ProfilesMenu.visible = false
			OptionsMenu.visible = false
			CreditsMenu.visible = false
			ColorSelectMenu.visible = false
			ColorSelectPicker.visible = true
			$Background/ViewControls.visible = false
		&"profile_renaming":
			OptionsMenu.visible = false
			CreditsMenu.visible = false
			ColorSelectMenu.visible = false
			ColorSelectPicker.visible = false
			$Background/ProfileRenaming.visible = true
			$Background/ViewControls.visible = false
		&"profile_deleting":
			PauseMenu.visible = false
			ProfilesMenu.visible = true
			OptionsMenu.visible = false
			CreditsMenu.visible = false
			ColorSelectMenu.visible = false
			ColorSelectPicker.visible = false
			$Background/ProfileDeleting.visible = true
			$Background/ViewControls.visible = false
		&"profile_switching":
			PauseMenu.visible = false
			ProfilesMenu.visible = true
			OptionsMenu.visible = false
			CreditsMenu.visible = false
			ColorSelectMenu.visible = false
			ColorSelectPicker.visible = false
			$Background/ProfileSwitching.visible = true
			$Background/ViewControls.visible = false
		&"viewcontrols":
			PauseMenu.visible = false
			ProfilesMenu.visible = false
			OptionsMenu.visible = false
			CreditsMenu.visible = false
			ColorSelectMenu.visible = false
			ColorSelectPicker.visible = false
			$Background/ProfileSwitching.visible = false
			$Background/ViewControls.visible = true
		&"audio_controls":
			PauseMenu.visible = false
			ProfilesMenu.visible = false
			OptionsMenu.visible = false
			CreditsMenu.visible = false
			ColorSelectMenu.visible = false
			ColorSelectPicker.visible = false
			$Background/ProfileSwitching.visible = false
			$Background/ViewControls.visible = false
			$Background/AudioSettings.visible = true



func _on_fullscreen_button_pressed() -> void:
	get_window().mode = Window.MODE_FULLSCREEN if get_window().mode != Window.MODE_FULLSCREEN else Window.MODE_WINDOWED
	SaveData.save_handler.vsave_value(["options", "fullscreen"], get_window().mode == Window.MODE_FULLSCREEN)



func _on_profile_panel_rename_request(profile: int) -> void:
	set_gui_state(&"profile_renaming")
	handling_profile = profile


func _on_profile_panel_delete_request(profile: int) -> void:
	set_gui_state(&"profile_deleting")
	handling_profile = profile


func _on_save_name_pressed() -> void:
	var handler := SaveHandler.new()
	handler.profile = handling_profile
	handler.load_profile_data()
	handler.profile_data["name"] = $Background/ProfileRenaming/PanelContainer/VBoxContainer/NameInput.text
	handler.save_profile_data()
	handler.free()
	set_gui_state(previous_state)


func _on_discard_name_pressed() -> void:
	set_gui_state(previous_state)


func _on_create_new_profile_pressed() -> void:
	var new_profile_handler := SaveHandler.new()
	new_profile_handler.profile = ProfileList.get_child_count()
	new_profile_handler.save_profile_data()
	add_profile_panel(ProfileList.get_child_count())


func add_profile_panel(p) -> void:
	var new_panel := PROFILE_PANEL.instantiate()
	new_panel.set_profile(p)
	new_panel.rename_request.connect(_on_profile_panel_rename_request)
	new_panel.delete_request.connect(_on_profile_panel_delete_request)
	new_panel.switch_to_request.connect(_on_profile_panel_switch_to_request)
	if p == SaveData.save_handler.profile:
		new_panel.deletable = false
		new_panel.switchable = false
	ProfileList.add_child(new_panel)


func _on_delete_profile_pressed() -> void:
	for index in ProfileList.get_child_count():
		if index == SaveData.save_handler.profile and index >= handling_profile:
			SaveData.save_handler.profile -= 1
			var file := FileAccess.open("user://.currentprofile", FileAccess.WRITE)
			file.store_string(str(SaveData.save_handler.profile))
			file.close()

		if index > handling_profile:
			var true_index = index - 1
			DirAccess.rename_absolute("user://profiles/%d" % index, "user://profiles/%d" % true_index)
		elif index == handling_profile:
			DirAccess.rename_absolute("user://profiles/%d" % index, "user://profiles/-1")

	ProfileList.get_child(handling_profile).free()


	var handler := SaveHandler.new()
	handler.profile = -1
	handler.delete_profile()
	handler.free()
	set_gui_state(&"profiles")


func _on_cancel_deletion_pressed() -> void:
	set_gui_state(&"profiles")


func _on_profile_panel_switch_to_request(profile: int) -> void:
	$"../Panel".visible = true
	get_tree().call_group("Puzzle", "save_data")
	SaveData.save()
	var tween = create_tween()
	tween.tween_property($"../Panel", "modulate:a", 1.0, 1.0)
	tween.finished.connect(do_the_switch.bind(profile))


func do_the_switch(profile: int) -> void:
	var file := FileAccess.open("user://.currentprofile", FileAccess.WRITE)
	file.store_string(str(profile))
	file.close()
	get_tree().reload_current_scene()
	SaveData.reset_all_globals()
	SaveData.save_handler.profile = profile
	SaveData._ready()
	print("d1")


func _on_cancel_switch_pressed() -> void:
	set_gui_state(&"profiles")


func _on_switch_close_pressed() -> void:
	var file := FileAccess.open("user://.currentprofile", FileAccess.WRITE)
	file.store_string(str(handling_profile))
	file.close()
	get_tree().call_group("Puzzle", "save_data")
	SaveData.save()
	get_tree().quit()


func _on_hold_mode_pressed() -> void:
	var get_hold_mode :bool = SaveData.save_handler.vget_value(["accessibility", "hold"], true)
	SaveData.save_handler.vsave_value(["accessibility", "hold"], !get_hold_mode)



func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _on_color_presets_index_pressed(index: int) -> void:
	var new_preset := "default"
	match index:
		1: new_preset = "protanopia"
		2: new_preset =  "deuteranopia"
		3: new_preset =  "tritanopia"
		_: new_preset = "default"

	SaveData.save_handler.vsave_value(["options", "accessibility", "preset"], new_preset)
	SaveData.save_handler.vsave_value(["options", "accessibility", "colors", str(NodeRule.COLORS.blue)], NodeRule.get_default_color(NodeRule.COLORS.blue))
	SaveData.save_handler.vsave_value(["options", "accessibility", "colors", str(NodeRule.COLORS.yellow)], NodeRule.get_default_color(NodeRule.COLORS.yellow))
	SaveData.save_handler.vsave_value(["options", "accessibility", "colors", str(NodeRule.COLORS.green)], NodeRule.get_default_color(NodeRule.COLORS.green))
	SaveData.save_handler.vsave_value(["options", "accessibility", "colors", str(NodeRule.COLORS.purple)], NodeRule.get_default_color(NodeRule.COLORS.purple))
	color_settings_changed.emit()


func _on_master_volume_value_changed(value: float) -> void:
	SaveData.save_handler.vsave_value(["options", "mastervol"], value)
	AudioServer.set_bus_volume_db(0, linear_to_db(value))


func _on_sfx_volume_value_changed(value: float) -> void:
	SaveData.save_handler.vsave_value(["options", "sfxvol"], value)
	AudioServer.set_bus_volume_db(1, linear_to_db(value))


func _on_music_volume_value_changed(value: float) -> void:
	SaveData.save_handler.vsave_value(["options", "musicvol"], value)
	AudioServer.set_bus_volume_db(2, linear_to_db(value))
