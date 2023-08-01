@tool
extends PanelContainer

signal switch_to_request(path)
signal rename_request(path)
signal delete_request(path)

@export var vertical := false
@export_category("Actions")
@export var deletable := true
@export var renamable := true
@export var switchable := true

var path :StringName
var file_username :String
var play_time: int


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		set_layout_settings()


func set_layout_settings() -> void:
	$HBoxContainer/Info/Actions/SwitchButton.visible = switchable
	$HBoxContainer/Info/Actions/RenameButton.visible = renamable
	$HBoxContainer/Info/Actions/DeleteButton.visible = deletable
	if not $HBoxContainer.vertical == vertical:
		$HBoxContainer.vertical = vertical
		$HBoxContainer/Info.vertical = not vertical
		$HBoxContainer/Info/Actions.vertical = vertical
		$HBoxContainer/Screenshot.expand_mode = TextureRect.EXPAND_FIT_HEIGHT if vertical else TextureRect.EXPAND_FIT_WIDTH


func _on_switch_button_pressed() -> void:
	switch_to_request.emit()


func _on_delete_button_pressed() -> void:
	delete_request.emit()


func _on_rename_button_pressed() -> void:
	rename_request.emit()
