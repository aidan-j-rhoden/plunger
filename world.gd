extends Node

#@onready var main_menu = $CanvasLayer/MainMenu
#@onready var address = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/address

const Player = preload("res://player/player.tscn")

const PORT = 9999


func _ready():
	pass


#func _process(delta):
#	$DirectionalLight3D.rotation_degrees.x += delta * 2


func add_players(players):
	for p_id in players:
		var player = Player.instantiate()
		player.name = str(p_id)
		get_node("players").add_child(player)


func remove_player(peer_id):
	get_node("players/" + str(peer_id)).queue_free()


func dedicated_server():
	return DisplayServer.get_name() == "headless" or OS.has_feature("dedicated_server")
