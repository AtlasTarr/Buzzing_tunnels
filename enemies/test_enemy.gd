extends Area3D

@export var enemy_name: String = "cube"
var state: int = 0

@warning_ignore("unused_parameter")
func _process(delta):
	if state == 1:
		delete()
	
	var overlap = self.get_overlapping_bodies()
	
	for i in overlap:
		if i.is_in_group("player"):
			if Input.is_action_just_pressed("interact"):
				var quest_container = i.find_child("quest_container")
				for e in quest_container.get_children():
					if e.quest_type == 1:
						var objective_container = e.find_child("objectives")
						for a in objective_container.get_children():
							if a.target_enemy_name == self.enemy_name:
								a.increment_counter()
				state = 1


func delete():
	visible = false
	collision_layer = 32
	set_process(false)
