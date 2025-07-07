extends Resource
class_name Item_Data

@export var name: String
@export_multiline var description: String
@export var stackable: bool = false
@export var texture: Texture

@warning_ignore("unused_parameter")
func use(target):
	pass
