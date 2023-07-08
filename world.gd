extends Node

#@onready var main_menu = $CanvasLayer/MainMenu
#@onready var address = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/address

const player_scene = preload("res://player/player.tscn")

#func _ready():
#	connect(multiplayer.peer_connected, remove_player())


#func _process(delta):
#	$DirectionalLight3D.rotation_degrees.x += delta * 2


func add_players(players):
	for ID in players:
		var player = player_scene.instantiate()
		player.name = str(ID)
		get_node("players").add_child(player)


func remove_player(peer_id):
	get_node("players/" + str(peer_id)).queue_free()


func dedicated_server():
	return DisplayServer.get_name() == "headless" or OS.has_feature("dedicated_server")
