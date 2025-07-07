extends RigidBody3D

var velocity: Vector3
var gravity: float = 9.8
var shot_by: CharacterBody3D
@export var collision_array: Array
@export var damage: float
@onready var ray: RayCast3D = $RayCast3D


func ray_test(delta):
	var offset = Vector3(1.1, 1.1, 1.1)
	var invert = Vector3(-1.1, -1.1, -1.1)
	move(delta)
	var target = ((velocity * offset) * invert) * delta
	ray.target_position = target
	if not ray.is_colliding() && get_contact_count() < 1:
		pass
	else :
		var collision_point = ray.get_collision_point()
		if collision_point != null:
			self.global_transform.origin = collision_point
		visible = false
		effector()


func effector():
	collision_array = get_colliding_bodies()
	
	for index in collision_array:
		if index.is_in_group("actor"):
			index.damage(damage, self)
			if index.has_method("agression_controller"):
				index.agression_controller(shot_by)
				_on_timer_timeout()


func move(delta):
	global_transform.origin += velocity*delta
	velocity -= velocity*delta
	velocity.y -= gravity*delta

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ray_test(delta)


func _on_timer_timeout() -> void:
	visible = false
	print("bullet deleted")
	queue_free()
