extends Node


var sections := []
var current_section := "house"

func _ready() -> void:
	var sections_dir := Directory.new()
	sections_dir.open("res://areas/%s" % current_section)
	sections_dir.list_dir_begin(true, true)
	var section_file_name = sections_dir.get_next()
	while section_file_name != "":
		sections.append(load("res://areas/%s/%s" % [current_section, section_file_name]))
		section_file_name = sections_dir.get_next()
