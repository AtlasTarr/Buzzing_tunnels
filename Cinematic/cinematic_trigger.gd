extends Node3D
@export var Cinematic: String


func on_trigger_interact() -> void:
	print("test")
	if CinematicManager.Cinematic_controller == null:
		print("is null")
	if CinematicManager.Cinematic_controller.has_animation(Cinematic):
		CinematicManager.Cinematic_controller.play(Cinematic)
		$MeshInstance3D/trigger.useable = false
