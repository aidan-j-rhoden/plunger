extends Node3D

const levels = ["res://maps/map_test.tscn", "res://maps/test_map_2.tscn"] # Eventually, multiple levels will be present in this array.

func load_level(which: int):
	if levels.size() > which and which > -1:
		var level = load(levels[which]).instantiate()
		add_child(level)
