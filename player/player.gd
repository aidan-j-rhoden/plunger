extends CharacterBody3D
class_name Player

@onready var camera = $Camera3D

const SPEED = 8.5
const JUMP_VELOCITY = 11
const CAMERA_ROT_SPEED = 0.5

var gravity = 30

@onready var plunger = preload("res://weapons/plunger/item_plunger.tscn")
var weapons = 0

const MAX_HEALTH: float = 100
var health: float = MAX_HEALTH

var crouched = false

func _enter_tree():
	$PlayerInput.set_multiplayer_authority(str(name).to_int())


func _ready():
	if str(name).to_int() == multiplayer.get_unique_id():
		camera.current = true
		$HUD.visible = true
		$HUD/Health.value = health
	set_physics_process(multiplayer.is_server())


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

	if $PlayerInput.crouching and is_on_floor() and not crouched:
		crouched = true
		$PlayerInput.crouching = false
		$AnimationPlayer.play("crouch")
	elif $PlayerInput.crouching and crouched:
		crouched = false
		$PlayerInput.crouching = false
		$AnimationPlayer.play_backwards("crouch")

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

	weapons += 1


func hurt(amount):
	health -= amount
	$HUD/Health.value = health
	if health <= 0:
		respawn()


func heal(amount):
	health = clamp(health + amount, 0, MAX_HEALTH)
	$HUD/Health.value = health


func respawn():
	health = MAX_HEALTH
	$HUD/Health.value = health
	global_transform.origin = Vector3(0, 4, 0)
