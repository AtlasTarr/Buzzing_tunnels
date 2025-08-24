extends Node
var Cinematic_controller

func _ready() -> void:
	set_player()

func set_player() -> void:
	for child in get_tree().current_scene.get_children(true):
		if child is AnimationPlayer:
			print()
			Cinematic_controller = child
