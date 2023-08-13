extends Object

class_name SaveHandler

var filename :StringName = "world.xau"
var profile := 0

var data_dictionary := {}
var profile_data := {
	"name": "Naraq",
	"puzzles": 0,
	"seconds": 0,
}
var screenshot :Image = preload("res://sprites/screenshot.png").get_image()


func load_data():
	print("according to handler: ", profile)
	if not DirAccess.dir_exists_absolute("user://profiles/" + str(profile)):
		DirAccess.make_dir_recursive_absolute("user://profiles/" + str(profile))

	if FileAccess.file_exists("user://profiles/%s/%s" % [str(profile), filename]):
		var file := FileAccess.open("user://profiles/%s/%s" % [str(profile), filename], FileAccess.READ)
		var test_json_conv = JSON.new()
		if test_json_conv.parse(file.get_as_text()) == OK:
			data_dictionary = test_json_conv.data
		file.close()

	load_profile_data()


func load_profile_data() -> void:
	if not DirAccess.dir_exists_absolute("user://profiles/" + str(profile)):
		DirAccess.make_dir_recursive_absolute("user://profiles/" + str(profile))

	if FileAccess.file_exists("user://profiles/%s/.profile" % str(profile)):
		var file := FileAccess.open("user://profiles/%s/.profile" % str(profile), FileAccess.READ)
		var test_json_conv = JSON.new()
		if test_json_conv.parse(file.get_as_text()) == OK:
			profile_data = test_json_conv.data
		file.close()
	else:
		save_profile_data()


func save():
	if not DirAccess.dir_exists_absolute("user://profiles/" + str(profile)):
		DirAccess.make_dir_recursive_absolute("user://profiles/" + str(profile))

	var file := FileAccess.open("user://profiles/%s/%s" % [str(profile), filename], FileAccess.WRITE)
	file.store_string(JSON.stringify(data_dictionary, "\t"))
	file.close()

	file = FileAccess.open("user://profiles/%s/.profile" % str(profile), FileAccess.WRITE)
	file.store_string(JSON.stringify(profile_data, "\t"))
	file.close()


func save_profile_data():
	if not DirAccess.dir_exists_absolute("user://profiles/" + str(profile)):
		DirAccess.make_dir_recursive_absolute("user://profiles/" + str(profile))

	var file := FileAccess.open("user://profiles/%s/.profile" % str(profile), FileAccess.WRITE)
	file.store_string(JSON.stringify(profile_data, "\t"))
	file.close()


func get_value_in_dict(dict: Dictionary, key: StringName, default: Variant) -> Variant:
	if not key in dict:
		return default

	var value = dict[key]

	if value is Dictionary and "type" in value:
		var type :StringName = value["type"]
		match type:
			"color":
				return Color(value["value"])
			"vector2":
				return Vector2(value["value"][0], value["value"][1])
			_:
				return value
	else:
		return value


func get_value(key: StringName, default: Variant) -> Variant:
	return get_value_in_dict(data_dictionary, key, default)


func save_value(key: StringName, value: Variant):
	save_value_in_dict(data_dictionary, key, value)


func save_value_in_dict(dict: Dictionary, key: StringName, value: Variant):
	if value is Color:
		dict[key] = {
			"type": "color",
			"value": value.to_html()
		}
	elif value is Vector2:
		dict[key] = {
			"type": "vector2",
			"value": [value.x, value.y]
		}
	else:
		dict[key] = value


func vget_value(keys: Array[StringName], default: Variant) -> Variant:
	var c_dict :Dictionary = data_dictionary

	for key_index in keys.size() - 1:
		var current_key :StringName = keys[key_index]
		if c_dict is Dictionary:
			if not current_key in c_dict:
				c_dict[current_key] = {}
			c_dict = c_dict[current_key]
		else:
			return default

	return get_value_in_dict(c_dict, keys.pop_back(), default)


func vsave_value(keys: Array[StringName], value: Variant):
	var c_dict :Dictionary = data_dictionary


	for key_index in keys.size() - 1:
		var current_key :StringName = keys[key_index]
		if c_dict is Dictionary:
			if current_key in c_dict:
				c_dict = c_dict[current_key]


	save_value_in_dict(c_dict, keys.pop_back(), value)


func store_screenshot():
	if not DirAccess.dir_exists_absolute("user://profiles/" + str(profile)):
		DirAccess.make_dir_recursive_absolute("user://profiles/" + str(profile))

	var th := Thread.new()
	th.start(screenshot.save_png.bind("user://profiles/%s/screenshot.png" % str(profile)))
	await th.wait_to_finish()


func load_screenshot():
	if not DirAccess.dir_exists_absolute("user://profiles/" + str(profile)):
		DirAccess.make_dir_recursive_absolute("user://profiles/" + str(profile))

	if FileAccess.file_exists("user://profiles/%s/screenshot.png" % str(profile)):
		screenshot = Image.load_from_file("user://profiles/%s/screenshot.png" % str(profile))
	else:
		screenshot = await SaveData.take_screenshot()
		store_screenshot()


func delete_profile():
	var path := "user://profiles/%s" % str(profile)
	if DirAccess.dir_exists_absolute(path):
		var dir := DirAccess.open(path)
		dir.include_hidden = true
		for i in dir.get_files():
			dir.remove(i)
		DirAccess.remove_absolute(path)



func erase_key(key: StringName):
	data_dictionary.erase(key)


func verase_key(keys: Array[StringName], key: Variant):
	var c_dict :Dictionary = data_dictionary


	for key_index in keys.size() - 1:
		var current_key :StringName = keys[key_index]
		if c_dict is Dictionary:
			if current_key in c_dict:
				c_dict = c_dict[current_key]
			else:
				return

	c_dict.erase(key)
