extends CharacterBody3D

signal toggle_inventory()
signal toggle_quest_log()

const objecct_scene = "res://quest_library/player/player_transfer.tscn"

var mouse_sensitivity = 0.002

@export var _playerdata: PlayerData

@onready var camera = $Pivot/Camera
@onready var camera_2 = $Pivot/Camera/SubViewportContainer/SubViewport/Camera

@onready var interact_ray = $Pivot/Camera/interact_ray

@export var UI_active: bool = false

@onready var quest_container = $quest_container
@export var old_quest_value_list: Dictionary
@export var quest_value_list: Dictionary

@export var mass : float = 1

var speed
var air_speed


var start: bool = true

@export var old_helmet_inventory: Equip_Helmet_Data
@export var old_body_inventory: Equip_Body_Data
@export var old_weapon_inventory: Equip_Weapon_Data

@export var inventory: Inventory_Data
@export var equip_helmet_data: Equip_Helmet_Data
@export var equip_body_data: Equip_Body_Data
@export var equip_weapon_data: Equip_Weapon_Data
@export var current_weapon_data: Gun_Data 

@onready var gun_container: Node3D = $Pivot/gun_container
var defence: float

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8 * mass

func _ready():
	PlayerManager.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func set_player_position(set_location: Vector3) -> void:
	global_transform.origin = set_location

func damage(damage: float, source: Object):
	var real_damage = damage - defence
	if real_damage >0:
		@warning_ignore("narrowing_conversion")
		_playerdata.health -= real_damage
	else:
		_playerdata.health -= 1
	death_state_checker(source)

func death_state_checker(damage_source: Object):
	if _playerdata.health <= 0:
		if "shot_by" in damage_source:
			var shot_by = damage_source.shot_by
			if "camera" in shot_by:
				shot_by.camera.current = true
		queue_free()

func heal(heal_amount: int):
	_playerdata.health += heal_amount

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		$Pivot.rotation.x = clamp($Pivot.rotation.x, -1.2, 1.2)
		
	
	if Input.is_action_just_pressed("interact"):
		interact()

func _physics_process(delta):
	
	air_speed = _playerdata.air_speed
	on_start()
	inventory.slot_datas = _playerdata.inventory_data.slot_datas
	camera_2.global_transform = camera.global_transform


	if Input.is_action_just_pressed("crouch"):
		self.scale.y = 0.5
		self.global_transform.origin.y -= 0.5
	if Input.is_action_just_released("crouch"):
		self.scale.y = 1
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
	
	for child in gun_container.get_children():
		if !UI_active:
			if Input.is_action_pressed("shoot"):
				if "gun_data" in child:
					child.shoot(delta)
	
	if Input.is_action_just_pressed("refresh_weapon"):
		refresh_weapon()
	
	if Input.is_action_just_pressed("quest log toggle"):
		toggle_quest_log.emit()

	update_helmet_stats()
	update_body_stats()
	update_weapon_equip()

	# Add the gravity.

	# Handle Jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = _playerdata.jump

	if Input.is_action_pressed("sprint"):
		speed = _playerdata.run_speed
	else:
		speed = _playerdata.base_speed
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	Move(delta)
	_playerdata.rotation = rotation
	_playerdata.camera_rotation = $Pivot.rotation
	_playerdata.inventory_data.slot_datas = inventory.slot_datas
	quest_list_update()

func Move(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = (direction.x * speed)
			velocity.z = (direction.z * speed)
			velocity.normalized()
		else:
			velocity.x = 0
			velocity.z = 0
	else:
		velocity.x -= velocity.x * delta * mass
		velocity.z -= velocity.z * delta * mass
		velocity.y -= gravity * delta
	move_and_slide()

func interact():
	if interact_ray.is_colliding():
		var collider = interact_ray.get_collider()
		if  collider.is_in_group("DialougeHolder"):
			if collider.can_access_inventory == true:
				collider.inventory_interact()
		elif "inventory" in collider:
			collider.inventory_interact()

func get_drop_direction() -> Vector3:
	var direction = -camera.global_transform.basis.z
	return camera.global_position + direction* 2

func on_start():
	if start == true:
		rotation = _playerdata.rotation
		$Pivot.rotation = _playerdata.camera_rotation
		start = false

func _on_timer_timeout():
	inventory.force_update()
	equip_helmet_data.force_update()
	old_helmet_inventory.force_update()
	equip_body_data.force_update()
	old_body_inventory.force_update()
	equip_weapon_data.force_update()
	old_weapon_inventory.force_update()
	quest_list_load()

func quest_list_update():
	for _quest in quest_container.get_children():
		old_quest_value_list =  {_quest.name: null}
		if old_quest_value_list.has(_quest.name):
			quest_value_list = {_quest.name : _quest.state}
			old_quest_value_list.merge(quest_value_list, true)
			_playerdata.quest_value_list.merge(quest_value_list, true)

func quest_list_load():
	for _quest in _playerdata.quest_value_list.keys():
		var filepath
		var new_quest
		if !old_quest_value_list.has(_quest):
			filepath = load("res://quest_library/quest_actual_scenes/%s.tscn" %_quest)
			new_quest = filepath.instantiate()
			new_quest.state = _playerdata.quest_value_list.get(_quest)
			quest_container.add_child(new_quest)

func update_helmet_stats():
	equip_helmet_data.slot_datas = _playerdata.equip_helmet_data.slot_datas
	for index in range(_playerdata.equip_helmet_data.slot_datas.size()):
		if not _playerdata.equip_helmet_data.slot_datas[index] == null:
			var added = _playerdata.equip_helmet_data.slot_datas[index].item_data.get("added")
			if not added:
				_playerdata.equip_helmet_data.slot_datas[index].item_data.added = true
				var item_defence = _playerdata.equip_helmet_data.slot_datas[index].item_data.defence
				defence += item_defence
				for i in old_helmet_inventory.slot_datas.size():
					old_helmet_inventory.slot_datas[i] = _playerdata.equip_helmet_data.slot_datas[i]

	for index in range(old_helmet_inventory.slot_datas.size()):
		if not old_helmet_inventory.slot_datas[index] == null:
			if equip_helmet_data.slot_datas[index] == null:
				var item_defence = old_helmet_inventory.slot_datas[index].item_data.defence
				old_helmet_inventory.slot_datas[index].item_data.added = false
				defence -= item_defence
				for i in _playerdata.equip_helmet_data.slot_datas.size():
					old_helmet_inventory.slot_datas[i] = _playerdata.equip_helmet_data.slot_datas[i]
	_playerdata.equip_helmet_data.slot_datas = equip_helmet_data.slot_datas

func update_weapon_equip():
	equip_weapon_data.slot_datas = _playerdata.equip_weapon_data.slot_datas
	for index in range(_playerdata.equip_weapon_data.slot_datas.size()):
		if not _playerdata.equip_weapon_data.slot_datas[index] == null:
			var added = _playerdata.equip_weapon_data.slot_datas[index].item_data.get("added")
			if not added:
				_playerdata.equip_weapon_data.slot_datas[index].item_data.added = true
				for i in old_weapon_inventory.slot_datas.size():
					weapon_equip(_playerdata.equip_weapon_data.slot_datas[index].item_data)
					old_weapon_inventory.slot_datas[i] = _playerdata.equip_weapon_data.slot_datas[i]
			else:
				for i in old_weapon_inventory.slot_datas.size():
					current_weapon_data = old_weapon_inventory.slot_datas[i].item_data
					old_weapon_inventory.slot_datas[i] = _playerdata.equip_weapon_data.slot_datas[i]

	for index in range(old_weapon_inventory.slot_datas.size()):
		if not old_weapon_inventory.slot_datas[index] == null:
			if equip_weapon_data.slot_datas[index] == null:
				old_weapon_inventory.slot_datas[index].item_data.added = false
				for i in _playerdata.equip_weapon_data.slot_datas.size():
					weapon_unequip(old_weapon_inventory.slot_datas[index].item_data)
					old_weapon_inventory.slot_datas[i] = _playerdata.equip_weapon_data.slot_datas[i]
	update_weapon_stats()
	_playerdata.equip_weapon_data.slot_datas = equip_weapon_data.slot_datas

func update_weapon_stats():
	for child in gun_container.get_children():
		if not _playerdata.current_weapon_data == null:
			if child.ammo_set == false:
				child.gun_data = _playerdata.current_weapon_data
		if not child == null:
			_playerdata.current_weapon_data = child.gun_data
			child.set_ammo()

func weapon_equip(weapon_data: Gun_Data):
	const GUN_SCENE = preload("res://quest_library/item/items/item scenes/gun_object.tscn")
	var gun_object = GUN_SCENE.instantiate()
	gun_object.gun_data = weapon_data
	gun_object.held_by = self
	gun_container.add_child(gun_object)
	update_weapon_stats()

func refresh_weapon():
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
					if gun != null:
						if slot_item.calliber == gun.gun_data.calliber:
							for amount in slot_data.quantity:
								if slot_data.quantity != 0 && reload_amount < missing_ammo:
									reload_amount +=1
									inventory.use_slot_data(slot)
							gun.reload(reload_amount)

func check_slot_datas():
	for slot in inventory.slot_datas.size():
		var slot_data = inventory.slot_datas[slot]
		if slot_data.quantity == 0:
			inventory.use_slot_data(slot)

func weapon_unequip(weapon_data: Gun_Data):
	for child in gun_container.get_children():
		if "gun_data" in child:
			if child.gun_data.name == weapon_data.name:
				child.queue_free()

func update_body_stats():
	equip_body_data.slot_datas = _playerdata.equip_body_data.slot_datas
	for index in range(_playerdata.equip_body_data.slot_datas.size()):
		if not _playerdata.equip_body_data.slot_datas[index] == null:
			var added = _playerdata.equip_body_data.slot_datas[index].item_data.get("added")
			if not added:
				_playerdata.equip_body_data.slot_datas[index].item_data.added = true
				var item_defence = _playerdata.equip_body_data.slot_datas[index].item_data.defence
				defence += item_defence
				for i in old_body_inventory.slot_datas.size():
					old_body_inventory.slot_datas[i] = _playerdata.equip_body_data.slot_datas[i]

	for index in range(old_body_inventory.slot_datas.size()):
		if not old_body_inventory.slot_datas[index] == null:
			if equip_body_data.slot_datas[index] == null:
				var item_defence = old_body_inventory.slot_datas[index].item_data.defence
				old_body_inventory.slot_datas[index].item_data.added = false
				defence -= item_defence
				for i in _playerdata.equip_body_data.slot_datas.size():
					old_body_inventory.slot_datas[i] = _playerdata.equip_body_data.slot_datas[i]
	_playerdata.equip_body_data.slot_datas = equip_body_data.slot_datas
