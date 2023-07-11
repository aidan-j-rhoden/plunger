extends Node3D

@export var levels = {"1": "res://maps/map_test.tscn", "2": "res://maps/test_map_2.tscn", "3": "res://maps/test_map_3.tscn", "4": "res://maps/test_level_4.tscn"}

func load_level(which: String):
	if which in levels:
		var level = load(levels[which]).instantiate()
		add_child(level)
	else:
		OS.alert("You tried to load a level that didn't exsist!")
		get_tree().quit(1)
