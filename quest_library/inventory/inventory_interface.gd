extends Control

signal drop_slot_data(slot_data: Slot_Data)
signal force_close

var external_inventory_owner

@onready var player_inventory: PanelContainer  = $player_inventory
@onready var grabbed_slot: PanelContainer  = $grabbed_slot
@onready var external_inventory: PanelContainer  = $external_inventory
@onready var helmet_inventory_data: PanelContainer  = $helmet_equip_inventory
@onready var body_equip_inventory: PanelContainer  = $body_equip_inventory
@onready var weapon_equip_inventory: PanelContainer = $weapon_equip_inventory


var grabbed_slot_data: Slot_Data

@warning_ignore("unused_parameter")
func _process(delta):
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(5, 5)
	
	if external_inventory_owner\
			and external_inventory_owner.global_position.distance_to(PlayerManager.get_player_position()) > 4:
		force_close.emit()

##sets the player inventory data and connects it to interactivity
func set_player_inventory_data(Inventory: Inventory_Data):
	Inventory.inventory_interact.connect(on_inventory_interact)
	player_inventory.set_inventory_data(Inventory)

##sets the helmet inventory data and connects it to interactivity
func set_helmet_inventory_data(Inventory: Inventory_Data):
	Inventory.inventory_interact.connect(on_inventory_interact)
	helmet_inventory_data.set_inventory_data(Inventory)

##sets the body inventory data and connects it to interactivity
func set_body_inventory_data(Inventory: Inventory_Data):
	Inventory.inventory_interact.connect(on_inventory_interact)
	body_equip_inventory.set_inventory_data(Inventory)

func set_weapon_inventory_data(Inventory: Inventory_Data):
	Inventory.inventory_interact.connect(on_inventory_interact)
	weapon_equip_inventory.set_inventory_data(Inventory) 

##sets the external inventory data and connects it to interactivity
func set_external_inventory_owner(_external_inventory_owner):
	external_inventory_owner = _external_inventory_owner
	var inventory_data = external_inventory_owner.inventory
	
	inventory_data.inventory_interact.connect(on_inventory_interact)
	external_inventory.set_inventory_data(inventory_data)
	
	external_inventory.show()

##clears the external inventory owner and data and removes it from interactivity
func clear_external_inventory_owner():
	if external_inventory_owner:
		var inventory_data = external_inventory_owner.inventory
		
		inventory_data.inventory_interact.disconnect(on_inventory_interact)
		external_inventory.clear_inventory_data(inventory_data)
		
		external_inventory.hide()
		external_inventory_owner = null

##handles setting grabbed slots as well as; setting its data, using and droping
func on_inventory_interact(inventory: Inventory_Data, index: int, button: int):
	
	match [grabbed_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory.grab_slot_data(index)
		[_, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory.drop_slot_data(grabbed_slot_data, index)
		[null, MOUSE_BUTTON_RIGHT]:
			inventory.use_slot_data(index)
		[_, MOUSE_BUTTON_RIGHT]:
			grabbed_slot_data = inventory.drop_single_slot_data(grabbed_slot_data, index)
	update_grabbed_slot()

##sets the grabbed data visibility
func update_grabbed_slot():
	if grabbed_slot_data:
		grabbed_slot.show()
		grabbed_slot.set_slot_data(grabbed_slot_data)
	else:
		if grabbed_slot.visible == true:
			grabbed_slot.hide()

func on_gui_input(event):
	var root = get_tree().get_first_node_in_group("level")
	if event is InputEventMouseButton\
			and event.is_pressed()\
			and grabbed_slot_data:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				drop_slot_data.emit(grabbed_slot_data)
				root.on_inventory_interface_drop_slot_data(grabbed_slot_data, true)
				grabbed_slot_data = null
			MOUSE_BUTTON_RIGHT:
				drop_slot_data.emit(grabbed_slot_data.create_single_slot())
				root.on_inventory_interface_drop_slot_data(grabbed_slot_data, false)
				if grabbed_slot_data.quantity <1:
					grabbed_slot_data = null
		
		update_grabbed_slot()

func _on_visibility_changed():
	if not visible and grabbed_slot_data:
		drop_slot_data.emit(grabbed_slot_data)
		grabbed_slot_data = null
		update_grabbed_slot()
