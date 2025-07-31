extends Dialouge

@onready var root = self.get_tree().root
func _process(delta: float) -> void:
	for child in root.get_children():
		if child.is_in_group("Player"):
			if child in $POI_area.get_overlapping_bodies():
				print("test")
