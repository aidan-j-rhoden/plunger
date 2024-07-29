extends StaticBody3D

const HEAL_FACTOR = 3
var user

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if user:
		user.heal(delta * HEAL_FACTOR)

# This area is set to the layer the player is on,
# so we don't need to check if the body is a player
func _on_area_3d_body_entered(body):
	user = body


func _on_area_3d_body_exited(body):
	if body == user:
		user = null
