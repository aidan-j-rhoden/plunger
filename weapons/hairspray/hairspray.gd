extends RigidBody3D

enum STATE {HELD, THROWN, LANDED}
var state: STATE = STATE.HELD

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent_node_3d().name == "player_weapons":
		state = STATE.HELD


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
