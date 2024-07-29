extends Node

@export var levels = {"1": "res://maps/map_test.tscn", "2": "res://maps/test_map_2.tscn", "3": "res://maps/test_map_3.tscn", "4": "res://maps/test_level_4.tscn"}

func spawn_level(which: String):
	if multiplayer.is_server():
		if which in levels:
			var level = load(levels[which]).instantiate()
			add_child(level)
		else:
			OS.alert("You tried to load a spawn that didn't exsist!")
			get_tree().quit(1)
