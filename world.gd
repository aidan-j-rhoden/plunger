extends Node

const player_scene = preload("res://player/player.tscn")

#func _ready():
#	multiplayer.peer_disconnected.connect(remove_player)


func add_player(id):
	if multiplayer.is_server():
		var player = player_scene.instantiate()
		player.name = str(id)
		get_node("map/players").add_child(player)


#func remove_player(peer_id):
#	get_node("players/" + str(peer_id)).queue_free()


func dedicated_server():
	return DisplayServer.get_name() == "headless" or OS.has_feature("dedicated_server")
