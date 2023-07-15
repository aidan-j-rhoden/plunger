extends Button

func _on_pressed():
	if not multiplayer.is_server():
		print("Party!  This worked, by jove.")
		get_node("/root/menu/World/").rpc_id(1, "add_player", multiplayer.get_unique_id())
#		rpc_id(1, "add_player", multiplayer.get_unique_id())
