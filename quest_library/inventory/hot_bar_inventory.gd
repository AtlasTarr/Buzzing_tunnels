extends PanelContainer

const slot = preload("res://quest_library/inventory/slot.tscn")

signal hot_bar_use(index: int)

@onready var h_box_container = $MarginContainer/HBoxContainer

func _unhandled_key_input(event):
	if not visible or not event.is_pressed():
		return
	
	if Input.is_action_just_pressed("hot item"):
		hot_bar_use.emit(0)

func set_inventory_data(Inventory: Inventory_Data) -> void:
	Inventory.inventory_updated.connect(populate_hot_bar)
	populate_hot_bar(Inventory)
	hot_bar_use.connect(Inventory.use_slot_data)

func populate_hot_bar(Inventory: Inventory_Data) -> void:
	for child in h_box_container.get_children():
		child.queue_free()
	
	for slot_data in Inventory.slot_datas.slice(0,1):
		var _slot = slot.instantiate()
		h_box_container.add_child(_slot)
		
		
		if slot_data:
			_slot.set_slot_data(slot_data)
