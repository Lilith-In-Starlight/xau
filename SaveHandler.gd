extends Object

class_name SaveHandler

var filename :StringName = "world.xau"

var data_dictionary := {}


func load_data():
	if FileAccess.file_exists("user://" + filename):
		var file := FileAccess.open("user://" + filename, FileAccess.READ)
		var test_json_conv = JSON.new()
		if test_json_conv.parse(file.get_as_text()) == OK:
			data_dictionary = test_json_conv.data
		file.close()


func save():
	var file := FileAccess.open("user://" + filename, FileAccess.WRITE)
	file.store_string(JSON.stringify(data_dictionary, "\t"))
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


