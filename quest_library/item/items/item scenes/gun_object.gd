extends RigidBody3D
@export var gun_data: Gun_Data
@onready var temp_data: Gun_Data
@export var held_by: CharacterBody3D
@export var current_ammo: int
@onready var collision: CollisionShape3D = $collision
@onready var mesh: MeshInstance3D = $collision/MeshInstance3D
@onready var spawner = $collision/Spawner
@onready var timer = $collision/Timer
@export var ammo_set: bool = false
var cycling: bool = false

func _ready() -> void:
	current_ammo = clamp(current_ammo,0, gun_data.mag_size)
	var veiw_model = gun_data.veiw_model.instantiate()
	mesh.mesh = veiw_model.mesh.mesh
	collision.shape = veiw_model.collision_shape.shape
	collision.scale = veiw_model.collision_shape.scale
	spawner.position= veiw_model.spawner_hint.position
	veiw_model.queue_free()
	temp_data = gun_data.duplicate()

func _process(delta: float) -> void:
	temp_data.current_ammo = current_ammo
	gun_data = temp_data

func shoot(delta):
	if not cycling && current_ammo > 0:
		set_variables(delta)
		print("shot")
		spawner.spawn()
		current_ammo -= 1
		temp_data = gun_data.duplicate()
		temp_data.current_ammo = current_ammo
		gun_data = temp_data
		timer.start()
		cycling = true
		for index in spawner.spawned_objects:
			if index != null:
				index.shot_by = held_by
				index.damage = gun_data.damage

func reload(amount):
	current_ammo += amount
	current_ammo = clamp(current_ammo,0, gun_data.mag_size)

func set_ammo():
	if not ammo_set:
		current_ammo = gun_data.current_ammo
		ammo_set = true
	else:
		pass

func set_variables(delta):
	current_ammo = clamp(current_ammo,0, gun_data.mag_size)
	var wait_time = delta* gun_data.cycle_length
	var spawn_velocity: Vector3 = Vector3.ZERO
	
	spawn_velocity = spawner.global_transform.basis.x * gun_data.muzzle_velocity
	spawner.spawn_velocity = spawn_velocity
	timer.wait_time = wait_time


func _on_timer_timeout():
	cycling = false
