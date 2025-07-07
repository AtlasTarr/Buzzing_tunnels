extends Objective

@export var input_name: String

func _process(delta):
	if active == true:
		if Input.is_action_pressed(input_name):
			self.completed = true
