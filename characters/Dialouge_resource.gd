@tool extends Resource
class_name Dialouge_resource

@export() var text: String
@export var has_options:bool = false:
	set(value):
		if value == has_options : return
		has_options = value
		notify_property_list_changed()

@export var Change_variable:bool = false:
	set(value):
		if value == Change_variable : return
		Change_variable = value
		notify_property_list_changed()

var options: Array[Option_resource] = []
var variable_to_change = {"has_inventory": false, "act": {"0": false,"1": false,"2": false,"3": false}}

func _get_property_list():
	if Engine.is_editor_hint():
		var ret =[]
		if has_options:
			ret.append({
				"name": &"options",
				"type": TYPE_ARRAY,
				"hint": PROPERTY_HINT_TYPE_STRING,
				"hint_string": "Option_resource",
				"Usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE
			})
		if Change_variable:
			ret.append({
				"name": &"variable_to_change",
				"type": TYPE_DICTIONARY,
				"hint": PROPERTY_HINT_ENUM,
				"usage": PROPERTY_USAGE_DEFAULT
			})
		return ret
