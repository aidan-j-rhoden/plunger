extends Node3D

const levels = [preload("res://maps/map_test.tscn"), preload("res://maps/test_map_2.tscn")] # Eventually, multiple levels will be present in this array.

func load_level(which: int):
	if levels.size() > which and which > -1:
		var level = levels[which].instantiate()
		add_child(level)
