extends CharacterBody3D
class_name Plunger

enum STATE {HELD, THROWN, LANDED}
var state: STATE = STATE.THROWN
var spin_speed = 1
var throw_force = 10

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var type = "plunger"

@onready var animation_tree = $AnimationTree
@onready var animation_player = $AnimationPlayer
var impact_param = "parameters/hit/request"
var squish_param = "parameters/Transition/transition_request"

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_tree[squish_param] = "reset"
	if get_parent_node_3d().name == "player_weapons":
		state = STATE.HELD


func _physics_process(delta):
	if state == STATE.THROWN:
		rotate_object_local(Vector3.UP, deg_to_rad(spin_speed))

		if !is_on_floor():
			velocity.y -= gravity * delta
		move_and_collide(velocity * delta)


func throw():
	if state == STATE.HELD:
#		var instance = item.instantiate()
#		get_node("root/level")
		top_level = true
		var direction = _get_direction()
		transform = transform.looking_at(global_position + direction, Vector3.UP)
		velocity = direction * throw_force
		state = STATE.THROWN


func _get_direction():
	var viewport := get_viewport()
	var camera := viewport.get_camera_3d()
	var center: Vector2 = viewport.size/2
	var from: Vector3 = camera.project_ray_origin(center)
	var to: Vector3 = from + camera.project_ray_normal(center) * 1000
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var collision = get_world_3d().direct_space_state.intersect_ray(query)
	if collision:
		return global_position.direction_to(collision.position)
	else:
		return global_position.direction_to(to)


func squish():
	if state != STATE.HELD:
		animation_tree[squish_param] = "squish"
	animation_tree[impact_param] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE


func _on_area_3d_body_entered(body):
	if state == STATE.HELD:
		return
	if state == STATE.LANDED:
		state = STATE.HELD
		body.gain_weapon(type)
		queue_free()


func _on_plunger_cup_body_entered(body):
	if body is Plunger:
		return
	squish()

	if state == STATE.THROWN:
		state = STATE.LANDED

	if body is Player:
		body.hurt(30)
