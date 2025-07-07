extends RigidBody3D

const object_scene = "res://quest_library/Pickups/test_item_pickup.tscn"

var state: int = 0

@export var slot_data: Slot_Data 
@export var spawned: bool = false

@onready var sprite_3d = $Sprite3D
@onready var mesh: MeshInstance3D = $CollisionShape3D/MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var area_3d: Area3D = $Area3D
@onready var pickup_area: CollisionShape3D = $Area3D/CollisionShape3D2

func _ready():
	if "veiw_model" in slot_data.item_data:
		var veiw_model = slot_data.item_data.veiw_model.instantiate()
		mesh.mesh = veiw_model.mesh.mesh
		collision_shape.shape = veiw_model.collision_shape.shape
		collision_shape.scale = veiw_model.collision_shape.scale
		pickup_area.shape = veiw_model.collision_shape.shape
		pickup_area.scale = veiw_model.collision_shape.scale
		veiw_model.queue_free()
	elif "texture" in slot_data.item_data:
		var texture = slot_data.item_data.texture
		var real_texture
		if texture is CompressedTexture2D:
			var image = texture.get_image()
			var _texture = ImageTexture.create_from_image(image)
			_texture.set_size_override(Vector2(128, 128))
			sprite_3d.texture = _texture
		else :
			texture.width = 128
			texture.height = 128
			sprite_3d.texture = texture
	$Timer.start()

func _process(delta):
	if state == 1:
		call_deferred("delete")
	sprite_3d.rotate_y(delta)

func delete():
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false
	collision_layer = 32

func _on_timer_timeout() -> void:
	if state == 0:
			for body in area_3d.get_overlapping_bodies():
				body_check(body)

func body_check(body: Node3D) -> void:
	if body.is_in_group("actor"):
		body.inventory.pick_up_slot_data(slot_data)
		state = 1
		self.call_deferred("delete")
		if body.has_method("better_gear_checker"):
			body.better_gear_checker()
