extends CharacterBody3D
class_name Plunger

enum STATE {HELD, THROWN, LANDED}
@export var state: STATE = STATE.THROWN
var spin_speed = 1
var throw_force = 30
var target := Vector3(0, 0, 0)

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var map = get_node("/root/menu/World/map/")

var type = "plunger"

@onready var animation_tree = $AnimationTree
@onready var animation_player = $AnimationPlayer
var impact_param = "parameters/hit/request"
var squish_param = "parameters/Transition/transition_request"
var can_hit = true

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_tree[squish_param] = "reset"
	if get_parent_node_3d().name == "player_weapons":
		state = STATE.HELD


func _physics_process(delta):
	if state == STATE.THROWN:
		if !is_on_floor():
			velocity.y -= gravity * delta
		move_and_collide(velocity * delta)
		rotation_degrees.x = lerp(rotation_degrees.x, global_transform.origin.direction_to(target).x, delta * 10)


func throw():
	if state == STATE.HELD:
		var thingy = self.duplicate()
		map.get_child(0).get_node("weapons").add_child(thingy, true)

		thingy.state = STATE.THROWN
		thingy.can_hit = true
		thingy.get_node("pickup").monitoring = false
		thingy.get_node("CollisionShape3D").disabled = true

		thingy.set_global_transform(global_transform)
		var direction = _get_direction()
		thingy.look_at(thingy.global_position + direction)
		thingy.rotation_degrees.x += 90
		thingy.velocity = direction * throw_force


func _get_direction():
	var viewport := get_viewport()
	var camera := viewport.get_camera_3d()
	var center: Vector2 = viewport.size/2
	var from: Vector3 = camera.project_ray_origin(center)
	target = from + camera.project_ray_normal(center) * 1000
	var query := PhysicsRayQueryParameters3D.create(from, target)
	var collision = get_world_3d().direct_space_state.intersect_ray(query)
	if collision:
		return global_position.direction_to(collision.position)
	else:
		return global_position.direction_to(target)


func squish():
	if state != STATE.HELD:
		animation_tree[squish_param] = "squish"
	animation_tree[impact_param] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE


func _on_area_3d_body_entered(body):
	if state == STATE.HELD or state == STATE.THROWN:
		return
	if state == STATE.LANDED:
		state = STATE.HELD
		body.gain_weapon(type)
		queue_free()


func _on_plunger_cup_body_entered(body):
	if body is Plunger or not can_hit:
		return
	squish()

	$pickup.monitoring = true
	$CollisionShape3D.set_deferred("disabled", false)

	if state == STATE.THROWN:
		state = STATE.LANDED

	if body is Player:
		body.hurt(30)
