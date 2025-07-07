extends Item_Data
class_name Consumable_Item_Data

@export var heal_amount: float

func use(target):
	if heal_amount != 0:
		target.heal(heal_amount)
