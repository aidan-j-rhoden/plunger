extends StaticBody3D

const HEAL_FACTOR = 2
var user

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if user:
		user.heal(delta * HEAL_FACTOR)


func _on_area_3d_body_entered(body):
	user = body


func _on_area_3d_body_exited(body):
	if body == user:
		user = null
