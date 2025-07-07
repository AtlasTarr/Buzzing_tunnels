extends Node3D

@onready var Trigger = $trigger
@export var level: PackedScene

func _ready() -> void:
	Trigger.connect("interact", use )

func use():
	var current_scene = get_tree().root.get_children(true)
	if level != null:
		for child in current_scene:
			child.queue_free()
		var node = level.instantiate()
		get_tree().root.add_child(node)
	print("test")
