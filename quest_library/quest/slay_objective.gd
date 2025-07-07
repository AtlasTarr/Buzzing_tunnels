extends Objective


@export var target_enemy_name: String = "cube"
@export var target_enemy_amount: int = 2

var killed_enemies:int = 0

@warning_ignore("unused_parameter")
func _process(delta):
	if killed_enemies >= target_enemy_amount:
		completed = true

func increment_counter():
	killed_enemies += 1
