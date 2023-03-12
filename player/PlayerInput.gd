extends MultiplayerSynchronizer

# Set via RPC to simulate is_action_just_pressed.
@export var jumping := false

# Synchronized property.
@export var direction := Vector2()
@export var x_rot = 0
@export var y_rot = 0

const CAMERA_ROT_SPEED = 0.05

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Only process for the local player
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())


@rpc("call_local")
func jump():
	jumping = true


func _input(event):
	if not is_multiplayer_authority():
		return
	if event is InputEventMouseMotion:
		y_rot = -event.relative.x * get_physics_process_delta_time() * CAMERA_ROT_SPEED
		x_rot = -event.relative.y * get_physics_process_delta_time() * CAMERA_ROT_SPEED
#		$"../".rotate_y(y_rot)
#		$"../Camera3D".rotate_x(x_rot)


func _process(_delta):
	# Get the input direction and handle the movement/deceleration.
	direction = Input.get_vector("left", "right", "forward", "back")
	y_rot = 0.0
	x_rot = 0.0
	if Input.is_action_just_pressed("jump"):
		jump.rpc()
