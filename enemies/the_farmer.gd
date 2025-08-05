extends Dialouge
var player: CharacterBody3D
@onready var root = self.get_tree().get_first_node_in_group("level")
func _process(delta: float) -> void:
	for child in root.get_children():
		if child.is_in_group("player"):
			if child in $POI_area.get_overlapping_bodies():
				if child != player:
					player = child
	if player != null:
		if player.global_transform.origin.distance_to(self.global_transform.origin) < 5:
			agression_controller(player)
