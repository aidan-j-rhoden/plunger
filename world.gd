extends Node

const player_scene = preload("res://player/player.tscn")

#func _ready():
#	multiplayer.peer_disconnected.connect(remove_player)

func spawn_level(which):
	if multiplayer.is_server():
		if which in Globals.levels:
			print(Globals.levels)
			var level = load(Globals.levels[str(which)]).instantiate()
			get_node("maps").add_child(level)
			level.set_owner(get_node("maps"))
			Globals.rooms[str(which)] = {"players": [], "level": str(which), "node_name": level.name}
		else:
			OS.alert("A player tried to load a map that didn't exsist!")
			get_tree().quit(1)


func load_level(which):
	await get_tree().create_timer(0.5).timeout
	if which in Globals.levels:
		var level = load(Globals.levels[str(which)]).instantiate()
		level.name = Globals.rooms[str(which)]["node_name"]
		get_node("maps").add_child(level)
	else:
		OS.alert("You tried to load a map that didn't exsist!")
		get_tree().quit(1)


@rpc("reliable", "any_peer")
func add_player(id, level):
	if multiplayer.is_server():
		print("    added " + str(id))
		var player = player_scene.instantiate()
		player.name = str(id)
		print("THIS ONE:")
		print(Globals.rooms[level]["node_name"])
		# TODO: something is wrong with this:   vvvvvvvvvvvvvvvvvvvv
		var map = $maps.find_child(Globals.rooms[level]["node_name"], false)
		map.get_node("players").add_child(player)
		randomize()
		player.global_transform.origin = get_node("maps").get_child(0).get_node("spawn_points").get_children()[randi() % get_node("maps").get_child(0).get_node("spawn_points").get_children().size()].global_transform.origin
#World/maps/map_test

#func remove_player(peer_id):
#	get_node("players/" + str(peer_id)).queue_free()


func dedicated_server():
	return DisplayServer.get_name() == "headless" or OS.has_feature("dedicated_server")
