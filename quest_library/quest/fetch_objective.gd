extends Objective

@export var Item : Item_Data
@export var amount : int = 1

var player: CharacterBody3D
var inventory : Inventory_Data

func _ready():
	player = get_tree().get_first_node_in_group("player")
	inventory = player._playerdata.inventory_data
	$Timer.start()

func check(): 
	for index in range(inventory.slot_datas.size()):
		var slot_data = inventory.slot_datas[index]
		
		if not slot_data == null:
			if slot_data.item_data.name == Item.name:
				completed = true


func _on_timer_timeout():
	check()
