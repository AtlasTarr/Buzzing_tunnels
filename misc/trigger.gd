extends Area3D
@export var active = false
var useable: bool = true
signal interact

func _ready():
	pass
#	add_user_signal("interact")

func _process(delta):
	if active == true:
		if useable == true:
			if Input.is_action_just_pressed("interact"):
				emit_signal("interact")

func _on_body_entered(body):
	if body.is_in_group("player"):
		active = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		active = false
