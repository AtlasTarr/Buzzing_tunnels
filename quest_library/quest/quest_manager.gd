extends Area3D

var active: bool = false

@export var quest: PackedScene

var quest_instance

@warning_ignore("unused_parameter")
func _process(delta):
	var overlap = self.get_overlapping_bodies()
	for i in overlap:
		if i.is_in_group("Player"):
			active = true
		else:
			active = false
	
	if active == true:
		if Input.is_action_just_pressed("interact"):
			for i in overlap:
				if i.is_in_group("Player"):
					var quest_container = i.find_child("quest_container")
					var has_quest = false
					var quest_node = quest.instantiate()
					var quest_node_names= quest._bundled.get("names")
					var root = get_parent()
					
					for e in quest_container.get_children():
						if e.name == quest_node_names[0]:
							has_quest = true
							quest_instance = e
#							print("test")
					
					if  quest_node != null:
						if has_quest == false:
							quest_container.add_child(quest_node)
							quest_node.activate()
							quest_instance = quest_node
					else:
						quest_instance = root.get_node("player/quest_container/%s" % quest_node_names[0])
					
					if quest_instance.state == 2:
						quest_instance.claim()
