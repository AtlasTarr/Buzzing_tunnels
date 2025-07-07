extends Node3D

var paused = false

var current_dialouge: String = "test"
var current_dialouge_holder: String = "test"

var choice_array: PackedStringArray

var choosing: bool = false

@onready var UI = $UI

@onready var text_box = UI.text_box
@onready var dialouge_ui = UI.dialouge_ui
@onready var choice_containerx2 = UI.choice_containerx2
@onready var choice_container = UI.choice_container
@onready var dialouge_holder_ui = UI.dialouge_holder_ui

const button = preload("res://misc/custom_button.tscn")

const pickup = preload("res://quest_library/Pickups/test_item_pickup.tscn")

const quest_block = preload("res://misc/quest_block.tscn")

@export var leve_data: Level_data = Level_data.new()

var can_save: bool = true
var save_file_path = "user://saves/"
var player_file_name = "playersave.tres"
@export var scene_name = "placeholder.tres"

enum state {full, half, one_quarter, empty}


@export var old_temp_list: Dictionary
@export var temp_list: Dictionary
@export var test_temp_list: Dictionary

@export var test_array: Array

@onready var children = self.get_children(true)
@onready var name_array: PackedStringArray


@onready var player = find_child("player")
@onready var playerdata = player._playerdata
@onready var inventory_interface = $UI/inventory_interface
@onready var hot_bar_inventory = $UI/Hot_bar_inventory
@onready var health_bars_interface = $"UI/health bits"
@onready var questlog = $UI/questlog
@onready var questlog_containers = $UI/questlog/TextureRect/MarginContainer/ScrollContainer/VBoxContainer/MarginContainer/PanelContainer/GridContainer
@onready var debug_label = $UI/Label


func _ready():
	var name_array: PackedStringArray
	load_level_data()
	for child in children:
		if not name_array.has(child.name):
			name_array.append(child.name)
			print(name_array)
	for child in children:
		var instance_id = child.get_instance_id()
		for key in leve_data.static_list.keys():
			
			if instance_id == key :
				var values = leve_data.static_list.get(key)
				var object = instance_from_id(instance_id)
				if "name" in object:
					object.name = values.name
				if "state" in object:
					object.state = values.state 
				if "inventory" in object:
					object.inventory.slot_datas = values.inventory
				if "current_weapon_data" in object:
					object.current_weapon_data = values.current_weapon_data
				if "slot_data" in object:
					object.slot_data = values.slot_data
					object.slot_data.item_data = values.item_data
				if "position" in object:
					object.position = values.position
				if "rotation" in object:
					object.rotation = values.rotation
				if "health" in object:
					object.health = values.health
				if "body_spawned" in object:
					object.body_spawned = values.body_spawned
				if "current_choice_tree" in object:
					object.current_choice_tree = values.current_choice_tree
				if "current_dialouge_file" in object:
					object.current_dialouge_file = values.current_dialouge_file
				if "current_dialouge" in object:
					object.current_dialouge = values.current_dialouge
				if "navmesh" in object:
					object.navmesh = values.navmesh
				if "point_index" in object:
					object.point_index = values.point_index
				if "waiting" in object:
					object.waiting = values.waiting
				if "afraid" in object:
					object.afraid = values.afraid
				if "flee_target" in object:
					object.flee_target = values.flee_target
				if "quest_index" in object:
					object.quest_index = values.quest_index
			elif not children.has(instance_from_id(key)):
				var values = leve_data.static_list.get(key)
				var object_scene
				print("instance id checked")
				if "objecct_scene" in values:
					object_scene = load(values.objecct_scene)
				var object = object_scene.instantiate()
				if "name" in object:
					object.name = values.name
				if "state" in object:
					object.state = values.state 
				if "inventory" in object:
					object.inventory.slot_datas = values.inventory
				if "current_weapon_data" in object:
					object.current_weapon_data = values.current_weapon_data
				if "slot_data" in object:
					object.slot_data = values.slot_data
					object.slot_data.item_data = values.item_data
				if "position" in object:
					object.position = values.position
				if "rotation" in object:
					object.rotation = values.rotation
				if "health" in object:
					object.health = values.health
				if "body_spawned" in object:
					object.body_spawned = values.body_spawned
				if "current_choice_tree" in object:
					object.current_choice_tree = values.current_choice_tree
				if "current_dialouge_file" in object:
					object.current_dialouge_file = values.current_dialouge_file
				if "current_dialouge" in object:
					object.current_dialouge = values.current_dialouge
				if "navmesh" in object:
					object.navmesh = values.navmesh
				if "point_index" in object:
					object.point_index = values.point_index
				if "waiting" in object:
					object.waiting = values.waiting
				if "afraid" in object:
					object.afraid = values.afraid
				if "flee_target" in object:
					object.flee_target = values.flee_target
				if "quest_index" in object:
					object.quest_index = values.quest_index
				if not name_array.has(object.name):
					add_child(object)
					children = self.get_children(true)
					for _child in children:
						if not name_array.has(_child.name):
							name_array.append(_child.name)
				else :
					object.queue_free()
	
	@warning_ignore("unused_variable")
	if UI.is_node_ready():
		var choices = choice_container.get_children()
		for child in children:
			if child.is_in_group("DialougeHolder"):
				child.connect("choice_update", option_update)
				child.connect("dialouge_toggle", dialouge_ui_toggle)

	
	update_value("all",4)
	
	## sets the mentioned inventory data
	inventory_interface.set_player_inventory_data(player.inventory)
	inventory_interface.set_helmet_inventory_data(player.equip_helmet_data)
	inventory_interface.set_weapon_inventory_data(player.equip_weapon_data)
	inventory_interface.set_body_inventory_data(player.equip_body_data)
	
	
	## connects the force close to the toggle details function
	inventory_interface.force_close.connect(toggle_player_details)
	
	
	## connects the toggle inventory and hotbar data/visibilty
	player.connect("toggle_inventory", toggle_player_details)
	hot_bar_inventory.set_inventory_data(player.inventory)
	
	##connects the quest_ui_toggle
	player.connect("toggle_quest_log", toggle_quest_log)
	
	
	## checks the save directory exists and loads the data
	create_folder(save_file_path)
	verify_save_directory(save_file_path)
	verify_save_directory(save_file_path)
	load_player_data()
	
	
	## connexts external inventory elements to the interface
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.connect("toggle_inventory", toggle_player_details)

@warning_ignore("unused_parameter")
func _process(delta):
	update_static_list()
	save()
	
	#if Input.is_action_just_pressed("test button"):
		#for child in get_children():
			#if child is DialougeHolder:
				#child.agression_controller(player)
	
	if Input.is_action_just_pressed("toggle_hints"):
		toggle_hints()
	
	var dialouge_holder_object = self.find_child(current_dialouge_holder,true, false)
	for bit in health_bars_interface.get_children():
		@warning_ignore("unused_variable")
		var index = bit.get_index()
		var current_health = playerdata.health % 4
		var bit_1  = range(12, 16)
		var bit_2  = range(8, 12)
		var bit_3  = range(0, 8)
		if bit_1.has(playerdata.health):
			if current_health >= 0:
				update_value(0,current_health)
			else:
				update_value(0,4)
		if bit_2.has(playerdata.health):
			if current_health >= 0:
				update_value(1,current_health)
			else:
				update_value(1,4)
		if bit_3.has(playerdata.health):
			if current_health >= 0:
				update_value(2,current_health)
			else:
				update_value(2,4)
	for child in children:
		if child != null:
			if child.is_in_group("DialougeHolder"):
				if child.active == true:
					current_dialouge_holder = child.name
					dialouge_holder_ui.text = current_dialouge_holder
	if current_dialouge.contains("[QUESTION]"):
		current_dialouge = current_dialouge.replace("[QUESTION]", " ")
		dialouge_option_ui()
	text_box.text = current_dialouge
	print_orphan_nodes()

##updates the variables of static objects
func update_static_list():
	children = self.get_children(true)

	for child in children:
		var _child = child
		if _child != null:
			var instance_id = _child.get_instance_id()
			
			if _child.is_in_group("static"):


				if "inventory" in _child && "current_weapon_data" in _child:
					old_temp_list = {instance_id: null, "inventory": null}
					if old_temp_list.has(instance_id):
						temp_list = {instance_id: {"name": _child.name,
						"objecct_scene": _child.object_scene,
						"state": _child.state,
						"inventory": _child.inventory.slot_datas, 
						"current_weapon_data": _child.current_weapon_data,
						"position": _child.global_transform.origin, 
						"rotation": _child.rotation,
						"health": _child.health, 
						"current_dialouge": null, 
						"current_dialouge_file": null, 
						"current_choice_tree": null , 
						"point_index": null, 
						"afraid": null, 
						"waiting": null, 
						"flee_target": null,
						"quest_index": null}}
						old_temp_list.merge(temp_list, false)

				elif "inventory" in _child:
					old_temp_list = {instance_id: null, "inventory": null}
					if old_temp_list.has(instance_id):
						temp_list = {instance_id: {"name": _child.name,
						"objecct_scene": _child.object_scene,
						"state": _child.state,
						"inventory": _child.inventory.slot_datas, 
						"position": _child.global_transform.origin, 
						"rotation": _child.rotation,
						"health": _child.health,
						"weapon_uses": null, 
						"current_dialouge": null, 
						"current_dialouge_file": null, 
						"current_choice_tree": null , 
						"point_index": null, 
						"afraid": null, 
						"waiting": null, 
						"flee_target": null,
						"quest_index": null}}
						old_temp_list.merge(temp_list, false)
				else :
					old_temp_list = {instance_id: null}
					if old_temp_list.has(instance_id):
						temp_list = {instance_id: {"name": _child.name,
						"objecct_scene": _child.object_scene,
						"state": _child.state, 
						"inventory": null, 
						"slot_data": _child.slot_data,
						"item_data": _child.slot_data.item_data,
						"position": _child.global_transform.origin, 
						"rotation": _child.rotation, 
						"current_dialouge": null, 
						"current_dialouge_file": null, 
						"current_choice_tree": null, 
						"point_index": null, 
						"afraid": null, 
						"waiting": null, 
						"flee_target": null,
						"quest_index": null}}
						old_temp_list.merge(temp_list, false)
				if _child.is_in_group("DialougeHolder"):
					old_temp_list = {instance_id: null, "inventory": null}
					if old_temp_list.has(instance_id):
						temp_list = {instance_id: {"name": _child.name,
						"objecct_scene": _child.object_scene,
						"state": _child.state, 
						"inventory": _child.inventory.slot_datas, 
						"current_weapon_data": _child.current_weapon_data,
						"position": _child.global_transform.origin, 
						"rotation": _child.rotation,
						"health": _child.health,
						"body_spawned": _child.body_spawned, 
						"current_dialouge": _child.current_dialouge, 
						"current_dialouge_file": _child.current_dialouge_file, 
						"current_choice_tree": _child.current_choice_tree, 
						"point_index": _child.point_index, 
						"afraid": _child.afraid, 
						"waiting": _child.waiting, 
						"flee_target": _child.flee_target,
						"quest_index": _child.quest_index}}
						old_temp_list.merge(temp_list, false)
				test_temp_list.merge(temp_list, true)
	leve_data.static_list.merge(test_temp_list, true)
	for child in get_tree().get_nodes_in_group("external_inventory"):
		if child.has_signal("toggle_inventory"):
			if child.get_signal_connection_list("toggle_inventory").size() == 0:
				child.connect("toggle_inventory", toggle_player_details)

##verifies that the save directory exists
func verify_save_directory(path: String):
	DirAccess.make_dir_absolute(path)
	print(path)

func create_folder(path: String):
	var folder = DirAccess.make_dir_recursive_absolute(path)

##gets the playerdata from the save and sets the current playerdata to the saved playerdata
func load_player_data():
	if DirAccess.get_files_at(save_file_path).has(player_file_name):
		playerdata = ResourceLoader.load(save_file_path + player_file_name).duplicate(true)
		if player!= null:
			player._playerdata = playerdata	
	else:
		pass

func load_level_data():
	if DirAccess.get_files_at(save_file_path).has(scene_name):
		leve_data = ResourceLoader.load(save_file_path + scene_name).duplicate(true)
		player.set_player_position(leve_data.player_location)

##overwrites the save playerdata with the current playerdata
func save():
	if can_save:
		if Input.is_action_just_pressed("save"):
			print("saved")
			ResourceSaver.save(playerdata, save_file_path + player_file_name)
			leve_data.player_location = player.global_transform.origin
			ResourceSaver.save(leve_data, save_file_path + scene_name)

##handles the values of health bits
func update_value(index,value):
	for bar in health_bars_interface.get_child_count():
		if index is String:
			if index == "all":
				health_bars_interface.get_child(bar).value = value
		else:
			health_bars_interface.get_child(index).value = value

##toggles the inventory visibilty
func toggle_player_details(external_inventory_owner = null):
	inventory_interface.visible = not inventory_interface.visible
	
	if inventory_interface.visible:
		player.UI_active = true
		hot_bar_inventory.hide()
		health_bars_interface.hide()
		questlog.hide()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else :
		player.UI_active = false
		hot_bar_inventory.show()
		health_bars_interface.show()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if external_inventory_owner and inventory_interface.visible:
		inventory_interface.set_external_inventory_owner(external_inventory_owner)
	else:
		inventory_interface.clear_external_inventory_owner()

func toggle_quest_log():
	if not questlog.visible:
		quest_log_update()
		hot_bar_inventory.visible = false
		inventory_interface.visible = false
		health_bars_interface.visible = false
		player.UI_active = true
		questlog.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		hot_bar_inventory.visible = true
		health_bars_interface.visible = true
		player.UI_active = false
		questlog.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func toggle_hints():
	print("test")
	if UI.control_hints.visible:
		UI.control_hints.visible = false
	else:
		UI.control_hints.visible = true

@export var questlog_subtitle_texts: PackedStringArray = []
func quest_log_update():
	var quest_children = player.quest_container.get_children()
	var _questlog_quests = questlog_containers.get_children()

	for _quest in quest_children:
		var quest_title = _quest.quest_name
		var quest_description = _quest.description
		if quest_children.size() > 0:
			var new_quest_block = quest_block.instantiate()
			new_quest_block.subtitle_label.text = quest_title.replace("_", " ")
			new_quest_block.block_text.text = quest_description
			if not questlog_subtitle_texts.has(new_quest_block.subtitle_label.text):
				questlog_containers.add_child(new_quest_block)
				questlog_subtitle_texts.append(new_quest_block.subtitle_label.text)
			else :
				questlog.add_child(new_quest_block)
				new_quest_block.queue_free()

func dialouge_option_ui():
	var dialouge_holder_object = self.find_child(current_dialouge_holder,true, false)
	dialouge_holder_object.option_update()
	option_update()
	choice_containerx2.visible = true

func no_dialouge_option_ui():
	choice_containerx2.visible = false

func option_update():
	@warning_ignore("unused_variable")
	var choices = choice_container.get_children()
	var dialouge_holder_object = self.find_child(current_dialouge_holder,true, false)
	if choice_array.size()> 0:
		if dialouge_holder_object != null:
			for choice in choice_array:
				var choice_container_children = choice_container.get_children()
				var button_text_array: Array
				for child in choice_container_children:
					button_text_array.append(child.text)
				var new_button = button.instantiate()
				new_button.text = choice
				if not button_text_array.has(new_button.text):
					
					if new_button.text.contains("[QUEST]"):
						new_button.pressed.connect(Callable(update_dialouge_tree.bind(new_button.text)))
						new_button.pressed.connect(Callable(dialouge_holder_object.increment_dialouge.bind(1)))
						new_button.pressed.connect(Callable(dialouge_holder_object.give_quest))
					else:
						new_button.pressed.connect(Callable(update_dialouge_tree.bind(new_button.text)))
						new_button.pressed.connect(Callable(dialouge_holder_object.increment_dialouge.bind(1)))
					choice_container.add_child(new_button)
				else:
					add_child(new_button)
					new_button.queue_free()

func update_dialouge_tree(tree_name: String):
	var dialouge_holder_object = self.find_child(current_dialouge_holder,true, false)
	dialouge_holder_object.answer()
	var File_path = "".join(["res://characters/", current_dialouge_holder, "/dialouges/", tree_name, "/", current_dialouge_holder, "0", ".txt"])
	var file_path_exists = FileAccess.file_exists(File_path)
	if file_path_exists:
		print(File_path)
		dialouge_holder_object.current_choice_tree = tree_name
		dialouge_holder_object.current_dialouge = 0
		dialouge_holder_object.current_dialouge_file = 0
		dialouge_holder_object.end_dialouge()
		dialouge_holder_object.initialise_dialouge()
		dialouge_holder_object.set_dialouge()
	else:
		dialouge_holder_object.current_choice_tree = "default"
		dialouge_holder_object.current_dialouge = 0
		dialouge_holder_object.current_dialouge_file = 0
		dialouge_holder_object.end_dialouge()
		dialouge_holder_object._on_trigger_interact()

func dialouge_ui_toggle():
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	paused = !paused
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
	player.UI_active = !player.UI_active
	dialouge_ui.visible = !dialouge_ui.visible

func on_inventory_interface_drop_slot_data(slot_data):
	var _pick_up = pickup.instantiate()
	_pick_up.slot_data = slot_data
	_pick_up.position = player.get_drop_direction()
	add_child(_pick_up)
