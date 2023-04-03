extends Node3D

@export var levels = ["res://maps/map_test.tscn", "res://maps/test_map_2.tscn", "res://maps/test_map_3.tscn"]

func load_level(which: int):
	if levels.size() > which and which > -1:
		var level = load(levels[which]).instantiate()
		add_child(level)
