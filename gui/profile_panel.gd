@tool
extends PanelContainer

signal switch_to_request(profile: int)
signal rename_request(profile: int)
signal delete_request(profile: int)

@export var vertical := false
@export_category("Actions")
@export var deletable := true
@export var renamable := true
@export var switchable := true


var profile_number := 0

func _ready() -> void:
	set_layout_settings()

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
		$HBoxContainer/Screenshot.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL if vertical else TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL


func _on_switch_button_pressed() -> void:
	switch_to_request.emit(profile_number)


func _on_delete_button_pressed() -> void:
	delete_request.emit(profile_number)


func _on_rename_button_pressed() -> void:
	rename_request.emit(profile_number)


func set_profile(profile: int):
	profile_number = profile
	var handler := SaveHandler.new()
	var dont_free_handler := false
	if profile == SaveData.save_handler.profile:
		handler.free()
		handler = SaveData.save_handler
		dont_free_handler = true
	handler.profile = profile
	handler.load_profile_data()
	if handler.profile_data.is_empty():
		return
	var hours = handler.profile_data["seconds"] / 3600.0
	var int_hours = int(hours)
	var minutes = int((hours - int_hours) * 60)
	$HBoxContainer/Info/Data/Info.text = "%02d:%02d\n%d/%s" % [int_hours, minutes, handler.profile_data["puzzles"], "WIP"]
	$HBoxContainer/Info/Data/Name.text = handler.profile_data["name"]
	handler.load_screenshot()
	var img := ImageTexture.create_from_image(handler.screenshot)
	$HBoxContainer/Screenshot.texture = img

	if !dont_free_handler:
		handler.free()
