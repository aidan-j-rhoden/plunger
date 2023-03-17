extends Control

@onready var main_menu = $MainMenu
@onready var address = $MainMenu/MarginContainer/VBoxContainer/address
@onready var ready_menu = $ReadyMenu

const Player = preload("res://player/player.tscn")
const test_level = preload("res://world.tscn")
const levels = [test_level]

const PORT = 9999
var upnp
var make_upnp = false
var enet_peer = ENetMultiplayerPeer.new()

var player_list = []
var ready_list = []
var start_game = false

func _unhandled_input(_event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		if make_upnp:
			assert(upnp.delete_port_mapping(PORT, "UDP") == 0, "Curses!  Dat network thingie done bamboozled me!")
			assert(upnp.delete_port_mapping(PORT, "TCP") == 0, "Oh no!")


func _ready():
	main_menu.show()
	ready_menu.hide()

	if dedicated_server():
		call_deferred(_on_host_pressed())


func _process(_delta):
	if start_game:
		get_tree().paused = false


func _on_host_pressed():
	main_menu.hide()

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
		print(str(external_ip) + ":" + str(PORT))

	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)

	if not dedicated_server():
		add_player(multiplayer.get_unique_id())

	ready_menu.show()


func _on_join_pressed():
	main_menu.hide()

	if address.text == "":
		enet_peer.create_client("localhost", PORT)
	else:
		enet_peer.create_client(address.text, PORT)
	multiplayer.multiplayer_peer = enet_peer

	ready_menu.show()
	ready_menu.get_node("MarginContainer/VBoxContainer/Start").disabled = true


func _on_start_pressed():
	for player in player_list:
		pre_start_game.rpc_id(player, 0)


@rpc("call_local")
func pre_start_game(level):
	var game_level = levels[level].instantiate()
	get_tree().paused = true
	add_child(game_level)
	main_menu.hide()
	ready_menu.hide()
	if not multiplayer.is_server():
		player_ready.rpc_id(1)


@rpc("any_peer")
func player_ready():
	ready_list.append(multiplayer.get_remote_sender_id())

	ready_list.sort()
	player_list.sort()
	if ready_list == player_list:
		start_game = true


func add_player(peer_id):
	print("Player " + str(peer_id) + " joined!")
	player_list.append(peer_id)
	update_player_list()


func remove_player(peer_id):
	print("Player " + str(peer_id) + " joined!")
	player_list.erase(peer_id)
	update_player_list()


func dedicated_server():
	return DisplayServer.get_name() == "headless" or OS.has_feature("dedicated_server")


func update_player_list():
	$ReadyMenu/MarginContainer/VBoxContainer/players.text = to_text_list(player_list)


func to_text_list(list):
	var thingy = ""
	for item in list:
		thingy += str(item) + "\n"
	return thingy
