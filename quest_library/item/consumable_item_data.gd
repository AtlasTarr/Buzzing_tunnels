extends Item_Data
class_name Consumable_Item_Data

@export var food: bool = false
@export var satiate_amout: float

func use(target):
	if satiate_amout != 0:
		target.satiate(food, satiate_amout)
