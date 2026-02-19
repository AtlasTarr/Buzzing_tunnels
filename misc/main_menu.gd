extends Control
var save_file_path = "user://saves/"
var player_file_name = "playersave.tres"
var playerdata
var current_level: String = "Home_tunnel"

func _ready():
	if DirAccess.get_files_at(save_file_path).has(player_file_name):
		playerdata = ResourceLoader.load(save_file_path + player_file_name).duplicate(true)
		if "current_level" in playerdata:
			current_level = playerdata.current_level
	else:
		pass


func _on_button_pressed() -> void:
	var level_string: String
	level_string = level_string.join(["res://levels/",current_level,".tscn"])
	get_tree().change_scene_to_file(level_string)


func _on_button_2_pressed() -> void:
	get_tree().quit()
