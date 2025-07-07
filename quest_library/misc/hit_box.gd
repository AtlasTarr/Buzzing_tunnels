extends Area3D

@export var damage: float


func _on_body_entered(body):
	if body.has_method("Damage"):
		body.Damage(damage)
