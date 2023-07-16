extends Control

signal color_settings_changed


@onready var BlueColorButton := $Background/ColorButtons/BlueButton
@onready var YellowColorButton := $Background/ColorButtons/YellowButton
@onready var GreenColorButton := $Background/ColorButtons/GreenButton
@onready var PurpleColorButton := $Background/ColorButtons/PurpleButton

@onready var BlueColorButtonIcon := $Background/ColorButtons/BlueButton/Icon
@onready var YellowColorButtonIcon := $Background/ColorButtons/YellowButton/Icon
@onready var GreenColorButtonIcon := $Background/ColorButtons/GreenButton/Icon
@onready var PurpleColorButtonIcon := $Background/ColorButtons/PurpleButton/Icon

@onready var ColorPickerNode := $Background/ColorPicker

@onready var ColorButtons := $Background/ColorButtons

var editing_color :int = -1


func _ready():
	BlueColorButton.pressed.connect(open_color_picker.bind(NodeRule.COLORS.blue))
	YellowColorButton.pressed.connect(open_color_picker.bind(NodeRule.COLORS.yellow))
	GreenColorButton.pressed.connect(open_color_picker.bind(NodeRule.COLORS.green))
	PurpleColorButton.pressed.connect(open_color_picker.bind(NodeRule.COLORS.purple))


func _process(delta):
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
	ColorPickerNode.visible = true
	ColorButtons.visible = false
	ColorPickerNode.color = SaveData.get_node_color(color)


func _on_done_pressed():
	SaveData.colors[str(editing_color)] = ColorPickerNode.color.to_html()
	_on_regret_pressed()
	SaveData.save()
	color_settings_changed.emit()

func _on_regret_pressed():
	ColorPickerNode.visible = false
	ColorButtons.visible = true


func _on_quit_pressed():
	get_tree().quit()
