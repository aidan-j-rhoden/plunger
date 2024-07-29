extends Button

func _on_pressed():
	if not multiplayer.is_server():
		get_node("/root/menu/").rpc_id(1, "client_join_request", get_parent().name)
#		rpc_id(1, "add_player", multiplayer.get_unique_id())
