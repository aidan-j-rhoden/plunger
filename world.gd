extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/address

const Player = preload("res://player/player.tscn")

const PORT = 9999
var upnp
var make_upnp = false
var enet_peer = ENetMultiplayerPeer.new()

func _unhandled_input(_event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		if make_upnp:
			assert(upnp.delete_port_mapping(PORT, "UDP") == 0, "Curses!  Dat network thingie done bamboozled me!")
			assert(upnp.delete_port_mapping(PORT, "TCP") == 0, "Oh no!")


func _ready():
	if make_upnp:
		upnp = UPNP.new()
		var discover_result = upnp.discover()

		if discover_result == UPNP.UPNP_RESULT_SUCCESS:
			if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
				var map_result_udp = upnp.add_port_mapping(PORT, PORT, "godot_udp", "UDP", 0)
				var map_result_tcp = upnp.add_port_mapping(PORT, PORT, "godot_tcp", "TCP", 0)
				if not map_result_udp == UPNP.UPNP_RESULT_SUCCESS:
					upnp.add_port_mapping(PORT, PORT, "", "UDP")
				if not map_result_tcp == UPNP.UPNP_RESULT_SUCCESS:
					upnp.add_port_mapping(PORT, PORT, "", "TCP")

		var external_ip = upnp.query_external_address()
		print(external_ip)

	if dedicated_server():
		_on_host_pressed()


#func _process(delta):
#	$DirectionalLight3D.rotation_degrees.x += delta * 2


func _on_host_pressed():
	main_menu.hide()

	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)

	if not dedicated_server():
		add_player(multiplayer.get_unique_id())


func _on_join_pressed():
	main_menu.hide()

	if address.text == "":
		enet_peer.create_client("localhost", PORT)
	else:
		enet_peer.create_client(address.text, PORT)
	multiplayer.multiplayer_peer = enet_peer


func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	get_node("players").add_child(player)


func remove_player(peer_id):
	get_node("players/" + str(peer_id)).queue_free()


func dedicated_server():
	return DisplayServer.get_name() == "headless" or OS.has_feature("dedicated_server")
