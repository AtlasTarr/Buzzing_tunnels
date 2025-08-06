extends Node
var Cinematic_controller

func _ready() -> void:
	for child in get_tree().current_scene.get_children(false):
		if child is AnimationPlayer:
			Cinematic_controller = child
