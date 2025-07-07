extends PanelContainer

signal slot_clicked(index: int, button: int)

@onready var texture_rect = $MarginContainer/TextureRect
@onready var quantity_label = $quantity_label

func set_slot_data(slot_data: Slot_Data):
	if slot_data != null:
		var item_data = slot_data.item_data
		texture_rect.texture = item_data.texture
		tooltip_text = "item: %s\ndescription: %s" % [item_data.name, item_data.description]
		quantity_update(slot_data)
		if slot_data.updated.get_connections().size() < 2	:
			slot_data.connect("updated", Callable(self, "quantity_update").bind(slot_data))

func quantity_update(slot_data: Slot_Data):
	if slot_data.quantity > 1:
		quantity_label.text = "x%s" % slot_data.quantity
		quantity_label.show()
	else:
		quantity_label.hide()

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseMotion:
		pass
	elif event is InputEventMouseButton \
			and (event.button_index == MOUSE_BUTTON_LEFT) \
			and event.is_pressed():
		slot_clicked.emit(get_index(), event.button_index)
	elif event is InputEventMouseButton \
			and (event.button_index == MOUSE_BUTTON_RIGHT) \
			and event.is_pressed():
		slot_clicked.emit(get_index(), event.button_index)
