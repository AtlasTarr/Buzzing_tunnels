extends Node3D

var open:bool = false
var talking:bool = false

const SCREEN_TEXTURE_OPEN = preload("res://3D assets/Characters/Zero/Shader/screen texture open.tres")
const SCREEN_TEXTURE = preload("res://3D assets/Characters/Zero/Shader/Screen texture.tres")

func _ready() -> void:
	get_parent().connect("toggle_talk_anim", self.toggle_talk_anim)



func toggle_talk_anim():
		if talking == false:
			$Timer.start()
		else:
			$Timer.stop()
			talking = false

func _on_timer_timeout() -> void:
	if open == false:
		$Cube_001.material_override = SCREEN_TEXTURE_OPEN
		open = true
	else:
		$Cube_001.material_override = SCREEN_TEXTURE
		open = false
	talking = true
