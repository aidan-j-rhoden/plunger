extends Node3D

@export var levels = ["res://maps/map_test.tscn", "res://maps/test_map_2.tscn", "res://maps/test_map_3.tscn", "res://maps/test_level_4.tscn"]

func load_level(which: int):
	if multiplayer.is_server():
		if levels.size() > which and which > -1:
			var level = load(levels[which]).instantiate()
			add_child(level)
