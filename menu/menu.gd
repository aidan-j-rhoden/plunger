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
var old_room_list = {} ## Client only

@onready var room_lists = $ChoiceMenu/MarginContainer/VBoxContainer/room_lists
@onready var example_room = $ChoiceMenu/MarginContainer/VBoxContainer/room_lists/example_room

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


func _process(_delta):
	if not multiplayer.is_server() and old_room_list != Globals.rooms:  ## If we update this every delta, it's impossible to click the button
		for child in room_lists.get_children():
			if child.name != "example_room":
				child.queue_free()

		for key in Globals.rooms.keys():
			var new_room_info = example_room.duplicate()
			new_room_info.visible = true
			new_room_info.get_node("level").text = "What level: " + str(Globals.rooms[key]["level"])
			new_room_info.get_node("players").text = "Players playing: " + str(len(Globals.rooms[key]["players"]))
			new_room_info.get_node("Button").pressed.connect(_on_join_room_pressed)
			room_lists.add_child(new_room_info)

		old_room_list = Globals.rooms


func _on_host_pressed(): # Start up the server.  This function is automatically called, except for when we are using a debug build.
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


func _on_connect_pressed(): # When you press the connect button.
	main_menu.hide() # Again, hide main menu.  We no longer need to see it.

	if address.text == "": # For the sake of speedy debugging, an empty IP will be interpeted as localhost.
		enet_peer.create_client("localhost", PORT) # Create the enet client
	else:
		enet_peer.create_client(address.text, PORT)
	multiplayer.multiplayer_peer = enet_peer # Set our multiplayer peer to that client

	choice_menu.show()


func _on_join_room_pressed(which_room):
	print("You pressed join room " + str(which_room))


func _on_create_room_pressed(): ## When the player presses the creat room button
	print("    I told server to make this room!")
	rpc_id(1, "create_level", $ChoiceMenu/MarginContainer/VBoxContainer/rooms/level_select.selected)


@rpc("reliable", "any_peer")
func create_level(which):
	Globals.rooms[which] = {"players": [], "level": which}
	$World.spawn_level(str(which))


@rpc("reliable") # The '@rpc' allows this function to be called remotly.
	# This uses the reliable protocal, and is allowed to be called locally, that is, by yourself on yourself.
func give_name(): # The server has ordered us to give our username.
	heres_my_dope_name.rpc_id(1, username.text) # Make an rpc call to a specific peer, 1. (1 is always the server)


@rpc("reliable", "any_peer") # "any_peer" is required here, because @rpc defaults to only allowing a call by the server.
	# We want any client to be able to call this.
func heres_my_dope_name(dope_name: String):
	if dope_name == "":
		var new_name = silly_names[randi() % silly_names.size()]
		Globals.player_names[multiplayer.get_remote_sender_id()] = new_name
	else:
		Globals.player_names[multiplayer.get_remote_sender_id()] = dope_name


func add_player(peer_id): # Server only
	print("Player " + str(peer_id) + " joined!")
	waiting_list.append(peer_id)
	give_name.rpc_id(peer_id)
	await get_tree().create_timer(1).timeout # Let the networking line up the player_names in the Globals.


func remove_player(peer_id): # Server only
	print("Player " + str(peer_id) + " left!")
	waiting_list.erase(peer_id)


func dedicated_server(): # A simple helper function to see if this project build is a dedicated server.
	return DisplayServer.get_name() == "headless" or OS.has_feature("dedicated_server")


func get_text_players(list: Array): # Some fancy formatting
	var thingy = ""
	for item in list:
		thingy += Globals.player_names[item] + " (" + str(item) + ")" + "\n"
	return thingy
