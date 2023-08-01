extends Control

signal color_settings_changed


@onready var BlueColorButton := $Background/ColorSelect/ColorButtons/BlueButton
@onready var YellowColorButton := $Background/ColorSelect/ColorButtons/YellowButton
@onready var GreenColorButton := $Background/ColorSelect/ColorButtons/GreenButton
@onready var PurpleColorButton := $Background/ColorSelect/ColorButtons/PurpleButton

@onready var BlueColorButtonIcon := $Background/ColorSelect/ColorButtons/BlueButton/Icon
@onready var YellowColorButtonIcon := $Background/ColorSelect/ColorButtons/YellowButton/Icon
@onready var GreenColorButtonIcon := $Background/ColorSelect/ColorButtons/GreenButton/Icon
@onready var PurpleColorButtonIcon := $Background/ColorSelect/ColorButtons/PurpleButton/Icon

@onready var ColorPickerNode := $Background/ColorSelectPicker/ColorPicker

@onready var ColorButtons := $Background/ColorSelect/ColorButtons

@onready var PauseMenu := $Background/Paused
@onready var ProfilesMenu := $Background/Profiles
@onready var OptionsMenu := $Background/Options
@onready var CreditsMenu := $Background/Credits
@onready var ColorSelectMenu := $Background/ColorSelect
@onready var ColorSelectPicker := $Background/ColorSelectPicker

var editing_color :int = -1


func _ready():
	BlueColorButton.pressed.connect(open_color_picker.bind(NodeRule.COLORS.blue))
	YellowColorButton.pressed.connect(open_color_picker.bind(NodeRule.COLORS.yellow))
	GreenColorButton.pressed.connect(open_color_picker.bind(NodeRule.COLORS.green))
	PurpleColorButton.pressed.connect(open_color_picker.bind(NodeRule.COLORS.purple))


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused

		if get_tree().paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	visible = get_tree().paused


	BlueColorButtonIcon.modulate = SaveData.get_node_color(NodeRule.COLORS.blue)
	YellowColorButtonIcon.modulate = SaveData.get_node_color(NodeRule.COLORS.yellow)
	GreenColorButtonIcon.modulate = SaveData.get_node_color(NodeRule.COLORS.green)
	PurpleColorButtonIcon.modulate = SaveData.get_node_color(NodeRule.COLORS.purple)


func open_color_picker(color: NodeRule.COLORS):
	editing_color = color
	ColorPickerNode.color = SaveData.get_node_color(color)
	set_gui_state(&"color_picker")


func _on_done_pressed():
	SaveData.save_handler.vsave_value(["options", "accessibility", "colors", str(editing_color)], ColorPickerNode.color)
	set_gui_state("color_setting")
	SaveData.save()
	color_settings_changed.emit()


func _on_quit_pressed():
	get_tree().call_group("Puzzle", "save_data")
	SaveData.save()
	get_tree().quit()


func set_gui_state(state: StringName):
	match state:
		&"pause":
			PauseMenu.visible = true
			ProfilesMenu.visible = false
			OptionsMenu.visible = false
			CreditsMenu.visible = false
			ColorSelectMenu.visible = false
			ColorSelectPicker.visible = false
		&"options":
			PauseMenu.visible = false
			ProfilesMenu.visible = false
			OptionsMenu.visible = true
			CreditsMenu.visible = false
			ColorSelectMenu.visible = false
			ColorSelectPicker.visible = false
			$Background/Options/Buttons/FullscreenButton.button_pressed = get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN
		&"profiles":
			PauseMenu.visible = false
			ProfilesMenu.visible = true
			OptionsMenu.visible = false
			CreditsMenu.visible = false
			ColorSelectMenu.visible = false
			ColorSelectPicker.visible = false
		&"credits":
			PauseMenu.visible = false
			ProfilesMenu.visible = false
			OptionsMenu.visible = false
			CreditsMenu.visible = true
			ColorSelectMenu.visible = false
			ColorSelectPicker.visible = false
		&"color_setting":
			PauseMenu.visible = false
			ProfilesMenu.visible = false
			OptionsMenu.visible = false
			CreditsMenu.visible = false
			ColorSelectMenu.visible = true
			ColorSelectPicker.visible = false
		&"color_picker":
			PauseMenu.visible = false
			ProfilesMenu.visible = false
			OptionsMenu.visible = false
			CreditsMenu.visible = false
			ColorSelectMenu.visible = false
			ColorSelectPicker.visible = true


func _on_fullscreen_button_pressed() -> void:
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (!((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED
