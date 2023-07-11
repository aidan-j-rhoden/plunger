extends Control

# Just have these ready to save time later
@onready var main_menu = $MainMenu
@onready var address = $MainMenu/MarginContainer/VBoxContainer/HBoxContainer/address
@onready var choice_menu = $ChoiceMenu
@onready var username = $MainMenu/MarginContainer/VBoxContainer/HBoxContainer/username

var silly_names = [ # A random name is chosen if you fail to give one. ;)
		"an anonymous jerk", "Sara Cobbler", "Silly Man Sam",
		"ima doofus", "Dan Thee Man", "Billy Bob Joe",
		"Princess Petunia", "a poopy diaper", "Poker Face Pete",
		"Deadeye Dan", "Doughboi", "Rachel",
		"The Grim Reaper of Wheat", "Kahmunrah, who is BACK!\nFROM THE DEAD!", "a democrat"
]

# Network stuff
const PORT = 9999
var upnp
var make_upnp = false
var enet_peer = ENetMultiplayerPeer.new()

var waiting_list = []
var ready_list = []

func _unhandled_input(_event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		if make_upnp: # Make sure to clean up the port mappings for security
			assert(upnp.delete_port_mapping(PORT, "UDP") == 0, "She left without saying goodbye. :(")
			assert(upnp.delete_port_mapping(PORT, "TCP") == 0, "It was already gone.")


func _ready():
	if dedicated_server() or OS.is_debug_build():
		$MainMenu/MarginContainer/VBoxContainer/HBoxContainer2.show()
	main_menu.show()
	choice_menu.hide()

	if dedicated_server(): # If this is a dedicated server build, we want it to host a game automatically
		call_deferred(_on_host_pressed())


func _on_host_pressed():
	main_menu.hide() # Hide the main menu, we no longer need it.

	if make_upnp: # This is a weird way to add port forwarding.  Not all routers support it.
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

	enet_peer.create_server(PORT) # Create enet server
	multiplayer.multiplayer_peer = enet_peer # Set our multiplayer peer to that server
	multiplayer.peer_connected.connect(add_player) # When a peer connects, automatically call add_player()
	multiplayer.peer_disconnected.connect(remove_player) # When a peer disconnects, automatically call remove_player()

#	Globals.which_level = int($MainMenu/MarginContainer/VBoxContainer/HBoxContainer2/level_select.value)

#	if not dedicated_server(): # If this is a dedicated server, then don't create a playr for it.
#		if username.text == "": # That's what you get for not filling out the required fields!
#			var new_name = silly_names[randi() % silly_names.size()]
#			Globals.player_names[multiplayer.get_unique_id()] = new_name # Record in the globals my peer id and my username
#		else:
#			Globals.player_names[multiplayer.get_unique_id()] = username.text # Record in the globals my peer id and my username
#		add_player(multiplayer.get_unique_id()) # Call add player for the server

#	choice_menu.show() # Show the standby and waiting menu.


func _on_connect_pressed(): # When you press the connect button.
	main_menu.hide() # Again, hide main menu.  We no longer need to see it.

	if address.text == "": # For the sake of speedy debugging, an empty IP will be interpeted as localhost.
		enet_peer.create_client("localhost", PORT) # Create the enet client
	else:
		enet_peer.create_client(address.text, PORT)
	multiplayer.multiplayer_peer = enet_peer # Set our multiplayer peer to that client

	choice_menu.show()
#	choice_menu.get_node("MarginContainer/VBoxContainer/Start").disabled = true
#	choice_menu.get_node("MarginContainer/VBoxContainer/players").text = get_text_players(player_list)


@rpc("reliable", "call_local") # The '@rpc' allows this function to be called remotly.
	# This uses the reliable protocal, and is allowed to be called locally, that is, by yourself on yourself.
func give_name(): # The server has ordered us to give our username.
	if multiplayer.is_server(): # You can't rpc_id yourself, so this fixes that.
		heres_my_dope_name(username.text)
	else:
		heres_my_dope_name.rpc_id(1, username.text) # Make an rpc call to a specific peer, 1. (1 is always the server)


@rpc("reliable", "any_peer") # "any_peer" is required here, because @rpc defaults to only allowing a call by the server.
	# We want any client to be able to call this.
func heres_my_dope_name(dope_name: String):
	if dope_name == "":
		var new_name = silly_names[randi() % silly_names.size()]
		Globals.player_names[multiplayer.get_remote_sender_id()] = new_name
	else:
		Globals.player_names[multiplayer.get_remote_sender_id()] = dope_name


#func _on_start_pressed():
#	print("  (pressed start)")
#	pre_start_game(Globals.which_level)
#	for player in player_list: # Iterate over each peer id.
#		print("    telling " + str(player) + " to pre_start...")
#		if player != 1:
#			pre_start_game.rpc_id(player, Globals.which_level)


@rpc("call_local", "reliable")
func pre_start_game(level):
	await get_tree().create_timer(0.1).timeout
	Globals.game_playing = true
	print("    Server told " + str(multiplayer.get_unique_id()) + " to prestart the game!")

	main_menu.hide()
	choice_menu.hide()

	get_tree().paused = true # Pause everything, so all peers start at the same time.
	$World/map.load_level(level)

#	if multiplayer.is_server(): # Only the server
#		$World.add_players(player_list) # Add all connected players to the game level

#	player_ready.rpc_id(1) # Tell server we have loaded the level successfully.


#@rpc("call_local", "any_peer", "reliable")
#func player_ready():
#	if multiplayer.is_server(): # For security reasons
#		print(str(multiplayer.get_remote_sender_id()) + " is ready!")
#		ready_list.append(multiplayer.get_remote_sender_id())
#
#		ready_list.sort()
#		player_list.sort()
#		if ready_list == player_list: # If all the players are ready, tell everyone to start!
#			unpause_and_start.rpc()


@rpc("call_local", "reliable")
func unpause_and_start():
	print("Server told " + str(multiplayer.get_unique_id()) + " to unpause!")
	get_tree().paused = false # Unpause everything


func add_player(peer_id):
	print("Player " + str(peer_id) + " joined!")
	waiting_list.append(peer_id)
	give_name.rpc_id(peer_id)
	await get_tree().create_timer(1).timeout # Let the networking line up the player_names in the Globals.
#	for player in player_list: # Go through everyone
#		update_player_list.rpc_id(player, player_list) # and tell them the new list.


func remove_player(peer_id):
	print("Player " + str(peer_id) + " left!")
	waiting_list.erase(peer_id)
#	for player in player_list:
#		update_player_list.rpc_id(player, player_list)


func dedicated_server(): # A simple helper function to see if this project build is a dedicated server.
	return DisplayServer.get_name() == "headless" or OS.has_feature("dedicated_server")


#@rpc("call_local", "reliable")
#func update_player_list(list = []):
#	player_list = list # Update to the new list given by the server
#	$ChoiceMenu/MarginContainer/VBoxContainer/players.text = get_text_players(player_list) # Set the HUD properly


func get_text_players(list: Array): # Some fancy formatting
	var thingy = ""
	for item in list:
		thingy += Globals.player_names[item] + " (" + str(item) + ")" + "\n"
	return thingy
