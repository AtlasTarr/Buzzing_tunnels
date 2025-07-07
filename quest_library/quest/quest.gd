extends Node
class_name quest

@export var needs_claiming: bool = true

@export_enum("test", "slay", "interact", "input") var quest_type: int

@export var quest_name: String
@export var description: String
@export var state: int = 0

@export var reward: Inventory_Data

@export var objectives_completed: Array

@onready var objective_container = $objectives

func activate():
	state = 1
	
	var objectives = objective_container.get_children()
	
	for i in objectives:
		i.active = true

func complete():
	state = 2
	print("completed")

func claim():
	var player = get_parent().get_parent()
	if reward.slot_datas.size() > 0:
		for index in reward.slot_datas.size():
			var item = reward.slot_datas[index]
			player.inventory.pick_up_slot_data(item)
	state = 3
	print("claimed")

func _on_timer_timeout():
	var objectives = objective_container.get_children()
	
	
	for i in objectives:
		if i.completed == true:
			if objectives_completed.size() > 0:
				for e in objectives_completed:
					if not objectives_completed.has(i):
						objectives_completed.append(i)
			else:
				objectives_completed.append(i)
	
	if objectives_completed.size() == objectives.size():
		if state == 1:
			if needs_claiming == true:
				complete()
			else:
				claim()

func delete_self():
	self.queue_free()
	
