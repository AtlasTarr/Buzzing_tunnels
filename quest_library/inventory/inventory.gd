extends PanelContainer

const slot = preload("res://quest_library/inventory/slot.tscn")

@onready var item_grid = $MarginContainer/item_grid

##updates the inventory
func set_inventory_data(Inventory: Inventory_Data):
	Inventory.inventory_updated.connect(populate_item_grid)
	populate_item_grid(Inventory)

##removes data and slots from parsed inventory
func clear_inventory_data(Inventory: Inventory_Data): 
	Inventory.inventory_updated.disconnect(populate_item_grid)

##fills the parsed inventory with the amount of slots and sets their data
func populate_item_grid(Inventory: Inventory_Data) -> void:
	for child in item_grid.get_children():
		child.queue_free()
	
	for slot_data in Inventory.slot_datas:
		var _slot = slot.instantiate()
		item_grid.add_child(_slot)
		
		_slot.slot_clicked.connect(Inventory.on_slot_clicked)
		
		if slot_data:
			_slot.set_slot_data(slot_data)
