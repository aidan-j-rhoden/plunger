extends Button

func _on_pressed():
	if not multiplayer.is_server():
		print("Party!  This worked, by jove.")
