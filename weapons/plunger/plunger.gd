extends RigidBody3D
class_name Plunger

var type = "plunger"
var picked = false
var chucked = false
var prev_vel = 0.0
var lvel = 0.0

@onready var animation_tree = $AnimationTree
@onready var animation_player = $AnimationPlayer
var impact_param = "parameters/hit/request"
var squish_param = "parameters/Transition/transition_request"

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_tree[squish_param] = "reset"


func _physics_process(_delta):
	if chucked:
		lock_rotation = true
	lvel = linear_velocity.length()


func squish():
	animation_tree[squish_param] = "squish"
	animation_tree[impact_param] = "fire"


func _on_area_3d_body_entered(body):
	if not picked and not chucked:
		picked = true
		body.gain_weapon(type)
		queue_free()


func _on_plunger_cup_body_entered(body):
	if body is Plunger:
		return
	if lvel >= 10:
		squish()
