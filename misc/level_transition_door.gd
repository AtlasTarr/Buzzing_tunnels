extends Node3D

@onready var Trigger = $trigger
@export var level: String

func _ready() -> void:
	Trigger.connect("interact", use )

func use():
	self.owner.save()
	var _level = "".join(["levels/",level,".tscn"])
	get_tree().call_deferred("unload_current_scene")
	get_tree().change_scene_to_file(_level)
	print("test")
