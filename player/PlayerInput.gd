extends MultiplayerSynchronizer

# Set via RPC to simulate is_action_just_pressed.
@export var jumping := false
@export var crouching := false
@export var firing := false
#@export var selected_weapon = 0

# Synchronized property.
@export var direction := Vector2()
@export var x_rot:float = 0.0
@export var y_rot:float = 0.0

const CAMERA_ROT_SPEED:float = 0.1

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Only process for the local player
	set_process_input(get_multiplayer_authority() == multiplayer.get_unique_id())
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())


@rpc("call_local")
func jump():
	jumping = true


@rpc("call_local")
func crouch():
	crouching = true


@rpc("call_local")
func fire():
	firing = true


func _input(event):
	if event is InputEventMouseMotion:
		y_rot = float(-event.relative.x) * CAMERA_ROT_SPEED
		x_rot = float(-event.relative.y) * CAMERA_ROT_SPEED


func _process(_delta):
	# Get the input direction and handle the movement/deceleration.
	direction = Input.get_vector("left", "right", "forward", "back")
#	if Input.is_action_just_pressed("next_weapon"):
#		selected_weapon += 1
#		if selected_weapon > 2:
#			selected_weapon = 0
#		$"..".update_weapons_hud()
#	if Input.is_action_just_pressed("prev_weapon"):
#		selected_weapon -= 1
#		if selected_weapon < 0:
#			selected_weapon = 2
#		$"..".update_weapons_hud()
	if Input.is_action_just_pressed("jump"):
		jump.rpc()
	if Input.is_action_just_pressed("crouch"):
		crouch.rpc()
	if Input.is_action_just_pressed("shoot"):
		fire.rpc()
