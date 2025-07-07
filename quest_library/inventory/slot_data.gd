extends Resource
class_name Slot_Data

const MAX_STACK_SIZE: int = 150

signal updated

@export var item_data: Item_Data
@export_range(1, MAX_STACK_SIZE) var quantity: int = 1: set = set_quatity

func can_merge_with(other_slot_data: Slot_Data) -> bool:
	return item_data == other_slot_data.item_data\
			and item_data.stackable\
			and quantity < MAX_STACK_SIZE

func can_fully_merge_with(other_slot_data: Slot_Data) -> bool:
	return item_data == other_slot_data.item_data\
			and item_data.stackable\
			and quantity + other_slot_data.quantity <= MAX_STACK_SIZE

func fully_merge_with(other_slot_data: Slot_Data):
	quantity += other_slot_data.quantity

func create_single_slot():
	var new_slot_data = duplicate()
	new_slot_data.quantity = 1
	quantity -= 1
	return new_slot_data

func set_quatity(value: int):
	quantity = value
	if quantity > 1 and not item_data.stackable == true:
		quantity = 1
		push_error("%s is not stackable quantity set to 1" % item_data.name)
	if quantity == 0:
		updated.emit()
	updated.emit()
