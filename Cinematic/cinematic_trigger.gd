extends Node3D
class_name Cinematic_trigger
@export var object_scene = "res://Cinematic/cinematic_trigger.tscn"
@export var Cinematic: String
@export var useable: bool = true

func _on_trigger_body_entered(body: Node3D) -> void:
	print("test")
	if useable:
		if CinematicManager.Cinematic_controller != null:
			print("test2")
			if CinematicManager.Cinematic_controller.has_animation(Cinematic):
				CinematicManager.Cinematic_controller.active =  true
				CinematicManager.Cinematic_controller.play(Cinematic)
				
				useable = false
