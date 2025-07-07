extends RigidBody3D

signal toggle_inventory(external_inventory_owner)

const object_scene = "res://quest_library/interactables/chest.tscn"
@export var spawned: bool = false

@export var collision: CollisionShape3D
@export var mesh: MeshInstance3D
@export var inventory: Inventory_Data
@export var health: float
var state: int = 0

func set_veiw_model(collison_shape: CollisionShape3D, mesh_shape: MeshInstance3D):
	collision.shape = collison_shape.shape
	mesh.mesh = mesh_shape.mesh
	

func inventory_interact():
	print("chest interact")
	toggle_inventory.emit(self)

func _physics_process(delta):
	if state == 1:
		call_deferred("delete")

func delete():
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false
	collision_layer = 32
