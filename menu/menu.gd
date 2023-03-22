extends Control

@onready var main_menu = $MainMenu
@onready var address = $MainMenu/MarginContainer/VBoxContainer/address
@onready var ready_menu = $ReadyMenu

const Player = preload("res://player/player.tscn")
const levels = [preload("res://world.tscn")]

const PORT = 9999
var upnp
var make_upnp = false
var enet_peer = ENetMultiplayerPeer.new()

var player_list = []
var ready_list = []

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
	ready_menu.get_node("MarginContainer/VBoxContainer/players").text = to_text_list(player_list)


func _on_start_pressed():
	print("    (pressed start)")
	for player in player_list:
		print("telling " + str(player) + " to pre_start...")
		pre_start_game.rpc_id(player, 0)


@rpc("call_local", "reliable")
func pre_start_game(level):
	await get_tree().create_timer(1).timeout
	print("Server told " + str(multiplayer.get_unique_id()) + " to prestart the game!")

	main_menu.hide()
	ready_menu.hide()

	get_tree().paused = true
	var game_level = levels[level].instantiate()
	add_child(game_level)

	if multiplayer.is_server():
		game_level.add_players(player_list)

	player_ready.rpc_id(1)


@rpc("call_local", "any_peer", "reliable")
func player_ready():
	if multiplayer.is_server():
		print(str(multiplayer.get_remote_sender_id()) + " is ready!")
		ready_list.append(multiplayer.get_remote_sender_id())

		ready_list.sort()
		player_list.sort()
		if ready_list == player_list:
			unpause_and_start.rpc()


@rpc("call_local", "reliable")
func unpause_and_start():
	print("Server told " + str(multiplayer.get_unique_id()) + " to unpause!")
	get_tree().paused = false


func add_player(peer_id):
	print("Player " + str(peer_id) + " joined!")
	player_list.append(peer_id)
	for player in player_list:
		update_player_list.rpc_id(player, player_list)


func remove_player(peer_id):
	print("Player " + str(peer_id) + " left!")
	player_list.erase(peer_id)
	for player in player_list:
		update_player_list.rpc_id(player, player_list)


func dedicated_server():
	return DisplayServer.get_name() == "headless" or OS.has_feature("dedicated_server")


@rpc("call_local", "reliable")
func update_player_list(list = []):
	if list == []:
		$ReadyMenu/MarginContainer/VBoxContainer/players.text = to_text_list(player_list)
	else:
		player_list = list
		$ReadyMenu/MarginContainer/VBoxContainer/players.text = to_text_list(player_list)


func to_text_list(list):
	var thingy = ""
	for item in list:
		thingy += str(item) + "\n"
	return thingy
