extends Node

const player_scene = preload("res://player/player.tscn")

#func _ready():
#	multiplayer.peer_disconnected.connect(remove_player)

func spawn_level(which: String): # We may need different functions for this, but we'll see.
	if multiplayer.is_server():
		if which in Globals.levels:
			var level = load(Globals.levels[which]).instantiate()
			get_node("maps").add_child(level)
		else:
			OS.alert("You tried to load a spawn that didn't exsist!")
			get_tree().quit(1)


func load_level(which: String):
	if not multiplayer.is_server():
		if which in Globals.levels:
			var level = load(Globals.levels[which]).instantiate()
			get_node("maps").add_child(level)
		else:
			OS.alert("You tried to load a spawn that didn't exsist!")
			get_tree().quit(1)


func add_player(id):
	if multiplayer.is_server():
		var player = player_scene.instantiate()
		player.name = str(id)
		get_node("maps").get_child(0).get_node("players").add_child(player)


#func remove_player(peer_id):
#	get_node("players/" + str(peer_id)).queue_free()


func dedicated_server():
	return DisplayServer.get_name() == "headless" or OS.has_feature("dedicated_server")
