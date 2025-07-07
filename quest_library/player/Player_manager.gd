extends Node

var player

func use_slot_data(slot_data: Slot_Data):
	slot_data.item_data.use(player)

func get_player_position() -> Vector3:
	return player.global_position
