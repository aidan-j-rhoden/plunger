extends CharacterBody3D
class_name Player

@onready var input = $PlayerInput
@onready var camera = $Camera3D

const SPEED = 8.5
const JUMP_VELOCITY = 11

var gravity = 30

## An inventory of all me weapons.  The keys must be in the same order that $HUD/weapons/ is organized, or tons of things will die horrible deaths.
@export var weapons = {"plungers": 0, "hairsprays": 0, "toilet_papers": 0}
#@onready var selected_weapon = $PlayerInput.selected_weapon

#Hud stuff
@onready var plunger_count = $HUD/weapons/plungers/count
@onready var hairspray_count = $HUD/weapons/hairsprays/count
@onready var toilet_papers_count = $HUD/weapons/toilet_papers/count

@onready var plunger_box = $HUD/weapons/plungers
@onready var hairsprays_box = $HUD/weapons/hairsprays
@onready var toilet_papers_box = $HUD/weapons/toilet_papers

const MAX_HEALTH: float = 100
@export var health: float = MAX_HEALTH

var crouched = false

func _enter_tree(): # Set the authority of the PlayerInput node to this node's name.
	$PlayerInput.set_multiplayer_authority(str(name).to_int())


func _ready():
	$player_name.text = Globals.player_names[$PlayerInput.get_multiplayer_authority()] # Set the 3d text label
#	update_weapons_hud()

	if str(name).to_int() == multiplayer.get_unique_id(): # If this client is associated with this player, 
		camera.current = true # use this camera,
		$HUD.visible = true # only show this HUD
		$HUD/Health.value = health # and set its health to our health.
	set_physics_process(multiplayer.is_server()) # Only process on the server


func _physics_process(delta):
	rotate_y(input.y_rot * delta)
	camera.rotate_x(input.x_rot * delta)
	input.y_rot = 0.0
	input.x_rot = 0.0
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -89.9, 89.9)
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if input.jumping and is_on_floor():
		velocity.y = JUMP_VELOCITY
	input.jumping = false

	# Handle crouch.  TODO: Doesn't work.
	if input.crouching and not crouched:
		crouched = true
		input.crouching = false
		$AnimationPlayer.play("crouch")
	elif input.crouching and crouched:
		crouched = false
		input.crouching = false
		$AnimationPlayer.play_backwards("crouch")

	# Handle Fire.
	if input.firing:
		input.firing = false
#		var item_list = []
#		for key in weapons.keys():
#			item_list.append(key)
#		if item_list[selected_weapon] == "plungers" and weapons["plungers"] > 0:
#			$player_weapons/plunger.throw()
#			weapons["plungers"] -= 1
#			update_weapons_hud()
#		elif item_list[selected_weapon] == "hairsprays" and weapons["hairsprays"] > 0:
#			$player_weapons/hairspray.fire()
#			update_weapons_hud()

	# Get the input direction and handle the movement/deceleration.
	var direction = (transform.basis * Vector3(input.direction.x, 0, input.direction.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


#func gain_weapon(type):
#	if type == "plunger":
#		weapons["plungers"] += 1
#	elif type == "hairspray":
#		weapons["hairsprays"] += 1
#	update_weapons_hud()


#func update_weapons_hud():
#	plunger_count.text = str(weapons["plungers"])
#	hairspray_count.text = str(weapons["hairsprays"])
#	toilet_papers_count.text = str(weapons["toilet_papers"])
#	var item_list = []
#	for key in weapons.keys():
#		item_list.append(key)
#
#	# Reset everything
#	plunger_box.modulate = Color(0, 0, 0, 255)
#	hairsprays_box.modulate = Color(0, 0, 0, 255)
#	toilet_papers_box.modulate = Color(0, 0, 0, 255)
#	for child in $player_weapons.get_children():
#		child.visible = false
#
#	selected_weapon = $PlayerInput.selected_weapon
#
#	if item_list[selected_weapon] == "plungers":
#		plunger_box.modulate = Color(1, 1, 1, 1)
#		if weapons["plungers"] > 0:
#			$player_weapons/plunger.visible = true
#	elif item_list[selected_weapon] == "hairsprays":
#		hairsprays_box.modulate = Color(1, 1, 1, 1)
#		if weapons["hairsprays"] > 0:
#			$player_weapons/hairspray.visible = true
#	elif item_list[selected_weapon] == "toilet_papers":
#		toilet_papers_box.modulate = Color(1, 1, 1, 1)


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
