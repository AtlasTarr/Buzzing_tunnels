extends Inventory_Data
class_name Equip_Body_Data


func drop_slot_data(grabbed_slot_data: Slot_Data, Index: int) -> Slot_Data:
	
	if not grabbed_slot_data.item_data is Body_Item_data:
		return grabbed_slot_data
	
	return super.drop_single_slot_data(grabbed_slot_data, Index)

func drop_single_slot_data(grabbed_slot_data: Slot_Data, Index: int) -> Slot_Data:
	
	if not grabbed_slot_data.item_data is Body_Item_data:
		return grabbed_slot_data
	
	return super.drop_slot_data(grabbed_slot_data, Index)
