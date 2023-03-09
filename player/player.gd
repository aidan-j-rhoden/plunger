extends CharacterBody3D

@onready var camera = $Camera3D

const SPEED = 8.5
const JUMP_VELOCITY = 11
const CAMERA_ROT_SPEED = 0.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 30

@onready var plunger = preload("res://weapons/plunger/plunger.tscn")
var weapons = 0

func _enter_tree():
	$PlayerInput.set_multiplayer_authority(str(name).to_int())


func _ready():
	if multiplayer.get_unique_id() == $PlayerInput.get_multiplayer_authority():
		camera.current = true


#func _input(event):
#	if event is InputEventMouseMotion:
#		rotate_y(-event.relative.x * get_physics_process_delta_time() * CAMERA_ROT_SPEED)
#		camera.rotate_x(-event.relative.y * get_physics_process_delta_time() * CAMERA_ROT_SPEED)
#		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -89.9, 89.9)


func _physics_process(delta):
	rotate_y($PlayerInput.y_rot)
	camera.rotate_x($PlayerInput.x_rot)
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -89.9, 89.9)
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if $PlayerInput.jumping and is_on_floor():
		velocity.y = JUMP_VELOCITY
	$PlayerInput.jumping = false

	# Get the input direction and handle the movement/deceleration.
	var direction = (transform.basis * Vector3($PlayerInput.direction.x, 0, $PlayerInput.direction.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func gain_weapon(type):
	if type == "plunger":
		var p = plunger.instantiate()
		$weapon.add_child(p)
		p.rotation_degrees.x = 15 * weapons
		p.picked = true

	weapons += 1
