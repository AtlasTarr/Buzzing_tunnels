extends Node3D
var paused = false

var current_dialouge: String = "test"
var current_dialouge_holder: String = "test"

var choice_array: PackedStringArray

var choosing: bool = false

@onready var text_box = $Control/MarginContainer/MarginContainer2/RichTextLabel 
@onready var dialouge_ui = $Control
@onready var choice_containerx2 = $Control/VBoxContainer
@onready var choice_container = $Control/VBoxContainer/VBoxContainer
@onready var dialouge_holder_ui = $Control/MarginContainer3/RichTextLabel
@onready var player = $player

const button = preload("res://custom_button.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var children = self.get_children()
	var choices = choice_container.get_children()
	for child in children:
		if child.is_in_group("DialougeHolder"):
			child.connect("choice_update", option_update)
			child.connect("dialouge_toggle", dialouge_ui_toggle)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var children = self.get_children()
	for child in children:
		if child.is_in_group("DialougeHolder"):
			if child.active == true:
				current_dialouge_holder = child.name
				dialouge_holder_ui.text = current_dialouge_holder
	if current_dialouge.contains("[QUESTION]"):
		current_dialouge = current_dialouge.replace("[QUESTION]", " ")
		dialouge_option_ui()
	text_box.text = current_dialouge

func dialouge_option_ui():
	choice_containerx2.visible = true

func no_dialouge_option_ui():
	choice_containerx2.visible = false

func option_update():
	var choices = choice_container.get_children()
	if choice_array.size()> 0:
		for choice in choice_array:
			var new_button = button.instantiate()
			new_button.text = choice
			new_button.pressed.connect(Callable(update_dialouge_tree.bind(new_button.text)))                         
			choice_container.add_child(new_button)

func update_dialouge_tree(tree_name: String):
	var dialouge_holder_object = self.find_child(current_dialouge_holder,true, false)
	dialouge_holder_object.current_choice_tree = tree_name
	for dilaouges in dialouge_holder_object.dialouges.size() + 1:
		dialouge_holder_object._on_trigger_interact()
		dialouge_holder_object.current_dialouge = 0
		dialouge_holder_object.current_dialouge_file = 0

func dialouge_ui_toggle():
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	paused = !paused
	var children = self.get_children()
	var choices = choice_container.get_children()
	for child in children:
		if paused == true:
			child.set_physics_process(false)
		else:
			child.set_physics_process(true)
	if choices.size()> 0:
		for choice in choices:
			choice_array.clear()
			choice.queue_free()
			no_dialouge_option_ui()
#		print("test")

	dialouge_ui.visible = !dialouge_ui.visible
