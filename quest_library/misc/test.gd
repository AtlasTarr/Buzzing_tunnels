extends Node3D


var save_file_path = "user://save/"
var save_file_name = "playersave.tres"

@onready var playerdata = $player.playerdata

func _ready():
	verify_save_directory(save_file_path)
	load_player_data()

func verify_save_directory(path: String):
	DirAccess.make_dir_absolute(path)

func load_player_data():
	if DirAccess.get_files_at(save_file_path).has(save_file_name):
		playerdata = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)
		var player = get_node("player")
		if player!= null:
			$player.playerdata = playerdata
	else:
		pass

func _unhandled_input(event):
	if Input.is_action_just_pressed("save"):
		ResourceSaver.save(playerdata, save_file_path + save_file_name)
		print("test")
