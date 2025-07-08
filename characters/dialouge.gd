extends DialougeHolder
var state:int = 0

signal toggle_inventory(external_inventory_owner)
signal toggle_talk_anim


const corpse = preload("res://quest_library/interactables/chest.tscn")
const object_scene = "res://characters/bean/bean.tscn"

@export var Name: String
@export var max_health: float = 100
@export var defence: float = 0
var health: float = max_health
@export var walk_speed: float = 5.0
@export var run_speed: float = 10.0
@onready var speed: float = walk_speed
@export var body_spawned: bool = false

@export var inventory: Inventory_Data
var has_ammo: bool = true
@export var current_weapon_data: Gun_Data
@export var current_body_data: Body_Item_data
@export var current_helmet_data: Helmet_Item_data

@export var can_access_inventory: bool = true

var acceleration = 0.2
var turn_speed = 5.0
@onready var nav_agent = $NavigationAgent3D

@export var patrol_path: Path3D
var patrol_curve: Curve3D
var patrol_points_size: int
@export var point_index:int  = 0
var patrol_point:Vector3 = Vector3()

@onready var flee_ray_container = $Node3D3
@export var flee_target: Vector3
var flee_ray_count
var flee_ray_ends: PackedVector3Array
var old_ray_datas: Dictionary
var ray_datas: Dictionary
var ray_datas_size
@onready var flee_timer = $Timer
@onready var fear_timer = $fear_timer
@export var afraid = false

@export var waiting: = false

@export var dialouges: PackedStringArray
@export var choices: PackedStringArray
@export var continue_on_interact := true
@export var current_choice_tree: String = "default"
@export var current_dialouge_file:int = 0
@export var current_dialouge: int = 0
var answered: bool = false
var file
var dialouge_as_string
@onready var trigger = $trigger
@onready var look_target = $Node3D
@onready var gun_container = $Node3D2
@onready var camera = $Camera3D
@onready var poi_area = $POI_area
var object_of_intrest: Object
var aggressive: bool = false

@export var quest_references: Array
@export var quest_index := 0
var current_quest

@export var move_state = range(4)

var quest_instance

# Called when the node enters the scene tree for the first time.
func _ready():
	move_state = 0
	var dialouges_resource: String  = "res://characters/"
	var real_dialouges_resource := ("".join([dialouges_resource, self.name, "/", "dialouges/", current_choice_tree, "/", self.name, var_to_str(current_dialouge_file), ".txt"]))
	file = FileAccess.open(real_dialouges_resource, FileAccess.READ)
	if file != null:
		var text: String = file.get_as_text()
		for line in text.count("|", 0, 0):
			var current_line: String= file.get_line()
			dialouges.append(current_line.replace("|", ""))
		format_dialouge_array()
		option_update()
		dialouges.append("[END]")
		file.close()
	better_gear_checker()
	death_state_checker(null)

func _on_start_timer_timeout() -> void:
	if current_weapon_data != null:
		weapon_equip(current_weapon_data)

func look_at_point(point: Vector3, delta):
	if global_transform.origin.distance_to(point) > 0:
			look_target.look_at(point, Vector3.UP, true)
			rotation.y = lerp_angle(rotation.y, look_target.rotation.y + rotation.y, delta * turn_speed)
			gun_container.rotation.x = lerp_angle(gun_container.rotation.x, look_target.rotation.x ,delta *turn_speed)

func set_current_quest():
	if quest_index <= quest_references.size()-1:
		current_quest = quest_references[quest_index]._bundled.get("names")[0]

func increment_quest_index():
	if not quest_index == quest_references.size()-1:
		quest_index += 1
		set_current_quest()

func set_patrol_index(point: int):
	if point <= patrol_points_size:
		point_index = point
	else:
		point_index = 0

func set_patrol_point():
	if patrol_path != null:
		patrol_curve = patrol_path.curve
		patrol_points_size = patrol_curve.point_count - 1
		patrol_point = patrol_curve.get_point_position(point_index)

func point_seek(point: Vector3, delta, threshold: float):
	move_state_mover(delta, point, threshold)

func update_flee_rays() -> RayCast3D:
	var self_position := global_transform.origin
	flee_ray_count = flee_ray_container.get_child_count()
	var ray_lenght := 4
	var flee_ray_end: Vector3
	
	
	if flee_ray_count < 12:
		flee_ray_count = flee_ray_container.get_child_count()
		var flee_ray: RayCast3D = RayCast3D.new()
		flee_ray_container.add_child(flee_ray)
		flee_ray_count = flee_ray_container.get_child_count()
		flee_ray.visible = true
		var target_position: Vector3 
		target_position.x = (self_position.x + ray_lenght * cos(flee_ray_count)) - self_position.x
		target_position.z = (self_position.z + ray_lenght * sin(flee_ray_count)) - self_position.z
		target_position.y = 0
		flee_ray.global_transform.origin = self_position
		flee_ray.target_position = target_position
		flee_ray.name = str(flee_ray_count)
		flee_ray_end = target_position
		return flee_ray
	else:
		for ray in flee_ray_count:
			ray = flee_ray_container.get_child(ray)
			ray.queue_free()
		flee_ray_count = flee_ray_container.get_child_count()
		return null

func flee_dict_update(target: Vector3):
	var ray_end := update_flee_rays()
	var ray_name: String
	var ray_distance: float
	var final_distance: = 0.0
	var ray_colliding: bool
	var final_colliding: = false
	var ray_target: Vector3
	var final_target: = Vector3.ZERO
	var old_keys: Array
	var keys: Array
	
	if not ray_end == null:
		ray_name = ray_end.name
		ray_distance = target.distance_to(ray_end.to_global(ray_end.target_position))
		ray_colliding = ray_end.is_colliding()
		ray_target = ray_end.to_global(ray_end.target_position)
	
		if not ray_datas.has(ray_end):
			var temp := {ray_name: {"distance": ray_distance, "colliding": ray_colliding, "target": ray_target}}
			ray_datas.merge(temp, true)
			ray_datas_size = ray_datas.size()

func flee_from_target(delta, target: Vector3):
	var final_distance: = 0.0
	var final_colliding: = false
	var final_target: = Vector3.ZERO
	if not ray_datas_size == null:
		for ray in ray_datas_size:
			var raw_value: Dictionary = ray_datas.get(str(ray + 1))
			
			var distance: float = raw_value.distance
			var colliding: bool = raw_value.colliding
			var raw_target: Vector3 = raw_value.target
			
			if  target.distance_to(self.global_transform.origin) < 21 and not waiting:
				if not colliding == true:
					if distance > final_distance:
						final_distance = distance
						final_colliding = colliding
						final_target = raw_target
				else:
					if colliding == true:
						final_distance = distance
						final_colliding = colliding
						final_target = raw_target
			else :
				waiting = true
		move_state_mover(delta, final_target, 0.1)

func format_dialouge_array():
	var dialouge_array := var_to_str(dialouges)
	dialouge_array = dialouge_array.replace("PackedStringArray", "")
	dialouge_array = dialouge_array.replace("(", "")
	dialouge_array = dialouge_array.replace("(", "")
	dialouge_array = dialouge_array.replace(")", "")
	dialouge_array = dialouge_array.replace(",", "")
	dialouge_array = dialouge_array.replace('"', "")
	dialouge_array = dialouge_array.replace("[END]", "")
	dialouge_as_string = dialouge_array

func wait_in_place(point: Vector3, delta, threshold: float):
	move_state_mover(delta, point, threshold, false)

func agression_controller(object_of_agreesion:Object):
	if gun_container.get_children().size() > 0:
		object_of_intrest = object_of_agreesion
		if object_of_agreesion != null:
			for obj in object_of_agreesion.get_children():
				if obj.name == "look_target":
					object_of_intrest = obj
					move_state = 1
					aggressive = true
					can_access_inventory = false
	else:
		object_of_intrest = object_of_agreesion
		if object_of_agreesion != null:
			for obj in object_of_agreesion.get_children():
				if obj.name == "look_target":
					object_of_intrest = obj
					move_state = 2
					aggressive = false
					can_access_inventory = false

func move_state_setter(delta):
	
	
	if move_state == 0:
		if patrol_path != null:
			set_patrol_point()
			patrol(delta)
		else:
			move_state = 2
	
	if move_state == 1:
		if aggressive:
			for child in gun_container.get_children():
				child.shoot(delta)
		if object_of_intrest != null:
			point_seek(object_of_intrest.global_transform.origin, delta, 5)
		else:
			move_state = 0
			aggressive = false
	
	if move_state == 2:
		wait_in_place(global_transform.origin, delta, 5)
	
	if afraid:
		flee_target = object_of_intrest.global_transform.origin
		flee_from_target(delta,flee_target)
		fear_timer.start()
	
	if current_weapon_data != null:
		if current_weapon_data.current_ammo <= 0:
			if has_ammo:
				refresh_weapon()

func move_state_mover(delta, target: Vector3, move_threshhold: float, look_at_destination: bool = true):
	nav_agent.target_position = target
	var next_nav_point: Vector3 = nav_agent.get_next_path_position()
	if transform.origin.distance_to(nav_agent.target_position) >=move_threshhold :
		velocity.x = ((next_nav_point - transform.origin).normalized() * speed).x
		velocity.z = ((next_nav_point - transform.origin).normalized() * speed).z
		velocity.y -= 9.8 * delta
	else :
		velocity.x = 0
		velocity.z = 0
		velocity.y -= 9.8 * delta
	move_and_slide()
	if look_at_destination == true:
		look_at_point(target, delta)
	else :
		look_at_point(target* Vector3.MODEL_FRONT, delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta):
	if trigger.active == true:
		can_access_inventory = false
	if dialouges.size() > 0:
		if dialouges[current_dialouge].contains("[QUESTION]"):
			answered = true
	format_dialouge_array()

func damage(damage: float, source: Object):
	waiting = false
	var real_damage = damage - defence
	if real_damage > 0:
		@warning_ignore("narrowing_conversion")
		health -= real_damage
	else:
		pass
	if not source == null:
		if "shot_by" in source:
			death_state_checker(source.shot_by)
		else:
			death_state_checker(source)
	var temp_speed = health/100 * speed
	speed = temp_speed

func death_state_checker(damage_source: Object) -> void:
	if health <= 0:
		if damage_source != null:
			if "quest_container" in damage_source:
				for _quest: quest in damage_source.quest_container.get_children():
					if _quest.quest_type == 1:
						for _objective: Objective in _quest.objective_container.get_children():
							if _objective.target_enemy_name == self.Name:
								_objective.increment_counter()
								visible = false
								self.process_mode = Node.PROCESS_MODE_DISABLED
		visible = false
		self.process_mode = Node.PROCESS_MODE_DISABLED
		print("died")
		if not body_spawned:
			var body = corpse.instantiate()
			body.name = "body of %s" % self.name
			body.set_veiw_model($CollisionShape3D, $MeshInstance3D)
			body.inventory = inventory
			body.inventory.slot_datas = self.inventory.slot_datas
			body.global_transform = self.global_transform
			owner.add_child(body)
			body_spawned = true

func  _physics_process(delta):
	speed = clamp(speed,0.0, run_speed)
	move_state_setter(delta)

func patrol(delta):
	if transform.origin.distance_to(nav_agent.target_position) <= 1.1:
		set_patrol_index(point_index +1)
		set_patrol_point()
	move_state_mover(delta, patrol_point, 0.1)

func answer():
	answered = false

func _on_trigger_interact():
	if not aggressive:
		current_dialouge = clamp(current_dialouge, 0, dialouges.size() -1)
		if active != true:
			initialise_dialouge()

		if active == true and dialouges[current_dialouge] != "[END]" and answered == false:
			set_dialouge()
			increment_dialouge(1)
		elif answered == true:
			set_dialouge()
			owner.can_save = false
		elif active == true and dialouges[current_dialouge] == "[END]":
			end_dialouge()
			if continue_on_interact == true:
				increment_dialouge_file(1)

func end_dialouge():
	emit_signal("toggle_talk_anim")
	emit_signal("dialouge_toggle")
	emit_signal("choice_update")
	active = false
	current_dialouge = 0
	owner.can_save = true

func option_update():
	choices.clear()
	var dialouges_resource: String  = "res://characters/"
	var file_dialouges_resource := ("".join([dialouges_resource, self.name, "/dialouges/", current_choice_tree, "/", self.name, var_to_str(current_dialouge_file), ".txt"]))
	file = FileAccess.open(file_dialouges_resource, FileAccess.READ)
	if FileAccess.file_exists(file_dialouges_resource):
		var dialouge_end_character: int
		var text: String = file.get_as_text()
		dialouge_end_character = dialouge_as_string.length()
		file.seek(dialouge_end_character)
		file.get_line()
		for line in text.count("[OPTION]", 0, 0):
			var current_line: String= file.get_line()
			choices.append(current_line.replace("[OPTION]", ""))
	owner.choice_array = choices
	file.close()

func check_quest_status():
	for i in owner.get_children(true):
		if i.is_in_group("player"):
			var quest_container := i.find_child("quest_container")
			var has_quest := false
			var quest_node_names
			if quest_index <= quest_references.size()-1:
				quest_node_names = quest_references[quest_index]._bundled.get("names")
			for e in quest_container.get_children():
				if e.name == quest_node_names[0]:
					has_quest = true
					quest_instance = e
	if quest_instance != null:
		print(quest_instance.quest_name)
		if quest_instance.state == 1:
			continue_on_interact = false
		if quest_instance.state == 2:
			quest_instance.claim()
			increment_dialouge_file(1)
			set_current_quest()
		if quest_instance.state == 3:
			if continue_on_interact == false:
				increment_quest_index()
				$Timer2.start()

func initialise_dialouge():
	print("test")
	emit_signal("toggle_talk_anim")
	check_quest_status()
	dialouges.clear()
	var dialouges_resource: String  = "res://characters/"
	var file_dialouges_resource = ("".join([dialouges_resource, self.name, "/dialouges/", current_choice_tree, "/", self.name, var_to_str(current_dialouge_file), ".txt"]))
	file = FileAccess.open(file_dialouges_resource, FileAccess.READ)
	if FileAccess.file_exists(file_dialouges_resource):
		var dialouge_end_character
		var text = file.get_as_text()
		for line in text.count("|", 0,0):
			var current_line = file.get_line()
			dialouge_end_character = dialouge_as_string.length() + 2
			dialouges.append(current_line.replace("|", ""))
		dialouges.append("[END]")
		active = true
		emit_signal("dialouge_toggle")
		emit_signal("choice_update")
	if file != null:
		file.close()

func increment_dialouge_file(value: int):
	var dialouges_resource: String  = "res://characters/"
	var file_dialouges_resource = ("".join([dialouges_resource, self.name, "/", "dialouges/", current_choice_tree, "/", self.name, var_to_str(current_dialouge_file + 1), ".txt"]))
	if FileAccess.file_exists(file_dialouges_resource):
		file = FileAccess.open(file_dialouges_resource, FileAccess.READ)
		current_dialouge_file += value
		file.close()

func set_dialouge():
	owner.current_dialouge = dialouges[current_dialouge]

func increment_dialouge(value: int):
	current_dialouge += value
	current_dialouge = clamp(current_dialouge, 0, dialouges.size() -1)

func give_quest():
	continue_on_interact = false
	set_current_quest()
	active = true
	var overlap = trigger.get_overlapping_bodies()
	
	if active == true:
		for i in overlap:
			if i.is_in_group("player"):
				var quest_container = i.find_child("quest_container")
				var has_quest = false
				var quest_node = quest_references[quest_index]
				var quest_node_names = quest_references[quest_index]._bundled.get("names")
				var root = get_parent()
					
				for e in quest_container.get_children():
					if e.name == quest_node_names[0]:
						has_quest = true
						quest_instance = e
				
				if  quest_node != null:
					if has_quest == false:
						var temp_quest_node = quest_node.instantiate()
						quest_container.add_child(temp_quest_node)
						temp_quest_node.activate()
						quest_instance = temp_quest_node
				else:
					quest_instance = root.get_node("player/quest_container/%s" % quest_node_names[0])

func inventory_interact():
	if trigger.active != true:
		print("interacted")
		toggle_inventory.emit(self)

func _on_timer_timeout():
	death_state_checker(null)
	var times := 0
	while times <13:
		flee_dict_update(flee_target)
		times += 1
	times = 0

func _on_fear_timer_timeout():
	afraid = false

func _on_timer_2_timeout():
	continue_on_interact = true
	print("reset")

func _on_quest_checker_timeout():
	check_quest_status()
	if max_health/health * 100 < 50:
		afraid = true
#____________________________________________Inventory Managment_____________________________________#

func update_weapon_stats():
	for child in gun_container.get_children():
		if not current_weapon_data == null:
			if child.ammo_set == false:
				child.gun_data = current_weapon_data
		if not child == null:
			current_weapon_data = child.gun_data
			child.set_ammo()

func weapon_equip(weapon_data: Gun_Data):
	print("weapon equip")
	const GUN_SCENE = preload("res://quest_library/item/items/item scenes/gun_object.tscn")
	var gun_object = GUN_SCENE.instantiate()
	gun_object.gun_data = weapon_data
	gun_object.held_by = self
	gun_container.add_child(gun_object)
	gun_object.rotation_degrees.y = 180
	update_weapon_stats()

func helmet_equip(helmet_data: Helmet_Item_data):
	current_helmet_data = helmet_data

func body_equip(body_data: Body_Item_data):
	current_body_data = body_data

func helmet_unequip():
	current_helmet_data = null

func body_unequip():
	current_body_data = null

func weapon_unequip(weapon_data: Gun_Data):
	for child in gun_container.get_children():
		if "gun_data" in child:
			if child.gun_data.name == weapon_data.name:
				child.queue_free()

func check_slot_datas():
	for slot in inventory.slot_datas.size():
		var slot_data = inventory.slot_datas[slot]
		if slot_data.quantity == 0:
			inventory.use_slot_data(slot)

func refresh_weapon():
	print("test1")
	var missing_ammo: int = 0
	var reload_amount: int = 0
	var gun: Object
	for child in gun_container.get_children():
		if "gun_data" in child:
			gun = child
			missing_ammo = gun.gun_data.mag_size - gun.current_ammo
	for slot in inventory.slot_datas.size():
		var slot_data = inventory.slot_datas[slot]
		if slot_data != null:
			if slot_data.item_data != null:
				var slot_item = slot_data.item_data
				if slot_item is Ammo_Item_Data:
					has_ammo = true
					if slot_item.calliber == gun.gun_data.calliber:
						for amount in slot_data.quantity:
							if slot_data.quantity != 0 && reload_amount < missing_ammo:
								reload_amount +=1
								inventory.use_slot_data(slot)
						gun.reload(reload_amount)
					update_weapon_stats()
					return
		has_ammo = false
		return

func _on_inventory_updater_timeout() -> void:
	inventory.force_update()
	update_weapon_stats()
	better_gear_checker()

func better_gear_checker():
	for slot in inventory.slot_datas:
		if slot != null:
			var item_data = slot.item_data
			if item_data is Helmet_Item_data:
				if not current_helmet_data == null:
					if item_data.defence > current_helmet_data.defence:
						helmet_unequip()
						helmet_equip(item_data)
				else :
					helmet_unequip()
					helmet_equip(item_data)
	for slot in inventory.slot_datas:
		if slot != null:
			var item_data = slot.item_data
			if item_data is Body_Item_data:
				if not current_body_data == null:
					if item_data.defence > current_body_data.defence:
						body_unequip()
						body_equip(item_data)
				else :
					body_unequip()
					body_equip(item_data)
	for slot in inventory.slot_datas:
		if slot != null:
			var item_data = slot.item_data
			if item_data is Gun_Data:
				if not current_weapon_data == null:
					if item_data.damage > current_weapon_data.damage:
						weapon_unequip(current_weapon_data)
						weapon_equip(item_data)
				else :
					weapon_unequip(current_weapon_data)
					weapon_equip(item_data)
