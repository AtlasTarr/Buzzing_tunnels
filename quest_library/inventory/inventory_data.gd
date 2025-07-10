extends Resource
class_name Inventory_Data

signal inventory_updated(inventory: Inventory_Data)
signal inventory_interact(inventory: Inventory_Data, index: int, button: int)

const pickup = preload("res://quest_library/Pickups/test_item_pickup.tscn")

@export var slot_datas: Array[Slot_Data]


func force_update():
	inventory_updated.emit(self)

func on_slot_clicked(index: int, button: int):
	inventory_interact.emit(self, index, button)


func grab_slot_data(Index: int) -> Slot_Data:
	var slot_data = slot_datas[Index]
	
	if slot_data:
		slot_datas[Index] = null
		inventory_updated.emit(self)
		return slot_data
	else :
		return null

func drop_slot_data(grabbed_slot_data: Slot_Data, Index: int) -> Slot_Data:
	var slot_data = slot_datas[Index]
	var _slot_data: Slot_Data
	var return_slot_data: Slot_Data
	
	if slot_data and slot_data.can_fully_merge_with(grabbed_slot_data):
		_slot_data = slot_data.duplicate()
		_slot_data.fully_merge_with(grabbed_slot_data)
	else:
			slot_datas[Index] = grabbed_slot_data
			return_slot_data = slot_data
	
	inventory_updated.emit(self)
	return return_slot_data


func drop_single_slot_data(grabbed_slot_data: Slot_Data, Index: int) -> Slot_Data:
	var slot_data = slot_datas[Index]
	
	if not slot_data:
		slot_datas[Index] = grabbed_slot_data.create_single_slot()
	elif slot_data.can_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data.create_single_slot())
	
	inventory_updated.emit(self)
	
	if grabbed_slot_data.quantity > 0:
		return grabbed_slot_data
	else:
		return null

func use_slot_data(index: int):
	var slot_data = slot_datas[index]
	
	if not slot_data:
		return
	
	if slot_data.item_data is Consumable_Item_Data:
		slot_data.set_quatity(slot_data.quantity - 1)
		if slot_data.quantity < 1:
			slot_datas[index] = null
	elif slot_data.item_data is Ammo_Item_Data:
		slot_data.set_quatity(slot_data.quantity - 1)
		if slot_data.quantity < 1:
			slot_datas[index] = null
	
	print(slot_data.item_data.name)
	PlayerManager.use_slot_data(slot_data)
	
	inventory_updated.emit(self)

func pick_up_slot_data(slot_data: Slot_Data) -> bool:
	
	for index in slot_datas.size():
		if slot_datas[index] and slot_datas[index].can_fully_merge_with(slot_data):
			slot_datas[index].fully_merge_with(slot_data)
			inventory_updated.emit(self)
			return true
	
	for index in slot_datas.size():
		if not slot_datas[index]:
			slot_datas[index] = slot_data
			inventory_updated.emit(self)
			return true
	
	return false
