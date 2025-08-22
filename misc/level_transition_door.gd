extends Node3D

@onready var Trigger = $trigger
@export var level: PackedScene

func _ready() -> void:
	Trigger.connect("interact", use )

func use():
	get_tree().change_scene_to_packed(level)
	print("test")
