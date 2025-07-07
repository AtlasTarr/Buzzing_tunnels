extends Node3D
class_name Spawner

@export var scene_spawn: PackedScene
@export var spawn_velocity: Vector3
@export var spawned_objects: Array

func spawn():
	var object = scene_spawn.instantiate()
	if "velocity" in object:
		object.velocity = spawn_velocity
	if "transform" in object:
		object.transform.origin = self.global_transform.origin
	spawned_objects.append(object)
	var root = get_tree().get_first_node_in_group("level")
	root.add_child(object)
